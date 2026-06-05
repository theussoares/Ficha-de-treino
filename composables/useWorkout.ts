export interface Exercise {
  name: string
  sets: string | null
  reps: string | null
  note: string | null
}

export interface Workout {
  name: string
  subtitle: string
  letter: string
  exercises: Exercise[]
}

export const DAYS = [
  { short: 'SEG', letter: 'A', tag: 'Push',     key: 'mon', rest: false },
  { short: 'TER', letter: 'B', tag: 'Pull',     key: 'tue', rest: false },
  { short: 'QUA', letter: 'C', tag: 'Legs A',   key: 'wed', rest: false },
  { short: 'QUI', letter: '—', tag: 'Descanso', key: 'thu', rest: true  },
  { short: 'SEX', letter: 'D', tag: 'Upper',    key: 'fri', rest: false },
  { short: 'SÁB', letter: 'E', tag: 'Legs B',   key: 'sat', rest: false },
  { short: 'DOM', letter: '—', tag: 'Descanso', key: 'sun', rest: true  },
]

export const DAY_NAMES: Record<string, string> = {
  mon: 'Segunda-feira',
  tue: 'Terça-feira',
  wed: 'Quarta-feira',
  thu: 'Quinta-feira',
  fri: 'Sexta-feira',
  sat: 'Sábado',
  sun: 'Domingo',
}

export const WORKOUTS: Record<string, Workout | null> = {
  mon: {
    name: 'PUSH',
    letter: 'A',
    subtitle: 'Peito · Ombro · Bíceps',
    exercises: [
      { name: 'Supino Reto Barra Olímpica',              sets: '6', reps: null,   note: '2x aquecimento · 2x prep · 2x válidas' },
      { name: 'Crossover Polia Alta',                    sets: '4', reps: '12',   note: 'Progressão de carga' },
      { name: 'Supino Inclinado com Halter',             sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Elevação Lateral no Banco',               sets: '4', reps: '8–12', note: 'Progressão de carga · Drop set na última' },
      { name: 'Elevação Frontal com Corda',              sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Bíceps Polia Barra Reta (costa p/ polia)',sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Bíceps Banco Scott Barra W',              sets: '4', reps: '8–12', note: 'Progressão de carga' },
    ],
  },
  tue: {
    name: 'PULL',
    letter: 'B',
    subtitle: 'Costas · Ombro Post. · Tríceps',
    exercises: [
      { name: 'Puxada Frente Pegada Aberta',              sets: '5', reps: '8–12', note: '1x aquecimento · 2x prep · 1x válida c/ drop set' },
      { name: 'Remada Pegada Aberta (Máquina Articulada)',sets: '4', reps: '8–12', note: '2x prep · 2x válidas' },
      { name: 'Pulldown Cross',                           sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Puxada Triângulo',                         sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Crucifixo Inverso Máquina',                sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Máquina',                          sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Pulley',                           sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Testa Barra W',                    sets: '4', reps: '8–12', note: 'Progressão de carga' },
    ],
  },
  wed: {
    name: 'LEGS A',
    letter: 'C',
    subtitle: 'Quadríceps · Posterior · Glúteo · Panturrilha',
    exercises: [
      { name: 'Agachamento Livre',  sets: null, reps: null, note: null },
      { name: 'Cadeira Extensora',  sets: null, reps: null, note: null },
      { name: 'Hack',               sets: null, reps: null, note: null },
      { name: 'Mesa Flexora',       sets: null, reps: null, note: null },
      { name: 'Elevação Pélvica',   sets: null, reps: null, note: null },
      { name: 'Panturrilha',        sets: null, reps: null, note: null },
      { name: 'Cadeira Flexora',    sets: null, reps: null, note: null },
    ],
  },
  thu: null,
  fri: {
    name: 'UPPER',
    letter: 'D',
    subtitle: 'Costas · Peito · Ombro · Bíceps · Tríceps',
    exercises: [
      { name: 'Puxada Frente',                    sets: '4', reps: '15',   note: '1x aquecimento · 1x prep · 2x válidas · Progressão de carga' },
      { name: 'Remada Máquina Pegada Aberta',     sets: '4', reps: '8–12', note: null },
      { name: 'Crucifixo Máquina',                sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Crossover Polia Alta',             sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Desenvolvimento com Halter',       sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Elevação Unilateral na Polia',     sets: '4', reps: '12',   note: null },
      { name: 'Bíceps Unilateral Banco Inclinado',sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Barra W na Polia',         sets: '4', reps: '8–12', note: 'Progressão de carga' },
    ],
  },
  sat: {
    name: 'LEGS B',
    letter: 'E',
    subtitle: 'Quadríceps · Posterior · Glúteo · Panturrilha',
    exercises: [
      { name: 'Agachamento Livre',  sets: null, reps: null, note: null },
      { name: 'Cadeira Extensora',  sets: null, reps: null, note: null },
      { name: 'Leg Press',          sets: null, reps: null, note: null },
      { name: 'Búlgaro',            sets: null, reps: null, note: null },
      { name: 'Cadeira Flexora',    sets: null, reps: null, note: null },
      { name: 'Stiff',              sets: null, reps: null, note: null },
    ],
  },
  sun: null,
}

export function useWorkoutState() {
  const state = useState<Record<string, number[]>>('workout_state', () => ({}))

  function load() {
    if (import.meta.client) {
      try {
        const saved = localStorage.getItem('treino_state')
        if (saved) state.value = JSON.parse(saved)
      } catch {}
    }
  }

  function persist() {
    if (import.meta.client) {
      localStorage.setItem('treino_state', JSON.stringify(state.value))
    }
  }

  function getDone(dayKey: string): Set<number> {
    return new Set(state.value[dayKey] || [])
  }

  function toggle(dayKey: string, idx: number) {
    const set = getDone(dayKey)
    if (set.has(idx)) set.delete(idx)
    else set.add(idx)
    state.value = { ...state.value, [dayKey]: [...set] }
    persist()
  }

  function markAll(dayKey: string) {
    const w = WORKOUTS[dayKey]
    if (!w) return
    const done = getDone(dayKey)
    if (done.size === w.exercises.length) {
      state.value = { ...state.value, [dayKey]: [] }
    } else {
      state.value = { ...state.value, [dayKey]: w.exercises.map((_, i) => i) }
    }
    persist()
  }

  function reset(dayKey: string) {
    state.value = { ...state.value, [dayKey]: [] }
    persist()
  }

  return { state, load, getDone, toggle, markAll, reset }
}
