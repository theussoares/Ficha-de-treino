<template>
  <div class="ov-page">
    <!-- Top bar (apenas no modo overlay) -->
    <div v-if="showBack" class="ov-topbar">
      <button class="ov-back" @click="$emit('back')">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 15l-7-7 7-7" transform="rotate(180 12 12)"/></svg>
        Voltar
      </button>
      <span class="ov-title">Gerenciar</span>
    </div>

    <!-- Workouts section -->
    <div class="ov-section">
      <div class="mv-section-header">
        <span class="ov-section-label">Meus Treinos</span>
        <button class="btn-add-workout" @click="$emit('new-workout')">+ Novo treino</button>
      </div>

      <div class="mv-list">
        <div v-for="w in workouts" :key="w.id" class="mv-card">
          <div class="mv-letter">{{ w.letter || '?' }}</div>
          <div class="mv-info">
            <div class="mv-name">{{ w.name }}</div>
            <div class="mv-sub">{{ w.subtitle }}</div>
            <div class="mv-count">{{ w.exercises.length }} exercício{{ w.exercises.length !== 1 ? 's' : '' }}</div>
          </div>
          <div class="mv-actions">
            <button class="btn-icon" @click="$emit('edit-workout', w.id)" title="Editar treino">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            </button>
            <button class="btn-icon danger" @click="askDelete(w)" title="Excluir treino">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
            </button>
          </div>
        </div>

        <div v-if="workouts.length === 0" class="mv-empty">
          Nenhum treino criado ainda. Crie um novo treino para começar.
        </div>
      </div>
    </div>

    <!-- Schedule section -->
    <div class="ov-section" style="margin-top: 32px;">
      <div class="ov-section-label">Escala Semanal</div>
      <div class="sched-list">
        <div v-for="d in DAYS_CONFIG" :key="d.key" class="sched-row">
          <div class="sched-day">
            <span class="sched-short">{{ d.short }}</span>
            <span class="sched-name">{{ DAY_NAMES[d.key] }}</span>
          </div>
          <div class="sched-select-wrap">
            <select
              class="sched-select"
              :value="schedule[d.key] ?? ''"
              @change="onAssign(d.key, $event)"
            >
              <option value="">😴 Descanso</option>
              <option v-for="w in workouts" :key="w.id" :value="w.id">
                {{ w.letter }} · {{ w.name }}
              </option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Confirm delete -->
    <Teleport to="body">
      <div v-if="pendingDelete" class="confirm-backdrop" @click.self="pendingDelete = null">
        <div class="confirm-box">
          <div class="confirm-title">Excluir treino?</div>
          <p class="confirm-msg">"{{ pendingDelete.name }}" será removido permanentemente e desvinculado de todos os dias da semana.</p>
          <div class="confirm-actions">
            <button class="btn-ghost" @click="pendingDelete = null">Cancelar</button>
            <button class="btn-danger-sm" @click="doDelete">Excluir</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { DAYS_CONFIG, DAY_NAMES } from '~/composables/useWorkout'
import type { Workout } from '~/composables/useWorkout'

withDefaults(defineProps<{ showBack?: boolean }>(), { showBack: true })

defineEmits<{
  back: []
  'new-workout': []
  'edit-workout': [id: string]
}>()

const { workouts, schedule, deleteWorkout, assignDay } = useWorkoutDb()

const pendingDelete = ref<Workout | null>(null)

function askDelete(w: Workout) {
  pendingDelete.value = w
}

function doDelete() {
  if (!pendingDelete.value) return
  deleteWorkout(pendingDelete.value.id)
  pendingDelete.value = null
}

function onAssign(dayKey: string, e: Event) {
  const val = (e.target as HTMLSelectElement).value
  assignDay(dayKey, val || null)
}
</script>

<style scoped>
.mv-section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.btn-add-workout {
  background: transparent;
  border: 1.5px solid var(--accent);
  color: var(--accent);
  border-radius: 8px;
  padding: 7px 14px;
  font-family: 'DM Sans', sans-serif;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  letter-spacing: 0.5px;
}
.btn-add-workout:hover { background: var(--accent); color: #0a0a0c; }

.mv-list { display: flex; flex-direction: column; gap: 10px; }

.mv-card {
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: 14px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  gap: 14px;
  transition: border-color 0.2s;
}
.mv-card:hover { border-color: #333340; }

.mv-letter {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px;
  color: var(--accent);
  background: #1a2000;
  border: 1px solid var(--accent);
  border-radius: 8px;
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  line-height: 1;
}

.mv-info { flex: 1; min-width: 0; }
.mv-name { font-family: 'Bebas Neue', sans-serif; font-size: 20px; letter-spacing: 1px; line-height: 1.1; }
.mv-sub { font-size: 11px; color: var(--muted); margin-top: 2px; }
.mv-count { font-size: 11px; color: var(--muted); margin-top: 3px; }

.mv-actions { display: flex; gap: 6px; flex-shrink: 0; }

.mv-empty {
  text-align: center;
  padding: 40px 20px;
  color: var(--muted);
  font-size: 14px;
  line-height: 1.5;
  border: 1.5px dashed var(--border);
  border-radius: 14px;
}

/* Schedule */
.sched-list { display: flex; flex-direction: column; }

.sched-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 12px 0;
  border-bottom: 1px solid var(--border);
}
.sched-row:last-child { border-bottom: none; }

.sched-day {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  min-width: 72px;
}
.sched-short { font-family: 'Bebas Neue', sans-serif; font-size: 18px; color: var(--accent); line-height: 1; }
.sched-name { font-size: 10px; color: var(--muted); margin-top: 2px; }

.sched-select-wrap { flex: 1; }
.sched-select {
  width: 100%;
  background: var(--surface2);
  border: 1.5px solid var(--border);
  color: var(--text);
  border-radius: 8px;
  padding: 9px 12px;
  font-family: 'DM Sans', sans-serif;
  font-size: 13px;
  cursor: pointer;
  appearance: none;
  -webkit-appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23666672' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
  padding-right: 30px;
  transition: border-color 0.2s;
}
.sched-select:focus { outline: none; border-color: var(--accent); }
.sched-select option { background: #18181d; }
</style>
