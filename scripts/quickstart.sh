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
# Características do Pluralsight Playground tratadas aqui:
#   - Usuário cloud_user (sem root direto, mas com sudo sem senha)
#   - Docker + docker-compose standalone já presentes
#   - systemctl pode não existir — serviços via service ou direto
#   - Sem acesso SSH externo — deploy é feito no próprio terminal
#   - /opt pode não ter permissão de escrita — usa ~/app como fallback
#   - Sessão temporária — não persiste reinicialização
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
step()    { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; \
            echo -e "${BLUE}  ▶ $*${NC}"; \
            echo -e "${BLUE}══════════════════════════════════════${NC}"; }

REPO_URL="https://github.com/crishpg/Demo-notion-ia-usando-antropic.git"
BRANCH="${BRANCH:-main}"

# ------------------------------------------------------------------------------
# Detectar diretório de instalação
# Tenta /opt/freelancers-app primeiro; usa ~/app como fallback
# ------------------------------------------------------------------------------
if sudo mkdir -p /opt/freelancers-app 2>/dev/null && \
   sudo chown "$(whoami)" /opt/freelancers-app 2>/dev/null; then
  APP_DIR="/opt/freelancers-app"
else
  APP_DIR="${HOME}/app"
  mkdir -p "$APP_DIR"
  warn "Sem permissão em /opt — usando ${APP_DIR}"
fi
export APP_DIR

# ------------------------------------------------------------------------------
# PASSO 1 — Verificar Docker
# ------------------------------------------------------------------------------
step "Verificando Docker"

command -v docker &>/dev/null || error "Docker não encontrado. Tente: sudo apt-get install -y docker.io"

# Garantir que o usuário atual pode usar docker sem sudo
if ! docker ps &>/dev/null 2>&1; then
  info "Adicionando $(whoami) ao grupo docker..."
  sudo usermod -aG docker "$(whoami)"
  # Reexecutar o script com newgrp para herdar o grupo
  warn "Permissões aplicadas. Reexecutando com novo grupo..."
  exec newgrp docker <<NEWGRP
    bash "$0"
NEWGRP
fi
success "Docker: $(docker --version)"

# Detectar compose
if docker compose version &>/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
else
  info "Instalando docker-compose standalone..."
  COMPOSE_VERSION=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
    | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
  sudo curl -fsSL \
    "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  COMPOSE_CMD="docker-compose"
fi
success "Docker Compose: $($COMPOSE_CMD version)"

# ------------------------------------------------------------------------------
# PASSO 2 — Clonar ou atualizar o repositório
# ------------------------------------------------------------------------------
step "Clonando repositório"

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

# ------------------------------------------------------------------------------
# PASSO 3 — Criar arquivo .env
# ------------------------------------------------------------------------------
step "Configurando variáveis de ambiente"

ENV_FILE="${APP_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  info "Criando .env com valores padrão..."
  cat > "$ENV_FILE" <<'EOF'
# Sistema Freelancers — Pluralsight Playground
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

# Carregar variáveis
set -o allexport; source "$ENV_FILE"; set +o allexport

# ------------------------------------------------------------------------------
# PASSO 4 — Construir imagem e subir containers
# ------------------------------------------------------------------------------
step "Build + Deploy dos containers"

cd "$APP_DIR"

# Parar containers anteriores sem apagar volumes
$COMPOSE_CMD --file docker-compose.yml --env-file "$ENV_FILE" \
  down --remove-orphans 2>/dev/null || true

# Build da imagem Next.js
info "Construindo imagem Docker (pode levar alguns minutos)..."
$COMPOSE_CMD --file docker-compose.yml --env-file "$ENV_FILE" \
  build --no-cache app

# Subir PostgreSQL primeiro
$COMPOSE_CMD --file docker-compose.yml --env-file "$ENV_FILE" \
  up -d postgres

info "Aguardando PostgreSQL ficar saudável..."
MAX_WAIT=60; WAITED=0
until $COMPOSE_CMD --file docker-compose.yml --env-file "$ENV_FILE" \
  exec -T postgres pg_isready -U "${POSTGRES_USER:-freelancer}" &>/dev/null; do
  sleep 2; WAITED=$((WAITED + 2))
  [[ $WAITED -ge $MAX_WAIT ]] && error "PostgreSQL não respondeu em ${MAX_WAIT}s"
done
success "PostgreSQL saudável."

# Subir aplicação
$COMPOSE_CMD --file docker-compose.yml --env-file "$ENV_FILE" \
  up -d --remove-orphans app
success "Containers no ar."

# ------------------------------------------------------------------------------
# PASSO 5 — Verificar saúde
# ------------------------------------------------------------------------------
step "Verificando saúde da aplicação"

APP_PORT="${APP_PORT:-3000}"
MAX_WAIT=90; WAITED=0

info "Aguardando aplicação responder na porta ${APP_PORT}..."
until curl -fsS "http://localhost:${APP_PORT}" &>/dev/null; do
  sleep 3; WAITED=$((WAITED + 3))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    warn "Aplicação demorou demais. Exibindo logs:"
    $COMPOSE_CMD --file docker-compose.yml --env-file "$ENV_FILE" logs --tail=30 app
    error "Deploy falhou. Veja os logs acima."
  fi
done

# Obter IP público do Playground
PUBLIC_IP=$(curl -fsS --max-time 3 http://checkip.amazonaws.com 2>/dev/null \
  || curl -fsS --max-time 3 http://icanhazip.com 2>/dev/null \
  || echo "localhost")

# ------------------------------------------------------------------------------
# Resumo final
# ------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Deploy concluído com sucesso!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Acesse pelo navegador do Playground:"
echo -e "  ${YELLOW}http://${PUBLIC_IP}:${APP_PORT}${NC}"
echo ""
echo -e "  Acesso local:      http://localhost:${APP_PORT}"
echo -e "  IP detectado:      ${PUBLIC_IP}"
echo -e "  Pasta do projeto:  ${APP_DIR}"
echo ""
echo -e "  Comandos úteis:"
echo -e "    Ver logs:    cd ${APP_DIR} && ${COMPOSE_CMD} logs -f app"
echo -e "    Status:      cd ${APP_DIR} && ${COMPOSE_CMD} ps"
echo -e "    Banco psql:  cd ${APP_DIR} && ${COMPOSE_CMD} exec postgres psql -U freelancer -d sistema_freelancers"
echo -e "    Parar:       cd ${APP_DIR} && ${COMPOSE_CMD} down"
echo ""
