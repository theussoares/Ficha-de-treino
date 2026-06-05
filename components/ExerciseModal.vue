<template>
  <Teleport to="body">
    <div class="em-backdrop" @click.self="$emit('cancel')">
      <div class="em-box">
        <div class="em-header">
          <span class="em-title">{{ props.exercise?.name ? 'Editar Exercício' : 'Novo Exercício' }}</span>
          <button class="em-close" @click="$emit('cancel')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <div class="em-body">
          <div class="form-field">
            <label class="form-label">Nome do exercício *</label>
            <input
              ref="nameInput"
              v-model="form.name"
              class="form-input"
              placeholder="Ex: Supino Reto com Barra"
              maxlength="80"
              @keydown.enter="save"
            />
          </div>

          <div class="form-row">
            <div class="form-field">
              <label class="form-label">Séries</label>
              <input v-model="form.sets" class="form-input" placeholder="4" maxlength="10" @keydown.enter="save" />
            </div>
            <div class="form-field">
              <label class="form-label">Repetições</label>
              <input v-model="form.reps" class="form-input" placeholder="8–12" maxlength="20" @keydown.enter="save" />
            </div>
          </div>

          <div class="form-field">
            <label class="form-label">Observação</label>
            <input v-model="form.note" class="form-input" placeholder="Progressão de carga, drop set..." maxlength="120" @keydown.enter="save" />
          </div>
        </div>

        <div v-if="nameError" class="em-error">{{ nameError }}</div>

        <div class="em-footer">
          <button class="btn-ghost em-btn" @click="$emit('cancel')">Cancelar</button>
          <button class="em-btn-save" @click="save">Salvar</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import type { Exercise } from '~/composables/useWorkout'

const props = defineProps<{
  exercise: Exercise
}>()

const emit = defineEmits<{
  save: [exercise: Exercise]
  cancel: []
}>()

const nameInput = ref<HTMLInputElement>()

const form = reactive({
  name: props.exercise.name,
  sets: props.exercise.sets ?? '',
  reps: props.exercise.reps ?? '',
  note: props.exercise.note ?? '',
})

const nameError = ref('')

onMounted(() => {
  nextTick(() => nameInput.value?.focus())
})

function save() {
  nameError.value = ''
  if (!form.name.trim()) {
    nameError.value = 'O nome do exercício é obrigatório.'
    return
  }

  emit('save', {
    name: form.name.trim(),
    sets: form.sets.trim() || null,
    reps: form.reps.trim() || null,
    note: form.note.trim() || null,
  })
}
</script>

<style scoped>
.em-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  z-index: 300;
  padding: 0 0 0 0;
}

@media (min-height: 600px) {
  .em-backdrop { align-items: center; padding: 24px; }
}

.em-box {
  background: var(--surface2);
  border: 1.5px solid var(--border);
  border-radius: 20px 20px 0 0;
  width: 100%;
  max-width: 560px;
  padding: 24px;
}

@media (min-height: 600px) {
  .em-box { border-radius: 20px; }
}

.em-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.em-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px;
  letter-spacing: 1px;
}

.em-close {
  background: var(--surface);
  border: 1.5px solid var(--border);
  color: var(--muted);
  border-radius: 8px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}
.em-close:hover { border-color: var(--text); color: var(--text); }

.em-body { }

.em-error {
  background: rgba(255, 68, 68, 0.1);
  border: 1px solid rgba(255, 68, 68, 0.3);
  color: #ff6666;
  border-radius: 8px;
  padding: 8px 12px;
  font-size: 13px;
  margin-bottom: 12px;
}

.em-footer {
  display: flex;
  gap: 10px;
  margin-top: 4px;
}

.em-btn {
  flex: 1;
  padding: 12px 16px;
  font-size: 14px;
}

.em-btn-save {
  flex: 1;
  background: var(--accent);
  color: #0a0a0c;
  border: none;
  border-radius: 10px;
  padding: 12px 16px;
  font-family: 'DM Sans', sans-serif;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
  cursor: pointer;
  transition: opacity 0.2s;
}
.em-btn-save:hover { opacity: 0.9; }
</style>
