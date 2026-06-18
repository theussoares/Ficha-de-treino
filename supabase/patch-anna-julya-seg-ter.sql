-- ============================================================
-- Patch: atualiza segunda e terça da Anna Julya
--   Seg = Treino Glúteos (Hip Thrust, Sumô, Bom Dia, Búlgaro, Coice, Abdutora)
--   Ter = Costas + Bíceps + Abdômen + Cardio
-- ============================================================

do $$
declare
  v_owner_id uuid;
  v_mon_id   uuid;
  v_tue_id   uuid;
begin
  select id into v_owner_id from public.profiles where username = 'annajulya';
  if v_owner_id is null then
    raise exception 'Perfil "annajulya" não encontrado.';
  end if;

  -- Remove escala dos dias que vamos substituir
  delete from public.schedule_entries
    where owner_id = v_owner_id and day_key in ('mon', 'tue');

  -- Remove os treinos antigos de segunda e terça
  -- (o workout_id usado nesses dias)
  delete from public.workouts
    where owner_id = v_owner_id and letter in ('A', 'B');

  -- ── SEGUNDA: Treino Glúteos ──────────────────────────────
  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'GLÚTEOS', 'A', 'Elevação Pélvica · Sumô · Bom Dia · Búlgaro · Coice · Abdutora', 0)
    returning id into v_mon_id;

  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    (v_mon_id, 'Elevação Pélvica (Hip Thrust)', '4', '12/10/8/8', '2 min',
      'Segura 2 segundos no topo. Aumenta a carga a cada série (pirâmide). Pesquise "hip thrust barra" no YouTube.', 0),
    (v_mon_id, 'Agachamento Sumô', '4', '10-12', '2 min',
      'Pés bem afastados, pontas dos pés levemente para fora. Desce o máximo mantendo a postura.', 1),
    (v_mon_id, 'Bom Dia (Good Morning)', '4', '12', '2 min',
      'Descida lenta em 3 segundos. Costas retas. Foco total no alongamento dos glúteos e posterior. Pesquise "bom dia glúteo" no YouTube.', 2),
    (v_mon_id, 'Búlgaro', '3', '10 por perna', '1.5 min',
      'Incline levemente o tronco para frente para recrutar mais glúteo. Pesquise "búlgaro agachamento" no YouTube.', 3),
    (v_mon_id, 'Coice na Polia', '4', '15 por perna', '1 min',
      'Segura 1 segundo na contração máxima. Quadril fixo, só a perna se move. Pesquise "coice polia glúteo".', 4),
    (v_mon_id, 'Cadeira Abdutora', '4', '20', '1 min',
      'Última série até a falha. Foco no glúteo médio (lateral do bumbum).', 5);

  -- ── TERÇA: Costas + Bíceps + Abdômen + Cardio ───────────
  insert into public.workouts (owner_id, name, letter, subtitle, position)
    values (v_owner_id, 'COSTAS + BÍCEPS', 'B', 'Costas · Bíceps · Abdômen · Cardio', 1)
    returning id into v_tue_id;

  insert into public.exercises (workout_id, name, sets, reps, rest, note, position) values
    -- Costas
    (v_tue_id, 'Puxada Frontal na Polia', '4', '10-12', '1.5 min',
      'Segura 1 segundo contraindo as costas no fim do movimento. Pesquise "puxada frontal polia".', 0),
    (v_tue_id, 'Remada Baixa Triângulo', '4', '10-12', '1.5 min',
      'Cotovelos próximos ao corpo. Puxa o triângulo em direção ao abdômen.', 1),
    (v_tue_id, 'Remada Máquina Articulada', '3', '10', '1.5 min',
      'Movimento controlado. Foco na contração das costas ao puxar.', 2),
    (v_tue_id, 'Pulldown na Polia', '3', '12-15', '1.5 min',
      'Puxa com os cotovelos para baixo e para o lado. Abre as dorsais. Pesquise "pulldown polia costas".', 3),
    (v_tue_id, 'Remada Curvada com Barra', '3', '8-10', '2 min',
      'Carga moderada a alta. Tronco inclinado ~45°. Cotovelos perto do corpo. Pesquise "remada curvada barra".', 4),
    -- Bíceps
    (v_tue_id, 'Rosca Direta Barra W', '4', '10', '1 min',
      'Barra W (EZ). Cotovelos fixos ao lado do corpo. Foco na contração do bíceps.', 5),
    (v_tue_id, 'Rosca Alternada com Halteres', '3', '12', '1 min',
      'Alterna os braços. Movimento completo, sem balançar o tronco.', 6),
    (v_tue_id, 'Rosca Martelo', '3', '12', '1 min',
      'Halteres na posição neutra (polegar para cima). Trabalha o braquial.', 7),
    (v_tue_id, 'Rosca Concentrada', '2', 'até a falha (cada braço)', '1 min',
      'Cotovelo apoiado na coxa. Foco máximo no bíceps. Execute até não conseguir mais.', 8),
    -- Abdômen
    (v_tue_id, 'Abdominal Infra no Banco', '3', '15', '1 min',
      'Deitada no banco, sobe os joelhos em direção ao peito. Foco na parte baixa do abdômen.', 9),
    (v_tue_id, 'Prancha no Cotovelo', '3', '40 seg', '1 min',
      'Corpo reto do calcanhar ao ombro. Respire normalmente durante os 40 segundos.', 10),
    -- Cardio
    (v_tue_id, 'Esteira (Cardio Finalizador)', null, '15 min', null,
      'Ritmo moderado para finalizar o treino. Pode usar intensidade de caminhada rápida ou trote leve.', 11);

  -- Recria a escala para os dois dias
  insert into public.schedule_entries (owner_id, day_key, workout_id) values
    (v_owner_id, 'mon', v_mon_id),
    (v_owner_id, 'tue', v_tue_id);

  raise notice 'Segunda e terça da Anna Julya atualizadas com sucesso!';
end $$;
