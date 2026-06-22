<template>
  <Teleport to="body">
    <Transition name="pwa-slide">
      <div v-if="visible" class="pwa-backdrop" @click.self="dismiss">
        <div class="pwa-box">
          <!-- Header -->
          <div class="pwa-header">
            <div class="pwa-app-icon">
              <img src="/icons/pwa-192x192.png" alt="FichaTreino" width="52" height="52" />
            </div>
            <div class="pwa-app-info">
              <div class="pwa-app-name">FichaTreino</div>
              <div class="pwa-app-sub">Instale e use sem internet</div>
            </div>
            <button class="pwa-close" @click="dismiss" aria-label="Fechar">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
          </div>

          <!-- Steps - iOS -->
          <template v-if="platform === 'ios'">
            <p class="pwa-intro">Adicione à sua tela inicial para abrir como app:</p>
            <div class="pwa-steps">
              <div class="pwa-step">
                <span class="pwa-step-num">1</span>
                <div class="pwa-step-content">
                  <span>Toque em</span>
                  <span class="pwa-ios-share">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>
                  </span>
                  <span>na barra inferior do Safari</span>
                </div>
              </div>
              <div class="pwa-step">
                <span class="pwa-step-num">2</span>
                <div class="pwa-step-content">
                  Role e toque em <strong>"Adicionar à Tela de Início"</strong>
                </div>
              </div>
              <div class="pwa-step">
                <span class="pwa-step-num">3</span>
                <div class="pwa-step-content">
                  Toque em <strong>"Adicionar"</strong> no canto superior direito
                </div>
              </div>
            </div>
            <button class="pwa-btn-got-it" @click="dismiss">Entendi!</button>
          </template>

          <!-- Android / Chrome — native prompt available -->
          <template v-else-if="platform === 'android' && deferredPrompt">
            <p class="pwa-intro">Instale o FichaTreino como app e acesse seus treinos mesmo sem internet.</p>
            <div class="pwa-features">
              <div class="pwa-feature"><span>⚡</span> Abre em menos de 1 segundo</div>
              <div class="pwa-feature"><span>📶</span> Funciona sem internet</div>
              <div class="pwa-feature"><span>🏠</span> Ícone direto na tela inicial</div>
            </div>
            <button class="pwa-btn-install" @click="triggerInstall">
              Instalar app
            </button>
            <button class="pwa-btn-later" @click="dismiss">Agora não</button>
          </template>

          <!-- Desktop Chrome / Edge -->
          <template v-else-if="deferredPrompt">
            <p class="pwa-intro">Instale o FichaTreino no seu computador para acesso rápido e offline.</p>
            <button class="pwa-btn-install" @click="triggerInstall">
              Instalar no computador
            </button>
            <button class="pwa-btn-later" @click="dismiss">Agora não</button>
          </template>

          <!-- Generic fallback -->
          <template v-else>
            <p class="pwa-intro">Adicione à sua tela inicial para acesso rápido e uso offline.</p>
            <p class="pwa-hint">No seu navegador, procure a opção <strong>"Adicionar à tela inicial"</strong> ou <strong>"Instalar app"</strong> no menu.</p>
            <button class="pwa-btn-got-it" @click="dismiss">Entendi</button>
          </template>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
const STORAGE_KEY = 'pwa_banner_dismissed_at'
const DISMISS_TTL = 7 * 24 * 60 * 60 * 1000 // 7 dias

const visible = ref(false)
const platform = ref<'ios' | 'android' | 'desktop'>('desktop')
const deferredPrompt = ref<Event | null>(null)

function isStandalone() {
  return (
    window.matchMedia('(display-mode: standalone)').matches ||
    (window.navigator as any).standalone === true
  )
}

function wasDismissedRecently() {
  try {
    const ts = localStorage.getItem(STORAGE_KEY)
    if (!ts) return false
    return Date.now() - Number(ts) < DISMISS_TTL
  } catch {
    return false
  }
}

function dismiss() {
  visible.value = false
  try { localStorage.setItem(STORAGE_KEY, String(Date.now())) } catch {}
}

async function triggerInstall() {
  if (!deferredPrompt.value) return
  const prompt = deferredPrompt.value as any
  prompt.prompt()
  const { outcome } = await prompt.userChoice
  deferredPrompt.value = null
  visible.value = false
  if (outcome === 'accepted') {
    try { localStorage.setItem(STORAGE_KEY, String(Date.now() + DISMISS_TTL * 52)) } catch {}
  }
}

onMounted(() => {
  if (!import.meta.client) return
  if (isStandalone() || wasDismissedRecently()) return

  // Detect platform
  const ua = navigator.userAgent
  const isIos = /iphone|ipad|ipod/i.test(ua)
  const isAndroid = /android/i.test(ua)
  platform.value = isIos ? 'ios' : isAndroid ? 'android' : 'desktop'

  // Capture Chrome install prompt
  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault()
    deferredPrompt.value = e
  }, { once: true })

  // Show after 4 seconds
  setTimeout(() => {
    if (isStandalone() || wasDismissedRecently()) return
    visible.value = true
  }, 4000)
})
</script>

<style scoped>
.pwa-backdrop {
  position: fixed;
  inset: 0;
  z-index: 500;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  background: rgba(0, 0, 0, 0.55);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  padding: 0;
}

@media (min-height: 600px) {
  .pwa-backdrop { padding: 0 16px 24px; }
}

.pwa-box {
  background: var(--surface2);
  border: 1.5px solid var(--border);
  border-radius: 24px 24px 0 0;
  width: 100%;
  max-width: 480px;
  padding: 24px 24px 32px;
}

@media (min-height: 600px) {
  .pwa-box { border-radius: 20px; }
}

/* ── Header ── */
.pwa-header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 18px;
}

.pwa-app-icon img {
  border-radius: 14px;
  border: 2px solid var(--border);
}

.pwa-app-info { flex: 1; }

.pwa-app-name {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px;
  letter-spacing: 1.5px;
  color: var(--text);
}

.pwa-app-sub {
  font-size: 12px;
  color: var(--muted);
  margin-top: 1px;
}

.pwa-close {
  background: var(--surface);
  border: 1.5px solid var(--border);
  color: var(--muted);
  border-radius: 8px;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;
}
.pwa-close:hover { border-color: var(--text); color: var(--text); }

/* ── Body ── */
.pwa-intro {
  font-size: 14px;
  color: var(--text);
  line-height: 1.5;
  margin-bottom: 16px;
}

.pwa-hint {
  font-size: 13px;
  color: var(--muted);
  line-height: 1.5;
  margin-bottom: 20px;
}

/* ── iOS steps ── */
.pwa-steps {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 20px;
}

.pwa-step {
  display: flex;
  align-items: center;
  gap: 12px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 10px 14px;
  font-size: 13px;
  color: var(--text);
  line-height: 1.4;
}

.pwa-step-num {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 20px;
  color: var(--accent);
  flex-shrink: 0;
  width: 20px;
  text-align: center;
}

.pwa-step-content {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px;
}

.pwa-ios-share {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #0a84ff;
  color: #fff;
  border-radius: 6px;
  width: 28px;
  height: 28px;
  flex-shrink: 0;
}

/* ── Features list ── */
.pwa-features {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 20px;
}

.pwa-feature {
  font-size: 13px;
  color: var(--muted);
  display: flex;
  align-items: center;
  gap: 8px;
}

.pwa-feature span:first-child { font-size: 16px; }

/* ── Buttons ── */
.pwa-btn-install {
  width: 100%;
  background: var(--accent);
  color: #0a0a0c;
  border: none;
  border-radius: 12px;
  padding: 14px;
  font-family: 'DM Sans', sans-serif;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 0.5px;
  cursor: pointer;
  transition: opacity 0.2s;
  margin-bottom: 10px;
}
.pwa-btn-install:hover { opacity: 0.9; }

.pwa-btn-got-it {
  width: 100%;
  background: var(--accent);
  color: #0a0a0c;
  border: none;
  border-radius: 12px;
  padding: 14px;
  font-family: 'DM Sans', sans-serif;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 0.2s;
}
.pwa-btn-got-it:hover { opacity: 0.9; }

.pwa-btn-later {
  width: 100%;
  background: transparent;
  border: 1.5px solid var(--border);
  color: var(--muted);
  border-radius: 12px;
  padding: 12px;
  font-family: 'DM Sans', sans-serif;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}
.pwa-btn-later:hover { border-color: var(--text); color: var(--text); }

/* ── Transition ── */
.pwa-slide-enter-active,
.pwa-slide-leave-active {
  transition: transform 0.35s cubic-bezier(0.32, 0.72, 0, 1);
}
.pwa-slide-enter-from,
.pwa-slide-leave-to {
  transform: translateY(100%);
}
</style>
