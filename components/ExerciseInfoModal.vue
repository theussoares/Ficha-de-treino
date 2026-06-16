<template>
  <Teleport to="body">
    <div class="em-backdrop" @click.self="$emit('close')">
      <div class="em-box">
        <div class="em-header">
          <span class="em-title">{{ exercise.name }}</span>
          <button class="em-close" @click="$emit('close')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        <div class="em-body">
          <div v-if="exercise.sets || exercise.reps || exercise.rest" class="eim-stats">
            <div v-if="exercise.sets" class="eim-stat">
              <span class="eim-stat-value">{{ exercise.sets }}</span>
              <span class="eim-stat-label">Séries</span>
            </div>
            <div v-if="exercise.reps" class="eim-stat">
              <span class="eim-stat-value">{{ exercise.reps }}</span>
              <span class="eim-stat-label">Reps</span>
            </div>
            <div v-if="exercise.rest" class="eim-stat">
              <span class="eim-stat-value">{{ exercise.rest }}</span>
              <span class="eim-stat-label">Descanso</span>
            </div>
          </div>

          <div v-if="techniques.length" class="eim-techniques">
            <span v-for="t in techniques" :key="t" class="ex-badge highlight">{{ t }}</span>
          </div>

          <div v-if="exercise.note" class="eim-note">
            <div class="eim-note-label">Técnica / Observação</div>
            <p class="eim-note-text">{{ exercise.note }}</p>
          </div>

          <p v-if="!exercise.note && techniques.length === 0" class="eim-empty">
            Nenhuma observação adicional para este exercício.
          </p>
        </div>

        <div class="em-footer">
          <button class="btn-ghost em-btn" @click="$emit('close')">Fechar</button>
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

defineEmits<{
  close: []
}>()

const techniques = computed(() => {
  const note = props.exercise.note?.toLowerCase() ?? ''
  const found: string[] = []
  if (note.includes('drop')) found.push('Drop Set')
  if (note.includes('supers')) found.push('Supersérie')
  if (note.includes('progressão')) found.push('Progressão de carga')
  return found
})
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
}

@media (min-height: 600px) {
  .em-backdrop { align-items: center; padding: 24px; }
}

.em-box {
  background: var(--surface2);
  border: 1.5px solid var(--border);
  border-radius: 20px 20px 0 0;
  width: 100%;
  max-width: 480px;
  padding: 24px;
}

@media (min-height: 600px) {
  .em-box { border-radius: 20px; }
}

.em-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 20px;
}

.em-title {
  font-family: 'Bebas Neue', sans-serif;
  font-size: 22px;
  letter-spacing: 1px;
  line-height: 1.1;
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
  flex-shrink: 0;
}
.em-close:hover { border-color: var(--text); color: var(--text); }

.eim-stats { display: flex; gap: 10px; margin-bottom: 18px; }
.eim-stat {
  flex: 1;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 10px 8px;
  text-align: center;
}
.eim-stat-value { display: block; font-family: 'Bebas Neue', sans-serif; font-size: 22px; color: var(--accent); }
.eim-stat-label { display: block; font-size: 9px; letter-spacing: 1.5px; text-transform: uppercase; color: var(--muted); margin-top: 2px; }

.eim-techniques { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 16px; }

.eim-note-label { font-size: 10px; letter-spacing: 2px; text-transform: uppercase; color: var(--muted); margin-bottom: 6px; }
.eim-note-text { font-size: 14px; color: var(--text); line-height: 1.6; }

.eim-empty { font-size: 13px; color: var(--muted); font-style: italic; }

.em-footer {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.em-btn {
  flex: 1;
  padding: 12px 16px;
  font-size: 14px;
}
</style>
