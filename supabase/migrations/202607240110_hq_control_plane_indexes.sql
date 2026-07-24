-- HQ views are owner-scoped; cover the RLS ownership predicate and expected lists.
create index if not exists hq_accounts_user_id_created_at_idx
  on public.hq_accounts (user_id, created_at desc);

create index if not exists hq_expenses_user_id_due_date_idx
  on public.hq_expenses (user_id, due_date);
