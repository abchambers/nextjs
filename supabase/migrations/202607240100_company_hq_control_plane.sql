-- Company HQ is a separate application, but it uses the same Frontline Forecast
-- identity and owner role. These records are intentionally not exposed to the
-- public product interface.

create table if not exists public.hq_accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  service text not null check (char_length(trim(service)) between 1 and 120),
  url text,
  purpose text,
  access_owner text,
  billing_owner text,
  recovery_contact text,
  renewal_date date,
  access_review_date date,
  status text not null default 'Active' check (status in ('Active', 'Planned', 'Review required', 'Archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.hq_expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  vendor text not null check (char_length(trim(vendor)) between 1 and 120),
  category text not null check (char_length(trim(category)) between 1 and 120),
  amount numeric(12, 2) not null check (amount >= 0),
  cadence text not null check (cadence in ('One-time', 'Monthly', 'Annual', 'Usage-based')),
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.hq_accounts enable row level security;
alter table public.hq_expenses enable row level security;

grant select, insert, update, delete on public.hq_accounts to authenticated;
grant select, insert, update, delete on public.hq_expenses to authenticated;

create policy "Platform owners manage HQ accounts"
on public.hq_accounts
for all
to authenticated
using ((select public.is_owner()) and (select auth.uid()) = user_id)
with check ((select public.is_owner()) and (select auth.uid()) = user_id);

create policy "Platform owners manage HQ expenses"
on public.hq_expenses
for all
to authenticated
using ((select public.is_owner()) and (select auth.uid()) = user_id)
with check ((select public.is_owner()) and (select auth.uid()) = user_id);
