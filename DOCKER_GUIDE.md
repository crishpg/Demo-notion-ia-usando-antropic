# 🐳 Guia Docker - Sistema Para Freelancers

Guia completo para executar o Sistema Para Freelancers usando Docker.

---

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Início Rápido](#início-rápido)
- [Configuração Detalhada](#configuração-detalhada)
- [Comandos Úteis](#comandos-úteis)
- [Troubleshooting](#troubleshooting)
- [Produção](#produção)

---

## 🔧 Pré-requisitos

### Instalar Docker

**Windows:**
- Baixe [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- Execute o instalador
- Reinicie o computador se necessário

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
```

**macOS:**
- Baixe [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
- Execute o instalador

### Verificar Instalação

```bash
docker --version
docker-compose --version
```

---

## 🚀 Início Rápido

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/Demo-notion-ia-usando-antropic.git
cd Demo-notion-ia-usando-antropic
```

### 2. Configure as variáveis de ambiente

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite conforme necessário (opcional para desenvolvimento)
# As configurações padrão já funcionam
```

### 3. Inicie os containers

```bash
docker-compose up -d
```

Isso irá:
- ✅ Baixar as imagens necessárias
- ✅ Criar o banco de dados PostgreSQL
- ✅ Executar o script SQL de inicialização
- ✅ Buildar e iniciar a aplicação Next.js

### 4. Acesse a aplicação

Abra o navegador em: **http://localhost:3000**

🎉 **Pronto!** O sistema está rodando.

---

## ⚙️ Configuração Detalhada

### Estrutura do Docker Compose

O `docker-compose.yml` define 3 serviços:

#### 1. **postgres** (Obrigatório)
- Banco de dados PostgreSQL 14
- Porta: `5432` (padrão)
- Volume persistente para dados
- Script de inicialização automático

#### 2. **app** (Obrigatório)
- Aplicação Next.js
- Porta: `3000` (padrão)
- Depende do PostgreSQL

#### 3. **pgadmin** (Opcional)
- Interface web para gerenciar PostgreSQL
- Porta: `5050` (padrão)
- Apenas para desenvolvimento

### Variáveis de Ambiente

Edite o arquivo `.env`:

```env
# Database
POSTGRES_USER=freelancer          # Usuário do banco
POSTGRES_PASSWORD=freelancer123   # Senha do banco
POSTGRES_DB=sistema_freelancers   # Nome do banco
POSTGRES_PORT=5432                # Porta do PostgreSQL

# Application
APP_PORT=3000                     # Porta da aplicação
NODE_ENV=production               # Ambiente

# PgAdmin (Opcional)
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050
```

---

## 📦 Comandos Úteis

### Iniciar Containers

```bash
# Iniciar em background
docker-compose up -d

# Iniciar com logs visíveis
docker-compose up

# Iniciar apenas serviços específicos
docker-compose up -d postgres app
```

### Parar Containers

```bash
# Parar containers
docker-compose stop

# Parar e remover containers
docker-compose down

# Parar e remover containers + volumes (limpa o banco)
docker-compose down -v
```

### Ver Logs

```bash
# Todos os serviços
docker-compose logs -f

# Apenas a aplicação
docker-compose logs -f app

# Apenas o banco
docker-compose logs -f postgres

# Últimas 100 linhas
docker-compose logs --tail=100 -f
```

### Executar Comandos nos Containers

```bash
# Acessar bash da aplicação
docker-compose exec app sh

# Acessar PostgreSQL
docker-compose exec postgres psql -U freelancer -d sistema_freelancers

# Executar query SQL
docker-compose exec postgres psql -U freelancer -d sistema_freelancers -c "SELECT * FROM clientes;"
```

### Rebuild da Aplicação

```bash
# Rebuild após mudanças no código
docker-compose up -d --build app

# Rebuild forçado (sem cache)
docker-compose build --no-cache app
docker-compose up -d app
```

### Status dos Containers

```bash
# Ver containers rodando
docker-compose ps

# Ver uso de recursos
docker stats

# Ver logs de health check
docker inspect freelancers-app | grep -A 10 Health
```

---

## 🔍 Troubleshooting

### Problema: Porta já em uso

**Erro:**
```
Error: bind: address already in use
```

**Solução:**
```bash
# Mudar a porta no .env
APP_PORT=3001
POSTGRES_PORT=5433

# Ou parar o serviço que está usando a porta
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/macOS
lsof -i :3000
kill -9 <PID>
```

### Problema: Banco de dados não inicializa

**Solução:**
```bash
# Remover volumes e recriar
docker-compose down -v
docker-compose up -d

# Verificar logs do PostgreSQL
docker-compose logs postgres
```

### Problema: Aplicação não conecta ao banco

**Solução:**
```bash
# Verificar se o PostgreSQL está saudável
docker-compose ps

# Verificar variável DATABASE_URL
docker-compose exec app env | grep DATABASE_URL

# Testar conexão manualmente
docker-compose exec postgres psql -U freelancer -d sistema_freelancers -c "SELECT 1;"
```

### Problema: Mudanças no código não aparecem

**Solução:**
```bash
# Rebuild da aplicação
docker-compose up -d --build app

# Ou rebuild completo
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Problema: Permissões no Linux

**Solução:**
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Fazer logout e login novamente
# Ou executar
newgrp docker
```

---

## 🔐 Produção

### Configurações de Segurança

#### 1. **Altere as senhas padrão**

```env
POSTGRES_PASSWORD=senha_forte_aleatoria_aqui
PGADMIN_PASSWORD=outra_senha_forte
```

#### 2. **Não exponha portas desnecessárias**

```yaml
# Remova a exposição da porta do PostgreSQL
services:
  postgres:
    # ports:
    #   - "5432:5432"  # Comentar ou remover
```

#### 3. **Use secrets do Docker**

```bash
# Criar secrets
echo "senha_secreta" | docker secret create db_password -

# Usar no docker-compose.yml
secrets:
  db_password:
    external: true
```

#### 4. **Configure HTTPS**

Use um reverse proxy como **Nginx** ou **Traefik**:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

### Deploy em Servidor

#### VPS / Servidor Dedicado

```bash
# 1. Conectar ao servidor
ssh user@seu-servidor.com

# 2. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Clonar repositório
git clone https://github.com/seu-usuario/repo.git
cd repo

# 4. Configurar .env
nano .env

# 5. Iniciar
docker-compose up -d

# 6. Configurar firewall (se necessário)
sudo ufw allow 3000
```

#### Docker Swarm / Kubernetes

Para ambientes em cluster, converta o `docker-compose.yml` para:
- **Docker Swarm**: Use `docker stack deploy`
- **Kubernetes**: Use `kompose convert`

---

## 📊 Monitoramento

### Health Checks

```bash
# Verificar health dos containers
docker-compose ps

# Inspecionar health check detalhado
docker inspect freelancers-app --format='{{json .State.Health}}' | jq
```

### Backup do Banco

```bash
# Backup manual
docker-compose exec postgres pg_dump -U freelancer sistema_freelancers > backup.sql

# Backup agendado (cron)
0 2 * * * docker-compose -f /path/to/docker-compose.yml exec -T postgres pg_dump -U freelancer sistema_freelancers > /backups/backup_$(date +\%Y\%m\%d).sql
```

### Restaurar Backup

```bash
# Restaurar de backup
docker-compose exec -T postgres psql -U freelancer -d sistema_freelancers < backup.sql
```

---

## 🎯 Profiles do Docker Compose

### Executar com PgAdmin (Desenvolvimento)

```bash
docker-compose --profile dev up -d
```

Acesse PgAdmin em: **http://localhost:5050**

**Conectar ao banco no PgAdmin:**
- Host: `postgres`
- Port: `5432`
- Database: `sistema_freelancers`
- Username: `freelancer`
- Password: `freelancer123`

---

## 📝 Checklist de Deploy

Antes de fazer deploy em produção:

- [ ] Alterar senhas padrão
- [ ] Configurar backups automáticos
- [ ] Configurar HTTPS/SSL
- [ ] Configurar firewall
- [ ] Testar health checks
- [ ] Configurar logs centralizados
- [ ] Configurar monitoring (Prometheus, Grafana)
- [ ] Documentar procedimentos de emergência
- [ ] Testar procedimento de restore
- [ ] Configurar rate limiting

---

## 🆘 Suporte

Para mais ajuda:

1. Consulte os logs: `docker-compose logs -f`
2. Verifique o [README principal](./README.md)
3. Abra uma issue no GitHub

---

<div align="center">

**[⬆ Voltar ao topo](#-guia-docker---sistema-para-freelancers)**

🐳 Happy Dockering!

</div>
