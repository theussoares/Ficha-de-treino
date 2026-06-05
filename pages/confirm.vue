<template>
  <div class="confirm-page">
    <div class="confirm-inner">
      <div class="confirm-spinner" />
      <p>Verificando sua conta...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
useSeoMeta({ robots: 'noindex,nofollow' })

const supabase = useSupabaseClient()

onMounted(async () => {
  // O cliente Supabase detecta automaticamente o token no hash da URL
  // e troca por uma sessão válida
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    await navigateTo('/dashboard')
  } else {
    // Aguarda brevemente o exchange do token (pode estar em processamento)
    setTimeout(async () => {
      const { data: { session: s2 } } = await supabase.auth.getSession()
      await navigateTo(s2 ? '/dashboard' : '/login?error=confirm_failed')
    }, 2000)
  }
})
</script>

<style scoped>
.confirm-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg);
}
.confirm-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  color: var(--muted);
  font-size: 14px;
}
.confirm-spinner {
  width: 36px;
  height: 36px;
  border: 3px solid var(--border);
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
</style>
