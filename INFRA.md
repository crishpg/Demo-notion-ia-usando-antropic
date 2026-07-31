# Infraestrutura — Deploy no Ubuntu 22.04

## Visão Geral

Este documento descreve como provisionar um servidor Ubuntu 22.04 do zero e fazer o deploy automatizado da aplicação **Sistema Freelancers**.

```
┌─────────────────────────────────────────────────────┐
│               Ubuntu 22.04 (Servidor)               │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │               Nginx (porta 80)               │   │
│  │     Proxy reverso para a aplicação          │   │
│  └────────────────────┬─────────────────────────┘   │
│                       │                             │
│  ┌────────────────────▼─────────────────────────┐   │
│  │          Docker Compose                      │   │
│  │  ┌────────────────┐  ┌───────────────────┐   │   │
│  │  │ Next.js : 3000 │  │ PostgreSQL : 5432 │   │   │
│  │  └────────────────┘  └───────────────────┘   │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `scripts/install.sh` | Setup inicial do servidor (dependências, Docker, UFW) |
| `scripts/deploy.sh` | Deploy automatizado (pull, build, up, healthcheck) |
| `scripts/healthcheck.sh` | Monitoramento + restart automático + limpeza de disco |
| `.github/workflows/deploy.yml` | Pipeline GitHub Actions (lint → build → deploy) |
| `Makefile` | Comandos utilitários (`make help` para listar) |
| `nginx/freelancers-app.conf` | Config do Nginx como proxy reverso |

---

## Passo a Passo — Primeira Instalação

### 1. Clonar o repositório no servidor

```bash
# No servidor Ubuntu 22.04
git clone https://github.com/SEU_USUARIO/Demo-notion-ia-usando-antropic.git /opt/freelancers-app
cd /opt/freelancers-app
```

### 2. Instalar dependências do sistema

```bash
# Instala Docker, Docker Compose, Nginx, UFW
sudo bash scripts/install.sh
```

> O script detecta se o ambiente já tem cada ferramenta instalada e pula a etapa se já estiver presente.

### 3. Configurar variáveis de ambiente

```bash
# Criado automaticamente pelo install.sh
nano /opt/freelancers-app/.env
```

Edite ao menos as senhas:
```env
POSTGRES_PASSWORD=SUA_SENHA_FORTE_AQUI
PGADMIN_PASSWORD=OUTRA_SENHA_FORTE
NOTION_TOKEN=ntn_xxxxxxxxxxxx   # opcional
```

### 4. Fazer o primeiro deploy

```bash
bash scripts/deploy.sh
# ou
make deploy
```

### 5. Configurar Nginx (proxy reverso)

```bash
# Copiar config para o Nginx
sudo cp nginx/freelancers-app.conf /etc/nginx/sites-available/freelancers
sudo ln -s /etc/nginx/sites-available/freelancers /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### 6. Configurar healthcheck automático via cron

```bash
sudo make setup-cron
# ou manualmente:
sudo crontab -e
# Adicionar:
# */5 * * * * /bin/bash /opt/freelancers-app/scripts/healthcheck.sh >> /var/log/freelancers-health.log 2>&1
```

---

## Deploy Contínuo — GitHub Actions

O workflow `.github/workflows/deploy.yml` executa automaticamente ao fazer push na branch `main` ou `master`:

```
push → Lint & Typecheck → Build Docker Image → Deploy SSH → Healthcheck
```

### Configurar os Secrets no GitHub

Vá em **Settings → Secrets and variables → Actions** e adicione:

| Secret | Valor |
|--------|-------|
| `SSH_HOST` | IP ou domínio do servidor |
| `SSH_USER` | Usuário SSH (ex: `ubuntu`, `deploy`) |
| `SSH_PRIVATE_KEY` | Conteúdo da chave privada SSH (`cat ~/.ssh/id_rsa`) |
| `SSH_PORT` | Porta SSH (padrão: `22`) |

### Gerar e autorizar chave SSH para o deploy

```bash
# Na máquina local (onde está o GitHub Actions runner)
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/deploy_key

# Copiar a chave pública para o servidor
ssh-copy-id -i ~/.ssh/deploy_key.pub usuario@IP_DO_SERVIDOR

# Adicionar a chave PRIVADA no secret SSH_PRIVATE_KEY do GitHub
cat ~/.ssh/deploy_key
```

---

## Comandos do Makefile

```bash
make help           # Lista todos os comandos

# Containers
make start          # Inicia todos os containers
make start-dev      # Inicia + PgAdmin na porta 5050
make stop           # Para os containers
make restart        # Reinicia
make build          # Reconstrói imagens sem cache
make status         # Status + uso de recursos

# Logs
make logs           # Todos os serviços
make logs-app       # Apenas Next.js
make logs-db        # Apenas PostgreSQL

# Banco de dados
make db-shell       # Abre psql
make backup         # Cria backup comprimido
make restore BACKUP=backups/arquivo.sql.gz

# Monitoramento
make healthcheck    # Executa verificação manual

# Limpeza (DESTRUTIVO)
make clean          # Remove containers + volumes
```

---

## Portas e Firewall (UFW)

| Porta | Serviço | Regra UFW |
|-------|---------|-----------|
| 22 | SSH | allow |
| 80 | Nginx (HTTP) | allow |
| 3000 | Next.js | allow |
| 5432 | PostgreSQL | allow |
| 5050 | PgAdmin (dev) | allow |

Para remover acesso direto ao PostgreSQL de fora (recomendado em produção):
```bash
sudo ufw delete allow 5432/tcp
```

---

## Estrutura de Arquivos no Servidor

```
/opt/freelancers-app/         ← raiz do projeto
├── scripts/
│   ├── install.sh            ← setup do servidor
│   ├── deploy.sh             ← deploy automatizado
│   └── healthcheck.sh        ← monitoramento
├── backups/                  ← backups automáticos (criado no deploy)
│   └── backup_YYYYMMDD_HHMMSS.sql.gz
├── docker-compose.yml
├── Dockerfile
└── .env                      ← variáveis de ambiente (chmod 600)

/var/log/
└── freelancers-health.log    ← logs do healthcheck (cron)
```

---

## Rollback

Em caso de falha no deploy, os backups ficam em `backups/`:

```bash
# Listar backups disponíveis
ls -lh backups/

# Restaurar um backup específico
make restore BACKUP=backups/backup_20250101_120000.sql.gz

# Ou voltar para uma versão anterior do código
git log --oneline
git checkout <commit-anterior>
make deploy
```

---

## Troubleshooting

### Container da aplicação não sobe
```bash
make logs-app
# Verifique o status do build
docker inspect freelancers-app
```

### PostgreSQL não conecta
```bash
make logs-db
make db-shell
# Dentro do psql: \l para listar bancos
```

### Porta 3000 não responde
```bash
curl -v http://localhost:3000
make status
# Verifique o firewall
sudo ufw status
```

### Espaço em disco
```bash
df -h
docker system df
docker system prune -a  # CUIDADO: remove imagens não utilizadas
```
