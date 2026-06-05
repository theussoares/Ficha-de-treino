export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/supabase'],
  supabase: {
    redirect: false, // gerenciado manualmente via middleware
  },
  app: {
    head: {
      title: 'Ficha de Treino',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Ficha de treino PPL + Upper + Lower' },
        { name: 'theme-color', content: '#0a0a0c' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Bebas+Neue&family=DM+Sans:wght@300;400;500;600&display=swap',
        },
      ],
    },
  },
})
