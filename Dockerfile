# ==================================
# Build Stage
# ==================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar arquivos de dependências
# package-lock.json é incluído quando presente (melhora cache)
COPY package*.json ./

# Instalar TODAS as dependências (dev incluído — necessário para o build Next.js)
# Usa npm install pois package-lock.json pode não existir no repositório
RUN npm install && npm cache clean --force

# Copiar código fonte
COPY . .

# Garantir que o diretório public existe (Next.js não o cria se não houver assets)
RUN mkdir -p public

# Build da aplicação Next.js (gera .next/standalone)
RUN npm run build

# ==================================
# Production Stage
# ==================================
FROM node:18-alpine AS runner

WORKDIR /app

# Configurar ambiente de produção
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Criar usuário não-root para segurança
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copiar arquivos públicos
COPY --from=builder /app/public ./public

# Copiar build output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Mudar para usuário não-root
USER nextjs

# Expor porta
EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando de inicialização
CMD ["node", "server.js"]
