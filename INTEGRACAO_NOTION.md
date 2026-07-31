# 🔗 Integração com Notion - Sistema Para Freelancers

Guia completo para integrar o Sistema Para Freelancers com o Notion usando Model Context Protocol (MCP).

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Configuração](#configuração)
- [Model Context Protocol (MCP)](#model-context-protocol-mcp)
- [Casos de Uso](#casos-de-uso)
- [API Notion](#api-notion)
- [Sincronização](#sincronização)
- [Troubleshooting](#troubleshooting)
- [Limitações](#limitações)

---

## 🎯 Visão Geral

Este projeto foi desenvolvido com base em uma página do Notion, permitindo sincronização e integração nativa com a plataforma.

### Página de Referência

**URL**: [Sistema Para Freelancers no Notion](https://app.notion.com/p/Sistema-Para-Freelancers-a4d2a76472be826bbbe28129ea70fdb5)

### Estrutura no Notion

O sistema foi baseado em 3 databases do Notion:

1. **Clientes** (Database ID: `d942a764-72be-831a-81eb-0132a732e71a`)
   - Nome (title)
   - E-mail (rich_text)
   - Telefone (phone_number)
   - Instagram (url)
   - Drive (url)

2. **Projetos** (Database ID: `aaf2a764-72be-826b-89c1-0118af897eba`)
   - Nome do Projeto (title)
   - Cliente (relation → Clientes)
   - Timeline (date range)
   - Status (status)
   - Lançado (checkbox)

3. **Atividades** (Database ID: `bf62a764-72be-83d5-8762-01b923f10c0c`)
   - Nome (title)
   - Projetos (relation → Projetos)
   - Status (status)
   - Prioridade (select)
   - Data inicio (date)
   - Data Fim (date)

---

## 🔧 Pré-requisitos

### 1. Conta Notion

- Conta Notion ativa (gratuita ou paga)
- Acesso às páginas que deseja integrar

### 2. Integração Notion

Você precisará criar uma integração interna no Notion:

1. Acesse [Notion Integrations](https://www.notion.so/my-integrations)
2. Clique em **"+ New integration"**
3. Configure:
   - **Name**: Sistema Freelancers Integration
   - **Associated workspace**: Seu workspace
   - **Capabilities**:
     - ✅ Read content
     - ✅ Update content
     - ✅ Insert content
4. Clique em **"Submit"**
5. Copie o **Internal Integration Token** (começa com `secret_` ou `ntn_`)

### 3. Compartilhar Páginas

Para que a integração acesse suas páginas:

1. Abra a página do Notion
2. Clique em **"..."** (três pontos) no canto superior direito
3. Clique em **"Add connections"**
4. Selecione sua integração **"Sistema Freelancers Integration"**
5. Clique em **"Confirm"**

Repita para todas as páginas/databases que deseja integrar.

---

## ⚙️ Configuração

### Model Context Protocol (MCP)

Este projeto utiliza o **Notion MCP Server** para comunicação com a API do Notion.

#### 1. Arquivo de Configuração Workspace

Edite o arquivo `.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": [
        "-y",
        "@notionhq/notion-mcp-server"
      ],
      "env": {
        "NOTION_API_KEY": "seu_token_aqui"
      },
      "disabled": false,
      "autoApprove": [
        "search_objects",
        "read_page",
        "read_database",
        "query_database"
      ]
    }
  }
}
```

**Substitua** `seu_token_aqui` pelo token da sua integração.

#### 2. Arquivo de Configuração Usuário (Opcional)

Para usar em todos os projetos, crie `~/.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": [
        "-y",
        "@notionhq/notion-mcp-server"
      ],
      "env": {
        "NOTION_API_KEY": "seu_token_aqui"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

#### 3. Variáveis de Ambiente (Alternativa)

Adicione no arquivo `.env`:

```env
NOTION_TOKEN=seu_token_aqui
```

E configure o MCP para ler do ambiente:

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "${NOTION_TOKEN}"
      }
    }
  }
}
```

### Teste a Configuração

Execute um teste simples via Kiro Agent ou código:

```typescript
// Teste de conexão
import { Client } from '@notionhq/client';

const notion = new Client({
  auth: process.env.NOTION_TOKEN,
});

// Listar databases
const response = await notion.search({
  filter: {
    property: 'object',
    value: 'database',
  },
});

console.log(response.results);
```

---

## 🔌 Model Context Protocol (MCP)

### O que é MCP?

O **Model Context Protocol** é um protocolo para conectar modelos de IA (como o Kiro Agent) a fontes de dados externas de forma segura e estruturada.

### Notion MCP Server

O `@notionhq/notion-mcp-server` é o servidor oficial da Notion para MCP.

#### Instalação

```bash
# Instalação global (opcional)
npm install -g @notionhq/notion-mcp-server

# Ou usar via npx (recomendado)
npx -y @notionhq/notion-mcp-server
```

#### Ferramentas Disponíveis

O MCP Server do Notion expõe várias ferramentas:

| Ferramenta | Descrição |
|------------|-----------|
| `search_objects` | Buscar páginas e databases |
| `read_page` | Ler conteúdo de uma página |
| `read_database` | Ler schema de um database |
| `query_database` | Consultar entries de um database |
| `create_page` | Criar nova página |
| `update_page` | Atualizar página existente |
| `append_block_children` | Adicionar blocos a uma página |

#### Exemplo de Uso

```typescript
// Via MCP (Kiro Agent)
const page = await mcp.notion.read_page({
  page_id: 'a4d2a76472be826bbbe28129ea70fdb5'
});

// Via API direta
const { Client } = require('@notionhq/client');
const notion = new Client({ auth: process.env.NOTION_TOKEN });

const page = await notion.pages.retrieve({
  page_id: 'a4d2a76472be826bbbe28129ea70fdb5'
});
```

---

## 💡 Casos de Uso

### 1. Importar Dados do Notion para PostgreSQL

```typescript
import { Client } from '@notionhq/client';
import { Client as PgClient } from 'pg';

const notion = new Client({ auth: process.env.NOTION_TOKEN });
const pg = new PgClient({ connectionString: process.env.DATABASE_URL });

await pg.connect();

// Buscar database de clientes
const clientes = await notion.databases.query({
  database_id: 'd942a764-72be-831a-81eb-0132a732e71a',
});

// Inserir no PostgreSQL
for (const page of clientes.results) {
  const properties = page.properties;
  
  await pg.query(
    `INSERT INTO clientes (nome, email, telefone, instagram, drive)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (nome) DO UPDATE
     SET email = EXCLUDED.email`,
    [
      properties.Nome.title[0]?.plain_text,
      properties['E-mail'].rich_text[0]?.plain_text,
      properties.Telefone.phone_number,
      properties.Instagram.url,
      properties.Drive.url,
    ]
  );
}

await pg.end();
```

### 2. Sincronizar Projetos

```typescript
// Buscar projetos do Notion
const projetos = await notion.databases.query({
  database_id: 'aaf2a764-72be-826b-89c1-0118af897eba',
});

// Atualizar no PostgreSQL
for (const page of projetos.results) {
  const props = page.properties;
  
  // Buscar cliente_id pela relação
  const clienteRelation = props.Cliente.relation[0];
  const clientePage = await notion.pages.retrieve({
    page_id: clienteRelation.id,
  });
  
  const clienteNome = clientePage.properties.Nome.title[0].plain_text;
  
  // Inserir ou atualizar projeto
  await pg.query(
    `INSERT INTO projetos (nome_projeto, cliente_id, data_inicio, data_fim, status, lancado)
     VALUES ($1, (SELECT id FROM clientes WHERE nome = $2), $3, $4, $5, $6)
     ON CONFLICT (nome_projeto) DO UPDATE
     SET status = EXCLUDED.status, lancado = EXCLUDED.lancado`,
    [
      props['Nome do Projeto'].title[0].plain_text,
      clienteNome,
      props.Timeline.date?.start,
      props.Timeline.date?.end,
      props.Status.status.name,
      props.Lançado.checkbox,
    ]
  );
}
```

### 3. Criar Página no Notion a partir do PostgreSQL

```typescript
// Buscar projeto do banco
const result = await pg.query(
  `SELECT p.*, c.nome as cliente_nome
   FROM projetos p
   JOIN clientes c ON p.cliente_id = c.id
   WHERE p.id = $1`,
  [projetoId]
);

const projeto = result.rows[0];

// Buscar database_id do cliente no Notion
const clienteSearch = await notion.search({
  query: projeto.cliente_nome,
  filter: { property: 'object', value: 'page' },
});

const clientePageId = clienteSearch.results[0].id;

// Criar página de projeto no Notion
await notion.pages.create({
  parent: {
    database_id: 'aaf2a764-72be-826b-89c1-0118af897eba',
  },
  properties: {
    'Nome do Projeto': {
      title: [{ text: { content: projeto.nome_projeto } }],
    },
    'Cliente': {
      relation: [{ id: clientePageId }],
    },
    'Timeline': {
      date: {
        start: projeto.data_inicio.toISOString().split('T')[0],
        end: projeto.data_fim.toISOString().split('T')[0],
      },
    },
    'Status': {
      status: { name: projeto.status },
    },
    'Lançado': {
      checkbox: projeto.lancado,
    },
  },
});
```

---

## 🔄 Sincronização

### Estratégias de Sincronização

#### 1. Sincronização Unidirecional (Notion → PostgreSQL)

```typescript
// Executar periodicamente (cron job)
async function syncNotionToPostgres() {
  console.log('Iniciando sincronização...');
  
  await syncClientes();
  await syncProjetos();
  await syncAtividades();
  
  console.log('Sincronização concluída!');
}

// Executar a cada 5 minutos
setInterval(syncNotionToPostgres, 5 * 60 * 1000);
```

#### 2. Sincronização Bidirecional

```typescript
// Webhook do Notion (quando disponível)
app.post('/webhook/notion', async (req, res) => {
  const { page_id, action } = req.body;
  
  if (action === 'updated') {
    await updateFromNotion(page_id);
  }
  
  res.status(200).send('OK');
});

// Trigger do PostgreSQL
CREATE OR REPLACE FUNCTION notify_notion_update()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('notion_update', json_build_object(
    'table', TG_TABLE_NAME,
    'id', NEW.id,
    'action', TG_OP
  )::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_notion
AFTER INSERT OR UPDATE ON projetos
FOR EACH ROW EXECUTE FUNCTION notify_notion_update();
```

#### 3. Sincronização Manual

```bash
# Script de sincronização
npm run sync:notion

# Ou via Docker
docker-compose exec app npm run sync:notion
```

### Script de Sincronização Completo

Crie `scripts/sync-notion.ts`:

```typescript
import { Client } from '@notionhq/client';
import { Client as PgClient } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const notion = new Client({ auth: process.env.NOTION_TOKEN });
const pg = new PgClient({ connectionString: process.env.DATABASE_URL });

async function main() {
  await pg.connect();
  
  try {
    console.log('🔄 Sincronizando Clientes...');
    await syncClientes();
    
    console.log('🔄 Sincronizando Projetos...');
    await syncProjetos();
    
    console.log('🔄 Sincronizando Atividades...');
    await syncAtividades();
    
    console.log('✅ Sincronização concluída!');
  } catch (error) {
    console.error('❌ Erro na sincronização:', error);
    process.exit(1);
  } finally {
    await pg.end();
  }
}

async function syncClientes() {
  const response = await notion.databases.query({
    database_id: 'd942a764-72be-831a-81eb-0132a732e71a',
  });
  
  for (const page of response.results) {
    const props = page.properties;
    
    await pg.query(
      `INSERT INTO clientes (nome, email, telefone, instagram, drive)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (nome) DO UPDATE
       SET email = EXCLUDED.email,
           telefone = EXCLUDED.telefone,
           instagram = EXCLUDED.instagram,
           drive = EXCLUDED.drive,
           updated_at = CURRENT_TIMESTAMP`,
      [
        props.Nome.title[0]?.plain_text || '',
        props['E-mail']?.rich_text[0]?.plain_text || null,
        props.Telefone?.phone_number || null,
        props.Instagram?.url || null,
        props.Drive?.url || null,
      ]
    );
  }
  
  console.log(`  ✓ ${response.results.length} clientes sincronizados`);
}

// Implementar syncProjetos() e syncAtividades() de forma similar

main();
```

Adicione no `package.json`:

```json
{
  "scripts": {
    "sync:notion": "ts-node scripts/sync-notion.ts"
  }
}
```

---

## 🌐 API Notion

### Client SDK

#### Instalação

```bash
npm install @notionhq/client
```

#### Uso Básico

```typescript
import { Client } from '@notionhq/client';

const notion = new Client({
  auth: process.env.NOTION_TOKEN,
});

// Buscar databases
const databases = await notion.search({
  filter: { property: 'object', value: 'database' },
});

// Ler página
const page = await notion.pages.retrieve({
  page_id: 'page-id-aqui',
});

// Query database
const results = await notion.databases.query({
  database_id: 'database-id-aqui',
  filter: {
    property: 'Status',
    status: { equals: 'Em andamento' },
  },
  sorts: [
    { property: 'Data Fim', direction: 'ascending' },
  ],
});
```

### Endpoints Principais

#### 1. Buscar Objetos

```typescript
const response = await notion.search({
  query: 'Sistema Para Freelancers',
  filter: { property: 'object', value: 'page' },
  sort: { direction: 'descending', timestamp: 'last_edited_time' },
});
```

#### 2. Ler Database

```typescript
const database = await notion.databases.retrieve({
  database_id: 'd942a764-72be-831a-81eb-0132a732e71a',
});

console.log(database.title);
console.log(database.properties);
```

#### 3. Query Database

```typescript
const query = await notion.databases.query({
  database_id: 'aaf2a764-72be-826b-89c1-0118af897eba',
  filter: {
    and: [
      { property: 'Status', status: { equals: 'Em andamento' } },
      { property: 'Lançado', checkbox: { equals: true } },
    ],
  },
  sorts: [
    { property: 'Data Fim', direction: 'ascending' },
  ],
  page_size: 100,
});
```

#### 4. Criar Página

```typescript
const newPage = await notion.pages.create({
  parent: { database_id: 'd942a764-72be-831a-81eb-0132a732e71a' },
  properties: {
    Nome: {
      title: [{ text: { content: 'Novo Cliente' } }],
    },
    'E-mail': {
      rich_text: [{ text: { content: 'cliente@email.com' } }],
    },
    Telefone: {
      phone_number: '+5511999999999',
    },
  },
});
```

#### 5. Atualizar Página

```typescript
await notion.pages.update({
  page_id: 'page-id-aqui',
  properties: {
    Status: {
      status: { name: 'Concluído' },
    },
  },
});
```

---

## 🐛 Troubleshooting

### Erro: "API token is invalid"

**Causa**: Token incorreto ou integração não configurada.

**Solução**:
1. Verifique se o token começa com `secret_` ou `ntn_`
2. Recrie a integração no [Notion Integrations](https://www.notion.so/my-integrations)
3. Copie o novo token
4. Atualize `.kiro/settings/mcp.json` ou `.env`

### Erro: "Could not find database with ID"

**Causa**: Database não foi compartilhado com a integração.

**Solução**:
1. Abra o database no Notion
2. Clique em "..." → "Add connections"
3. Selecione sua integração
4. Confirme

### Erro: "object not found"

**Causa**: Página/database foi deletado ou movido.

**Solução**:
1. Verifique se o ID está correto
2. Use `notion.search()` para encontrar o novo ID
3. Atualize as referências no código

### Erro: "rate_limited"

**Causa**: Muitas requisições em pouco tempo.

**Solução**:
```typescript
// Adicionar retry com backoff
async function notionQueryWithRetry(params: any, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      return await notion.databases.query(params);
    } catch (error) {
      if (error.code === 'rate_limited' && i < retries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        continue;
      }
      throw error;
    }
  }
}
```

### Erro: "validation_error"

**Causa**: Propriedade inválida ou tipo incorreto.

**Solução**:
1. Verifique o schema do database: `notion.databases.retrieve()`
2. Confira os tipos das propriedades
3. Use os valores corretos (ex: status válidos, formato de data correto)

---

## ⚠️ Limitações

### API Notion

- **Rate Limit**: 3 requisições por segundo (média)
- **Tamanho de Resposta**: Máximo de 100 items por página
- **Paginação**: Use `start_cursor` para buscar mais resultados
- **Filtros**: Nem todas as propriedades são filtráveis
- **Webhooks**: Ainda não disponíveis oficialmente

### MCP Server

- **Sincronização**: Não há sincronização automática em tempo real
- **Conflitos**: Sincronização bidirecional pode causar conflitos
- **Performance**: Sincronização de grandes volumes pode ser lenta

### Recomendações

✅ **Use cache** para reduzir chamadas à API  
✅ **Implemente retry** para lidar com rate limiting  
✅ **Sincronize periodicamente** em vez de em tempo real  
✅ **Valide dados** antes de enviar ao Notion  
✅ **Monitore logs** para identificar problemas  

---

## 📚 Recursos Adicionais

### Documentação Oficial

- [Notion API Documentation](https://developers.notion.com/)
- [Notion SDK for JavaScript](https://github.com/makenotion/notion-sdk-js)
- [Notion MCP Server](https://github.com/makenotion/notion-mcp-server)

### Tutoriais

- [Getting Started with Notion API](https://developers.notion.com/docs/getting-started)
- [Working with Databases](https://developers.notion.com/docs/working-with-databases)
- [Property Values](https://developers.notion.com/reference/property-value-object)

### Exemplos

- [Notion SDK Examples](https://github.com/makenotion/notion-sdk-js/tree/main/examples)
- [Notion API Examples](https://developers.notion.com/docs/examples)

---

## 🤝 Contribuindo

Encontrou um problema na integração ou tem uma sugestão?

1. Abra uma [issue](https://github.com/seu-usuario/Demo-notion-ia-usando-antropic/issues)
2. Descreva o problema/sugestão
3. Inclua logs e exemplos de código

---

<div align="center">

**[⬆ Voltar ao README](./README.md)**

🔗 Integração completa com Notion

</div>
