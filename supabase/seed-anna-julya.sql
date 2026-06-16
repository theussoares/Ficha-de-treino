-- ============================================================
-- Seed: perfil "Anna Julya" — Hipertrofia de Pernas (5 dias)
-- Rode no SQL Editor do seu projeto Supabase.
--
-- Cria um usuário novo (email/senha abaixo), o profile, os 5
-- treinos com todos os exercícios (séries/reps/descanso/técnica)
-- e a escala semanal. Troque o e-mail/senha/username conforme
-- necessário antes de rodar.
-- ============================================================

-- Se ainda não rodou a migration do campo "rest", rode primeiro:
-- alter table public.exercises add column if not exists rest text;

do $$
declare
  v_user_id uuid := gen_random_uuid();
  v_email   text := 'anna.julya@fichatreino.com';
  v_pass    text := 'annajulya123';
  v_username text := 'annajulya';
  v_display  text := 'Anna Julya';

  v_lower_a uuid;
  v_upper_a uuid;
  v_lower_b uuid;
  v_upper_b uuid;
  v_lower_c uuid;
begin
  -- 1. Usuário de autenticação
  insert into auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, confirmation_token, recovery_token
  ) values (
    v_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    v_email, crypt(v_pass, gen_salt('bf')),
    now(), '{"provider":"email","providers":["email"]}',
    jsonb_build_object('username', v_username, 'display_name', v_display),
    now(), now(), '', ''
  );

  insert into auth.identities (
    id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
  ) values (
    gen_random_uuid(), v_user_id, v_user_id::text,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email),
    'email', now(), now(), now()
  );

  -- 2. Profile (o trigger handle_new_user já cria um profile básico; sobrescrevemos)
  update public.profiles
    set username = v_username, display_name = v_display
    where id = v_user_id;

  -- 3. Treinos
  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'LOWER BODY A', 'A', 'Quadríceps HEAVY', 0)
    returning id into v_lower_a;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'UPPER BODY A', 'B', 'Peito + Costas', 1)
    returning id into v_upper_a;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'LOWER BODY B', 'C', 'Glúteo + Posterior HEAVY', 2)
    returning id into v_lower_b;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'UPPER BODY B', 'D', 'Ombro + Braço', 3)
    returning id into v_upper_b;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'LOWER BODY C', 'E', 'Pernas (Leve / Accessories)', 4)
    returning id into v_lower_c;

  -- 4. Exercícios — LOWER BODY A (Segunda)
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_a, 'Agachamento Livre', '4', '6-8', '3-4 min', 'Pausa 1s no fundo. ROM ≥90°. Foco controle, não velocidade.', 0),
    (v_lower_a, 'Leg Press', '3', '8-10', '2-3 min', 'Última série com DROP SET: atinge falha → reduz 25% peso → mais 6-8 reps.', 1),
    (v_lower_a, 'Leg Extension', '3', '10-12', '1.5-2 min', 'Pausa 1s na extensão máxima. Sinta o quadríceps queimar.', 2),
    (v_lower_a, 'Caminhada com Halter (Avanço)', '2', '12 por perna', '1.5 min', 'Controlada, sem balanço. Perna traseira quase toca o chão.', 3);

  -- Exercícios — UPPER BODY A (Terça)
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_upper_a, 'Supino (Haltere ou Barra)', '4', '6-8', '2.5-3 min', 'ROM máxima, pausa 1s no peito.', 0),
    (v_upper_a, 'Puxada na Frente (ou Barra Fixa)', '3', '8-10', '2 min', 'Controlada, foco nas costas (não no braço).', 1),
    (v_upper_a, 'Rosca Inclinada (Haltere)', '3', '10-12', '1.5 min', 'Pico máximo de contração, pausa 1s.', 2),
    (v_upper_a, 'Remada Sentada (ou Máquina)', '2', '12-15', '1.5 min', 'Leve, foco na contração dorsal.', 3);

  -- Exercícios — LOWER BODY B (Quarta)
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_b, 'Deadlift Romeno (ou Convencional)', '4', '5-8', '3-4 min', 'Pausa 1s no topo. Sinta o glúteo e o posterior contraindo — foco não é nas costas.', 0),
    (v_lower_b, 'Hip Thrust (Elevação de Glúteo)', '3', '10-12', '2 min', 'Pausa 2-3s no topo. Squeeze máximo no glúteo.', 1),
    (v_lower_b, 'Leg Curl Deitado', '3', '8-10', '2 min', 'ROM completa, pausa 1s no pico. Posterior de coxa queimando.', 2),
    (v_lower_b, 'Leg Curl Máquina + Cadeira Extensora (SUPERSÉRIE)', '2', '10 + 10', '1.5 min', 'Sem descanso entre os dois — bomba metabólica = crescimento.', 3);

  -- Exercícios — UPPER BODY B (Sexta)
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_upper_b, 'Desenvolvimento Militar (Haltere ou Smith)', '3', '6-8', '2.5 min', 'Controlado, ombros para trás (não para o pescoço).', 0),
    (v_upper_b, 'Elevação Lateral', '3', '12-15', '1.5 min', 'Peso leve, foco na sensação. Cotovelos levemente dobrados.', 1),
    (v_upper_b, 'Rosca Direta + Tríceps Corda (SUPERSÉRIE)', '3', '10 + 10', '1.5 min', 'Sem descanso entre os dois. Bíceps + tríceps = braço completo.', 2),
    (v_upper_b, 'Rosca Inversa (Posterior + Antebraço)', '2', '12-15', '1 min', 'Controlada, leve. O antebraço também cresce.', 3);

  -- Exercícios — LOWER BODY C (Sábado)
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_c, 'Leg Press (ou Smith Agachamento)', '3', '10-12', '1.5-2 min', 'Pausa 1s no fundo. Foco na conexão mente-músculo.', 0),
    (v_lower_c, 'Adutor Máquina + Abdutor (SUPERSÉRIE)', '2', '15 cada', '1.5 min', 'Bomba metabólica — sem descanso entre os dois.', 1),
    (v_lower_c, 'Leg Extension Unilateral', '2', '12 por perna', '1.5 min', 'Uma perna por vez, maior adução. Sinta cada perna isoladamente.', 2),
    (v_lower_c, 'Cadeira Extensora + Leg Curl Máquina (DROP SET)', '2', '12 + drop 8', '1.5 min', 'Extensão até a falha → reduz peso → leg curl até a falha. Quadríceps + posterior.', 3);

  -- 5. Escala semanal (quinta e domingo ficam de fora = descanso)
  insert into public.schedule_entries (owner_id, day_key, workout_id) values
    (v_user_id, 'mon', v_lower_a),
    (v_user_id, 'tue', v_upper_a),
    (v_user_id, 'wed', v_lower_b),
    (v_user_id, 'fri', v_upper_b),
    (v_user_id, 'sat', v_lower_c);

  raise notice 'Perfil criado: % / username=% / senha=%', v_email, v_username, v_pass;
end $$;
