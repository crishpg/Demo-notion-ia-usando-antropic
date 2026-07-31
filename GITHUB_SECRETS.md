# Variáveis de Ambiente — GitHub Actions

Este documento descreve **todos os secrets e variables** que devem ser configurados
no GitHub para que o pipeline CI/CD funcione corretamente.

---

## Onde configurar

No repositório GitHub acesse:

```
Settings → Secrets and variables → Actions
```

Existem dois tipos:

| Tipo | Aba | Visível nos logs? | Criptografado? |
|------|-----|:-----------------:|:--------------:|
| **Secret** | Secrets | ❌ Nunca | ✅ Sim |
| **Variable** | Variables | ✅ Sim | ❌ Não |

> Use **Secrets** para senhas, tokens e chaves SSH.
> Use **Variables** para configurações não sensíveis (porta, usuário do banco, etc.).

---

## Secrets obrigatórios — Deploy SSH

Necessários para o job `deploy` conectar ao servidor e executar o `scripts/deploy.sh`.

| Nome do Secret | Descrição | Exemplo |
|----------------|-----------|---------|
| `SSH_HOST` | IP ou domínio do servidor Ubuntu 22.04 | `203.0.113.10` |
| `SSH_USER` | Usuário SSH que executa o deploy | `ubuntu` ou `cloud_user` |
| `SSH_PRIVATE_KEY` | Chave privada SSH completa (incluindo cabeçalho) | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `SSH_PORT` | Porta SSH do servidor | `22` |

### Como gerar a chave SSH para o deploy

Execute na sua máquina local:

```bash
# Gerar par de chaves dedicado para o GitHub Actions
ssh-keygen -t ed25519 -C "github-actions-deploy" \
  -f ~/.ssh/deploy_key -N ""

# Copiar a chave PÚBLICA para o servidor
ssh-copy-id -i ~/.ssh/deploy_key.pub USUARIO@IP_DO_SERVIDOR

# Exibir a chave PRIVADA (copiar para o secret SSH_PRIVATE_KEY)
cat ~/.ssh/deploy_key
```

Cole o conteúdo **inteiro** da chave privada no secret `SSH_PRIVATE_KEY`, incluindo:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...conteúdo...
-----END OPENSSH PRIVATE KEY-----
```

---

## Secrets obrigatórios — Banco de Dados

Usados para criar o arquivo `.env` no servidor durante o deploy.

| Nome do Secret | Descrição | Valor padrão (NÃO use em produção) |
|----------------|-----------|-------------------------------------|
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | `freelancer123` |
| `PGADMIN_PASSWORD` | Senha do painel PgAdmin | `admin` |

---

## Secrets opcionais — Integrações

| Nome do Secret | Descrição | Obrigatório |
|----------------|-----------|:-----------:|
| `NOTION_TOKEN` | Token de integração do Notion (formato: `ntn_xxx...`) | ❌ |

---

## Variables (não sensíveis)

Configure em **Secrets and variables → Actions → Variables**.

| Nome da Variable | Descrição | Valor sugerido |
|-----------------|-----------|---------------|
| `POSTGRES_USER` | Usuário do PostgreSQL | `freelancer` |
| `POSTGRES_DB` | Nome do banco de dados | `sistema_freelancers` |
| `POSTGRES_PORT` | Porta do PostgreSQL | `5432` |
| `APP_PORT` | Porta da aplicação Next.js | `3000` |
| `NODE_ENV` | Ambiente de execução | `production` |

---

## Ambiente "production" (Environment)

O job de deploy usa o ambiente `production` do GitHub, que permite configurar
secrets exclusivos por ambiente e regras de aprovação manual.

### Como criar

```
Settings → Environments → New environment → "production"
```

Opções recomendadas para produção:

- ✅ **Required reviewers** — exige aprovação antes do deploy
- ✅ **Wait timer** — aguarda N minutos após o merge
- ✅ **Deployment branches** — restringir apenas à branch `main`

> Os secrets SSH e banco podem ser definidos no nível do repositório
> **ou** dentro do ambiente `production`. Se definidos nos dois, o
> ambiente tem prioridade.

---

## Resumo visual — onde cada valor vai parar

```
GitHub Secrets / Variables
         │
         ▼
.github/workflows/deploy.yml
         │
         ├── SSH_HOST, SSH_USER, SSH_PORT, SSH_PRIVATE_KEY
         │         └──▶ Conexão SSH ao servidor
         │
         └── POSTGRES_PASSWORD, PGADMIN_PASSWORD, NOTION_TOKEN
                   └──▶ Geração do arquivo .env no servidor
                              └──▶ docker-compose.yml lê o .env
                                        └──▶ containers recebem as variáveis
```

---

## Checklist de configuração

Antes de fazer o primeiro push para `main`, confirme:

- [ ] Secret `SSH_HOST` criado com o IP do servidor
- [ ] Secret `SSH_USER` criado com o usuário SSH
- [ ] Secret `SSH_PRIVATE_KEY` criado com a chave privada completa
- [ ] Secret `SSH_PORT` criado (geralmente `22`)
- [ ] Secret `POSTGRES_PASSWORD` criado com senha forte
- [ ] Secret `PGADMIN_PASSWORD` criado com senha forte
- [ ] Chave pública adicionada ao `~/.ssh/authorized_keys` do servidor
- [ ] Ambiente `production` criado em Settings → Environments
- [ ] Testado conexão SSH manual: `ssh -i ~/.ssh/deploy_key USUARIO@HOST`

---

## Troubleshooting

### Erro: `Host key verification failed`
O servidor não está no `known_hosts` do runner. O workflow já executa
`ssh-keyscan` automaticamente, mas se persistir, verifique se `SSH_HOST`
está correto.

### Erro: `Permission denied (publickey)`
A chave pública não foi adicionada ao servidor ou o `SSH_USER` está errado.
Verifique com:
```bash
ssh -i ~/.ssh/deploy_key -v USUARIO@HOST
```

### Erro: `Environment production not found`
Crie o ambiente em: **Settings → Environments → New environment → "production"**

### Deploy não dispara após push
Confirme que a branch é exatamente `main` ou `master` (configurado no workflow).
Verifique em **Actions** se o workflow está habilitado.
