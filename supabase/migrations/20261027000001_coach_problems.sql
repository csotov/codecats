-- Problems the coach (admin) uploads: own problems with hidden tests, or
-- Codeforces links verified through the public Codeforces API.
create table if not exists public.coach_problems (
  id uuid primary key default gen_random_uuid(),
  created_by uuid default auth.uid() references auth.users(id) on delete set null,
  title text not null,
  statement text not null default '',
  input_desc text not null default '',
  output_desc text not null default '',
  samples jsonb not null default '[]',
  tests jsonb not null default '[]',
  hints jsonb not null default '[]',
  topic text not null default '',
  xp int not null default 150,
  cf_contest int,
  cf_index text,
  created_at timestamptz not null default now()
);
alter table public.coach_problems enable row level security;
create policy "signed-in read coach problems" on public.coach_problems
  for select using (auth.uid() is not null);
create policy "admin insert coach problems" on public.coach_problems
  for insert with check (public.is_admin());
create policy "admin update coach problems" on public.coach_problems
  for update using (public.is_admin());
create policy "admin delete coach problems" on public.coach_problems
  for delete using (public.is_admin());
