# ⚡ Quick Start - Sistema Para Freelancers

Comece a usar em menos de 5 minutos!

---

## 🎯 Opção 1: Docker (Recomendado)

### Pré-requisito
- Docker instalado

### Passos

```bash
# 1. Clone
git clone https://github.com/seu-usuario/Demo-notion-ia-usando-antropic.git
cd Demo-notion-ia-usando-antropic

# 2. Configure (opcional - já vem configurado)
cp .env.example .env

# 3. Inicie
docker-compose up -d

# 4. Acesse
# http://localhost:3000
```

### Pronto! 🎉

Veja logs: `docker-compose logs -f`  
Pare: `docker-compose down`

---

## 💻 Opção 2: Local

### Pré-requisitos
- Node.js 18+
- PostgreSQL 14+

### Passos

```bash
# 1. Clone
git clone https://github.com/seu-usuario/Demo-notion-ia-usando-antropic.git
cd Demo-notion-ia-usando-antropic

# 2. Instale dependências
npm install

# 3. Configure banco
createdb sistema_freelancers
psql -d sistema_freelancers -f sistema_freelancers_ddl.sql

# 4. Configure .env
cp .env.example .env
# Edite DATABASE_URL

# 5. Inicie
npm run dev

# 6. Acesse
# http://localhost:3000
```

---

## 📚 Documentação Completa

- **[README.md](./README.md)** - Documentação principal
- **[DOCKER_GUIDE.md](./DOCKER_GUIDE.md)** - Guia Docker detalhado
- **[RESUMO_BANCO_DADOS.md](./RESUMO_BANCO_DADOS.md)** - Documentação do banco
- **[DIAGRAMA_ER.md](./DIAGRAMA_ER.md)** - Diagrama do banco
- **[INTEGRACAO_NOTION.md](./INTEGRACAO_NOTION.md)** - Integração Notion

---

## 🐛 Problemas?

### Porta em uso
```bash
# Mude no .env
APP_PORT=3001
```

### Banco não conecta
```bash
# Verifique logs
docker-compose logs postgres
```

### Rebuild necessário
```bash
docker-compose up -d --build
```

---

## 📞 Precisa de Ajuda?

1. Consulte [README.md](./README.md)
2. Veja [DOCKER_GUIDE.md](./DOCKER_GUIDE.md)
3. Abra uma issue

---

**Desenvolvido com ❤️ para freelancers**
