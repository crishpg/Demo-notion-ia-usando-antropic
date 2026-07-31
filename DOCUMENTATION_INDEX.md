# 📚 Índice de Documentação

Guia completo de toda a documentação disponível no projeto.

---

## 🚀 Para Começar

| Documento | Descrição | Tempo |
|-----------|-----------|-------|
| **[QUICK_START.md](./QUICK_START.md)** | Início rápido em 5 minutos | ⚡ 5 min |
| **[README.md](./README.md)** | Documentação principal completa | 📖 15 min |

---

## 🐳 Docker & Deploy

| Documento | Descrição | Conteúdo |
|-----------|-----------|----------|
| **[DOCKER_GUIDE.md](./DOCKER_GUIDE.md)** | Guia completo Docker | Setup, comandos, troubleshooting |
| **[Dockerfile](./Dockerfile)** | Imagem Docker da aplicação | Build multi-stage, otimizado |
| **[docker-compose.yml](./docker-compose.yml)** | Orquestração de containers | PostgreSQL + App + PgAdmin |
| **[.dockerignore](./.dockerignore)** | Arquivos ignorados no build | Performance de build |
| **[.env.example](./.env.example)** | Variáveis de ambiente | Configuração de exemplo |

---

## 🗄️ Banco de Dados

| Documento | Descrição | Conteúdo |
|-----------|-----------|----------|
| **[sistema_freelancers_ddl.sql](./sistema_freelancers_ddl.sql)** | Script SQL completo | DDL, índices, views, triggers |
| **[RESUMO_BANCO_DADOS.md](./RESUMO_BANCO_DADOS.md)** | Documentação do banco | Tabelas, relações, queries |
| **[DIAGRAMA_ER.md](./DIAGRAMA_ER.md)** | Diagrama Entidade-Relacionamento | Visualização das relações |
| **[banco dados.md](./banco%20dados.md)** | Especificação inicial | Requirements originais |

---

## 🔗 Integração Notion

| Documento | Descrição | Conteúdo |
|-----------|-----------|----------|
| **[INTEGRACAO_NOTION.md](./INTEGRACAO_NOTION.md)** | Guia de integração Notion | Setup, sincronização, API |
| **[.kiro/settings/mcp.json](./.kiro/settings/mcp.json)** | Configuração MCP | Token e servidor Notion |

---

## 💻 Código & Desenvolvimento

### Estrutura Principal

| Arquivo/Pasta | Descrição |
|---------------|-----------|
| **[app/](./app/)** | Next.js App Router |
| **[components/](./components/)** | Componentes React |
| **[lib/](./lib/)** | Utilitários e helpers |
| **[types/](./types/)** | Definições TypeScript |

### Configurações

| Arquivo | Descrição |
|---------|-----------|
| **[package.json](./package.json)** | Dependências e scripts |
| **[tsconfig.json](./tsconfig.json)** | Configuração TypeScript |
| **[tailwind.config.ts](./tailwind.config.ts)** | Configuração Tailwind |
| **[next.config.js](./next.config.js)** | Configuração Next.js |
| **[postcss.config.js](./postcss.config.js)** | Configuração PostCSS |

### Arquivos Chave

| Arquivo | Descrição |
|---------|-----------|
| **[app/layout.tsx](./app/layout.tsx)** | Layout principal |
| **[components/Sidebar.tsx](./components/Sidebar.tsx)** | Menu lateral |
| **[lib/mockData.ts](./lib/mockData.ts)** | Dados mockados |
| **[types/index.ts](./types/index.ts)** | Tipos TypeScript |
| **[app/globals.css](./app/globals.css)** | Estilos globais |

---

## 📖 Documentação por Tópico

### 🎯 Para Iniciantes

1. **[QUICK_START.md](./QUICK_START.md)** - Comece aqui
2. **[README.md](./README.md)** - Visão geral
3. **[DOCKER_GUIDE.md](./DOCKER_GUIDE.md)** - Setup Docker

### 🏗️ Para Desenvolvedores

1. **[README.md](./README.md)** - Arquitetura
2. **[types/index.ts](./types/index.ts)** - Tipos do sistema
3. **[lib/mockData.ts](./lib/mockData.ts)** - Dados de teste
4. **[app/layout.tsx](./app/layout.tsx)** - Estrutura layout

### 🗄️ Para DBAs

1. **[sistema_freelancers_ddl.sql](./sistema_freelancers_ddl.sql)** - Script SQL
2. **[RESUMO_BANCO_DADOS.md](./RESUMO_BANCO_DADOS.md)** - Documentação
3. **[DIAGRAMA_ER.md](./DIAGRAMA_ER.md)** - Diagrama ER

### 🚀 Para DevOps

1. **[DOCKER_GUIDE.md](./DOCKER_GUIDE.md)** - Guia Docker
2. **[Dockerfile](./Dockerfile)** - Build da imagem
3. **[docker-compose.yml](./docker-compose.yml)** - Orquestração
4. **[.env.example](./.env.example)** - Variáveis de ambiente

### 🔗 Para Integrações

1. **[INTEGRACAO_NOTION.md](./INTEGRACAO_NOTION.md)** - Notion MCP
2. **[.kiro/settings/mcp.json](./.kiro/settings/mcp.json)** - Config MCP

---

## 📊 Fluxo de Leitura Recomendado

### Primeiro Uso

```
1. QUICK_START.md          (5 min)
2. README.md - Seção Setup (10 min)
3. Executar aplicação      (5 min)
```

### Desenvolvimento

```
1. README.md - Completo           (15 min)
2. RESUMO_BANCO_DADOS.md          (10 min)
3. Código: app/, components/, lib (30 min)
```

### Deploy

```
1. DOCKER_GUIDE.md         (20 min)
2. .env.example            (5 min)
3. docker-compose.yml      (10 min)
```

---

## 🔍 Como Encontrar Informações

### Por Funcionalidade

- **Instalação**: `QUICK_START.md` ou `README.md`
- **Docker**: `DOCKER_GUIDE.md`
- **Banco de Dados**: `RESUMO_BANCO_DADOS.md`
- **Notion**: `INTEGRACAO_NOTION.md`
- **Código**: Arquivos em `app/`, `components/`, `lib/`

### Por Problema

- **Erro de instalação**: `QUICK_START.md` → Troubleshooting
- **Erro Docker**: `DOCKER_GUIDE.md` → Troubleshooting
- **Erro de banco**: `RESUMO_BANCO_DADOS.md` → Queries
- **Erro de código**: `README.md` → Estrutura

---

## 📝 Atualizações

Este índice está atualizado com a versão **1.0.0** do projeto.

**Última atualização**: 31 de Julho de 2026

---

## 🤝 Contribuindo

| Documento | Descrição |
|-----------|-----------|
| **[CONTRIBUINDO.md](./CONTRIBUINDO.md)** | Guia completo de contribuição |

Ao adicionar nova documentação:

1. Crie o arquivo `.md` apropriado
2. Adicione entrada neste índice
3. Referencie em documentos relacionados
4. Atualize a data de atualização

---

<div align="center">

**[⬆ Voltar ao README](./README.md)**

📚 Documentação completa e organizada

</div>
