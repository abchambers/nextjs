-- One-time owner bootstrap. This runs against the authenticated Supabase user,
-- not a browser session, so the role persists across devices and deployments.
insert into public.profiles (id, email, role)
select id, email, 'admin'
from auth.users
where email = 'drew.chamberz@gmail.com'
on conflict (id) do update
set email = excluded.email,
    role = 'admin';
