-- ============================================================
-- Seed: perfil "Anna Julya" — Iniciante, Foco em Inferiores
-- Plano: 5 dias (seg/ter/qua/sex/sab) | Qui e Dom = descanso
-- Estrutura: 3x Lower Body + 2x Upper Body
--
-- ANTES de rodar: certifique-se de ter rodado migration-add-rest.sql
-- ============================================================

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

  -- profile criado pelo trigger; garante username/display corretos
  update public.profiles
    set username = v_username, display_name = v_display
    where id = v_user_id;

  -- 2. Treinos
  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'LOWER BODY A', 'A', 'Glúteo · Posterior · Quadríceps', 0)
    returning id into v_lower_a;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'UPPER BODY A', 'B', 'Costas · Bíceps · Abdômen', 1)
    returning id into v_upper_a;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'LOWER BODY B', 'C', 'Quadríceps · Glúteo · Adutores', 2)
    returning id into v_lower_b;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'UPPER BODY B', 'D', 'Ombros · Tríceps · Abdômen', 3)
    returning id into v_upper_b;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_user_id, 'LOWER BODY C', 'E', 'Glúteo · Perna · Acessórios (Leve)', 4)
    returning id into v_lower_c;

  -- 3. Exercícios — LOWER BODY A (Segunda)
  -- Foco: glúteo e posterior de coxa. Exercícios compostos pesados.
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_a, 'Agachamento no Smith', '4', '10-12', '2 min', 'Desça até 90° ou abaixo. Foco no glúteo e quadríceps. Pesquise "agachamento smith máquina" no YouTube.', 0),
    (v_lower_a, 'Elevação de Quadril (Hip Thrust)', '4', '12-15', '1.5 min', 'Aperte o glúteo no topo e segure 1 segundo. O exercício mais eficaz para o bumbum. Pesquise "hip thrust iniciante".', 1),
    (v_lower_a, 'Cadeira Flexora (Leg Curl)', '3', '12-15', '1.5 min', 'Movimento lento — 2s descendo. Foco no posterior de coxa.', 2),
    (v_lower_a, 'Stiff com Halteres', '3', '12', '1.5 min', 'Costas retas, joelhos levemente dobrados. Sinta o alongamento no posterior de coxa ao descer.', 3);

  -- Exercícios — UPPER BODY A (Terça)
  -- Foco: costas e bíceps. Volume moderado, peso acessível.
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_upper_a, 'Puxada Alta na Polia', '4', '10-12', '1.5 min', 'Puxe a barra até o peito. Foco nas costas, não nos braços. Pesquise "puxada frente iniciante".', 0),
    (v_upper_a, 'Remada na Máquina', '3', '12', '1.5 min', 'Puxe os cotovelos para trás e aperte as escápulas. Peito encostado no apoio.', 1),
    (v_upper_a, 'Rosca Direta com Halteres', '3', '12-15', '1 min', 'Cotovelos fixos ao lado do corpo. Suba e desça com controle.', 2),
    (v_upper_a, 'Prancha no Cotovelo', '3', '30 seg', '1 min', 'Corpo reto do calcanhar até o ombro. Respire normalmente. Pesquise "prancha isométrica".', 3);

  -- Exercícios — LOWER BODY B (Quarta)
  -- Foco: quadríceps e glúteo. Volume médio, máquinas acessíveis.
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_b, 'Leg Press 45°', '4', '12-15', '2 min', 'Pés na largura dos ombros. Desça até 90° de joelho — não trave os joelhos no topo.', 0),
    (v_lower_b, 'Cadeira Extensora', '3', '12-15', '1.5 min', 'Pausa de 1 segundo no topo. Sinta o quadríceps contraindo.', 1),
    (v_lower_b, 'Agachamento Sumô com Haltere', '3', '15', '1.5 min', 'Pés bem abertos, dedos apontados para fora. Foco no glúteo e na parte interna da coxa.', 2),
    (v_lower_b, 'Panturrilha em Pé na Máquina', '3', '15-20', '1 min', 'Amplitude total — desça bem e suba na ponta dos pés. Movimento lento.', 3);

  -- Exercícios — UPPER BODY B (Sexta)
  -- Foco: ombros e tríceps. Treino mais curto, peso leve.
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_upper_b, 'Desenvolvimento de Ombros com Halteres', '3', '10-12', '1.5 min', 'Sentada, empurre para cima sem travar os cotovelos no topo. Peso acessível.', 0),
    (v_upper_b, 'Elevação Lateral com Halteres', '3', '12-15', '1 min', 'Peso bem leve. Cotovelos ligeiramente dobrados, suba até a altura dos ombros.', 1),
    (v_upper_b, 'Tríceps na Polia (Corda)', '3', '12-15', '1 min', 'Cotovelo fixo ao lado do corpo. Estenda o braço completamente.', 2),
    (v_upper_b, 'Abdominal Crunch na Máquina', '3', '15-20', '1 min', 'Movimento curto e controlado. Não force o pescoço — foco no abdômen.', 3);

  -- Exercícios — LOWER BODY C (Sábado)
  -- Foco: glúteo leve + acessórios. Treino mais curto para fechar a semana.
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_c, 'Abdução de Quadril na Máquina', '3', '15-20', '1 min', 'Peso leve. Foco na parte lateral do glúteo (glúteo médio). Movimento controlado.', 0),
    (v_lower_c, 'Elevação de Quadril no Chão (sem peso)', '3', '20', '1 min', 'Deitada de costas, pés no chão. Suba o quadril e aperte o glúteo no topo. Pesquise "glute bridge".', 1),
    (v_lower_c, 'Afundo com Halteres', '3', '10 por perna', '1.5 min', 'Dê um passo à frente, joelho traseiro quase toca o chão. Suba com controle. Pesquise "avanço ou afundo iniciante".', 2),
    (v_lower_c, 'Cadeira Extensora (Leve)', '3', '15-20', '1 min', 'Peso mais leve que quarta. Complemento de quadríceps para fechar a semana.', 3);

  -- 4. Escala semanal
  insert into public.schedule_entries (owner_id, day_key, workout_id) values
    (v_user_id, 'mon', v_lower_a),
    (v_user_id, 'tue', v_upper_a),
    (v_user_id, 'wed', v_lower_b),
    (v_user_id, 'fri', v_upper_b),
    (v_user_id, 'sat', v_lower_c);

  raise notice 'Perfil criado: % / username=% / senha=%', v_email, v_username, v_pass;
end $$;
