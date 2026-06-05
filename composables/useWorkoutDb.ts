import type { Exercise, Workout } from './useWorkout'

export type { Exercise, Workout }

interface ProfileRow {
  id: string
  username: string
  display_name: string
}

interface ScheduleRow {
  day_key: string
  workout_id: string | null
}

interface ExerciseRow {
  name: string
  sets: string | null
  reps: string | null
  note: string | null
  position: number
}

interface WorkoutRow {
  id: string
  name: string
  letter: string
  subtitle: string
  position: number
  exercises: ExerciseRow[]
}

function toWorkout(row: WorkoutRow): Workout {
  return {
    id: row.id,
    name: row.name,
    letter: row.letter,
    subtitle: row.subtitle,
    exercises: (row.exercises ?? [])
      .sort((a, b) => a.position - b.position)
      .map(e => ({ name: e.name, sets: e.sets, reps: e.reps, note: e.note })),
  }
}

export function useWorkoutDb() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const workouts  = useState<Workout[]>('workouts',  () => [])
  const schedule  = useState<Record<string, string | null>>('schedule', () => ({}))
  const doneState = useState<Record<string, number[]>>('done_state', () => ({}))
  const loading   = useState<boolean>('wdb_loading', () => false)

  // Namespace usado para persistir progresso no localStorage (por username)
  const doneKey = useState<string>('done_key', () => 'treino_done')

  // ─── helpers ────────────────────────────────────────────────

  function persistDone() {
    if (!import.meta.client) return
    localStorage.setItem(doneKey.value, JSON.stringify(doneState.value))
  }

  function loadDoneFromStorage() {
    if (!import.meta.client) return
    try {
      const saved = localStorage.getItem(doneKey.value)
      doneState.value = saved ? JSON.parse(saved) : {}
    } catch {
      doneState.value = {}
    }
  }

  async function fetchForOwner(ownerId: string) {
    const [wRes, sRes] = await Promise.all([
      supabase
        .from('workouts')
        .select('id, name, letter, subtitle, position, exercises(name, sets, reps, note, position)')
        .eq('owner_id', ownerId)
        .order('position', { ascending: true }),
      supabase
        .from('schedule_entries')
        .select('day_key, workout_id')
        .eq('owner_id', ownerId),
    ])

    workouts.value = ((wRes.data ?? []) as WorkoutRow[]).map(toWorkout)
    schedule.value = Object.fromEntries(
      ((sRes.data ?? []) as ScheduleRow[]).map(s => [s.day_key, s.workout_id ?? null]),
    )
  }

  // ─── loaders ────────────────────────────────────────────────

  async function loadPublic(username: string): Promise<{ displayName: string } | null> {
    loading.value = true
    workouts.value = []
    schedule.value = {}
    doneKey.value = `treino_done_${username}`

    try {
      const { data: profile } = await supabase
        .from('profiles')
        .select('id, display_name')
        .eq('username', username.toLowerCase())
        .single() as { data: ProfileRow | null }

      if (!profile) return null

      await fetchForOwner(profile.id)
      loadDoneFromStorage()

      return { displayName: profile.display_name }
    } finally {
      loading.value = false
    }
  }

  async function loadDashboard() {
    let uid = user.value?.id
    if (!uid) {
      const { data: { session } } = await supabase.auth.getSession()
      uid = session?.user?.id
    }
    if (!uid) return
    loading.value = true
    workouts.value = []
    schedule.value = {}
    try {
      await fetchForOwner(uid)
    } finally {
      loading.value = false
    }
  }

  // ─── workout CRUD ────────────────────────────────────────────

  async function createWorkout(data: Omit<Workout, 'id'>): Promise<Workout> {
    const uid = user.value?.id
    if (!uid) throw new Error('Não autenticado')

    const { data: row, error } = await supabase
      .from('workouts')
      .insert({ owner_id: uid, name: data.name, letter: data.letter, subtitle: data.subtitle, position: workouts.value.length })
      .select('id')
      .single()

    if (error || !row) throw error ?? new Error('Falha ao criar treino')

    const wid = (row as { id: string }).id

    if (data.exercises.length > 0) {
      await supabase.from('exercises').insert(
        data.exercises.map((e, i) => ({ workout_id: wid, name: e.name, sets: e.sets, reps: e.reps, note: e.note, position: i })),
      )
    }

    const workout: Workout = { id: wid, ...data }
    workouts.value = [...workouts.value, workout]
    return workout
  }

  async function updateWorkout(id: string, data: Partial<Omit<Workout, 'id'>>) {
    // Atualização otimista
    workouts.value = workouts.value.map(w => w.id === id ? { ...w, ...data } : w)

    const { name, letter, subtitle, exercises } = data

    // Atualiza metadata
    if (name !== undefined || letter !== undefined || subtitle !== undefined) {
      await supabase.from('workouts').update({ name, letter, subtitle }).eq('id', id)
    }

    // Substitui exercícios integralmente (delete + reinsert)
    if (exercises !== undefined) {
      await supabase.from('exercises').delete().eq('workout_id', id)
      if (exercises.length > 0) {
        await supabase.from('exercises').insert(
          exercises.map((e, i) => ({ workout_id: id, name: e.name, sets: e.sets, reps: e.reps, note: e.note, position: i })),
        )
      }
    }
  }

  async function deleteWorkout(id: string) {
    // Atualização otimista
    workouts.value = workouts.value.filter(w => w.id !== id)
    const newSched = { ...schedule.value }
    for (const k of Object.keys(newSched)) {
      if (newSched[k] === id) newSched[k] = null
    }
    schedule.value = newSched

    await supabase.from('workouts').delete().eq('id', id)
  }

  async function assignDay(dayKey: string, workoutId: string | null) {
    const uid = user.value?.id
    if (!uid) return

    schedule.value = { ...schedule.value, [dayKey]: workoutId }

    if (workoutId) {
      await supabase.from('schedule_entries').upsert(
        { owner_id: uid, day_key: dayKey, workout_id: workoutId },
        { onConflict: 'owner_id,day_key' },
      )
    } else {
      await supabase.from('schedule_entries').delete().eq('owner_id', uid).eq('day_key', dayKey)
    }
  }

  // ─── getters ────────────────────────────────────────────────

  function getWorkout(id: string): Workout | undefined {
    return workouts.value.find(w => w.id === id)
  }

  function getScheduledWorkout(dayKey: string): Workout | null {
    const id = schedule.value[dayKey]
    if (!id) return null
    return getWorkout(id) ?? null
  }

  // ─── done state (progresso local) ───────────────────────────

  function getDone(dayKey: string): Set<number> {
    return new Set(doneState.value[dayKey] || [])
  }

  function toggle(dayKey: string, idx: number) {
    const s = getDone(dayKey)
    if (s.has(idx)) s.delete(idx)
    else s.add(idx)
    doneState.value = { ...doneState.value, [dayKey]: [...s] }
    persistDone()
  }

  function markAll(dayKey: string) {
    const w = getScheduledWorkout(dayKey)
    if (!w) return
    const done = getDone(dayKey)
    doneState.value = {
      ...doneState.value,
      [dayKey]: done.size === w.exercises.length ? [] : w.exercises.map((_, i) => i),
    }
    persistDone()
  }

  function reset(dayKey: string) {
    doneState.value = { ...doneState.value, [dayKey]: [] }
    persistDone()
  }

  return {
    workouts, schedule, doneState, loading,
    loadPublic, loadDashboard,
    getWorkout, getScheduledWorkout,
    createWorkout, updateWorkout, deleteWorkout, assignDay,
    getDone, toggle, markAll, reset,
  }
}
