-- Adults who get the admin role automatically when they sign up.
create table if not exists public.admin_emails (
  email text primary key
);
alter table public.admin_emails enable row level security;
-- No policies on purpose: only the trigger (security definer) reads it.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $$
begin
  insert into public.profiles (id, display_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', 'Jugador'),
    case when exists (
      select 1 from public.admin_emails a where lower(a.email) = lower(new.email)
    ) then 'admin' else 'student' end
  )
  on conflict (id) do nothing;
  return new;
end $$;
