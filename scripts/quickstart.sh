#!/usr/bin/env bash
# ==============================================================================
# quickstart.sh — Deploy completo em 1 comando
# Otimizado para: Pluralsight Cloud Playground (Ubuntu 22.04)
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/crishpg/Demo-notion-ia-usando-antropic/main/scripts/quickstart.sh | bash
#
#   — OU, após clonar o repo —
#   bash scripts/quickstart.sh
#
# Notas sobre o Pluralsight Playground:
#   - Usuário cloud_user com sudo sem senha, mas fora do grupo docker
#   - docker-compose standalone (não plugin) já instalado
#   - systemctl pode não funcionar — sem systemd completo
#   - /opt/freelancers-app já existe de sessões anteriores
#   - Sessão temporária — IP muda a cada novo lab
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Cores e helpers
# ------------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${BLUE}══════════════════════════════════════${NC}"
            echo -e "${BLUE}  ▶ $*${NC}"
            echo -e "${BLUE}══════════════════════════════════════${NC}"; }

REPO_URL="https://github.com/crishpg/Demo-notion-ia-usando-antropic.git"
BRANCH="${BRANCH:-main}"

# ------------------------------------------------------------------------------
# Determina se docker precisa de sudo
# No Playground, cloud_user não está no grupo docker na 1ª execução.
# NÃO tentamos reexecutar o script (quebra com curl|bash pois $0 = /dev/stdin).
# Solução: prefixar todos os comandos docker com sudo quando necessário.
# ------------------------------------------------------------------------------
if docker ps &>/dev/null 2>&1; then
  DSUDO=""
else
  DSUDO="sudo"
  info "Docker requer sudo nesta sessão (cloud_user fora do grupo docker)."
fi

# Detectar e fixar o comando do compose
if ${DSUDO} docker compose version &>/dev/null 2>&1; then
  # Plugin nativo: "docker compose"
  if [[ -n "$DSUDO" ]]; then
    COMPOSE="sudo docker compose"
  else
    COMPOSE="docker compose"
  fi
elif command -v docker-compose &>/dev/null; then
  # Binário standalone
  if [[ -n "$DSUDO" ]]; then
    COMPOSE="sudo docker-compose"
  else
    COMPOSE="docker-compose"
  fi
else
  error "Docker Compose não encontrado. Execute: sudo apt-get install -y docker-compose-plugin"
fi

# ------------------------------------------------------------------------------
# Detectar diretório de instalação
# /opt/freelancers-app tem ownership de root após install.sh.
# Garantimos ownership do usuário atual ou usamos ~/app como fallback.
# ------------------------------------------------------------------------------
if sudo chown "$(whoami)" /opt/freelancers-app 2>/dev/null && [[ -w "/opt/freelancers-app" ]]; then
  APP_DIR="/opt/freelancers-app"
else
  APP_DIR="${HOME}/app"
  mkdir -p "$APP_DIR"
  warn "Usando diretório alternativo: ${APP_DIR}"
fi
export APP_DIR

# ==============================================================================
# PASSO 1 — Verificar Docker
# ==============================================================================
step "Verificando Docker"

command -v docker &>/dev/null || error "Docker não encontrado. Execute: sudo apt-get install -y docker.io"

success "Docker:          $(docker --version)"
success "Docker Compose:  $($COMPOSE version)"

# ==============================================================================
# PASSO 2 — Clonar ou atualizar o repositório
# ==============================================================================
step "Clonando repositório"

# Corrige ownership do diretório quando criado como root (install.sh usa sudo).
# Sem isso o Git recusa operar com "dubious ownership".
if [[ -d "$APP_DIR" ]] && [[ "$(stat -c '%U' "$APP_DIR")" != "$(whoami)" ]]; then
  info "Corrigindo ownership de ${APP_DIR} para $(whoami)..."
  sudo chown -R "$(whoami)":"$(whoami)" "$APP_DIR"
fi

# Registra safe.directory como fallback caso o chown não seja suficiente
git config --global --add safe.directory "$APP_DIR" 2>/dev/null || true

if [[ -d "${APP_DIR}/.git" ]]; then
  info "Repositório já existe. Atualizando..."
  cd "$APP_DIR"
  git fetch origin "$BRANCH" --quiet
  git checkout "$BRANCH" --quiet
  git pull origin "$BRANCH" --quiet
  success "Código atualizado: $(git rev-parse --short HEAD)"
else
  info "Clonando ${REPO_URL}..."
  git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
  cd "$APP_DIR"
  success "Repositório clonado em: ${APP_DIR}"
fi

cd "$APP_DIR"

# ==============================================================================
# PASSO 3 — Criar arquivo .env
# ==============================================================================
step "Configurando variáveis de ambiente"

ENV_FILE="${APP_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  info "Criando .env com valores padrão..."
  cat > "$ENV_FILE" <<'EOF'
POSTGRES_USER=freelancer
POSTGRES_PASSWORD=freelancer123
POSTGRES_DB=sistema_freelancers
POSTGRES_PORT=5432
DATABASE_URL=postgresql://freelancer:freelancer123@postgres:5432/sistema_freelancers
NODE_ENV=production
APP_PORT=3000
NOTION_TOKEN=
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050
EOF
  chmod 600 "$ENV_FILE"
  success ".env criado em: ${ENV_FILE}"
else
  success ".env já existe: ${ENV_FILE}"
fi

set -o allexport; source "$ENV_FILE"; set +o allexport

# ==============================================================================
# PASSO 4 — Build + containers
# ==============================================================================
step "Build + Deploy dos containers"

# Para containers anteriores sem apagar volumes
$COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" \
  down --remove-orphans 2>/dev/null || true

info "Construindo imagem Docker (pode levar alguns minutos)..."
$COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" \
  build --no-cache app

# Sobe PostgreSQL e aguarda ficar saudável
$COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" up -d postgres

info "Aguardando PostgreSQL ficar saudável..."
MAX_WAIT=60; WAITED=0
until $COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" \
  exec -T postgres pg_isready -U "${POSTGRES_USER:-freelancer}" &>/dev/null; do
  sleep 2; WAITED=$((WAITED + 2))
  [[ $WAITED -ge $MAX_WAIT ]] && error "PostgreSQL não respondeu em ${MAX_WAIT}s"
done
success "PostgreSQL saudável."

$COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" \
  up -d --remove-orphans app
success "Containers no ar."

# ==============================================================================
# PASSO 5 — Healthcheck
# ==============================================================================
step "Verificando saúde da aplicação"

APP_PORT="${APP_PORT:-3000}"
MAX_WAIT=90; WAITED=0

info "Aguardando aplicação responder na porta ${APP_PORT}..."
until curl -fsS "http://localhost:${APP_PORT}" &>/dev/null; do
  sleep 3; WAITED=$((WAITED + 3))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    warn "Aplicação demorou demais. Exibindo logs:"
    $COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" logs --tail=30 app
    error "Deploy falhou. Veja os logs acima."
  fi
done

PUBLIC_IP=$(curl -fsS --max-time 3 http://checkip.amazonaws.com 2>/dev/null \
  || curl -fsS --max-time 3 http://icanhazip.com 2>/dev/null \
  || echo "localhost")

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Deploy concluído com sucesso!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${YELLOW}http://${PUBLIC_IP}:${APP_PORT}${NC}"
echo ""
echo -e "  Pasta do projeto:  ${APP_DIR}"
echo -e "  Logs:   cd ${APP_DIR} && $COMPOSE logs -f app"
echo -e "  Status: cd ${APP_DIR} && $COMPOSE ps"
echo -e "  Parar:  cd ${APP_DIR} && $COMPOSE down"
echo ""
