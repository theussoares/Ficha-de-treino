<template>
  <div class="ov-page">
    <!-- Top bar -->
    <div class="ov-topbar">
      <button class="ov-back" @click="handleBack">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
        Voltar
      </button>
      <span class="ov-title">{{ props.workoutId ? 'Editar Treino' : 'Novo Treino' }}</span>
    </div>

    <!-- Workout metadata form -->
    <div class="ov-section">
      <div class="ov-section-label">Dados do Treino</div>

      <div class="form-field">
        <label class="form-label">Nome do treino</label>
        <input v-model="form.name" class="form-input form-input-big" placeholder="Ex: PUSH, LEGS, FULL BODY..." maxlength="40" />
      </div>

      <div class="form-row">
        <div class="form-field">
          <label class="form-label">Letra / Tag</label>
          <input v-model="form.letter" class="form-input" placeholder="A" maxlength="4" />
        </div>
        <div class="form-field">
          <label class="form-label">Subtítulo</label>
          <input v-model="form.subtitle" class="form-input" placeholder="Peito · Ombro · Tríceps" maxlength="60" />
        </div>
      </div>
    </div>

    <!-- Exercises list -->
    <div class="ov-section" style="margin-top: 28px;">
      <div class="we-exheader">
        <span class="ov-section-label" style="margin-bottom:0">Exercícios ({{ form.exercises.length }})</span>
        <button class="btn-add-ex" @click="openAddExercise">+ Adicionar</button>
      </div>

      <div class="we-exlist">
        <div
          v-for="(ex, i) in form.exercises"
          :key="i"
          class="we-excard"
        >
          <div class="we-exnum">{{ String(i + 1).padStart(2, '0') }}</div>
          <div class="we-exbody">
            <div class="we-exname">{{ ex.name }}</div>
            <div v-if="ex.sets || ex.reps" class="we-exmeta">
              <span v-if="ex.sets" class="ex-badge">{{ ex.sets }} séries</span>
              <span v-if="ex.reps" class="ex-badge">{{ ex.reps }} reps</span>
            </div>
            <div v-if="ex.note" class="we-exnote">{{ ex.note }}</div>
          </div>
          <div class="we-exbtns">
            <button class="btn-icon" :disabled="i === 0" @click="moveEx(i, 'up')" title="Mover para cima">↑</button>
            <button class="btn-icon" :disabled="i === form.exercises.length - 1" @click="moveEx(i, 'down')" title="Mover para baixo">↓</button>
            <button class="btn-icon" @click="openEditExercise(i)" title="Editar">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            </button>
            <button class="btn-icon danger" @click="deleteExercise(i)" title="Remover">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
          </div>
        </div>

        <div v-if="form.exercises.length === 0" class="we-exempty">
          Nenhum exercício ainda. Clique em "+ Adicionar" para incluir.
        </div>
      </div>
    </div>

    <!-- Save / Cancel -->
    <div class="ov-section we-footer">
      <div v-if="nameError" class="we-error">{{ nameError }}</div>
      <button class="btn-primary" @click="save">Salvar Treino</button>
      <button class="btn-ghost" style="margin-top: 10px;" @click="handleBack">Cancelar</button>
    </div>

    <!-- Confirm back with unsaved changes -->
    <Teleport to="body">
      <div v-if="confirmBack" class="confirm-backdrop" @click.self="confirmBack = false">
        <div class="confirm-box">
          <div class="confirm-title">Descartar alterações?</div>
          <p class="confirm-msg">As mudanças feitas neste treino não serão salvas.</p>
          <div class="confirm-actions">
            <button class="btn-ghost" @click="confirmBack = false">Continuar editando</button>
            <button class="btn-danger-sm" @click="$emit('back')">Descartar</button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Exercise modal -->
    <ExerciseModal
      v-if="exerciseModal"
      :exercise="exerciseModal.exercise"
      @save="saveExercise"
      @cancel="exerciseModal = null"
    />
  </div>
</template>

<script setup lang="ts">
import { useWorkoutStore } from '~/composables/useWorkout'
import type { Exercise } from '~/composables/useWorkout'

const props = defineProps<{
  workoutId: string | null
}>()

const emit = defineEmits<{
  back: []
  saved: []
}>()

const store = useWorkoutStore()

const form = reactive({
  name: '',
  letter: '',
  subtitle: '',
  exercises: [] as Exercise[],
})

const originalJson = ref('')

onMounted(() => {
  if (props.workoutId) {
    const w = store.getWorkout(props.workoutId)
    if (w) {
      form.name = w.name
      form.letter = w.letter
      form.subtitle = w.subtitle
      form.exercises = w.exercises.map(e => ({ ...e }))
    }
  }
  originalJson.value = JSON.stringify({ ...form, exercises: [...form.exercises] })
})

const isDirty = computed(() => {
  return JSON.stringify({ name: form.name, letter: form.letter, subtitle: form.subtitle, exercises: form.exercises }) !== originalJson.value
})

const confirmBack = ref(false)

function handleBack() {
  if (isDirty.value) {
    confirmBack.value = true
  } else {
    emit('back')
  }
}

// Exercise modal
const exerciseModal = ref<{
  index: number | null
  exercise: Exercise
} | null>(null)

function openAddExercise() {
  exerciseModal.value = {
    index: null,
    exercise: { name: '', sets: null, reps: null, note: null },
  }
}

function openEditExercise(idx: number) {
  exerciseModal.value = {
    index: idx,
    exercise: { ...form.exercises[idx] },
  }
}

function saveExercise(ex: Exercise) {
  if (exerciseModal.value!.index === null) {
    form.exercises.push(ex)
  } else {
    form.exercises[exerciseModal.value!.index] = ex
  }
  exerciseModal.value = null
}

function deleteExercise(idx: number) {
  form.exercises.splice(idx, 1)
}

function moveEx(idx: number, dir: 'up' | 'down') {
  const to = dir === 'up' ? idx - 1 : idx + 1
  if (to < 0 || to >= form.exercises.length) return
  const exs = form.exercises
  ;[exs[idx], exs[to]] = [exs[to], exs[idx]]
}

// Validation
const nameError = ref('')

function save() {
  nameError.value = ''
  if (!form.name.trim()) {
    nameError.value = 'O nome do treino é obrigatório.'
    return
  }

  const data = {
    name: form.name.trim().toUpperCase(),
    letter: form.letter.trim().toUpperCase(),
    subtitle: form.subtitle.trim(),
    exercises: form.exercises.map(e => ({ ...e })),
  }

  if (props.workoutId) {
    store.updateWorkout(props.workoutId, data)
  } else {
    store.createWorkout(data)
  }

  emit('saved')
}
</script>

<style scoped>
.form-input-big {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 28px;
  letter-spacing: 1px;
  padding: 10px 14px;
}

.we-exheader {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.btn-add-ex {
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
}
.btn-add-ex:hover { background: var(--accent); color: #0a0a0c; }

.we-exlist { display: flex; flex-direction: column; gap: 8px; }

.we-excard {
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: 12px;
  padding: 12px 14px;
  display: flex;
  align-items: center;
  gap: 12px;
  transition: border-color 0.2s;
}
.we-excard:hover { border-color: #333340; }

.we-exnum { font-family: 'Bebas Neue', sans-serif; font-size: 20px; color: var(--border); width: 24px; text-align: center; flex-shrink: 0; }
.we-exbody { flex: 1; min-width: 0; }
.we-exname { font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.we-exmeta { display: flex; gap: 6px; margin-top: 4px; }
.we-exnote { font-size: 11px; color: var(--muted); margin-top: 3px; font-style: italic; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.we-exbtns { display: flex; gap: 4px; flex-shrink: 0; }

.we-exempty {
  text-align: center;
  padding: 36px 16px;
  color: var(--muted);
  font-size: 13px;
  border: 1.5px dashed var(--border);
  border-radius: 12px;
}

.we-footer { margin-top: 32px; }

.we-error {
  background: rgba(255, 68, 68, 0.1);
  border: 1px solid rgba(255, 68, 68, 0.3);
  color: #ff6666;
  border-radius: 8px;
  padding: 10px 14px;
  font-size: 13px;
  margin-bottom: 12px;
}
</style>
