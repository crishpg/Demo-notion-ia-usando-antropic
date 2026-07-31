# ==============================================================================
# Makefile — Comandos utilitários do projeto
# Sistema Freelancers — Demo Notion IA usando Anthropic
#
# Uso: make <comando>
# Pré-requisito: Docker e Docker Compose instalados
# ==============================================================================

# Detecta o comando correto de docker compose
COMPOSE := $(shell docker compose version > /dev/null 2>&1 && echo "docker compose" || echo "docker-compose")
ENV_FILE ?= $(wildcard /opt/freelancers-app/.env .env)
COMPOSE_ARGS := --file docker-compose.yml $(if $(ENV_FILE),--env-file $(firstword $(ENV_FILE)),)

.DEFAULT_GOAL := help
.PHONY: help install deploy start stop restart logs status \
        build clean backup restore db-shell app-shell \
        setup-cron healthcheck

# ==============================================================================
# help — Lista todos os comandos disponíveis
# ==============================================================================
help:
	@echo ""
	@echo "  Sistema Freelancers — Comandos Disponíveis"
	@echo "  ============================================"
	@echo ""
	@echo "  Infraestrutura:"
	@echo "    make install        Instala Docker e dependências no servidor Ubuntu 22.04"
	@echo "    make deploy         Executa deploy completo (build + start + healthcheck)"
	@echo "    make setup-cron     Configura healthcheck automático via cron (root)"
	@echo ""
	@echo "  Containers:"
	@echo "    make start          Sobe todos os containers (detached)"
	@echo "    make start-dev      Sobe containers + PgAdmin (perfil dev)"
	@echo "    make stop           Para todos os containers"
	@echo "    make restart        Para e reinicia os containers"
	@echo "    make build          Reconstrói as imagens Docker"
	@echo "    make clean          Para containers e remove volumes (CUIDADO!)"
	@echo ""
	@echo "  Monitoramento:"
	@echo "    make logs           Mostra logs de todos os serviços"
	@echo "    make logs-app       Mostra logs apenas da aplicação"
	@echo "    make logs-db        Mostra logs apenas do banco"
	@echo "    make status         Mostra status dos containers"
	@echo "    make healthcheck    Executa healthcheck manual"
	@echo ""
	@echo "  Banco de Dados:"
	@echo "    make db-shell       Abre shell psql no PostgreSQL"
	@echo "    make backup         Cria backup do banco de dados"
	@echo "    make restore        Restaura backup (BACKUP=caminho/arquivo.sql.gz)"
	@echo ""
	@echo "  Desenvolvimento:"
	@echo "    make app-shell      Abre shell no container da aplicação"
	@echo "    make lint           Executa ESLint"
	@echo "    make typecheck      Verifica tipos TypeScript"
	@echo ""

# ==============================================================================
# Infraestrutura
# ==============================================================================
install:
	@echo "▶  Instalando dependências no servidor..."
	sudo bash scripts/install.sh

deploy:
	@echo "▶  Executando deploy..."
	bash scripts/deploy.sh

setup-cron:
	@echo "▶  Configurando cron de healthcheck (requer sudo)..."
	@CRON_JOB="*/5 * * * * /bin/bash $(PWD)/scripts/healthcheck.sh >> /var/log/freelancers-health.log 2>&1"
	@(sudo crontab -l 2>/dev/null | grep -v "healthcheck.sh" ; \
	  echo "*/5 * * * * /bin/bash $(PWD)/scripts/healthcheck.sh >> /var/log/freelancers-health.log 2>&1") \
	  | sudo crontab -
	@echo "   Cron configurado. Verificando:"
	@sudo crontab -l | grep healthcheck

# ==============================================================================
# Containers
# ==============================================================================
start:
	@echo "▶  Iniciando containers..."
	$(COMPOSE) $(COMPOSE_ARGS) up -d
	@echo "   Aplicação: http://localhost:3000"

start-dev:
	@echo "▶  Iniciando containers (perfil dev com PgAdmin)..."
	$(COMPOSE) $(COMPOSE_ARGS) --profile dev up -d
	@echo "   Aplicação: http://localhost:3000"
	@echo "   PgAdmin:   http://localhost:5050"

stop:
	@echo "▶  Parando containers..."
	$(COMPOSE) $(COMPOSE_ARGS) down

restart: stop start

build:
	@echo "▶  Reconstruindo imagens..."
	$(COMPOSE) $(COMPOSE_ARGS) build --no-cache

clean:
	@echo ""
	@echo "  ⚠️  ATENÇÃO: Isso vai remover todos os containers E volumes (dados do banco)!"
	@read -p "  Digite 'sim' para confirmar: " CONFIRM && [ "$$CONFIRM" = "sim" ] || exit 1
	$(COMPOSE) $(COMPOSE_ARGS) down -v --remove-orphans
	docker image prune -f
	@echo "   Limpeza concluída."

# ==============================================================================
# Monitoramento
# ==============================================================================
logs:
	$(COMPOSE) $(COMPOSE_ARGS) logs -f --tail=100

logs-app:
	$(COMPOSE) $(COMPOSE_ARGS) logs -f --tail=100 app

logs-db:
	$(COMPOSE) $(COMPOSE_ARGS) logs -f --tail=100 postgres

status:
	@echo ""
	@echo "  Status dos containers:"
	@echo "  ----------------------"
	$(COMPOSE) $(COMPOSE_ARGS) ps
	@echo ""
	@echo "  Uso de recursos:"
	@docker stats --no-stream --format \
	  "  {{.Name}}: CPU={{.CPUPerc}} | MEM={{.MemUsage}} | NET={{.NetIO}}" 2>/dev/null || true

healthcheck:
	@bash scripts/healthcheck.sh

# ==============================================================================
# Banco de Dados
# ==============================================================================
db-shell:
	@echo "▶  Abrindo shell PostgreSQL..."
	$(COMPOSE) $(COMPOSE_ARGS) exec postgres \
	  psql -U $${POSTGRES_USER:-freelancer} -d $${POSTGRES_DB:-sistema_freelancers}

backup:
	@echo "▶  Criando backup do banco..."
	@mkdir -p backups
	@FILENAME="backups/backup_$(shell date +%Y%m%d_%H%M%S).sql.gz"
	$(COMPOSE) $(COMPOSE_ARGS) exec -T postgres \
	  pg_dump -U $${POSTGRES_USER:-freelancer} $${POSTGRES_DB:-sistema_freelancers} \
	  | gzip > "backups/backup_$(shell date +%Y%m%d_%H%M%S).sql.gz"
	@echo "   Backup criado em: backups/"
	@ls -lh backups/*.sql.gz | tail -1

restore:
ifndef BACKUP
	@echo "  Uso: make restore BACKUP=backups/arquivo.sql.gz"
	@exit 1
endif
	@echo "▶  Restaurando backup: $(BACKUP)"
	gunzip -c "$(BACKUP)" | \
	$(COMPOSE) $(COMPOSE_ARGS) exec -T postgres \
	  psql -U $${POSTGRES_USER:-freelancer} -d $${POSTGRES_DB:-sistema_freelancers}
	@echo "   Backup restaurado com sucesso."

# ==============================================================================
# Desenvolvimento
# ==============================================================================
app-shell:
	$(COMPOSE) $(COMPOSE_ARGS) exec app sh

lint:
	npm run lint

typecheck:
	npx tsc --noEmit
