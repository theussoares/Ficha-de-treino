export interface Exercise {
  name: string
  sets: string | null
  reps: string | null
  note: string | null
}

export interface Workout {
  id: string
  name: string
  subtitle: string
  letter: string
  exercises: Exercise[]
}

export const DAYS_CONFIG = [
  { short: 'SEG', key: 'mon' },
  { short: 'TER', key: 'tue' },
  { short: 'QUA', key: 'wed' },
  { short: 'QUI', key: 'thu' },
  { short: 'SEX', key: 'fri' },
  { short: 'SÁB', key: 'sat' },
  { short: 'DOM', key: 'sun' },
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

export const SEED_WORKOUTS: Workout[] = [
  {
    id: 'push',
    name: 'PUSH',
    letter: 'A',
    subtitle: 'Peito · Ombro · Bíceps',
    exercises: [
      { name: 'Supino Reto Barra Olímpica', sets: '6', reps: null, note: '2x aquecimento · 2x prep · 2x válidas' },
      { name: 'Crossover Polia Alta', sets: '4', reps: '12', note: 'Progressão de carga' },
      { name: 'Supino Inclinado com Halter', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Elevação Lateral no Banco', sets: '4', reps: '8–12', note: 'Progressão de carga · Drop set na última' },
      { name: 'Elevação Frontal com Corda', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Bíceps Polia Barra Reta (costa p/ polia)', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Bíceps Banco Scott Barra W', sets: '4', reps: '8–12', note: 'Progressão de carga' },
    ],
  },
  {
    id: 'pull',
    name: 'PULL',
    letter: 'B',
    subtitle: 'Costas · Ombro Post. · Tríceps',
    exercises: [
      { name: 'Puxada Frente Pegada Aberta', sets: '5', reps: '8–12', note: '1x aquecimento · 2x prep · 1x válida c/ drop set' },
      { name: 'Remada Pegada Aberta (Máquina Articulada)', sets: '4', reps: '8–12', note: '2x prep · 2x válidas' },
      { name: 'Pulldown Cross', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Puxada Triângulo', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Crucifixo Inverso Máquina', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Máquina', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Pulley', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Testa Barra W', sets: '4', reps: '8–12', note: 'Progressão de carga' },
    ],
  },
  {
    id: 'legs-a',
    name: 'LEGS A',
    letter: 'C',
    subtitle: 'Quadríceps · Posterior · Glúteo · Panturrilha',
    exercises: [
      { name: 'Agachamento Livre', sets: null, reps: null, note: null },
      { name: 'Cadeira Extensora', sets: null, reps: null, note: null },
      { name: 'Hack', sets: null, reps: null, note: null },
      { name: 'Mesa Flexora', sets: null, reps: null, note: null },
      { name: 'Elevação Pélvica', sets: null, reps: null, note: null },
      { name: 'Panturrilha', sets: null, reps: null, note: null },
      { name: 'Cadeira Flexora', sets: null, reps: null, note: null },
    ],
  },
  {
    id: 'upper',
    name: 'UPPER',
    letter: 'D',
    subtitle: 'Costas · Peito · Ombro · Bíceps · Tríceps',
    exercises: [
      { name: 'Puxada Frente', sets: '4', reps: '15', note: '1x aquecimento · 1x prep · 2x válidas · Progressão de carga' },
      { name: 'Remada Máquina Pegada Aberta', sets: '4', reps: '8–12', note: null },
      { name: 'Crucifixo Máquina', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Crossover Polia Alta', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Desenvolvimento com Halter', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Elevação Unilateral na Polia', sets: '4', reps: '12', note: null },
      { name: 'Bíceps Unilateral Banco Inclinado', sets: '4', reps: '8–12', note: 'Progressão de carga' },
      { name: 'Tríceps Barra W na Polia', sets: '4', reps: '8–12', note: 'Progressão de carga' },
    ],
  },
  {
    id: 'legs-b',
    name: 'LEGS B',
    letter: 'E',
    subtitle: 'Quadríceps · Posterior · Glúteo · Panturrilha',
    exercises: [
      { name: 'Agachamento Livre', sets: null, reps: null, note: null },
      { name: 'Cadeira Extensora', sets: null, reps: null, note: null },
      { name: 'Leg Press', sets: null, reps: null, note: null },
      { name: 'Búlgaro', sets: null, reps: null, note: null },
      { name: 'Cadeira Flexora', sets: null, reps: null, note: null },
      { name: 'Stiff', sets: null, reps: null, note: null },
    ],
  },
]

export const SEED_SCHEDULE: Record<string, string | null> = {
  mon: 'push',
  tue: 'pull',
  wed: 'legs-a',
  thu: null,
  fri: 'upper',
  sat: 'legs-b',
  sun: null,
}

function genId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 6)
}

export function useWorkoutStore() {
  const workouts = useState<Workout[]>('workouts', () => [])
  const schedule = useState<Record<string, string | null>>('schedule', () => ({}))
  const doneState = useState<Record<string, number[]>>('done_state', () => ({}))

  function load() {
    if (!import.meta.client) return
    try {
      const sw = localStorage.getItem('treino_workouts')
      const ss = localStorage.getItem('treino_schedule')
      const sd = localStorage.getItem('treino_done') ?? localStorage.getItem('treino_state')
      workouts.value = sw ? JSON.parse(sw) : JSON.parse(JSON.stringify(SEED_WORKOUTS))
      schedule.value = ss ? JSON.parse(ss) : { ...SEED_SCHEDULE }
      doneState.value = sd ? JSON.parse(sd) : {}
    } catch {
      workouts.value = JSON.parse(JSON.stringify(SEED_WORKOUTS))
      schedule.value = { ...SEED_SCHEDULE }
      doneState.value = {}
    }
  }

  function persist() {
    if (!import.meta.client) return
    localStorage.setItem('treino_workouts', JSON.stringify(workouts.value))
    localStorage.setItem('treino_schedule', JSON.stringify(schedule.value))
    localStorage.setItem('treino_done', JSON.stringify(doneState.value))
  }

  function getWorkout(id: string): Workout | undefined {
    return workouts.value.find(w => w.id === id)
  }

  function getScheduledWorkout(dayKey: string): Workout | null {
    const id = schedule.value[dayKey]
    if (!id) return null
    return getWorkout(id) ?? null
  }

  function createWorkout(data: Omit<Workout, 'id'>): Workout {
    const w: Workout = { ...data, id: genId(), exercises: data.exercises.map(e => ({ ...e })) }
    workouts.value = [...workouts.value, w]
    persist()
    return w
  }

  function updateWorkout(id: string, data: Partial<Omit<Workout, 'id'>>) {
    workouts.value = workouts.value.map(w => w.id === id ? { ...w, ...data } : w)
    persist()
  }

  function deleteWorkout(id: string) {
    workouts.value = workouts.value.filter(w => w.id !== id)
    const newSched = { ...schedule.value }
    for (const k of Object.keys(newSched)) {
      if (newSched[k] === id) newSched[k] = null
    }
    schedule.value = newSched
    persist()
  }

  function assignDay(dayKey: string, workoutId: string | null) {
    schedule.value = { ...schedule.value, [dayKey]: workoutId }
    persist()
  }

  function getDone(dayKey: string): Set<number> {
    return new Set(doneState.value[dayKey] || [])
  }

  function toggle(dayKey: string, idx: number) {
    const s = getDone(dayKey)
    if (s.has(idx)) s.delete(idx)
    else s.add(idx)
    doneState.value = { ...doneState.value, [dayKey]: [...s] }
    persist()
  }

  function markAll(dayKey: string) {
    const w = getScheduledWorkout(dayKey)
    if (!w) return
    const done = getDone(dayKey)
    doneState.value = {
      ...doneState.value,
      [dayKey]: done.size === w.exercises.length ? [] : w.exercises.map((_, i) => i),
    }
    persist()
  }

  function reset(dayKey: string) {
    doneState.value = { ...doneState.value, [dayKey]: [] }
    persist()
  }

  return {
    workouts, schedule, doneState, load,
    getWorkout, getScheduledWorkout,
    createWorkout, updateWorkout, deleteWorkout,
    assignDay,
    getDone, toggle, markAll, reset,
  }
}
