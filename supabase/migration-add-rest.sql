-- ============================================================
-- Migration: adiciona o campo "rest" (descanso) aos exercícios
-- Rode no SQL Editor do seu projeto Supabase (projeto já existente).
-- ============================================================

alter table public.exercises add column if not exists rest text;
