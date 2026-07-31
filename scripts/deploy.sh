#!/usr/bin/env bash
# ==============================================================================
# deploy.sh — Deploy automatizado da aplicação no Ubuntu 22.04
# Sistema Freelancers — Demo Notion IA usando Anthropic
#
# Uso: bash scripts/deploy.sh [--branch main] [--env /caminho/.env]
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Cores e helpers
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }
step()    { echo -e "\n${BLUE}▶ $*${NC}"; }

# ------------------------------------------------------------------------------
# Parâmetros com valores padrão
# ------------------------------------------------------------------------------
BRANCH="${BRANCH:-main}"
APP_DIR="${APP_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
ENV_FILE="${ENV_FILE:-/opt/freelancers-app/.env}"
COMPOSE_FILE="${APP_DIR}/docker-compose.yml"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Parse de argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2 ;;
    --env)    ENV_FILE="$2"; shift 2 ;;
    --dir)    APP_DIR="$2"; shift 2 ;;
    *) warn "Argumento desconhecido: $1"; shift ;;
  esac
done

# ------------------------------------------------------------------------------
# Verificações pré-deploy
# ------------------------------------------------------------------------------
step "Verificando pré-requisitos..."

command -v docker &>/dev/null || error "Docker não encontrado. Execute: sudo bash scripts/install.sh"

[[ -f "$COMPOSE_FILE" ]] || error "docker-compose.yml não encontrado em: $APP_DIR"

# Determina o comando correto de compose:
# Prioridade: plugin nativo "docker compose" > binário standalone "docker-compose"
if docker compose version &>/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
else
  error "Docker Compose não encontrado. Execute: sudo bash scripts/install.sh"
fi

success "Docker:          $(docker --version)"
success "Docker Compose:  $($COMPOSE_CMD version)"

# ------------------------------------------------------------------------------
# 1. Carregar variáveis de ambiente
# ------------------------------------------------------------------------------
step "Carregando variáveis de ambiente..."

# Procura .env na raiz do projeto se o arquivo global não existir
if [[ ! -f "$ENV_FILE" ]]; then
  LOCAL_ENV="${APP_DIR}/.env"
  if [[ -f "$LOCAL_ENV" ]]; then
    ENV_FILE="$LOCAL_ENV"
    warn "Usando .env local: $ENV_FILE"
  else
    warn "Arquivo .env não encontrado. Usando valores padrão do docker-compose.yml"
  fi
fi

if [[ -f "$ENV_FILE" ]]; then
  # Exporta as variáveis sem expor segredos no log
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
  success "Variáveis de ambiente carregadas de: $ENV_FILE"
fi

# ------------------------------------------------------------------------------
# 2. Atualizar código-fonte via git
# ------------------------------------------------------------------------------
step "Atualizando código-fonte..."

cd "$APP_DIR"

if git rev-parse --git-dir &>/dev/null; then
  CURRENT_COMMIT=$(git rev-parse --short HEAD)
  info "Branch atual: $(git branch --show-current)"
  info "Commit atual: $CURRENT_COMMIT"

  git fetch origin "$BRANCH" --quiet
  git checkout "$BRANCH" --quiet
  git pull origin "$BRANCH" --quiet

  NEW_COMMIT=$(git rev-parse --short HEAD)
  if [[ "$CURRENT_COMMIT" == "$NEW_COMMIT" ]]; then
    info "Nenhuma atualização disponível (HEAD: $NEW_COMMIT)"
  else
    success "Código atualizado: $CURRENT_COMMIT → $NEW_COMMIT"
  fi
else
  warn "Não é um repositório git. Pulando etapa de atualização."
fi

# ------------------------------------------------------------------------------
# 3. Criar backup dos volumes antes do deploy
# ------------------------------------------------------------------------------
step "Criando backup dos volumes..."

BACKUP_DIR="${APP_DIR}/backups/${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

if docker volume ls --quiet | grep -q "freelancers_postgres_data"; then
  info "Realizando backup do volume postgres..."
  docker run --rm \
    -v freelancers_postgres_data:/data \
    -v "${BACKUP_DIR}:/backup" \
    alpine \
    tar czf "/backup/postgres_data_${TIMESTAMP}.tar.gz" -C /data . \
    && success "Backup criado em: ${BACKUP_DIR}/postgres_data_${TIMESTAMP}.tar.gz" \
    || warn "Backup falhou. Continuando deploy..."
else
  info "Volume postgres ainda não existe. Backup ignorado."
fi

# ------------------------------------------------------------------------------
# 4. Construir as imagens Docker
# ------------------------------------------------------------------------------
step "Construindo imagens Docker..."

$COMPOSE_CMD --file "$COMPOSE_FILE" \
  ${ENV_FILE:+--env-file "$ENV_FILE"} \
  build --no-cache app
success "Imagem da aplicação construída."

# ------------------------------------------------------------------------------
# 5. Subir os containers (zero-downtime com recriação gradual)
# ------------------------------------------------------------------------------
step "Iniciando containers..."

# Sobe banco de dados primeiro e aguarda healthcheck
$COMPOSE_CMD --file "$COMPOSE_FILE" \
  ${ENV_FILE:+--env-file "$ENV_FILE"} \
  up -d postgres

info "Aguardando PostgreSQL ficar saudável..."
MAX_WAIT=60
WAITED=0
until $COMPOSE_CMD --file "$COMPOSE_FILE" \
  ${ENV_FILE:+--env-file "$ENV_FILE"} \
  exec -T postgres pg_isready -U "${POSTGRES_USER:-freelancer}" &>/dev/null; do
  sleep 2
  WAITED=$((WAITED + 2))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    error "PostgreSQL não respondeu em ${MAX_WAIT}s. Verifique os logs: $COMPOSE_CMD logs postgres"
  fi
done
success "PostgreSQL está saudável."

# Sobe a aplicação
$COMPOSE_CMD --file "$COMPOSE_FILE" \
  ${ENV_FILE:+--env-file "$ENV_FILE"} \
  up -d --remove-orphans app
success "Containers iniciados."

# ------------------------------------------------------------------------------
# 6. Verificar saúde da aplicação
# ------------------------------------------------------------------------------
step "Verificando saúde da aplicação..."

APP_PORT="${APP_PORT:-3000}"
MAX_WAIT=90
WAITED=0

info "Aguardando aplicação responder na porta ${APP_PORT}..."
until curl -fsS "http://localhost:${APP_PORT}" &>/dev/null; do
  sleep 3
  WAITED=$((WAITED + 3))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    warn "Aplicação não respondeu em ${MAX_WAIT}s."
    info "Logs da aplicação:"
    $COMPOSE_CMD --file "$COMPOSE_FILE" \
      ${ENV_FILE:+--env-file "$ENV_FILE"} \
      logs --tail=50 app
    error "Deploy falhou. Veja os logs acima."
  fi
done
success "Aplicação respondendo em http://localhost:${APP_PORT}"

# ------------------------------------------------------------------------------
# 7. Limpeza de imagens antigas
# ------------------------------------------------------------------------------
step "Limpando imagens Docker antigas..."
docker image prune -f --filter "until=24h" &>/dev/null || true
success "Limpeza concluída."

# ------------------------------------------------------------------------------
# Resumo do deploy
# ------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  Deploy concluído com sucesso!  $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "  Aplicação:       http://localhost:${APP_PORT:-3000}"
echo -e "  PostgreSQL:      localhost:${POSTGRES_PORT:-5432}"
echo -e "  Commit:          $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo -e "  Backup:          ${BACKUP_DIR}"
echo ""
echo -e "  Comandos úteis:"
echo -e "    Logs app:      ${COMPOSE_CMD} logs -f app"
echo -e "    Logs db:       ${COMPOSE_CMD} logs -f postgres"
echo -e "    Status:        ${COMPOSE_CMD} ps"
echo -e "    Parar tudo:    ${COMPOSE_CMD} down"
echo ""
