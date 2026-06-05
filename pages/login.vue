<template>
  <div class="auth-page">
    <div class="auth-card">
      <!-- Logo -->
      <div class="auth-logo">
        <span class="auth-logo-text">FICHA<span>TREINO</span></span>
        <p class="auth-logo-sub">Plataforma para influencers fitness</p>
      </div>

      <!-- Tabs -->
      <div class="auth-tabs">
        <button :class="['auth-tab', { active: mode === 'login' }]" @click="mode = 'login'; error = ''">Entrar</button>
        <button :class="['auth-tab', { active: mode === 'signup' }]" @click="mode = 'signup'; error = ''">Criar conta</button>
      </div>

      <!-- Login Form -->
      <form v-if="mode === 'login'" class="auth-form" @submit.prevent="handleLogin">
        <div class="form-field">
          <label class="form-label">Email</label>
          <input v-model="email" type="email" class="form-input" placeholder="seu@email.com" required autocomplete="email" />
        </div>
        <div class="form-field">
          <label class="form-label">Senha</label>
          <input v-model="password" type="password" class="form-input" placeholder="••••••••" required autocomplete="current-password" />
        </div>
        <div v-if="error" class="auth-error">{{ error }}</div>
        <button type="submit" class="btn-primary" :disabled="submitting">
          {{ submitting ? 'Entrando...' : 'Entrar' }}
        </button>
      </form>

      <!-- Signup Form -->
      <form v-else class="auth-form" @submit.prevent="handleSignup">
        <div class="form-field">
          <label class="form-label">Seu nome</label>
          <input v-model="displayName" type="text" class="form-input" placeholder="João Silva" required maxlength="60" />
        </div>
        <div class="form-field">
          <label class="form-label">Username <span class="label-hint">(URL pública: meusite.com/<em>username</em>)</span></label>
          <input
            v-model="username"
            type="text"
            class="form-input"
            placeholder="joaosilva"
            required
            maxlength="30"
            pattern="[a-z0-9_-]{3,30}"
            @input="username = username.toLowerCase().replace(/[^a-z0-9_-]/g, '')"
          />
          <span v-if="username" class="field-preview">/{{ username }}</span>
        </div>
        <div class="form-field">
          <label class="form-label">Email</label>
          <input v-model="email" type="email" class="form-input" placeholder="seu@email.com" required autocomplete="email" />
        </div>
        <div class="form-field">
          <label class="form-label">Senha <span class="label-hint">(mín. 6 caracteres)</span></label>
          <input v-model="password" type="password" class="form-input" placeholder="••••••••" required minlength="6" autocomplete="new-password" />
        </div>
        <div v-if="error" class="auth-error">{{ error }}</div>
        <div v-if="successMsg" class="auth-success">{{ successMsg }}</div>
        <button type="submit" class="btn-primary" :disabled="submitting || !!successMsg">
          {{ submitting ? 'Criando conta...' : 'Criar conta' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
useSeoMeta({ robots: 'noindex,nofollow', title: 'Entrar | FichaTreino' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()

if (user.value) {
  await navigateTo('/dashboard')
}

const mode = ref<'login' | 'signup'>('login')

const email       = ref('')
const password    = ref('')
const displayName = ref('')
const username    = ref('')

const submitting = ref(false)
const error      = ref('')
const successMsg = ref('')

async function handleLogin() {
  error.value = ''
  submitting.value = true
  try {
    const { error: err } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
    if (err) { error.value = err.message; return }
    await navigateTo('/dashboard')
  } finally {
    submitting.value = false
  }
}

async function handleSignup() {
  error.value = ''
  successMsg.value = ''

  if (!username.value || username.value.length < 3) {
    error.value = 'Username deve ter pelo menos 3 caracteres.'
    return
  }

  // Verifica se username já existe
  submitting.value = true
  try {
    const { data: existing } = await supabase
      .from('profiles')
      .select('id')
      .eq('username', username.value)
      .maybeSingle()

    if (existing) {
      error.value = `O username "${username.value}" já está em uso.`
      return
    }

    const { data, error: err } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
      options: {
        data: {
          username: username.value,
          display_name: displayName.value,
        },
        emailRedirectTo: `${window.location.origin}/confirm`,
      },
    })

    if (err) { error.value = err.message; return }

    // Cria profile manualmente (o trigger é backup)
    if (data.user) {
      await supabase.from('profiles').upsert({
        id: data.user.id,
        username: username.value,
        display_name: displayName.value,
      })
    }

    successMsg.value = `Conta criada! Verifique seu email (${email.value}) para confirmar o cadastro.`
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: var(--bg);
}

.auth-card {
  width: 100%;
  max-width: 420px;
}

.auth-logo { margin-bottom: 32px; }
.auth-logo-text {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 48px;
  letter-spacing: 2px;
  line-height: 1;
  display: block;
}
.auth-logo-text span { color: var(--accent); }
.auth-logo-sub { font-size: 12px; color: var(--muted); margin-top: 4px; }

.auth-tabs {
  display: flex;
  gap: 4px;
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: 12px;
  padding: 4px;
  margin-bottom: 24px;
}

.auth-tab {
  flex: 1;
  padding: 9px;
  border: none;
  border-radius: 9px;
  background: transparent;
  color: var(--muted);
  font-family: 'DM Sans', sans-serif;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.auth-tab.active { background: var(--surface2); color: var(--text); }

.auth-form { display: flex; flex-direction: column; gap: 0; }

.label-hint { font-weight: 400; text-transform: none; letter-spacing: 0; font-size: 10px; }

.field-preview {
  display: block;
  margin-top: 5px;
  font-size: 12px;
  color: var(--accent);
  font-family: 'DM Sans', sans-serif;
}

.auth-error {
  background: rgba(255,68,68,0.1);
  border: 1px solid rgba(255,68,68,0.3);
  color: #ff6666;
  border-radius: 8px;
  padding: 10px 14px;
  font-size: 13px;
  margin-bottom: 12px;
  line-height: 1.4;
}

.auth-success {
  background: rgba(200,240,0,0.08);
  border: 1px solid rgba(200,240,0,0.3);
  color: var(--accent);
  border-radius: 8px;
  padding: 12px 14px;
  font-size: 13px;
  margin-bottom: 12px;
  line-height: 1.5;
}
</style>
