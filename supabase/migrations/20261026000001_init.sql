-- CodeCats: accounts, cloud progress and telemetry.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Jugador',
  role text not null default 'student' check (role in ('student','admin')),
  created_at timestamptz not null default now()
);
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', 'Jugador'))
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- One JSON snapshot per user: the same blob Progress saves locally.
create table if not exists public.progress_snapshots (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

-- Fine-grained gameplay events (typing, errors, modes, memes, time).
create table if not exists public.events (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  session_id text not null,
  ts timestamptz not null default now(),
  type text not null,
  level_id text,
  data jsonb not null default '{}'::jsonb
);
create index if not exists events_user_ts on public.events(user_id, ts desc);
create index if not exists events_type on public.events(type);

alter table public.profiles enable row level security;
alter table public.progress_snapshots enable row level security;
alter table public.events enable row level security;

create policy "own or admin read profiles" on public.profiles for select
  using (id = auth.uid() or public.is_admin());
create policy "own update profile" on public.profiles for update
  using (id = auth.uid()) with check (id = auth.uid() and role = (select role from public.profiles where id = auth.uid()));

create policy "own or admin read snapshot" on public.progress_snapshots for select
  using (user_id = auth.uid() or public.is_admin());
create policy "own write snapshot" on public.progress_snapshots for insert
  with check (user_id = auth.uid());
create policy "own update snapshot" on public.progress_snapshots for update
  using (user_id = auth.uid());

create policy "own or admin read events" on public.events for select
  using (user_id = auth.uid() or public.is_admin());
create policy "own insert events" on public.events for insert
  with check (user_id = auth.uid());

-- Admin summary: per user, per level aggregates (RPC keeps the client simple).
create or replace function public.admin_level_stats(p_user uuid)
returns table (level_id text, opens bigint, seconds numeric, fights bigint, wins bigint,
               hints bigint, compile_errors bigint, code_seconds numeric, blocks_seconds numeric,
               keystrokes bigint, backspaces bigint)
language sql stable security definer set search_path = public as $$
  select level_id,
    count(*) filter (where type = 'level_open'),
    coalesce(sum((data->>'seconds')::numeric) filter (where type = 'level_leave'), 0),
    count(*) filter (where type = 'fight'),
    count(*) filter (where type = 'fight' and (data->>'won')::boolean),
    count(*) filter (where type = 'hint_buy'),
    count(*) filter (where type = 'compile_error'),
    coalesce(sum((data->>'code')::numeric) filter (where type = 'level_leave'), 0),
    coalesce(sum((data->>'blocks')::numeric) filter (where type = 'level_leave'), 0),
    coalesce(sum((data->>'keys')::bigint) filter (where type = 'typing'), 0),
    coalesce(sum((data->>'backspaces')::bigint) filter (where type = 'typing'), 0)
  from public.events
  where user_id = p_user and level_id is not null
    and (p_user = auth.uid() or public.is_admin())
  group by level_id;
$$;
