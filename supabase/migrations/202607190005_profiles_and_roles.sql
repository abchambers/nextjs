create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'student' check (role in ('student', 'forecaster', 'reviewer', 'admin')),
  created_at timestamptz not null default now()
);

insert into public.profiles (id, email)
select id, email from auth.users
on conflict (id) do nothing;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email);
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

alter table public.profiles enable row level security;
grant select on public.profiles to authenticated;

create policy "Users read their profile" on public.profiles
  for select using (id = auth.uid() or public.is_admin());
create policy "Admins manage profiles" on public.profiles
  for all using (public.is_admin()) with check (public.is_admin());
