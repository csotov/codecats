-- Coaching decisions the admin applies or dismisses from the report
-- ("Aplicar" / "Descartar"). The game reads the applied ones of the
-- signed-in student, e.g. hint 1 visible from the start on a topic.
create table if not exists public.coach_tweaks (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  topic text not null,
  action text not null,
  status text not null check (status in ('applied', 'dismissed')),
  evidence text not null default '',
  created_by uuid default auth.uid() references auth.users(id) on delete set null,
  updated_at timestamptz not null default now(),
  unique (student_id, topic, action)
);
alter table public.coach_tweaks enable row level security;
create policy "own or admin read tweaks" on public.coach_tweaks
  for select using (student_id = auth.uid() or public.is_admin());
create policy "admin insert tweaks" on public.coach_tweaks
  for insert with check (public.is_admin());
create policy "admin update tweaks" on public.coach_tweaks
  for update using (public.is_admin());
create policy "admin delete tweaks" on public.coach_tweaks
  for delete using (public.is_admin());
