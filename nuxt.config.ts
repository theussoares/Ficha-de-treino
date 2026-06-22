export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/supabase', '@vite-pwa/nuxt'],
  supabase: {
    redirect: false,
  },
  runtimeConfig: {
    public: {
      siteUrl: process.env.NUXT_PUBLIC_SITE_URL || 'https://fichatreino.vercel.app',
    },
  },

  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: 'FichaTreino',
      short_name: 'FichaTreino',
      description: 'Sua ficha de treino personalizada. Acesse os treinos do seu influencer favorito, marque exercícios e acompanhe o progresso.',
      theme_color: '#0a0a0c',
      background_color: '#0a0a0c',
      display: 'standalone',
      orientation: 'portrait',
      start_url: '/',
      id: '/',
      icons: [
        { src: 'icons/pwa-192x192.png', sizes: '192x192', type: 'image/png' },
        { src: 'icons/pwa-512x512.png', sizes: '512x512', type: 'image/png' },
        { src: 'icons/pwa-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' },
      ],
    },
    workbox: {
      navigateFallback: null,
      globPatterns: ['**/*.{js,css,html,svg,png,ico,woff2}'],
      runtimeCaching: [
        {
          urlPattern: /^https:\/\/fonts\.(googleapis|gstatic)\.com\/.*/i,
          handler: 'CacheFirst',
          options: {
            cacheName: 'google-fonts',
            expiration: { maxEntries: 20, maxAgeSeconds: 60 * 60 * 24 * 365 },
            cacheableResponse: { statuses: [0, 200] },
          },
        },
        {
          urlPattern: /^https?:\/\/[^/]+\/((?!_nuxt|api|\.)[^?]*)?$/,
          handler: 'NetworkFirst',
          options: {
            cacheName: 'pages',
            networkTimeoutSeconds: 5,
            expiration: { maxEntries: 20, maxAgeSeconds: 60 * 60 * 24 * 7 },
            cacheableResponse: { statuses: [0, 200] },
          },
        },
      ],
    },
    client: {
      installPrompt: false,
    },
    devOptions: {
      enabled: false,
    },
  },

  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      title: 'FichaTreino — Plataforma para influencers fitness',
      meta: [
        { name: 'description', content: 'Monte sua ficha de treino personalizada e compartilhe com seus seguidores. Treinos PPL, Upper/Lower e muito mais.' },
        { name: 'theme-color', content: '#0a0a0c' },
        { name: 'mobile-web-app-capable', content: 'yes' },
        { name: 'apple-mobile-web-app-capable', content: 'yes' },
        { name: 'apple-mobile-web-app-status-bar-style', content: 'black-translucent' },
        { name: 'apple-mobile-web-app-title', content: 'FichaTreino' },
        { property: 'og:site_name', content: 'FichaTreino' },
        { property: 'og:type', content: 'website' },
        { property: 'og:image', content: '/og.png' },
        { property: 'og:image:width', content: '1200' },
        { property: 'og:image:height', content: '630' },
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:image', content: '/og.png' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;600&display=swap',
        },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' },
        { rel: 'icon', type: 'image/svg+xml', href: '/icon.svg' },
        { rel: 'icon', type: 'image/png', sizes: '192x192', href: '/icons/pwa-192x192.png' },
      ],
    },
  },
})
