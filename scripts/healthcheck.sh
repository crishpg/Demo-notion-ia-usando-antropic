#!/usr/bin/env bash
# ==============================================================================
# healthcheck.sh — Monitoramento contínuo da aplicação
# Sistema Freelancers — Demo Notion IA usando Anthropic
#
# Uso: bash scripts/healthcheck.sh
# Cron: */5 * * * * /bin/bash /opt/freelancers-app/scripts/healthcheck.sh >> /var/log/freelancers-health.log 2>&1
# ==============================================================================

set -euo pipefail

APP_DIR="${APP_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
APP_PORT="${APP_PORT:-3000}"
LOG_FILE="/var/log/freelancers-health.log"
ALERT_EMAIL="${ALERT_EMAIL:-}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Determina o comando correto de compose
if docker compose version &>/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
else
  echo "[$TIMESTAMP] ERROR: Docker Compose não encontrado"
  exit 1
fi

COMPOSE_FILE="${APP_DIR}/docker-compose.yml"
ENV_FILE="/opt/freelancers-app/.env"
[[ -f "$ENV_FILE" ]] || ENV_FILE="${APP_DIR}/.env"

check_service() {
  local service="$1"
  local status

  status=$($COMPOSE_CMD --file "$COMPOSE_FILE" \
    ${ENV_FILE:+--env-file "$ENV_FILE"} \
    ps --format json "$service" 2>/dev/null \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('State','unknown'))" 2>/dev/null \
    || echo "unknown")

  echo "$status"
}

restart_service() {
  local service="$1"
  echo "[$TIMESTAMP] RESTART: Reiniciando serviço $service..."
  $COMPOSE_CMD --file "$COMPOSE_FILE" \
    ${ENV_FILE:+--env-file "$ENV_FILE"} \
    restart "$service" &>/dev/null
}

# ------------------------------------------------------------------
# 1. Verificar se a aplicação responde HTTP
# ------------------------------------------------------------------
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" \
  --max-time 5 "http://localhost:${APP_PORT}/" 2>/dev/null || echo "000")

if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "304" ]]; then
  echo "[$TIMESTAMP] OK:    Aplicação respondendo (HTTP $HTTP_STATUS)"
else
  echo "[$TIMESTAMP] WARN:  Aplicação não respondendo (HTTP $HTTP_STATUS). Tentando reiniciar..."
  restart_service "app"

  # Aguarda 15s e testa novamente
  sleep 15
  HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" \
    --max-time 5 "http://localhost:${APP_PORT}/" 2>/dev/null || echo "000")

  if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "304" ]]; then
    echo "[$TIMESTAMP] OK:    Aplicação recuperada após restart (HTTP $HTTP_STATUS)"
  else
    echo "[$TIMESTAMP] ERROR: Aplicação falhou após restart. Verifique os logs!"
    if [[ -n "$ALERT_EMAIL" ]] && command -v mail &>/dev/null; then
      echo "Aplicação freelancers está DOWN em $(hostname) - $(date)" \
        | mail -s "[ALERTA] Aplicação Freelancers DOWN" "$ALERT_EMAIL"
    fi
  fi
fi

# ------------------------------------------------------------------
# 2. Verificar espaço em disco
# ------------------------------------------------------------------
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [[ "$DISK_USAGE" -gt 85 ]]; then
  echo "[$TIMESTAMP] WARN:  Disco com ${DISK_USAGE}% de uso. Executando limpeza..."
  docker image prune -f --filter "until=48h" &>/dev/null || true
  docker volume prune -f &>/dev/null || true
  echo "[$TIMESTAMP] INFO:  Limpeza Docker executada."
else
  echo "[$TIMESTAMP] OK:    Disco com ${DISK_USAGE}% de uso."
fi

# ------------------------------------------------------------------
# 3. Verificar uso de memória dos containers
# ------------------------------------------------------------------
echo "[$TIMESTAMP] INFO:  Uso de recursos dos containers:"
docker stats --no-stream --format \
  "         {{.Name}}: CPU={{.CPUPerc}} MEM={{.MemUsage}}" \
  2>/dev/null || echo "         (containers não encontrados)"

# ------------------------------------------------------------------
# 4. Rotacionar log se maior que 10MB
# ------------------------------------------------------------------
if [[ -f "$LOG_FILE" ]]; then
  LOG_SIZE=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
  if [[ "$LOG_SIZE" -gt 10485760 ]]; then
    mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d).bak"
    echo "[$TIMESTAMP] INFO:  Log rotacionado."
  fi
fi
