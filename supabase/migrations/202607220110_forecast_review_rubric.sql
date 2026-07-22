-- Keep automatic verification separate from an instructor's instructional assessment.
alter table public.forecast_reviews
  add column if not exists rubric_scores jsonb not null default '{}'::jsonb;

alter table public.forecast_reviews
  add constraint forecast_reviews_rubric_scores_object
  check (jsonb_typeof(rubric_scores) = 'object');
