-- ============================================================
-- Ficha de Treino — Supabase Schema
-- Rode no SQL Editor do seu projeto Supabase
-- ============================================================

-- profiles (estende auth.users)
create table public.profiles (
  id           uuid references auth.users on delete cascade primary key,
  username     text unique not null,
  display_name text not null,
  created_at   timestamptz default now() not null,
  constraint username_format check (username ~ '^[a-z0-9_-]{3,30}$')
);

-- workouts (treinos de cada influencer)
create table public.workouts (
  id         uuid default gen_random_uuid() primary key,
  owner_id   uuid references public.profiles(id) on delete cascade not null,
  name       text not null default '',
  letter     text not null default '',
  subtitle   text not null default '',
  position   int  not null default 0,
  created_at timestamptz default now() not null
);

-- exercises (exercícios de cada treino)
create table public.exercises (
  id         uuid default gen_random_uuid() primary key,
  workout_id uuid references public.workouts(id) on delete cascade not null,
  name       text not null default '',
  sets       text,
  reps       text,
  note       text,
  position   int  not null default 0
);

-- schedule_entries (escala semanal por influencer)
create table public.schedule_entries (
  id         uuid default gen_random_uuid() primary key,
  owner_id   uuid references public.profiles(id) on delete cascade not null,
  day_key    text not null,
  workout_id uuid references public.workouts(id) on delete set null,
  unique(owner_id, day_key),
  constraint valid_day check (day_key in ('mon','tue','wed','thu','fri','sat','sun'))
);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table public.profiles        enable row level security;
alter table public.workouts        enable row level security;
alter table public.exercises       enable row level security;
alter table public.schedule_entries enable row level security;

-- profiles
create policy "profiles_select_all"   on public.profiles for select using (true);
create policy "profiles_insert_own"   on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own"   on public.profiles for update using (auth.uid() = id);

-- workouts
create policy "workouts_select_all"   on public.workouts for select using (true);
create policy "workouts_insert_own"   on public.workouts for insert with check (auth.uid() = owner_id);
create policy "workouts_update_own"   on public.workouts for update using (auth.uid() = owner_id);
create policy "workouts_delete_own"   on public.workouts for delete using (auth.uid() = owner_id);

-- exercises (permissão delegada ao dono do treino)
create policy "exercises_select_all"  on public.exercises for select using (true);
create policy "exercises_insert_own"  on public.exercises for insert with check (
  exists (select 1 from public.workouts where id = workout_id and owner_id = auth.uid())
);
create policy "exercises_update_own"  on public.exercises for update using (
  exists (select 1 from public.workouts where id = workout_id and owner_id = auth.uid())
);
create policy "exercises_delete_own"  on public.exercises for delete using (
  exists (select 1 from public.workouts where id = workout_id and owner_id = auth.uid())
);

-- schedule
create policy "schedule_select_all"   on public.schedule_entries for select using (true);
create policy "schedule_insert_own"   on public.schedule_entries for insert with check (auth.uid() = owner_id);
create policy "schedule_update_own"   on public.schedule_entries for update using (auth.uid() = owner_id);
create policy "schedule_delete_own"   on public.schedule_entries for delete using (auth.uid() = owner_id);

-- ============================================================
-- Trigger: cria profile automaticamente ao criar usuário
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================================
-- CONFIGURAÇÕES NO SUPABASE DASHBOARD
-- ============================================================
-- 1. Authentication → URL Configuration:
--    Site URL: https://seudominio.com (ou http://localhost:3000 em dev)
--    Redirect URLs: http://localhost:3000/confirm, https://seudominio.com/confirm
--
-- 2. Não é necessário configurar SMTP para testes —
--    o Supabase tem um servidor de email interno para desenvolvimento.
--    Para produção, configure um provedor SMTP em Authentication → Email.
-- ============================================================
