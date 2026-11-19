-- Public customer reviews for the plumbing website
-- Run this once in Supabase Dashboard -> SQL Editor.

create table if not exists public.site_reviews (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 60),
  rating smallint not null check (rating between 1 and 5),
  review text not null check (char_length(btrim(review)) between 10 and 1000),
  created_at timestamptz not null default now()
);

alter table public.site_reviews enable row level security;

-- Restrict the public API to read + insert only.
revoke all on table public.site_reviews from anon, authenticated;
grant select on table public.site_reviews to anon;
grant insert (name, rating, review) on table public.site_reviews to anon;

drop policy if exists "Anyone can read public site reviews" on public.site_reviews;
create policy "Anyone can read public site reviews"
  on public.site_reviews
  for select
  to anon
  using (true);

drop policy if exists "Visitors can submit valid site reviews" on public.site_reviews;
create policy "Visitors can submit valid site reviews"
  on public.site_reviews
  for insert
  to anon
  with check (
    char_length(btrim(name)) between 1 and 60
    and rating between 1 and 5
    and char_length(btrim(review)) between 10 and 1000
  );
