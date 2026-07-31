#!/usr/bin/env bash
# ==============================================================================
# install.sh — Setup completo do servidor Ubuntu 22.04 (Jammy Jellyfish)
# Sistema Freelancers — Demo Notion IA usando Anthropic
#
# Uso: sudo bash scripts/install.sh
#
# Compatível com:
#   - Servidor Ubuntu 22.04 dedicado (VPS, EC2, etc.)
#   - Pluralsight Cloud Playground (cloud_user com sudo sem senha)
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
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ------------------------------------------------------------------------------
# Verificações iniciais
# ------------------------------------------------------------------------------
# No Pluralsight Playground o usuário é cloud_user com sudo sem senha.
# Aceita tanto root quanto sudo.
if [[ "$EUID" -ne 0 ]]; then
  info "Não é root — reexecutando com sudo..."
  exec sudo bash "$0" "$@"
fi

OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
OS_VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')

if [[ "$OS_ID" != "ubuntu" || "$OS_VERSION" != "22.04" ]]; then
  warn "Este script foi testado no Ubuntu 22.04. OS detectado: $OS_ID $OS_VERSION"
fi

info "==== Setup do Servidor Ubuntu 22.04 ===="
info "Iniciando instalação de dependências..."

# ------------------------------------------------------------------------------
# 1. Atualizar sistema
# ------------------------------------------------------------------------------
info "Atualizando pacotes do sistema..."
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq \
  curl \
  wget \
  git \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  apt-transport-https \
  unzip \
  make
success "Pacotes base instalados."

# ------------------------------------------------------------------------------
# 2. Instalar Docker Engine
# ------------------------------------------------------------------------------
if command -v docker &>/dev/null; then
  success "Docker já instalado: $(docker --version)"
else
  info "Instalando Docker Engine..."
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -qq
  apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  systemctl enable docker
  systemctl start docker
  success "Docker instalado: $(docker --version)"
fi

# ------------------------------------------------------------------------------
# 3. Instalar Docker Compose (standalone v2 como fallback)
# ------------------------------------------------------------------------------
if docker compose version &>/dev/null 2>&1; then
  success "Docker Compose (plugin) disponível: $(docker compose version)"
elif command -v docker-compose &>/dev/null; then
  success "Docker Compose já instalado: $(docker-compose --version)"
else
  info "Instalando Docker Compose standalone..."
  COMPOSE_VERSION=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest \
    | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
  curl -fsSL "https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  success "Docker Compose instalado: $(docker-compose --version)"
fi

# ------------------------------------------------------------------------------
# 4. Adicionar usuário atual ao grupo docker (evita sudo nos próximos comandos)
# ------------------------------------------------------------------------------
REAL_USER="${SUDO_USER:-${USER:-cloud_user}}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
  usermod -aG docker "$REAL_USER" 2>/dev/null || true
  success "Usuário '$REAL_USER' adicionado ao grupo docker."
  warn "Faça logout/login (ou 'newgrp docker') para aplicar as permissões."
fi

# ------------------------------------------------------------------------------
# 5. Configurar firewall básico (UFW)
# No Pluralsight Playground o firewall é gerenciado pela plataforma —
# UFW é pulado se o ambiente não suportar (evita travar o SSH do lab).
# ------------------------------------------------------------------------------
IS_PLAYGROUND=false
grep -qi "pluralsight\|playground\|cloud_user\|lab" /etc/hostname 2>/dev/null && IS_PLAYGROUND=true
grep -qi "cloud_user" /etc/passwd 2>/dev/null && IS_PLAYGROUND=true

if [[ "$IS_PLAYGROUND" == "true" ]]; then
  warn "Ambiente Playground detectado — UFW ignorado (firewall gerenciado pela plataforma)."
elif command -v ufw &>/dev/null; then
  info "Configurando UFW..."
  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw allow 3000/tcp  comment 'Next.js App'
  ufw allow 5432/tcp  comment 'PostgreSQL'
  ufw allow 5050/tcp  comment 'PgAdmin (dev)'
  ufw --force enable
  success "UFW configurado."
else
  warn "UFW não encontrado. Instale manualmente: apt-get install ufw"
fi

# ------------------------------------------------------------------------------
# 6. Criar diretório de dados persistentes
# Usa /opt/freelancers-app; fallback para ~/app no Playground
# ------------------------------------------------------------------------------
if mkdir -p /opt/freelancers-app/data 2>/dev/null; then
  APP_DATA_DIR="/opt/freelancers-app"
  # Dar ownership ao usuário real (não root) para scripts sem sudo
  chown -R "${REAL_USER:-root}:${REAL_USER:-root}" /opt/freelancers-app 2>/dev/null || true
else
  APP_DATA_DIR="/home/${REAL_USER:-cloud_user}/app"
  mkdir -p "${APP_DATA_DIR}/data"
  warn "Sem permissão em /opt — usando ${APP_DATA_DIR}"
fi
chmod 755 "${APP_DATA_DIR}"
success "Diretório de dados criado em ${APP_DATA_DIR}."

# ------------------------------------------------------------------------------
# 7. Criar arquivo .env de produção (se não existir)
# ------------------------------------------------------------------------------
ENV_FILE="${APP_DATA_DIR}/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  info "Gerando arquivo .env de produção em ${ENV_FILE}..."
  cat > "$ENV_FILE" <<'EOF'
# ==============================================================================
# Variáveis de Ambiente — Produção
# Edite com: nano /opt/freelancers-app/.env
# ==============================================================================

# Banco de dados
POSTGRES_USER=freelancer
POSTGRES_PASSWORD=freelancer123
POSTGRES_DB=sistema_freelancers
POSTGRES_PORT=5432

# Aplicação
NODE_ENV=production
APP_PORT=3000

# Notion (opcional)
NOTION_TOKEN=

# PgAdmin (apenas com profile dev)
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050
EOF
  chmod 600 "$ENV_FILE"
  success "Arquivo .env criado. Edite as senhas antes de fazer deploy!"
  warn "  nano ${ENV_FILE}"
else
  success "Arquivo .env já existe em ${ENV_FILE}."
fi

# ------------------------------------------------------------------------------
# 8. Instalar Nginx (proxy reverso opcional)
# No Playground a aplicação já fica acessível diretamente na porta 3000,
# portanto o Nginx é instalado mas não bloqueante se systemctl falhar.
# ------------------------------------------------------------------------------
if command -v nginx &>/dev/null; then
  success "Nginx já instalado."
else
  info "Instalando Nginx..."
  apt-get install -y -qq nginx
  # systemctl pode não funcionar em containers/playground — usa service como fallback
  (systemctl enable nginx 2>/dev/null && systemctl start nginx 2>/dev/null) || \
  service nginx start 2>/dev/null || \
  warn "Nginx instalado mas não iniciado (ambiente não suporta serviços em background)."
  command -v nginx &>/dev/null && success "Nginx instalado."
fi

# ------------------------------------------------------------------------------
# Resumo final
# ------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  Setup concluído com sucesso!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "  Docker:          $(docker --version)"
echo -e "  Docker Compose:  $(docker compose version 2>/dev/null || docker-compose --version)"
echo -e "  Nginx:           $(nginx -v 2>&1 || echo 'não disponível')"
echo -e "  Diretório app:   ${APP_DATA_DIR}"
echo ""
echo -e "  Próximos passos:"
echo -e "  ${YELLOW}1. Faça o deploy completo (1 comando):${NC}"
echo -e "     bash scripts/quickstart.sh"
echo -e "  ${YELLOW}— OU —${NC}"
echo -e "  ${YELLOW}2. Edite as variáveis de ambiente e faça deploy manual:${NC}"
echo -e "     nano ${ENV_FILE}"
echo -e "     APP_DIR=${APP_DATA_DIR} bash scripts/deploy.sh"
echo ""
