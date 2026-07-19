create extension if not exists pgcrypto;

create table public.forecasts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  location_name text not null default 'Athens, GA',
  latitude numeric(8, 5),
  longitude numeric(8, 5),
  forecast_date date not null,
  forecast_data jsonb not null,
  evidence_snapshot jsonb not null,
  status text not null default 'pending_verification'
    check (status in ('draft', 'pending_verification', 'verified')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index forecasts_user_created_at_idx on public.forecasts (user_id, created_at desc);

alter table public.forecasts enable row level security;

create policy "Users can read their own forecasts"
  on public.forecasts for select
  using ((select auth.uid()) = user_id);

create policy "Users can create their own forecasts"
  on public.forecasts for insert
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own forecasts"
  on public.forecasts for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own forecasts"
  on public.forecasts for delete
  using ((select auth.uid()) = user_id);
