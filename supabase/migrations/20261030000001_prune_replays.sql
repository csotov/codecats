-- Code replays (type 'code_replay': every edit with its time, so the
-- admin can watch how the code was written) are the only heavy events.
-- Keep 60 days of them; the client calls this once per run.
create or replace function public.prune_replays() returns void
language sql security definer set search_path = public as $$
  delete from public.events
  where user_id = auth.uid() and type = 'code_replay'
    and ts < now() - interval '60 days';
$$;
revoke all on function public.prune_replays() from public;
grant execute on function public.prune_replays() to authenticated;
