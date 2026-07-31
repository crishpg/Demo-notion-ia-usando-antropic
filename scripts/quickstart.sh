#!/usr/bin/env bash
# ==============================================================================
# quickstart.sh — Deploy completo em 1 comando
# Otimizado para: Pluralsight Cloud Playground (Ubuntu 22.04)
#
# Uso CORRETO (sem sudo — o script escala internamente só o docker):
#   curl -fsSL "https://raw.githubusercontent.com/crishpg/Demo-notion-ia-usando-antropic/main/scripts/quickstart.sh?$(date +%s)" | bash
#
#   — OU, após clonar o repo —
#   bash scripts/quickstart.sh
#
# NÃO execute com sudo:  sudo bash ...  ou  sudo curl ... | bash
# O script usa sudo apenas nos comandos docker quando necessário.
# ==============================================================================

set -euo pipefail

# Trap global para imprimir linha exata de qualquer erro
trap 'echo -e "\n\033[0;31m[ERRO na linha $LINENO]\033[0m Comando falhou: $BASH_COMMAND" >&2' ERR

# ──────────────────────────────────────────────────────────────────────────────
# GUARDA-CHUVA: se executado como root (sudo curl|bash ou sudo bash),
# baixa o script para um arquivo temporário e reexecuta como usuário real.
#
# Problema: curl|bash faz o bash ler de stdin — $0 vira "/dev/stdin" e não
# pode ser copiado/reexecutado. A solução é baixar novamente via curl.
# ──────────────────────────────────────────────────────────────────────────────
_SCRIPT_URL="https://raw.githubusercontent.com/crishpg/Demo-notion-ia-usando-antropic/main/scripts/quickstart.sh"

if [[ "$EUID" -eq 0 ]]; then
  REAL_USER="${SUDO_USER:-}"
  if [[ -z "$REAL_USER" ]]; then
    REAL_USER=$(getent passwd | awk -F: '$3>=1000 && $7!~/nologin|false/{print $1; exit}')
  fi

  if [[ -n "$REAL_USER" ]]; then
    TMPSCRIPT=$(mktemp /tmp/quickstart-XXXXXX.sh)
    # Usa o arquivo em disco se disponível; caso contrário baixa do GitHub
    if [[ -f "$0" && "$0" != "/dev/stdin" && "$0" != "bash" ]]; then
      cp "$0" "$TMPSCRIPT"
    else
      echo "[WARN]  Baixando script para arquivo temporário..."
      curl -fsSL "${_SCRIPT_URL}?t=$(date +%s)" -o "$TMPSCRIPT" || \
        { echo "[ERROR] Falha ao baixar o script. Verifique a conexão."; exit 1; }
    fi
    chmod +x "$TMPSCRIPT"
    chown "$REAL_USER" "$TMPSCRIPT"
    echo "[WARN]  Executado como root. Reexecutando como '${REAL_USER}'..."
    exec sudo -u "$REAL_USER" bash "$TMPSCRIPT" "$@"
  fi
  echo "[WARN]  Continuando como root (usuário real não identificado)."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Cores e helpers
# ──────────────────────────────────────────────────────────────────────────────
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
CURRENT_USER="$(whoami)"

info "Executando como usuário: ${CURRENT_USER}"

# ──────────────────────────────────────────────────────────────────────────────
# Determina prefixo sudo para comandos docker
# cloud_user não está no grupo docker na 1ª execução — usa sudo só para docker.
# ──────────────────────────────────────────────────────────────────────────────
if docker ps &>/dev/null 2>&1; then
  DSUDO=""
else
  DSUDO="sudo"
  info "Docker requer sudo nesta sessão."
fi

# Monta string do compose respeitando DSUDO
if ${DSUDO} docker compose version &>/dev/null 2>&1; then
  COMPOSE="${DSUDO:+sudo }docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE="${DSUDO:+sudo }docker-compose"
else
  error "Docker Compose não encontrado. Execute: sudo apt-get install -y docker-compose-plugin"
fi
COMPOSE="${COMPOSE# }"   # remove espaço inicial se DSUDO vazio

# ──────────────────────────────────────────────────────────────────────────────
# Detectar diretório de instalação
# Corrige ownership para o usuário atual (não root) antes de qualquer operação.
# ──────────────────────────────────────────────────────────────────────────────
if [[ -d "/opt/freelancers-app" ]]; then
  # Sempre corrige ownership para o usuário atual
  sudo chown -R "${CURRENT_USER}:${CURRENT_USER}" /opt/freelancers-app 2>/dev/null || true
  APP_DIR="/opt/freelancers-app"
elif sudo mkdir -p /opt/freelancers-app 2>/dev/null && \
     sudo chown -R "${CURRENT_USER}:${CURRENT_USER}" /opt/freelancers-app 2>/dev/null; then
  APP_DIR="/opt/freelancers-app"
else
  APP_DIR="${HOME}/app"
  mkdir -p "$APP_DIR"
  warn "Sem permissão em /opt — usando ${APP_DIR}"
fi
export APP_DIR

# ══════════════════════════════════════════════════════════════════════════════
# PASSO 1 — Verificar Docker
# ══════════════════════════════════════════════════════════════════════════════
step "Verificando Docker"

command -v docker &>/dev/null || error "Docker não encontrado. Execute: sudo apt-get install -y docker.io"

success "Docker:          $(docker --version)"
success "Docker Compose:  $($COMPOSE version)"

# ══════════════════════════════════════════════════════════════════════════════
# PASSO 2 — Clonar ou atualizar o repositório
# ══════════════════════════════════════════════════════════════════════════════
step "Clonando repositório"

# Garante safe.directory para o usuário atual
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

# ══════════════════════════════════════════════════════════════════════════════
# PASSO 3 — Criar arquivo .env
# ══════════════════════════════════════════════════════════════════════════════
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

# ══════════════════════════════════════════════════════════════════════════════
# PASSO 4 — Build + containers
# ══════════════════════════════════════════════════════════════════════════════
step "Build + Deploy dos containers"

$COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" \
  down --remove-orphans 2>/dev/null || true

info "Construindo imagem Docker (pode levar alguns minutos)..."
$COMPOSE --file docker-compose.yml --env-file "$ENV_FILE" \
  build --no-cache app

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

# ══════════════════════════════════════════════════════════════════════════════
# PASSO 5 — Healthcheck
# ══════════════════════════════════════════════════════════════════════════════
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
