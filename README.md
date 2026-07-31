# 💼 Sistema Para Freelancers

> Um sistema completo dedicado para você organizar todos os seus projetos de freelancer!

[![Next.js](https://img.shields.io/badge/Next.js-14.2-black?style=flat&logo=next.js)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue?style=flat&logo=typescript)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-38bdf8?style=flat&logo=tailwindcss)](https://tailwindcss.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-336791?style=flat&logo=postgresql)](https://www.postgresql.org/)

---

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Banco de Dados](#banco-de-dados)
- [Instalação e Execução](#instalação-e-execução)
  - [Local (Desenvolvimento)](#local-desenvolvimento)
  - [Docker](#docker)
  - [Docker Compose](#docker-compose)
- [Configuração](#configuração)
- [Funcionalidades](#funcionalidades)
- [Integração com Notion](#integração-com-notion)
- [Scripts Disponíveis](#scripts-disponíveis)
- [Documentação Adicional](#documentação-adicional)
- [Roadmap](#roadmap)
- [Licença](#licença)

---

## 🎯 Sobre o Projeto

O **Sistema Para Freelancers** é uma aplicação web completa desenvolvida para ajudar freelancers a gerenciar seus clientes, projetos e atividades de forma organizada e eficiente. 

### Baseado no Notion

Este projeto foi desenvolvido com base na estrutura de uma página do Notion, oferecendo uma experiência familiar e intuitiva para usuários que já utilizam a plataforma.

**Página de Referência**: [Sistema Para Freelancers no Notion](https://app.notion.com/p/Sistema-Para-Freelancers-a4d2a76472be826bbbe28129ea70fdb5)

### Principais Benefícios

✅ **Gestão Centralizada**: Todos os seus clientes, projetos e atividades em um só lugar  
✅ **Rastreamento de Prazos**: Acompanhe deadlines e identifique projetos urgentes  
✅ **Priorização**: Sistema de prioridades para atividades  
✅ **Estatísticas**: Visualize o progresso dos seus projetos  
✅ **Interface Limpa**: Design minimalista inspirado no Notion  

---

## 🏗️ Arquitetura

### Stack Tecnológico

```
┌─────────────────────────────────────┐
│         Frontend (Next.js)          │
│  ┌──────────────────────────────┐   │
│  │   App Router + React 18      │   │
│  │   TypeScript + Tailwind CSS  │   │
│  └──────────────────────────────┘   │
└─────────────────┬───────────────────┘
                  │
                  │ API Routes / Server Actions
                  │
┌─────────────────▼───────────────────┐
│         Backend (Node.js)           │
│  ┌──────────────────────────────┐   │
│  │   PostgreSQL Database        │   │
│  │   UUID + Relations           │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Modelo de Dados

O sistema utiliza um modelo relacional com 3 entidades principais:

```
CLIENTES (1) ──→ (N) PROJETOS (1) ──→ (N) ATIVIDADES
```

Veja mais detalhes em: [`DIAGRAMA_ER.md`](./DIAGRAMA_ER.md)

---

## 🛠️ Tecnologias

### Frontend
- **[Next.js 14](https://nextjs.org/)** - Framework React com App Router
- **[React 18](https://react.dev/)** - Biblioteca UI
- **[TypeScript](https://www.typescriptlang.org/)** - Tipagem estática
- **[Tailwind CSS](https://tailwindcss.com/)** - Framework CSS utility-first
- **[Lucide React](https://lucide.dev/)** - Ícones SVG

### Backend
- **[PostgreSQL](https://www.postgresql.org/)** - Banco de dados relacional
- **UUID** - Identificadores únicos
- **PL/pgSQL** - Triggers e funções

### DevOps
- **[Docker](https://www.docker.com/)** - Containerização
- **[Docker Compose](https://docs.docker.com/compose/)** - Orquestração

### Integração
- **[Notion MCP Server](https://github.com/makenotion/notion-mcp-server)** - Model Context Protocol

---

## 📁 Estrutura do Projeto

```
Demo-notion-ia-usando-antropic/
├── app/                          # Next.js App Router
│   ├── layout.tsx               # Layout principal
│   ├── page.tsx                 # Dashboard (página inicial)
│   ├── globals.css              # Estilos globais
│   ├── clientes/                # Módulo de Clientes
│   ├── projetos/                # Módulo de Projetos
│   └── atividades/              # Módulo de Atividades
│
├── components/                   # Componentes React reutilizáveis
│   ├── Sidebar.tsx              # Menu lateral
│   ├── Header.tsx               # Cabeçalho
│   └── ...
│
├── lib/                         # Utilitários e helpers
│   ├── mockData.ts              # Dados mockados para desenvolvimento
│   ├── database.ts              # Conexão com banco de dados
│   └── utils.ts                 # Funções auxiliares
│
├── types/                       # Definições TypeScript
│   └── index.ts                 # Tipos baseados no schema SQL
│
├── .kiro/                       # Configurações Kiro
│   └── settings/
│       └── mcp.json             # Configuração Notion MCP
│
├── docs/                        # Documentação
│   ├── RESUMO_BANCO_DADOS.md   # Documentação do banco
│   ├── DIAGRAMA_ER.md          # Diagrama ER
│   └── INTEGRACAO_NOTION.md    # Guia de integração
│
├── sistema_freelancers_ddl.sql  # Script SQL do banco de dados
├── docker-compose.yml           # Orquestração Docker
├── Dockerfile                   # Imagem Docker da aplicação
├── package.json                 # Dependências Node.js
├── tsconfig.json                # Configuração TypeScript
├── tailwind.config.ts           # Configuração Tailwind
└── README.md                    # Este arquivo
```

---

## 🗄️ Banco de Dados

### Schema PostgreSQL

O banco de dados foi projetado com base nas estruturas do Notion, mantendo a mesma nomenclatura e relacionamentos.

**Arquivo**: [`sistema_freelancers_ddl.sql`](./sistema_freelancers_ddl.sql)

### Tabelas Principais

#### 1. **clientes**
```sql
id UUID PRIMARY KEY
nome VARCHAR(255) NOT NULL
email VARCHAR(255)
telefone VARCHAR(20)
instagram VARCHAR(500)
drive VARCHAR(500)
created_at TIMESTAMP
updated_at TIMESTAMP
```

#### 2. **projetos**
```sql
id UUID PRIMARY KEY
nome_projeto VARCHAR(255) NOT NULL
cliente_id UUID (FK → clientes)
data_inicio DATE
data_fim DATE
status VARCHAR(50) CHECK IN ('Não iniciado', 'Em andamento', 'Concluído')
lancado BOOLEAN
created_at TIMESTAMP
updated_at TIMESTAMP
```

#### 3. **atividades**
```sql
id UUID PRIMARY KEY
nome VARCHAR(255) NOT NULL
projeto_id UUID (FK → projetos)
status VARCHAR(50) CHECK IN ('Não iniciada', 'Em andamento', 'Concluído')
prioridade VARCHAR(20) CHECK IN ('Baixa', 'Média', 'Alta')
data_inicio DATE
data_fim DATE
created_at TIMESTAMP
updated_at TIMESTAMP
```

### Views e Índices

O banco inclui:
- ✅ 11 índices para performance
- ✅ 3 views para consultas otimizadas
- ✅ Triggers para atualização automática de `updated_at`
- ✅ Constraints de validação

Documentação completa: [`RESUMO_BANCO_DADOS.md`](./RESUMO_BANCO_DADOS.md)

---

## 🚀 Instalação e Execução

### Pré-requisitos

- **Node.js** 18+ ou **Docker**
- **PostgreSQL** 14+ (se rodar localmente)
- **Git**

---

### 💻 Local (Desenvolvimento)

#### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/Demo-notion-ia-usando-antropic.git
cd Demo-notion-ia-usando-antropic
```

#### 2. Instale as dependências

```bash
npm install
# ou
yarn install
# ou
pnpm install
```

#### 3. Configure o banco de dados

```bash
# Crie o banco de dados
createdb sistema_freelancers

# Execute o script DDL
psql -d sistema_freelancers -f sistema_freelancers_ddl.sql
```

#### 4. Configure as variáveis de ambiente

Crie um arquivo `.env.local`:

```env
# Database
DATABASE_URL="postgresql://usuario:senha@localhost:5432/sistema_freelancers"

# Notion (opcional)
NOTION_TOKEN="seu_token_aqui"

# Ambiente
NODE_ENV="development"
```

#### 5. Execute o servidor de desenvolvimento

```bash
npm run dev
```

Acesse: **http://localhost:3000**

---

### 🐳 Docker

#### Opção 1: Build e Run Manual

```bash
# Build da imagem
docker build -t sistema-freelancers .

# Run do container
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://usuario:senha@host.docker.internal:5432/sistema_freelancers" \
  sistema-freelancers
```

#### Opção 2: Docker Compose (Recomendado)

Crie o arquivo `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Banco de dados PostgreSQL
  postgres:
    image: postgres:14-alpine
    container_name: freelancers-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: freelancer
      POSTGRES_PASSWORD: freelancer123
      POSTGRES_DB: sistema_freelancers
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sistema_freelancers_ddl.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - freelancers-network

  # Aplicação Next.js
  app:
    build: .
    container_name: freelancers-app
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://freelancer:freelancer123@postgres:5432/sistema_freelancers
      NODE_ENV: production
    ports:
      - "3000:3000"
    depends_on:
      - postgres
    networks:
      - freelancers-network

volumes:
  postgres_data:

networks:
  freelancers-network:
    driver: bridge
```

#### Execute com Docker Compose

```bash
# Inicie os containers
docker-compose up -d

# Veja os logs
docker-compose logs -f

# Pare os containers
docker-compose down

# Pare e remova volumes (limpa o banco)
docker-compose down -v
```

Acesse: **http://localhost:3000**

---

### 📦 Dockerfile

Crie o arquivo `Dockerfile`:

```dockerfile
# Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependências
RUN npm ci

# Copiar código fonte
COPY . .

# Build da aplicação
RUN npm run build

# Production Stage
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV production

# Copiar necessários do build
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Expor porta
EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# Comando de inicialização
CMD ["node", "server.js"]
```

---

## ⚙️ Configuração

### Variáveis de Ambiente

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `DATABASE_URL` | String de conexão PostgreSQL | `postgresql://user:pass@host:5432/db` |
| `NOTION_TOKEN` | Token de integração Notion (opcional) | `ntn_xxxxxxxxxxxxx` |
| `NODE_ENV` | Ambiente de execução | `development` ou `production` |
| `PORT` | Porta do servidor | `3000` |

### Notion MCP (Opcional)

Para integração com Notion via MCP:

1. Configure o token no arquivo `.kiro/settings/mcp.json`
2. Siga o guia: [`INTEGRACAO_NOTION.md`](./INTEGRACAO_NOTION.md)

---

## ✨ Funcionalidades

### ✅ Implementado

- [x] **Dashboard**
  - Visão geral de estatísticas
  - Projetos urgentes e atrasados
  - Resumo de atividades

- [x] **Gestão de Clientes**
  - Cadastro completo
  - Edição e exclusão
  - Histórico de projetos

- [x] **Gestão de Projetos**
  - Criação e edição
  - Vinculação com clientes
  - Controle de status
  - Cálculo de prazos

- [x] **Gestão de Atividades**
  - Criação e priorização
  - Vinculação com projetos
  - Controle de status
  - Alertas de prazo

- [x] **Interface Responsiva**
  - Design inspirado no Notion
  - Dark mode
  - Mobile-first

### 🚧 Em Desenvolvimento

- [ ] Autenticação de usuários
- [ ] Sincronização com Notion
- [ ] Relatórios em PDF
- [ ] Controle financeiro
- [ ] Notificações

---

## 📜 Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev          # Inicia servidor de desenvolvimento
npm run build        # Build para produção
npm run start        # Inicia servidor de produção
npm run lint         # Executa linter

# Docker
docker-compose up -d           # Inicia containers
docker-compose down            # Para containers
docker-compose logs -f app     # Logs da aplicação
docker-compose exec postgres psql -U freelancer -d sistema_freelancers  # Acessa PostgreSQL
```

---

## 📚 Documentação Adicional

- **[RESUMO_BANCO_DADOS.md](./RESUMO_BANCO_DADOS.md)** - Documentação completa do banco de dados
- **[DIAGRAMA_ER.md](./DIAGRAMA_ER.md)** - Diagrama entidade-relacionamento
- **[INTEGRACAO_NOTION.md](./INTEGRACAO_NOTION.md)** - Guia de integração com Notion via MCP
- **[banco dados.md](./banco%20dados.md)** - Especificação inicial do banco

---

## 🔗 Integração com Notion

Este projeto pode ser sincronizado com o Notion usando o **Model Context Protocol (MCP)**.

### Configuração Rápida

1. Obtenha um token de integração no [Notion](https://www.notion.so/my-integrations)
2. Configure no arquivo `.kiro/settings/mcp.json`
3. Compartilhe suas páginas com a integração

Guia completo: [`INTEGRACAO_NOTION.md`](./INTEGRACAO_NOTION.md)

---

## 🗺️ Roadmap

### Versão 1.1
- [ ] Autenticação e autorização
- [ ] Multi-tenant support
- [ ] API REST documentada

### Versão 1.2
- [ ] Sincronização bidirecional com Notion
- [ ] Webhooks para automações
- [ ] Notificações push

### Versão 2.0
- [ ] Módulo financeiro
- [ ] Controle de horas trabalhadas
- [ ] Geração de propostas
- [ ] Relatórios avançados

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## 👨‍💻 Autor

Desenvolvido com ❤️ para facilitar a vida de freelancers

---

## 🙏 Agradecimentos

- [Notion](https://www.notion.so/) - Pela inspiração do design e estrutura
- [Next.js](https://nextjs.org/) - Framework incrível
- [Tailwind CSS](https://tailwindcss.com/) - CSS utility-first

---

## 📞 Suporte

Para dúvidas ou problemas:

1. Consulte a [documentação](#documentação-adicional)
2. Abra uma [issue](https://github.com/seu-usuario/Demo-notion-ia-usando-antropic/issues)
3. Entre em contato via email

---

## 🔄 Atualizações

**Última atualização**: 31 de Julho de 2026  
**Versão**: 1.0.0

---

<div align="center">

**[⬆ Voltar ao topo](#-sistema-para-freelancers)**

Made with ❤️ using Next.js, TypeScript, and Tailwind CSS

</div>
