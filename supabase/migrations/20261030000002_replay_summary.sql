-- Before a code replay older than 60 days is deleted, keep a permanent
-- 'replay_summary' per level visit so yearly statistics still have it:
-- length, edits, letters typed/deleted, big inserts (pastes), pauses,
-- delay before the first edit and time actually typing.
create or replace function public.prune_replays() returns void
language plpgsql security definer set search_path = public as $$
declare cutoff timestamptz := now() - interval '60 days';
begin
  with ops as (
    select e.user_id, e.session_id, e.level_id, e.data->>'t0' as t0,
           (op->>0)::bigint as ms, (op->>2)::int as dl,
           length(op->>3) as il
    from public.events e, jsonb_array_elements(e.data->'ops') op
    where e.user_id = auth.uid() and e.type = 'code_replay'
      and e.ts < cutoff and e.data ? 't0'
  ), g as (
    select *, ms - lag(ms) over (
      partition by user_id, level_id, t0 order by ms) as gap
    from ops
  )
  insert into public.events (user_id, session_id, ts, type, level_id, data)
  select user_id, min(session_id), t0::timestamptz, 'replay_summary',
         level_id,
         jsonb_build_object(
           't0', t0, 'ms', max(ms), 'edits', count(*),
           'ins', sum(il), 'del', sum(dl),
           'big_ins', count(*) filter (where il >= 25),
           'pauses10', count(*) filter (where gap > 10000),
           'pauses60', count(*) filter (where gap > 60000),
           'maxGap', coalesce(max(gap), 0), 'first', min(ms),
           'typeMs', coalesce(sum(gap) filter (where gap <= 5000), 0))
  from g group by user_id, level_id, t0;

  delete from public.events
  where user_id = auth.uid() and type = 'code_replay' and ts < cutoff;
end;
$$;
revoke all on function public.prune_replays() from public;
grant execute on function public.prune_replays() to authenticated;
