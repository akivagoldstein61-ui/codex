-- Phase 2 minimal data foundation for Deck Factory OS / Mystery of Meaning
-- Safe defaults: explicit stable IDs, immutable content versions, idempotent ingestion tracking,
-- and deny-by-default RLS for user-sensitive tables.

create extension if not exists pgcrypto;

create table if not exists public.content_versions (
  id uuid primary key default gen_random_uuid(),
  content_version_id text not null unique,
  content_type text not null check (content_type in ('deck', 'card', 'journey', 'asset_bundle')),
  source_system text not null check (source_system in ('google_sheets', 'google_drive', 'runtime')),
  source_ref text not null,
  content_hash text not null,
  created_by uuid,
  approval_status text not null default 'draft' check (approval_status in ('draft', 'approved', 'rejected')),
  approved_by uuid,
  approved_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  metadata jsonb not null default '{}'::jsonb,
  unique (source_system, source_ref, content_hash)
);

create table if not exists public.ingestion_runs (
  id uuid primary key default gen_random_uuid(),
  request_id text not null unique,
  idempotency_key text not null unique,
  source_system text not null check (source_system in ('google_sheets', 'google_drive', 'runtime')),
  source_ref text not null,
  run_status text not null default 'pending' check (run_status in ('pending', 'validated', 'applied', 'failed')),
  dry_run boolean not null default true,
  triggered_by uuid,
  started_at timestamptz not null default timezone('utc', now()),
  finished_at timestamptz,
  validation_report jsonb,
  error_message text,
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  handle text unique,
  display_name text,
  avatar_asset_id text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.decks (
  id uuid primary key default gen_random_uuid(),
  deck_id text not null unique,
  slug text not null unique,
  title text not null,
  description text,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  canonical_sheet_ref text,
  content_version_id text not null references public.content_versions (content_version_id),
  content_hash text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  card_id text not null unique,
  deck_id text not null references public.decks (deck_id) on delete cascade,
  slug text not null unique,
  title text not null,
  body text,
  image_asset_id text,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  content_version_id text not null references public.content_versions (content_version_id),
  content_hash text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.journeys (
  id uuid primary key default gen_random_uuid(),
  journey_id text not null unique,
  slug text not null unique,
  title text not null,
  summary text,
  steps jsonb not null default '[]'::jsonb,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  content_version_id text not null references public.content_versions (content_version_id),
  content_hash text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  asset_id text not null unique,
  owner_content_type text not null check (owner_content_type in ('deck', 'card', 'journey', 'profile', 'system')),
  owner_content_id text not null,
  storage_path text not null,
  mime_type text not null,
  premium boolean not null default false,
  status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
  source_drive_ref text,
  content_version_id text not null references public.content_versions (content_version_id),
  content_hash text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.saves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  deck_id text references public.decks (deck_id) on delete set null,
  journey_id text references public.journeys (journey_id) on delete set null,
  play_state jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (deck_id is not null or journey_id is not null)
);

create table if not exists public.entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  resource_type text not null check (resource_type in ('deck', 'card', 'journey', 'asset', 'bundle')),
  resource_id text not null,
  entitlement_status text not null check (entitlement_status in ('active', 'expired', 'revoked')),
  granted_by uuid,
  granted_at timestamptz not null default timezone('utc', now()),
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  unique (user_id, resource_type, resource_id)
);

create table if not exists public.analytics_events (
  id uuid primary key default gen_random_uuid(),
  event_name text not null,
  user_id uuid references auth.users (id) on delete set null,
  session_id text,
  request_id text not null,
  path text,
  properties jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_content_versions_type_status
  on public.content_versions (content_type, approval_status, created_at desc);
create index if not exists idx_ingestion_runs_source_status
  on public.ingestion_runs (source_system, run_status, started_at desc);
create index if not exists idx_decks_status_slug on public.decks (status, slug);
create index if not exists idx_cards_deck_status on public.cards (deck_id, status);
create index if not exists idx_journeys_status_slug on public.journeys (status, slug);
create index if not exists idx_assets_owner_status on public.assets (owner_content_type, owner_content_id, status);
create index if not exists idx_saves_user_updated on public.saves (user_id, updated_at desc);
create index if not exists idx_entitlements_lookup
  on public.entitlements (user_id, resource_type, resource_id, entitlement_status);
create index if not exists idx_analytics_events_name_created
  on public.analytics_events (event_name, created_at desc);

alter table public.profiles enable row level security;
alter table public.decks enable row level security;
alter table public.cards enable row level security;
alter table public.journeys enable row level security;
alter table public.assets enable row level security;
alter table public.saves enable row level security;
alter table public.entitlements enable row level security;
alter table public.analytics_events enable row level security;
alter table public.content_versions enable row level security;
alter table public.ingestion_runs enable row level security;

alter table public.profiles force row level security;
alter table public.decks force row level security;
alter table public.cards force row level security;
alter table public.journeys force row level security;
alter table public.assets force row level security;
alter table public.saves force row level security;
alter table public.entitlements force row level security;
alter table public.analytics_events force row level security;
alter table public.content_versions force row level security;
alter table public.ingestion_runs force row level security;

create policy "profiles_select_own"
  on public.profiles
  for select
  using (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles
  for insert
  with check (auth.uid() = id);

create policy "decks_select_published"
  on public.decks
  for select
  using (status = 'published');

create policy "cards_select_published"
  on public.cards
  for select
  using (status = 'published');

create policy "journeys_select_published"
  on public.journeys
  for select
  using (status = 'published');

create policy "assets_select_published_nonpremium"
  on public.assets
  for select
  using (status = 'published' and premium = false);

create policy "saves_select_own"
  on public.saves
  for select
  using (auth.uid() = user_id);

create policy "saves_insert_own"
  on public.saves
  for insert
  with check (auth.uid() = user_id);

create policy "saves_update_own"
  on public.saves
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "saves_delete_own"
  on public.saves
  for delete
  using (auth.uid() = user_id);

create policy "entitlements_select_own"
  on public.entitlements
  for select
  using (auth.uid() = user_id);

create policy "entitlements_service_write"
  on public.entitlements
  for all
  using ((auth.jwt() ->> 'role') = 'service_role')
  with check ((auth.jwt() ->> 'role') = 'service_role');

create policy "analytics_insert_authenticated"
  on public.analytics_events
  for insert
  with check (auth.uid() is not null and (user_id is null or auth.uid() = user_id));

create policy "analytics_select_service_role"
  on public.analytics_events
  for select
  using ((auth.jwt() ->> 'role') = 'service_role');

create policy "content_versions_select_published"
  on public.content_versions
  for select
  using (approval_status = 'approved');

create policy "content_versions_service_write"
  on public.content_versions
  for all
  using ((auth.jwt() ->> 'role') = 'service_role')
  with check ((auth.jwt() ->> 'role') = 'service_role');

create policy "ingestion_runs_service_role"
  on public.ingestion_runs
  for all
  using ((auth.jwt() ->> 'role') = 'service_role')
  with check ((auth.jwt() ->> 'role') = 'service_role');
