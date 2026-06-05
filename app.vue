<template>
  <!-- Main View -->
  <div v-if="currentView === 'main'" class="app">
    <header class="header">
      <div class="header-top">
        <div>
          <p class="header-label">Divisão PPL + Upper + Lower</p>
          <h1 class="header-title">FICHA<br><span>TREINO</span></h1>
        </div>
        <button class="manage-btn" @click="currentView = 'manage'" title="Gerenciar treinos">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="3"/>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
          </svg>
        </button>
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
              <div v-if="ex.sets || ex.reps || ex.note" class="ex-details">
                <span v-if="ex.sets" class="ex-badge">{{ ex.sets }} séries</span>
                <span v-if="ex.reps" class="ex-badge">{{ ex.reps }} reps</span>
                <span v-if="ex.note?.toLowerCase().includes('progressão')" class="ex-badge highlight">↑ Carga</span>
                <span v-if="ex.note?.toLowerCase().includes('drop')" class="ex-badge highlight">Drop Set</span>
              </div>
              <p v-if="ex.note" class="ex-note">{{ ex.note }}</p>
            </div>
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
  </div>

  <!-- Manage View -->
  <ManageView
    v-else-if="currentView === 'manage'"
    @back="currentView = 'main'"
    @edit-workout="id => openWorkoutEditor(id)"
    @new-workout="openWorkoutEditor(null)"
  />

  <!-- Workout Editor View -->
  <WorkoutEditorView
    v-else-if="currentView === 'workout-editor'"
    :workout-id="editingWorkoutId"
    @back="currentView = 'manage'"
    @saved="currentView = 'manage'"
  />
</template>

<script setup lang="ts">
import { DAYS_CONFIG, DAY_NAMES, useWorkoutStore } from '~/composables/useWorkout'

const { workouts, schedule, doneState, load, getScheduledWorkout, getDone, toggle, markAll, reset } = useWorkoutStore()

onMounted(() => load())

const currentView = ref<'main' | 'manage' | 'workout-editor'>('main')
const editingWorkoutId = ref<string | null>(null)

function openWorkoutEditor(id: string | null) {
  editingWorkoutId.value = id
  currentView.value = 'workout-editor'
}

const jsDay = new Date().getDay()
const keyOrder = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
const todayKey = keyOrder[jsDay]

const selectedKey = ref(todayKey)

function select(key: string) {
  selectedKey.value = key
}

const days = computed(() => DAYS_CONFIG.map(d => {
  const w = getScheduledWorkout(d.key)
  return {
    ...d,
    letter: w?.letter ?? '—',
    tag: w?.name ?? 'Descanso',
    rest: !w,
  }
}))

const selectedWorkout = computed(() => getScheduledWorkout(selectedKey.value))

const doneSet = computed(() => getDone(selectedKey.value))
const doneCount = computed(() => doneSet.value.size)
const totalCount = computed(() => selectedWorkout.value?.exercises.length ?? 0)
const allDone = computed(() => totalCount.value > 0 && doneCount.value === totalCount.value)

function isDone(idx: number) {
  return doneSet.value.has(idx)
}

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

<style>
*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

:root {
  --bg: #0a0a0c;
  --surface: #111114;
  --surface2: #18181d;
  --border: #222228;
  --accent: #c8f000;
  --text: #f0f0f0;
  --muted: #666672;
  --done-bg: #1a2500;
  --done-border: #4a7a00;
}

html, body {
  background: var(--bg);
  color: var(--text);
  font-family: 'DM Sans', sans-serif;
  min-height: 100vh;
  overflow-x: hidden;
  -webkit-font-smoothing: antialiased;
}

.app {
  max-width: 600px;
  margin: 0 auto;
  min-height: 100vh;
  position: relative;
  padding-bottom: 80px;
}

/* HEADER */
.header { padding: 36px 24px 0; }
.header-top { display: flex; align-items: flex-start; justify-content: space-between; }
.header-label { font-size: 11px; letter-spacing: 3px; color: var(--muted); text-transform: uppercase; margin-bottom: 4px; }
.header-title { font-family: 'Bebas Neue', sans-serif; font-size: clamp(52px, 14vw, 96px); line-height: 0.9; letter-spacing: 2px; }
.header-title span { color: var(--accent); }
.header-quote { margin-top: 14px; font-size: 12px; color: var(--muted); font-style: italic; max-width: 360px; line-height: 1.6; border-left: 2px solid var(--accent); padding-left: 10px; }

.manage-btn {
  background: var(--surface2); border: 1.5px solid var(--border); color: var(--muted);
  border-radius: 10px; width: 42px; height: 42px; display: flex; align-items: center;
  justify-content: center; cursor: pointer; transition: all 0.2s; flex-shrink: 0; margin-top: 6px;
}
.manage-btn:hover { border-color: var(--accent); color: var(--accent); background: #1a2000; }

/* WEEK NAV */
.week-nav { display: flex; gap: 8px; padding: 28px 24px 0; overflow-x: auto; scrollbar-width: none; }
.week-nav::-webkit-scrollbar { display: none; }

.day-btn {
  flex-shrink: 0; display: flex; flex-direction: column; align-items: center; gap: 4px;
  padding: 12px 14px; border-radius: 12px; border: 1.5px solid var(--border);
  background: var(--surface); cursor: pointer; transition: all 0.2s; min-width: 60px;
  position: relative; color: var(--text);
}
.day-btn:hover:not(.rest) { border-color: var(--accent); background: var(--surface2); }
.day-btn.active:not(.rest) { border-color: var(--accent); background: #1a2000; }
.day-btn.active .day-letter { color: var(--accent); }
.day-btn.rest { opacity: 0.4; cursor: default; }
.day-name { font-size: 10px; text-transform: uppercase; letter-spacing: 1px; color: var(--muted); font-weight: 600; }
.day-letter { font-family: 'Bebas Neue', sans-serif; font-size: 22px; line-height: 1; }
.day-tag { font-size: 8px; letter-spacing: 0.5px; color: var(--muted); text-transform: uppercase; }
.done-dot { position: absolute; top: 6px; right: 6px; width: 7px; height: 7px; border-radius: 50%; background: var(--accent); display: none; }
.day-btn.completed .done-dot { display: block; }

/* TODAY STRIP */
.today-strip { margin: 20px 24px 0; padding: 12px 16px; background: var(--surface2); border-radius: 10px; border: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
.today-info { display: flex; flex-direction: column; gap: 2px; }
.today-label { font-size: 10px; letter-spacing: 2px; text-transform: uppercase; color: var(--muted); }
.today-day { font-family: 'Bebas Neue', sans-serif; font-size: 20px; letter-spacing: 1px; }

.progress-ring { width: 48px; height: 48px; position: relative; }
.progress-ring svg { transform: rotate(-90deg); width: 100%; height: 100%; }
.progress-ring circle { fill: none; stroke-width: 3; }
.progress-ring .track { stroke: var(--border); }
.progress-ring .fill { stroke: var(--accent); stroke-linecap: round; transition: stroke-dashoffset 0.4s ease; }
.progress-pct { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; color: var(--accent); }

/* CONTENT */
.content { padding: 20px 24px 0; }

/* REST */
.rest-card { text-align: center; padding: 60px 0; }
.rest-icon { font-size: 48px; margin-bottom: 16px; }
.rest-title { font-family: 'Bebas Neue', sans-serif; font-size: 36px; color: var(--muted); letter-spacing: 2px; }
.rest-sub { margin-top: 8px; font-size: 14px; color: var(--muted); line-height: 1.6; }

/* WORKOUT HEADER */
.workout-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 20px; gap: 12px; }
.workout-type-tag { display: inline-block; font-size: 10px; letter-spacing: 2px; text-transform: uppercase; color: var(--accent); background: #1a2000; border: 1px solid var(--accent); padding: 3px 9px; border-radius: 99px; margin-bottom: 6px; }
.workout-name { font-family: 'Bebas Neue', sans-serif; font-size: 40px; letter-spacing: 1px; line-height: 1; }
.workout-count { font-size: 13px; color: var(--muted); margin-top: 4px; }

.complete-all-btn { flex-shrink: 0; padding: 10px 16px; border-radius: 10px; border: 1.5px solid var(--accent); background: transparent; color: var(--accent); font-family: 'DM Sans', sans-serif; font-size: 12px; font-weight: 600; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.2s; white-space: nowrap; }
.complete-all-btn:hover, .complete-all-btn.all-done { background: var(--accent); color: #0a0a0c; }

/* EXERCISE CARDS */
.exercise-list { display: flex; flex-direction: column; gap: 10px; }
.exercise-card { background: var(--surface); border: 1.5px solid var(--border); border-radius: 14px; padding: 16px 18px; display: flex; align-items: center; gap: 14px; cursor: pointer; transition: all 0.2s; user-select: none; }
.exercise-card:hover { border-color: #333340; background: var(--surface2); }
.exercise-card.done { background: var(--done-bg); border-color: var(--done-border); }
.exercise-card.done .ex-name { color: var(--muted); text-decoration: line-through; text-decoration-color: var(--accent); }
.ex-number { font-family: 'Bebas Neue', sans-serif; font-size: 22px; color: var(--border); flex-shrink: 0; width: 24px; text-align: center; transition: color 0.2s; }
.exercise-card.done .ex-number { color: var(--done-border); }
.ex-body { flex: 1; min-width: 0; }
.ex-name { font-size: 15px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; transition: color 0.2s; }
.ex-details { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
.ex-badge { font-size: 10px; padding: 3px 8px; border-radius: 6px; background: var(--surface2); border: 1px solid var(--border); color: var(--muted); font-weight: 500; }
.ex-badge.highlight { background: #1a1a00; border-color: #555500; color: #cccc00; }
.ex-note { font-size: 11px; color: var(--muted); margin-top: 5px; font-style: italic; line-height: 1.4; }
.ex-checkbox { width: 24px; height: 24px; border-radius: 7px; border: 2px solid var(--border); flex-shrink: 0; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
.exercise-card.done .ex-checkbox { background: var(--accent); border-color: var(--accent); }
.checkmark { opacity: 0; transition: opacity 0.2s; color: #0a0a0c; font-size: 13px; font-weight: 700; }
.exercise-card.done .checkmark { opacity: 1; }

/* COMPLETION */
.completion-banner { margin-top: 20px; padding: 20px; background: var(--done-bg); border: 1.5px solid var(--done-border); border-radius: 14px; text-align: center; }
.cb-emoji { font-size: 32px; }
.cb-title { font-family: 'Bebas Neue', sans-serif; font-size: 28px; color: var(--accent); letter-spacing: 2px; margin-top: 4px; }
.cb-sub { font-size: 13px; color: var(--muted); margin-top: 4px; }

/* RESET */
.reset-btn { display: block; margin: 16px auto 0; padding: 8px 20px; border-radius: 8px; border: 1px solid var(--border); background: transparent; color: var(--muted); font-family: 'DM Sans', sans-serif; font-size: 12px; cursor: pointer; transition: all 0.2s; }
.reset-btn:hover { border-color: #ff4444; color: #ff4444; }

/* BOTTOM LINE */
.bottom-line { position: fixed; bottom: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, var(--accent), #8aff00); transform-origin: left; transition: transform 0.5s ease; }

/* ── Shared overlay page ── */
.ov-page { max-width: 600px; margin: 0 auto; min-height: 100vh; padding-bottom: 60px; }
.ov-topbar { display: flex; align-items: center; gap: 12px; padding: 20px 24px 16px; border-bottom: 1px solid var(--border); position: sticky; top: 0; background: var(--bg); z-index: 10; }
.ov-back { background: none; border: none; color: var(--muted); cursor: pointer; display: flex; align-items: center; gap: 6px; font-family: 'DM Sans', sans-serif; font-size: 14px; padding: 6px 0; transition: color 0.2s; flex-shrink: 0; }
.ov-back:hover { color: var(--text); }
.ov-title { font-family: 'Bebas Neue', sans-serif; font-size: 26px; letter-spacing: 2px; flex: 1; }
.ov-section { padding: 24px 24px 0; }
.ov-section-label { font-size: 10px; letter-spacing: 3px; text-transform: uppercase; color: var(--muted); font-weight: 600; margin-bottom: 14px; }

/* ── Shared form ── */
.form-field { margin-bottom: 16px; }
.form-label { display: block; font-size: 10px; letter-spacing: 2px; text-transform: uppercase; color: var(--muted); margin-bottom: 6px; }
.form-input { width: 100%; background: var(--surface); border: 1.5px solid var(--border); color: var(--text); border-radius: 10px; padding: 12px 14px; font-family: 'DM Sans', sans-serif; font-size: 15px; transition: border-color 0.2s; }
.form-input:focus { outline: none; border-color: var(--accent); }
.form-input::placeholder { color: var(--muted); }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
.form-row .form-field { margin-bottom: 0; }

/* ── Shared buttons ── */
.btn-primary { background: var(--accent); color: #0a0a0c; border: none; border-radius: 10px; padding: 14px 24px; font-family: 'DM Sans', sans-serif; font-size: 14px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: opacity 0.2s; width: 100%; }
.btn-primary:hover { opacity: 0.9; }
.btn-primary:disabled { opacity: 0.4; cursor: not-allowed; }
.btn-ghost { background: transparent; border: 1.5px solid var(--border); color: var(--muted); border-radius: 10px; padding: 14px 24px; font-family: 'DM Sans', sans-serif; font-size: 14px; cursor: pointer; transition: all 0.2s; width: 100%; }
.btn-ghost:hover { border-color: var(--text); color: var(--text); }
.btn-icon { background: var(--surface2); border: 1.5px solid var(--border); color: var(--muted); border-radius: 8px; width: 34px; height: 34px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s; flex-shrink: 0; font-size: 14px; }
.btn-icon:hover { border-color: var(--accent); color: var(--accent); }
.btn-icon.danger:hover { border-color: #ff4444; color: #ff4444; }
.btn-icon:disabled { opacity: 0.25; cursor: not-allowed; }
.btn-icon:disabled:hover { border-color: var(--border); color: var(--muted); }

/* ── Confirm dialog ── */
.confirm-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.75); display: flex; align-items: center; justify-content: center; z-index: 200; padding: 24px; }
.confirm-box { background: var(--surface2); border: 1.5px solid var(--border); border-radius: 16px; padding: 24px; max-width: 340px; width: 100%; }
.confirm-title { font-family: 'Bebas Neue', sans-serif; font-size: 24px; letter-spacing: 1px; margin-bottom: 8px; }
.confirm-msg { font-size: 14px; color: var(--muted); line-height: 1.5; margin-bottom: 20px; }
.confirm-actions { display: flex; gap: 10px; }
.confirm-actions .btn-ghost, .confirm-actions .btn-danger-sm { padding: 10px 18px; font-size: 13px; width: auto; flex: 1; }
.btn-danger-sm { background: transparent; border: 1.5px solid #ff4444; color: #ff4444; border-radius: 10px; font-family: 'DM Sans', sans-serif; cursor: pointer; transition: all 0.2s; }
.btn-danger-sm:hover { background: #ff4444; color: #fff; }
</style>
