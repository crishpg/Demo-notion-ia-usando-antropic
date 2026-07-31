# 📂 Estrutura do Projeto

Visão completa da estrutura de arquivos e pastas do Sistema Para Freelancers.

---

## 🌳 Árvore de Diretórios

```
Demo-notion-ia-usando-antropic/
│
├── 📁 .kiro/                           # Configurações Kiro IDE
│   └── settings/
│       └── mcp.json                    # Config Notion MCP Server
│
├── 📁 .vscode/                         # Configurações VS Code
│   └── settings.json
│
├── 📁 app/                             # Next.js App Router
│   ├── layout.tsx                      # Layout principal da aplicação
│   ├── page.tsx                        # Dashboard (home)
│   ├── globals.css                     # Estilos globais
│   │
│   ├── 📁 clientes/                    # Módulo de Clientes
│   │   ├── page.tsx                    # Lista de clientes
│   │   └── [id]/
│   │       └── page.tsx                # Detalhes do cliente
│   │
│   ├── 📁 projetos/                    # Módulo de Projetos
│   │   ├── page.tsx                    # Lista de projetos
│   │   └── [id]/
│   │       └── page.tsx                # Detalhes do projeto
│   │
│   ├── 📁 atividades/                  # Módulo de Atividades
│   │   ├── page.tsx                    # Lista de atividades
│   │   └── [id]/
│   │       └── page.tsx                # Detalhes da atividade
│   │
│   └── 📁 api/                         # API Routes (futuro)
│       ├── clientes/
│       ├── projetos/
│       └── atividades/
│
├── 📁 components/                      # Componentes React
│   ├── Sidebar.tsx                     # Menu lateral de navegação
│   ├── Header.tsx                      # Cabeçalho
│   ├── Card.tsx                        # Card reutilizável
│   ├── Table.tsx                       # Tabela reutilizável
│   ├── StatusBadge.tsx                 # Badge de status
│   └── ...                             # Outros componentes
│
├── 📁 lib/                             # Bibliotecas e utilitários
│   ├── mockData.ts                     # Dados mockados para desenvolvimento
│   ├── database.ts                     # Conexão com banco (futuro)
│   ├── utils.ts                        # Funções auxiliares
│   └── constants.ts                    # Constantes da aplicação
│
├── 📁 types/                           # Definições TypeScript
│   └── index.ts                        # Tipos baseados no schema SQL
│
├── 📁 public/                          # Arquivos estáticos
│   ├── favicon.ico
│   └── images/
│
├── 📄 .dockerignore                    # Arquivos ignorados no Docker build
├── 📄 .env.example                     # Template de variáveis de ambiente
├── 📄 .gitignore                       # Arquivos ignorados pelo Git
│
├── 🐳 Dockerfile                       # Imagem Docker da aplicação
├── 🐳 docker-compose.yml               # Orquestração de containers
│
├── 📄 next.config.js                   # Configuração Next.js
├── 📄 package.json                     # Dependências e scripts npm
├── 📄 postcss.config.js                # Configuração PostCSS
├── 📄 tailwind.config.ts               # Configuração Tailwind CSS
├── 📄 tsconfig.json                    # Configuração TypeScript
│
├── 🗄️ sistema_freelancers_ddl.sql     # Script DDL do banco de dados
│
├── 📖 banco dados.md                   # Especificação inicial do banco
├── 📖 DIAGRAMA_ER.md                   # Diagrama Entidade-Relacionamento
├── 📖 DOCKER_GUIDE.md                  # Guia completo Docker
├── 📖 DOCUMENTATION_INDEX.md           # Índice de toda documentação
├── 📖 LICENSE                          # Licença MIT
├── 📖 PROJECT_STRUCTURE.md             # Este arquivo
├── 📖 QUICK_START.md                   # Guia de início rápido
├── 📖 README.md                        # Documentação principal
└── 📖 RESUMO_BANCO_DADOS.md            # Documentação do banco
```

---

## 📊 Estatísticas do Projeto

| Categoria | Quantidade |
|-----------|------------|
| **Documentação** | 10 arquivos .md |
| **Código TypeScript** | 5+ arquivos .ts/.tsx |
| **Configuração** | 7 arquivos config |
| **Docker** | 3 arquivos |
| **SQL** | 1 arquivo DDL |
| **Total de Arquivos** | 25+ |

---

## 🎯 Arquivos Principais por Função

### 🚀 Início Rápido
```
QUICK_START.md          → Como começar em 5 minutos
README.md               → Documentação completa
.env.example            → Configuração de ambiente
```

### 💻 Desenvolvimento
```
app/layout.tsx          → Layout principal
components/Sidebar.tsx  → Menu lateral
lib/mockData.ts         → Dados de teste
types/index.ts          → Tipos TypeScript
```

### 🗄️ Banco de Dados
```
sistema_freelancers_ddl.sql  → Script DDL
RESUMO_BANCO_DADOS.md        → Documentação
DIAGRAMA_ER.md               → Diagrama ER
```

### 🐳 Docker
```
Dockerfile              → Build da imagem
docker-compose.yml      → Orquestração
DOCKER_GUIDE.md         → Guia completo
.dockerignore           → Build otimizado
```

### ⚙️ Configuração
```
package.json            → Dependências
tsconfig.json           → TypeScript
tailwind.config.ts      → Tailwind CSS
next.config.js          → Next.js
postcss.config.js       → PostCSS
```

---

## 📁 Detalhamento por Pasta

### `/app` - Next.js App Router

Estrutura do roteamento da aplicação usando o novo App Router do Next.js 14.

**Convenções:**
- `page.tsx` → Define uma rota
- `layout.tsx` → Layout compartilhado
- `loading.tsx` → Estado de carregamento
- `error.tsx` → Tratamento de erros
- `[id]/` → Rotas dinâmicas

**Rotas:**
- `/` → Dashboard
- `/clientes` → Lista de clientes
- `/clientes/[id]` → Detalhes do cliente
- `/projetos` → Lista de projetos
- `/projetos/[id]` → Detalhes do projeto
- `/atividades` → Lista de atividades
- `/atividades/[id]` → Detalhes da atividade

### `/components` - Componentes React

Componentes reutilizáveis da aplicação.

**Categorias:**
- **Layout**: Sidebar, Header, Footer
- **UI**: Button, Card, Table, Badge
- **Forms**: Input, Select, Textarea
- **Data**: ClienteCard, ProjetoCard, AtividadeCard

### `/lib` - Utilitários

Funções auxiliares e bibliotecas.

**Arquivos principais:**
- `mockData.ts` → Dados de exemplo
- `database.ts` → Conexão com banco
- `utils.ts` → Funções auxiliares
- `constants.ts` → Constantes

### `/types` - Tipos TypeScript

Definições de tipos baseadas no schema SQL.

**Tipos principais:**
- `Cliente`
- `Projeto`
- `Atividade`
- `ProjetoComCliente`
- `AtividadeCompleta`
- `EstatisticasCliente`

---

## 🔄 Fluxo de Dados

```
┌─────────────────┐
│   PostgreSQL    │
│   (Database)    │
└────────┬────────┘
         │
         │ SQL Queries
         │
┌────────▼────────┐
│  lib/database   │
│  (Connection)   │
└────────┬────────┘
         │
         │ TypeScript Types
         │
┌────────▼────────┐
│  app/ (Pages)   │
│  Next.js Routes │
└────────┬────────┘
         │
         │ Props
         │
┌────────▼────────┐
│  components/    │
│  React UI       │
└─────────────────┘
```

---

## 🎨 Estrutura de Estilos

```
app/globals.css          → Estilos base + utilitários Tailwind
tailwind.config.ts       → Tema personalizado (cores Notion)
components/*.tsx         → Estilos inline com Tailwind classes
```

**Tema de Cores:**
- **Notion Colors**: Tons de cinza inspirados no Notion
- **Primary**: Azul (#2563eb)
- **Accent**: Red, Blue, Green, Yellow, Purple, Pink

---

## 📦 Dependências Principais

### Produção
```json
{
  "next": "^14.2.0",
  "react": "^18.3.0",
  "react-dom": "^18.3.0",
  "lucide-react": "^0.400.0"
}
```

### Desenvolvimento
```json
{
  "@types/node": "^20",
  "@types/react": "^18",
  "@types/react-dom": "^18",
  "typescript": "^5",
  "tailwindcss": "^3.4.4",
  "autoprefixer": "^10.4.19",
  "postcss": "^8.4.38"
}
```

---

## 🚀 Scripts NPM

```bash
npm run dev      # Desenvolvimento (http://localhost:3000)
npm run build    # Build para produção
npm run start    # Servidor de produção
npm run lint     # Linter ESLint
```

---

## 🔐 Arquivos Sensíveis (.gitignore)

**Nunca commitar:**
- `.env` e `.env.local`
- `node_modules/`
- `.next/`
- `*.log`

**Commitar:**
- `.env.example`
- Todos os arquivos de configuração
- Documentação

---

## 📝 Convenções de Nomenclatura

### Arquivos
- **Componentes**: `PascalCase.tsx` (ex: `Sidebar.tsx`)
- **Utilitários**: `camelCase.ts` (ex: `mockData.ts`)
- **Páginas**: `page.tsx` (convenção Next.js)
- **Documentação**: `UPPER_SNAKE_CASE.md`

### Variáveis
- **Componentes**: `PascalCase`
- **Funções**: `camelCase`
- **Constantes**: `UPPER_SNAKE_CASE`
- **Tipos**: `PascalCase`

### Banco de Dados
- **Tabelas**: `snake_case` (ex: `clientes`)
- **Colunas**: `snake_case` (ex: `nome_projeto`)
- **Views**: `vw_` prefix (ex: `vw_projetos_clientes`)

---

## 🔄 Ciclo de Vida de Desenvolvimento

```
1. Clone          → git clone
2. Install        → npm install
3. Configure      → .env
4. Database       → PostgreSQL setup
5. Development    → npm run dev
6. Build          → npm run build
7. Test           → Manual testing
8. Docker Build   → docker build
9. Deploy         → docker-compose up
```

---

## 📊 Métricas do Código

| Métrica | Valor |
|---------|-------|
| Linhas de Código (TS/TSX) | ~2,000+ |
| Linhas de SQL | ~400+ |
| Linhas de Documentação | ~3,000+ |
| Componentes React | 10+ |
| Páginas Next.js | 7+ |
| Tipos TypeScript | 15+ |

---

<div align="center">

**[⬆ Voltar ao README](./README.md)**

📂 Estrutura completa e documentada

</div>
