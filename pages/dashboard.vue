<template>
  <div>
    <!-- Loading -->
    <div v-if="loading" class="dash-loading">
      <div class="dash-spinner" />
    </div>

    <template v-else>
      <!-- Manage view -->
      <div v-if="view === 'manage'" class="ov-page">
        <div class="ov-topbar dash-topbar">
          <div class="dash-brand">
            <span class="dash-title">FICHA<span>TREINO</span></span>
            <span class="dash-greeting">Olá, {{ profile?.displayName }}</span>
          </div>
          <div class="dash-actions">
            <a v-if="profile" :href="`/${profile.username}`" target="_blank" class="btn-share" title="Ver ficha pública">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
              /{{ profile.username }}
            </a>
            <button class="btn-icon" @click="handleLogout" title="Sair">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            </button>
          </div>
        </div>

        <!-- Conteúdo do manage sem topbar próprio -->
        <ManageView
          :show-back="false"
          @new-workout="openEditor(null)"
          @edit-workout="id => openEditor(id)"
        />
      </div>

      <!-- Workout Editor -->
      <WorkoutEditorView
        v-else-if="view === 'workout-editor'"
        :workout-id="editingId"
        @back="view = 'manage'"
        @saved="view = 'manage'"
      />
    </template>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ middleware: 'auth' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { loadDashboard, loading } = useWorkoutDb()

const view = ref<'manage' | 'workout-editor'>('manage')
const editingId = ref<string | null>(null)
const profile = ref<{ username: string; displayName: string } | null>(null)

onMounted(async () => {
  const { data } = await supabase
    .from('profiles')
    .select('username, display_name')
    .eq('id', user.value!.id)
    .single() as { data: { username: string; display_name: string } | null }

  if (data) {
    profile.value = { username: data.username, displayName: data.display_name }
  }

  await loadDashboard()
})

function openEditor(id: string | null) {
  editingId.value = id
  view.value = 'workout-editor'
}

async function handleLogout() {
  await supabase.auth.signOut()
  await navigateTo('/login')
}
</script>

<style scoped>
.dash-loading {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
}

.dash-spinner {
  width: 36px; height: 36px;
  border: 3px solid var(--border);
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.dash-topbar {
  justify-content: space-between;
}

.dash-brand {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.dash-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 26px;
  letter-spacing: 2px;
  line-height: 1;
}
.dash-title span { color: var(--accent); }

.dash-greeting {
  font-size: 11px;
  color: var(--muted);
}

.dash-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-share {
  display: flex;
  align-items: center;
  gap: 6px;
  background: transparent;
  border: 1.5px solid var(--accent);
  color: var(--accent);
  border-radius: 8px;
  padding: 7px 12px;
  font-family: 'DM Sans', sans-serif;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  transition: all 0.2s;
  white-space: nowrap;
}
.btn-share:hover { background: var(--accent); color: #0a0a0c; }
</style>
