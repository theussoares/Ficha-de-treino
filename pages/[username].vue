<template>
  <!-- Loading -->
  <div v-if="pageState === 'loading'" class="pub-state">
    <div class="pub-spinner" />
  </div>

  <!-- Not found -->
  <div v-else-if="pageState === 'notfound'" class="pub-state">
    <div class="pub-404">
      <span class="pub-404-code">404</span>
      <p class="pub-404-msg">Nenhuma ficha encontrada para <strong>@{{ username }}</strong></p>
      <a href="/login" class="pub-404-link">Criar minha ficha →</a>
    </div>
  </div>

  <!-- Main workout view -->
  <div v-else class="app">
    <header class="header">
      <div class="header-top">
        <div>
          <p class="header-label">Ficha de {{ displayName }}</p>
          <h1 class="header-title">FICHA<br><span>TREINO</span></h1>
        </div>
        <div class="pub-badge">@{{ username }}</div>
      </div>
      <p class="header-quote">"O tempo recompensa aqueles que não negociam com a própria desistência."</p>
    </header>

    <!-- Week Nav -->
    <nav class="week-nav">
      <button
        v-for="d in days"
        :key="d.key"
        :class="['day-btn', { rest: d.rest, active: selectedKey === d.key, completed: isDayCompleted(d.key) }]"
        @click="!d.rest && select(d.key)"
      >
        <span class="day-name">{{ d.short }}</span>
        <span class="day-letter">{{ d.letter }}</span>
        <span class="day-tag">{{ d.tag }}</span>
        <span class="done-dot" />
      </button>
    </nav>

    <!-- Today Strip -->
    <div class="today-strip">
      <div class="today-info">
        <span class="today-label">Hoje é</span>
        <span class="today-day">{{ DAY_NAMES[todayKey] }}</span>
      </div>
      <div class="progress-ring">
        <svg viewBox="0 0 48 48">
          <circle class="track" cx="24" cy="24" r="20" />
          <circle
            class="fill"
            cx="24" cy="24" r="20"
            stroke-dasharray="125.66"
            :stroke-dashoffset="ringOffset"
          />
        </svg>
        <span class="progress-pct">{{ progressPct }}</span>
      </div>
    </div>

    <!-- Content -->
    <main class="content">
      <!-- Rest day -->
      <div v-if="!selectedWorkout" class="rest-card">
        <div class="rest-icon">😴</div>
        <div class="rest-title">DIA DE DESCANSO</div>
        <p class="rest-sub">Recuperação faz parte do processo.<br>Descanse, hidrate-se, durma bem.</p>
      </div>

      <!-- Workout -->
      <template v-else>
        <div class="workout-header">
          <div class="workout-title-block">
            <span class="workout-type-tag">Treino {{ selectedWorkout.letter }}</span>
            <h2 class="workout-name">{{ selectedWorkout.name }}</h2>
            <p class="workout-count">{{ doneCount }}/{{ totalCount }} exercícios concluídos · {{ selectedWorkout.subtitle }}</p>
          </div>
          <button
            :class="['complete-all-btn', { 'all-done': allDone }]"
            @click="markAll(selectedKey)"
          >
            {{ allDone ? 'Desfazer' : 'Tudo feito' }}
          </button>
        </div>

        <div class="exercise-list">
          <div
            v-for="(ex, i) in selectedWorkout.exercises"
            :key="i"
            :class="['exercise-card', { done: isDone(i) }]"
            @click="toggle(selectedKey, i)"
          >
            <span class="ex-number">{{ String(i + 1).padStart(2, '0') }}</span>
            <div class="ex-body">
              <div class="ex-name">{{ ex.name }}</div>
              <div v-if="ex.sets || ex.reps || ex.rest || ex.note" class="ex-details">
                <span v-if="ex.sets" class="ex-badge">{{ ex.sets }} séries</span>
                <span v-if="ex.reps" class="ex-badge">{{ ex.reps }} reps</span>
                <span v-if="ex.rest" class="ex-badge">{{ ex.rest }} descanso</span>
                <span v-if="ex.note?.toLowerCase().includes('progressão')" class="ex-badge highlight">↑ Carga</span>
                <span v-if="ex.note?.toLowerCase().includes('drop')" class="ex-badge highlight">Drop Set</span>
              </div>
              <p v-if="ex.note" class="ex-note">{{ ex.note }}</p>
            </div>
            <button v-if="ex.note || ex.rest" class="ex-info-btn" @click.stop="infoExercise = ex" title="Mais informações">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            </button>
            <div class="ex-checkbox">
              <span class="checkmark">✓</span>
            </div>
          </div>
        </div>

        <div v-if="allDone" class="completion-banner">
          <div class="cb-emoji">🔥</div>
          <div class="cb-title">TREINO COMPLETO!</div>
          <p class="cb-sub">Treino {{ selectedWorkout.name }} finalizado. Missão cumprida.</p>
        </div>

        <button class="reset-btn" @click="reset(selectedKey)">Reiniciar treino</button>
      </template>
    </main>

    <!-- Progress bar bottom -->
    <div class="bottom-line" :style="{ transform: `scaleX(${progressFraction})` }" />

    <!-- Exercise info modal -->
    <ExerciseInfoModal
      v-if="infoExercise"
      :exercise="infoExercise"
      @close="infoExercise = null"
    />
  </div>
</template>

<script setup lang="ts">
import { DAYS_CONFIG, DAY_NAMES, type Exercise } from '~/composables/useWorkout'

const route = useRoute()
const config = useRuntimeConfig()
const username = (route.params.username as string).toLowerCase()

const { workouts, schedule, doneState, loadPublic, getScheduledWorkout, getDone, toggle, markAll, reset } = useWorkoutDb()

const pageState = ref<'loading' | 'ready' | 'notfound'>('loading')
const displayName = ref('')
const infoExercise = ref<Exercise | null>(null)

// Fetch leve para SSR — só o que o Google precisa
const { data: seoProfile } = await useAsyncData(`seo-${username}`, async () => {
  const client = useSupabaseClient()
  const { data } = await client
    .from('profiles')
    .select('display_name')
    .eq('username', username)
    .single()
  return data as { display_name: string } | null
})

useSeoMeta({
  title: () => seoProfile.value
    ? `Ficha de ${seoProfile.value.display_name} | FichaTreino`
    : 'FichaTreino',
  description: () => seoProfile.value
    ? `Acesse a ficha de treino de ${seoProfile.value.display_name}. Exercícios, séries e repetições detalhados para cada dia da semana.`
    : 'Página não encontrada.',
  ogTitle: () => seoProfile.value
    ? `Ficha de ${seoProfile.value.display_name} | FichaTreino`
    : 'FichaTreino',
  ogDescription: () => seoProfile.value
    ? `Confira os treinos de ${seoProfile.value.display_name} — séries, reps e observações de cada exercício.`
    : '',
  ogUrl: `${config.public.siteUrl}/${username}`,
  twitterTitle: () => seoProfile.value
    ? `Ficha de ${seoProfile.value.display_name} | FichaTreino`
    : 'FichaTreino',
  robots: () => seoProfile.value ? 'index,follow' : 'noindex,nofollow',
})

useHead({
  link: [{ rel: 'canonical', href: `${config.public.siteUrl}/${username}` }],
})

onMounted(async () => {
  const result = await loadPublic(username)
  if (!result) {
    pageState.value = 'notfound'
  } else {
    displayName.value = result.displayName
    pageState.value = 'ready'
  }
})

// Day logic
const jsDay = new Date().getDay()
const keyOrder = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
const todayKey = keyOrder[jsDay]
const selectedKey = ref(todayKey)

function select(key: string) { selectedKey.value = key }

const days = computed(() => DAYS_CONFIG.map(d => {
  const w = getScheduledWorkout(d.key)
  return { ...d, letter: w?.letter ?? '—', tag: w?.name ?? 'Descanso', rest: !w }
}))

const selectedWorkout = computed(() => getScheduledWorkout(selectedKey.value))
const doneSet = computed(() => getDone(selectedKey.value))
const doneCount = computed(() => doneSet.value.size)
const totalCount = computed(() => selectedWorkout.value?.exercises.length ?? 0)
const allDone = computed(() => totalCount.value > 0 && doneCount.value === totalCount.value)

function isDone(idx: number) { return doneSet.value.has(idx) }

function isDayCompleted(key: string) {
  const w = getScheduledWorkout(key)
  if (!w) return false
  const done = getDone(key)
  return done.size === w.exercises.length && w.exercises.length > 0
}

const progressFraction = computed(() => totalCount.value ? doneCount.value / totalCount.value : 0)
const ringOffset = computed(() => 125.66 * (1 - progressFraction.value))
const progressPct = computed(() => totalCount.value ? `${Math.round(progressFraction.value * 100)}%` : '—')

watch([workouts, schedule, doneState], () => {}, { deep: true })
</script>

<style scoped>
.pub-state {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg);
}
.pub-spinner {
  width: 36px; height: 36px;
  border: 3px solid var(--border);
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.pub-404 { text-align: center; padding: 0 24px; }
.pub-404-code {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 80px;
  color: var(--border);
  line-height: 1;
  display: block;
}
.pub-404-msg { color: var(--muted); font-size: 15px; margin-top: 8px; }
.pub-404-link {
  display: inline-block;
  margin-top: 20px;
  color: var(--accent);
  text-decoration: none;
  font-size: 14px;
  font-weight: 600;
}
.pub-404-link:hover { text-decoration: underline; }

.pub-badge {
  background: var(--surface2);
  border: 1.5px solid var(--border);
  border-radius: 8px;
  padding: 6px 12px;
  font-size: 12px;
  color: var(--muted);
  flex-shrink: 0;
  margin-top: 6px;
  font-family: 'DM Sans', sans-serif;
}
</style>
