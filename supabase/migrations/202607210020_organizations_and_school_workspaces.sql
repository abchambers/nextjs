-- Organization and classroom foundation.
-- Existing personal forecast runs remain valid: organization_id and classroom_id
-- are nullable until a forecast is deliberately created inside a workspace.

alter table public.profiles
  drop constraint if exists profiles_role_check;

alter table public.profiles
  alter column role set default 'member',
  add constraint profiles_role_check
    check (role in ('owner', 'admin', 'instructor', 'reviewer', 'forecaster', 'student', 'member'));

create or replace function public.is_owner()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'owner');
$$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role in ('owner', 'admin'));
$$;

create or replace function public.protect_owner_role()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' and old.role = 'owner' and new.role is distinct from 'owner' then
    raise exception 'The owner role cannot be removed through the application.';
  end if;
  if new.role = 'owner' and coalesce(old.role, '') <> 'owner' and auth.uid() is not null and not public.is_owner() then
    raise exception 'Only the existing owner can assign the owner role.';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_owner_role on public.profiles;
create trigger profiles_protect_owner_role
  before insert or update on public.profiles
  for each row execute procedure public.protect_owner_role();

-- The designated account is the platform owner across every organization.
insert into public.profiles (id, email, role)
select id, email, 'owner'
from auth.users
where email = 'drew.chamberz@gmail.com'
on conflict (id) do update
set email = excluded.email,
    role = 'owner';

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  kind text not null check (kind in ('company', 'school', 'personal')),
  visibility text not null default 'private' check (visibility in ('private', 'shared', 'public')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table public.organization_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'admin', 'instructor', 'reviewer', 'forecaster', 'student', 'member')),
  status text not null default 'active' check (status in ('active', 'invited', 'suspended')),
  created_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create table public.classrooms (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null,
  term text,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (organization_id, name, term)
);

create table public.classroom_memberships (
  id uuid primary key default gen_random_uuid(),
  classroom_id uuid not null references public.classrooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'student' check (role in ('instructor', 'student', 'assistant')),
  status text not null default 'active' check (status in ('active', 'invited', 'suspended')),
  created_at timestamptz not null default now(),
  unique (classroom_id, user_id)
);

-- Store only a hash of a code. The future join endpoint verifies it server-side;
-- clients never receive a reusable school or classroom code from this table.
create table public.workspace_join_codes (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete cascade,
  classroom_id uuid references public.classrooms(id) on delete cascade,
  code_hash text not null unique,
  default_role text not null default 'student' check (default_role in ('member', 'student', 'forecaster')),
  expires_at timestamptz,
  max_uses integer,
  use_count integer not null default 0,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  check (num_nonnulls(organization_id, classroom_id) = 1),
  check (max_uses is null or max_uses > 0)
);

create table public.forecast_reviews (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.forecast_runs(id) on delete cascade,
  reviewer_id uuid not null references auth.users(id) on delete cascade,
  comment text,
  manual_score numeric(5,2) check (manual_score between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (comment is not null or manual_score is not null)
);

alter table public.forecast_runs
  add column if not exists organization_id uuid references public.organizations(id) on delete set null,
  add column if not exists classroom_id uuid references public.classrooms(id) on delete set null,
  add column if not exists publication_scope text not null default 'private' check (publication_scope in ('private', 'class', 'school_shared', 'company_review', 'company_public')),
  add column if not exists published_by uuid references auth.users(id) on delete set null;

create index forecast_runs_organization_created_idx on public.forecast_runs (organization_id, created_at desc);
create index forecast_runs_classroom_created_idx on public.forecast_runs (classroom_id, created_at desc);
create index organization_memberships_user_idx on public.organization_memberships (user_id, organization_id);
create index classroom_memberships_user_idx on public.classroom_memberships (user_id, classroom_id);
create index forecast_reviews_run_idx on public.forecast_reviews (run_id, created_at desc);

create or replace function public.can_view_organization(target_organization uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_owner() or exists (
    select 1 from public.organization_memberships
    where organization_id = target_organization and user_id = auth.uid() and status = 'active'
  );
$$;

create or replace function public.can_manage_organization(target_organization uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_owner() or public.is_admin() or exists (
    select 1 from public.organization_memberships
    where organization_id = target_organization and user_id = auth.uid()
      and status = 'active' and role in ('owner', 'admin', 'instructor')
  );
$$;

create or replace function public.can_view_classroom(target_classroom uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_owner() or exists (
    select 1 from public.classroom_memberships
    where classroom_id = target_classroom and user_id = auth.uid() and status = 'active'
  ) or exists (
    select 1 from public.classrooms c
    where c.id = target_classroom and public.can_manage_organization(c.organization_id)
  );
$$;

alter table public.organizations enable row level security;
alter table public.organization_memberships enable row level security;
alter table public.classrooms enable row level security;
alter table public.classroom_memberships enable row level security;
alter table public.workspace_join_codes enable row level security;
alter table public.forecast_reviews enable row level security;

grant select, insert, update, delete on public.organizations, public.organization_memberships, public.classrooms, public.classroom_memberships, public.forecast_reviews to authenticated;

create policy "Organization members read their organizations" on public.organizations
  for select using (public.can_view_organization(id));
create policy "Organization managers manage organizations" on public.organizations
  for all using (public.can_manage_organization(id)) with check (public.is_admin() or public.can_manage_organization(id));

create policy "Organization members read memberships" on public.organization_memberships
  for select using (public.can_view_organization(organization_id));
create policy "Organization managers manage memberships" on public.organization_memberships
  for all using (public.can_manage_organization(organization_id)) with check (public.can_manage_organization(organization_id));

create policy "Organization members read classrooms" on public.classrooms
  for select using (public.can_view_organization(organization_id));
create policy "Organization managers manage classrooms" on public.classrooms
  for all using (public.can_manage_organization(organization_id)) with check (public.can_manage_organization(organization_id));

create policy "Classroom members read roster" on public.classroom_memberships
  for select using (public.can_view_classroom(classroom_id));
create policy "Classroom managers manage roster" on public.classroom_memberships
  for all using (exists (select 1 from public.classrooms c where c.id = classroom_id and public.can_manage_organization(c.organization_id)))
  with check (exists (select 1 from public.classrooms c where c.id = classroom_id and public.can_manage_organization(c.organization_id)));

-- Join-code reads and redemptions are intentionally server-only until the
-- invitation endpoint is implemented.
create policy "Owners manage join codes" on public.workspace_join_codes
  for all using (public.is_owner()) with check (public.is_owner());

create policy "Authors and owners read reviews" on public.forecast_reviews
  for select using (public.is_owner() or reviewer_id = auth.uid() or exists (select 1 from public.forecast_runs r where r.id = run_id and r.user_id = auth.uid()));
create policy "Users write their reviews" on public.forecast_reviews
  for insert with check (reviewer_id = auth.uid() or public.is_owner());
create policy "Reviewers and owners update reviews" on public.forecast_reviews
  for update using (reviewer_id = auth.uid() or public.is_owner()) with check (reviewer_id = auth.uid() or public.is_owner());
create policy "Reviewers and owners delete reviews" on public.forecast_reviews
  for delete using (reviewer_id = auth.uid() or public.is_owner());

create policy "Owner can manage all forecast runs" on public.forecast_runs
  for all using (public.is_owner()) with check (public.is_owner());
create policy "Owner can manage all forecast periods" on public.forecast_periods
  for all using (public.is_owner()) with check (public.is_owner());
create policy "Owner can manage all forecast verification" on public.forecast_verifications
  for all using (public.is_owner()) with check (public.is_owner());
