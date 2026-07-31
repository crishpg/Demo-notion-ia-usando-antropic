/** @type {import('next').NextConfig} */
const nextConfig = {
  // Habilitar output standalone para Docker
  output: 'standalone',
  
  // Configurações de otimização
  reactStrictMode: true,
  
  // Configurações de imagem (se usar next/image)
  images: {
    domains: [],
  },
}

module.exports = nextConfig
