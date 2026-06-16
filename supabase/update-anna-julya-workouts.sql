-- ============================================================
-- Update: treinos da Anna Julya — Iniciante, Foco em Inferiores
-- Estrutura Breaking My Limits: 3x Lower + 2x Upper
--   Seg = Inferiores A (Posteriores da Coxa)
--   Ter = Superiores A (Ombros)
--   Qua = Inferiores B (Quadríceps)
--   Qui = Descanso
--   Sex = Superiores B (Costas)
--   Sab = Inferiores C (Glúteos)
--   Dom = Descanso
-- ============================================================

do $$
declare
  v_owner_id uuid;
  v_lower_a uuid;
  v_upper_a uuid;
  v_lower_b uuid;
  v_upper_b uuid;
  v_lower_c uuid;
begin
  select id into v_owner_id from public.profiles where username = 'annajulya';
  if v_owner_id is null then
    raise exception 'Perfil "annajulya" não encontrado.';
  end if;

  delete from public.schedule_entries where owner_id = v_owner_id;
  delete from public.workouts where owner_id = v_owner_id;

  -- ── Treinos ────────────────────────────────────────────────
  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'INFERIORES A', 'A', 'Posteriores da Coxa · Glúteo · Panturrilha', 0)
    returning id into v_lower_a;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'SUPERIORES A', 'B', 'Ombros · Costas · Bíceps · Tríceps', 1)
    returning id into v_upper_a;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'INFERIORES B', 'C', 'Quadríceps · Glúteo · Abdômen', 2)
    returning id into v_lower_b;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'SUPERIORES B', 'D', 'Costas · Peito · Ombros · Braços', 3)
    returning id into v_upper_b;

  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'INFERIORES C', 'E', 'Glúteos · Adutores · Posteriores · Abdômen', 4)
    returning id into v_lower_c;

  -- ── Segunda: INFERIORES A — Ênfase nos Posteriores da Coxa ─
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_a, 'Stiff com Halteres', '3', '10-12', '2 min',
      'Costas retas, joelhos levemente dobrados. Desça os halteres pelo corpo sentindo o alongamento no posterior de coxa. Pesquise "stiff halteres" no YouTube.', 0),
    (v_lower_a, 'Cadeira Flexora (Leg Curl)', '3', '12-15', '1.5 min',
      'Desce lentamente (2 segundos). Foco total no posterior de coxa.', 1),
    (v_lower_a, 'Leg Press 45°', '3', '12-15', '2 min',
      'Pés na largura dos ombros, desça até 90° de joelho. Não trave os joelhos no topo.', 2),
    (v_lower_a, 'Abdução de Quadril na Máquina', '3', '15-20', '1 min',
      'Peso leve. Abre as pernas contra a resistência. Foco no glúteo médio (lateral do bumbum).', 3),
    (v_lower_a, 'Panturrilha em Pé na Máquina', '3', '15-20', '1 min',
      'Amplitude total — desce bem e sobe na ponta dos pés. Movimento lento.', 4);

  -- ── Terça: SUPERIORES A — Ênfase nos Ombros ───────────────
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_upper_a, 'Desenvolvimento de Ombros com Halteres', '3', '10-12', '1.5 min',
      'Sentada, empurre os halteres para cima. Não trave os cotovelos no topo. Peso acessível para iniciante. Pesquise "desenvolvimento halteres iniciante".', 0),
    (v_upper_a, 'Elevação Lateral com Halteres', '3', '12-15', '1 min',
      'Peso bem leve. Cotovelos levemente dobrados. Suba até a altura dos ombros. Foco no ombro lateral.', 1),
    (v_upper_a, 'Face Pull na Polia (Corda)', '3', '12-15', '1 min',
      'Puxa a corda em direção ao rosto, abrindo os cotovelos. Foco no ombro posterior. Pesquise "face pull polia".', 2),
    (v_upper_a, 'Puxada Alta na Polia (pegada larga)', '3', '10-12', '1.5 min',
      'Puxa a barra até o peito. Cotovelos abertos para os lados. Foco nas costas. Pesquise "puxada frente pegada aberta".', 3),
    (v_upper_a, 'Rosca Direta com Halteres', '3', '12-15', '1 min',
      'Cotovelos fixos ao lado do corpo. Suba e desça com controle.', 4),
    (v_upper_a, 'Tríceps na Polia (Corda)', '3', '12-15', '1 min',
      'Cotovelo fixo, estenda o braço completamente. Separa a corda no final do movimento.', 5);

  -- ── Quarta: INFERIORES B — Ênfase nos Quadríceps ──────────
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_b, 'Agachamento no Smith', '3', '10-12', '2 min',
      'Desça até 90° ou mais fundo. Joelhos seguindo a direção dos pés. Pesquise "agachamento smith máquina" no YouTube.', 0),
    (v_lower_b, 'Cadeira Extensora', '3', '12-15', '1.5 min',
      'Pausa de 1 segundo no topo. Sinta o quadríceps contrair. Desce com controle.', 1),
    (v_lower_b, 'Afundo com Halteres', '3', '10 por perna', '1.5 min',
      'Dê um passo à frente, desça o joelho traseiro quase até o chão. Suba com controle. Pesquise "afundo ou avanço halteres".', 2),
    (v_lower_b, 'Cadeira Flexora (Leg Curl)', '3', '12-15', '1.5 min',
      'Complemento de posterior de coxa. Movimento lento e controlado.', 3),
    (v_lower_b, 'Abdominal Crunch na Máquina', '3', '15-20', '1 min',
      'Movimento curto e controlado. Não force o pescoço — foco no abdômen.', 4),
    (v_lower_b, 'Panturrilha em Pé na Máquina', '3', '15-20', '1 min',
      'Amplitude total. Igual à segunda.', 5);

  -- ── Sexta: SUPERIORES B — Ênfase nas Costas ───────────────
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_upper_b, 'Remada na Máquina (pegada aberta)', '3', '10-12', '1.5 min',
      'Cotovelos para os lados ao puxar. Aperte as escápulas no final. Foco nas costas superiores. Pesquise "remada máquina pegada aberta".', 0),
    (v_upper_b, 'Puxada Alta na Polia (pegada fechada)', '3', '10-12', '1.5 min',
      'Cotovelos junto ao tronco ao puxar. Foco na parte central das costas. Pesquise "puxada polia pegada fechada".', 1),
    (v_upper_b, 'Supino na Máquina', '3', '12-15', '1.5 min',
      'Amplitude total — sinta o alongamento no peito. Não bata os pesos no topo. Pesquise "supino máquina".', 2),
    (v_upper_b, 'Crucifixo (Voador) na Máquina', '3', '12-15', '1 min',
      'Braços levemente dobrados. Foco no peito. Abra e feche de forma controlada.', 3),
    (v_upper_b, 'Rosca Direta com Halteres', '3', '12-15', '1 min',
      'Mesmo movimento da terça. Cotovelos fixos.', 4),
    (v_upper_b, 'Tríceps na Polia (Corda)', '3', '12-15', '1 min',
      'Mesmo movimento da terça.', 5);

  -- ── Sábado: INFERIORES C — Ênfase nos Glúteos ─────────────
  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_lower_c, 'Elevação de Quadril (Hip Thrust)', '4', '12-15', '1.5 min',
      'O exercício número 1 para glúteo. Aperte o bumbum no topo e segure 1 segundo. Pesquise "hip thrust iniciante" no YouTube.', 0),
    (v_lower_c, 'Agachamento Sumô com Haltere', '3', '15', '1.5 min',
      'Pés bem abertos, dedos apontados para fora. Desça fundo. Foco no glúteo e na parte interna da coxa.', 1),
    (v_lower_c, 'Afundo com Halteres', '3', '10 por perna', '1.5 min',
      'Igual à quarta, mas como exercício principal. Foco no glúteo ao empurrar de volta.', 2),
    (v_lower_c, 'Cadeira Flexora (Leg Curl)', '3', '12-15', '1.5 min',
      'Complemento de posterior de coxa. Movimento controlado.', 3),
    (v_lower_c, 'Abdução de Quadril na Máquina', '3', '15-20', '1 min',
      'Igual à segunda. Glúteo médio. Fecha a semana de inferiores.', 4),
    (v_lower_c, 'Abdominal Crunch na Máquina', '3', '15-20', '1 min',
      'Abdômen para fechar. Movimento curto e controlado.', 5);

  -- ── Escala semanal ─────────────────────────────────────────
  insert into public.schedule_entries (owner_id, day_key, workout_id) values
    (v_owner_id, 'mon', v_lower_a),
    (v_owner_id, 'tue', v_upper_a),
    (v_owner_id, 'wed', v_lower_b),
    (v_owner_id, 'fri', v_upper_b),
    (v_owner_id, 'sat', v_lower_c);

  raise notice 'Treinos da Anna Julya atualizados com sucesso!';
end $$;
