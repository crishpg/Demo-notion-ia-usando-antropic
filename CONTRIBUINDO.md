# 🤝 Guia de Contribuição - Sistema Para Freelancers

Obrigado por considerar contribuir para o Sistema Para Freelancers! Este guia ajudará você a começar.

---

## 📋 Índice

- [Como Contribuir](#como-contribuir)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Padrões de Código](#padrões-de-código)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Fluxo de Trabalho](#fluxo-de-trabalho)
- [Testes](#testes)
- [Documentação](#documentação)
- [Code Review](#code-review)

---

## 🚀 Como Contribuir

### Tipos de Contribuições

Aceitamos diversos tipos de contribuições:

- 🐛 **Bug Fixes**: Correção de bugs e problemas
- ✨ **Features**: Novas funcionalidades
- 📝 **Documentação**: Melhorias na documentação
- 🎨 **UI/UX**: Melhorias de interface
- ⚡ **Performance**: Otimizações
- ♿ **Acessibilidade**: Melhorias de a11y
- 🔒 **Segurança**: Correções de segurança

### Antes de Começar

1. ✅ Verifique se já existe uma [issue](https://github.com/seu-usuario/Demo-notion-ia-usando-antropic/issues) relacionada
2. ✅ Se não existir, crie uma issue descrevendo o problema/feature
3. ✅ Aguarde feedback antes de começar a codificar
4. ✅ Faça fork do repositório
5. ✅ Clone seu fork localmente

---

## ⚙️ Configuração do Ambiente

### 1. Clone e Instale

```bash
# Clone seu fork
git clone https://github.com/seu-usuario/Demo-notion-ia-usando-antropic.git
cd Demo-notion-ia-usando-antropic

# Adicione o upstream
git remote add upstream https://github.com/original-usuario/Demo-notion-ia-usando-antropic.git

# Instale dependências
npm install
```

### 2. Configure o Banco de Dados

```bash
# Opção 1: Docker (Recomendado)
docker-compose up -d postgres

# Opção 2: PostgreSQL Local
createdb sistema_freelancers
psql -d sistema_freelancers -f sistema_freelancers_ddl.sql
```

### 3. Configure Variáveis de Ambiente

```bash
# Copie o exemplo
cp .env.example .env

# Edite o .env com suas configurações
# Se usar Docker, as configurações padrão já funcionam
```

### 4. Inicie o Servidor de Desenvolvimento

```bash
npm run dev
```

Acesse: http://localhost:3000

---

## 📝 Padrões de Código

### TypeScript

```typescript
// ✅ BOM
interface Cliente {
  id: string;
  nome: string;
  email: string | null;
}

function getClienteById(id: string): Cliente | undefined {
  return clientes.find(c => c.id === id);
}

// ❌ RUIM
function getCliente(id) {
  return clientes.find(c => c.id === id);
}
```

### Componentes React

```tsx
// ✅ BOM
interface CardProps {
  title: string;
  description?: string;
  onClick?: () => void;
}

export default function Card({ title, description, onClick }: CardProps) {
  return (
    <div onClick={onClick} className="p-4 bg-white rounded-lg">
      <h3 className="font-semibold">{title}</h3>
      {description && <p className="text-gray-600">{description}</p>}
    </div>
  );
}

// ❌ RUIM
export default function Card({ title, description, onClick }) {
  return <div onClick={onClick}><h3>{title}</h3><p>{description}</p></div>;
}
```

### Tailwind CSS

```tsx
// ✅ BOM - Classes organizadas
<div className="flex items-center justify-between p-4 bg-white border border-gray-200 rounded-lg hover:shadow-md">

// ❌ RUIM - Classes desorganizadas
<div className="p-4 flex bg-white items-center rounded-lg hover:shadow-md border-gray-200 border justify-between">
```

### Nomenclatura

| Tipo | Convenção | Exemplo |
|------|-----------|---------|
| **Componentes** | PascalCase | `ClienteCard.tsx` |
| **Funções** | camelCase | `getClienteById()` |
| **Constantes** | UPPER_SNAKE_CASE | `MAX_ITEMS_PER_PAGE` |
| **Tipos/Interfaces** | PascalCase | `interface Cliente {}` |
| **Arquivos Utils** | camelCase | `dateUtils.ts` |
| **Database** | snake_case | `nome_projeto` |

### Comentários

```typescript
// ✅ BOM - Comentários úteis
/**
 * Busca um cliente pelo ID e retorna seus projetos ativos
 * @param id - UUID do cliente
 * @returns Cliente com projetos ou undefined se não encontrado
 */
function getClienteComProjetos(id: string): ClienteComProjetos | undefined {
  // Implementação
}

// ❌ RUIM - Comentários óbvios
// Busca cliente
function getCliente(id: string) {
  return clientes.find(c => c.id === id); // Retorna o cliente
}
```

---

## 📁 Estrutura do Projeto

### Onde Adicionar Código

| Tipo de Arquivo | Localização |
|-----------------|-------------|
| **Páginas** | `app/[modulo]/page.tsx` |
| **Componentes UI** | `components/ui/` |
| **Componentes de Negócio** | `components/` |
| **Utilitários** | `lib/utils.ts` |
| **Tipos** | `types/index.ts` |
| **Constantes** | `lib/constants.ts` |
| **Estilos Globais** | `app/globals.css` |

### Exemplo de Nova Feature

Para adicionar um módulo de "Contratos":

```
1. Criar tipos em types/index.ts
   └── export interface Contrato { ... }

2. Criar página em app/contratos/page.tsx
   └── Lista de contratos

3. Criar página de detalhes em app/contratos/[id]/page.tsx
   └── Detalhes do contrato

4. Criar componentes em components/
   └── ContratoCard.tsx
   └── ContratoForm.tsx

5. Adicionar dados mock em lib/mockData.ts
   └── export const contratos: Contrato[] = [...]

6. Atualizar Sidebar.tsx
   └── Adicionar link para /contratos

7. Atualizar banco de dados
   └── Adicionar tabela em sistema_freelancers_ddl.sql
   └── Documentar em RESUMO_BANCO_DADOS.md
```

---

## 🔄 Fluxo de Trabalho

### 1. Criar Branch

```bash
# Sempre crie a partir da main atualizada
git checkout main
git pull upstream main

# Nomeie a branch de forma descritiva
git checkout -b feature/nome-da-feature
# ou
git checkout -b fix/nome-do-bug
# ou
git checkout -b docs/nome-da-doc
```

### 2. Desenvolver

```bash
# Faça commits pequenos e frequentes
git add .
git commit -m "feat: adiciona componente ClienteCard"

# Use conventional commits
# feat: nova feature
# fix: correção de bug
# docs: documentação
# style: formatação
# refactor: refatoração
# test: testes
# chore: tarefas gerais
```

### 3. Sincronizar

```bash
# Mantenha sua branch atualizada
git fetch upstream
git rebase upstream/main
```

### 4. Push e PR

```bash
# Push para seu fork
git push origin feature/nome-da-feature

# Abra um Pull Request no GitHub
# Use o template fornecido
# Descreva as mudanças claramente
```

---

## 🧪 Testes

### Antes de Submeter PR

```bash
# Build da aplicação
npm run build

# Verifique erros de TypeScript
npm run lint

# Teste localmente
npm run dev
# Teste manualmente todas as mudanças
```

### Checklist de Testes

- [ ] Build sem erros
- [ ] Sem warnings do TypeScript
- [ ] Componentes renderizam corretamente
- [ ] Funciona em Chrome, Firefox, Safari
- [ ] Responsivo (mobile, tablet, desktop)
- [ ] Sem erros no console
- [ ] Performance adequada

### Testes Manuais

1. **Desktop**: 1920x1080
2. **Tablet**: 768x1024
3. **Mobile**: 375x667

---

## 📚 Documentação

### Quando Documentar

- ✅ Novas features
- ✅ Mudanças em APIs
- ✅ Novos componentes públicos
- ✅ Alterações no banco de dados
- ✅ Configurações Docker

### Como Documentar

```markdown
# Título Claro

## Descrição
Breve descrição da funcionalidade

## Uso
\`\`\`typescript
// Exemplo de código
import { Component } from './Component';

<Component prop="value" />
\`\`\`

## Props/Parâmetros
| Nome | Tipo | Descrição |
|------|------|-----------|
| prop | string | Descrição |

## Exemplos
Exemplos práticos de uso
```

### Arquivos a Atualizar

- `README.md` - Se mudanças principais
- `RESUMO_BANCO_DADOS.md` - Se mudanças no banco
- `DOCKER_GUIDE.md` - Se mudanças no Docker
- `INTEGRACAO_NOTION.md` - Se mudanças na integração
- Comentários no código - Sempre

---

## 👀 Code Review

### O que Avaliar

**Como Revisor:**
- ✅ Código segue os padrões
- ✅ Testes passam
- ✅ Documentação atualizada
- ✅ Sem bugs óbvios
- ✅ Performance adequada
- ✅ Acessibilidade

**Como Autor:**
- ✅ Auto-review antes de submeter
- ✅ Descrição clara do PR
- ✅ Screenshots se mudanças visuais
- ✅ Responda comentários rapidamente
- ✅ Faça mudanças solicitadas

### Feedback Construtivo

```markdown
# ✅ BOM
"Sugiro usar `useMemo` aqui para evitar re-renderizações desnecessárias.
Exemplo: `const value = useMemo(() => heavyCalculation(), [deps]);`"

# ❌ RUIM
"Esse código está ruim, refaça."
```

---

## 📦 Pull Request Template

```markdown
## Descrição
Breve descrição das mudanças

## Tipo de Mudança
- [ ] Bug fix
- [ ] Nova feature
- [ ] Breaking change
- [ ] Documentação

## Checklist
- [ ] Build passa
- [ ] Lint passa
- [ ] Testes manuais feitos
- [ ] Documentação atualizada
- [ ] Responsivo
- [ ] Acessível

## Screenshots (se aplicável)
[Adicionar screenshots]

## Como Testar
1. Passo 1
2. Passo 2
3. Passo 3

## Issues Relacionadas
Closes #123
```

---

## 🐛 Reportar Bugs

### Template de Issue

```markdown
## Descrição do Bug
Descrição clara e concisa

## Como Reproduzir
1. Vá para '...'
2. Clique em '...'
3. Role até '...'
4. Veja o erro

## Comportamento Esperado
O que deveria acontecer

## Screenshots
Se aplicável

## Ambiente
- OS: [ex: Windows 11]
- Browser: [ex: Chrome 120]
- Versão: [ex: 1.0.0]

## Contexto Adicional
Qualquer outra informação relevante
```

---

## 💡 Sugerir Features

### Template de Feature Request

```markdown
## Problema
Descreva o problema que essa feature resolve

## Solução Proposta
Descrição clara da solução

## Alternativas
Outras soluções consideradas

## Contexto Adicional
Screenshots, mockups, etc.
```

---

## 🎯 Prioridades do Projeto

### Alta Prioridade
- 🐛 Bugs críticos
- 🔒 Problemas de segurança
- ♿ Problemas de acessibilidade
- 📱 Problemas de responsividade

### Média Prioridade
- ✨ Novas features planejadas
- ⚡ Melhorias de performance
- 📝 Documentação faltante

### Baixa Prioridade
- 🎨 Melhorias estéticas
- 🧹 Refatorações não urgentes
- ✅ Nice-to-have features

---

## 📞 Contato

Dúvidas sobre contribuição?

- **Issues**: [GitHub Issues](https://github.com/seu-usuario/Demo-notion-ia-usando-antropic/issues)
- **Discussões**: [GitHub Discussions](https://github.com/seu-usuario/Demo-notion-ia-usando-antropic/discussions)

---

## 📜 Código de Conduta

### Nossa Promessa

Criamos um ambiente respeitoso e inclusivo para todos.

### Comportamento Esperado
- ✅ Seja respeitoso
- ✅ Aceite críticas construtivas
- ✅ Foque no que é melhor para o projeto
- ✅ Mostre empatia

### Comportamento Inaceitável
- ❌ Assédio ou discriminação
- ❌ Linguagem ofensiva
- ❌ Ataques pessoais
- ❌ Comportamento não profissional

---

## 🙏 Agradecimentos

Obrigado por contribuir! Cada contribuição, grande ou pequena, faz diferença.

---

<div align="center">

**[⬆ Voltar ao README](./README.md)**

🤝 Contribua para tornar este projeto ainda melhor!

</div>
