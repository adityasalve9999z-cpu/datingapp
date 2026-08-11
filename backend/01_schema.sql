-- ==============================================================================
-- PHASE 2: DATABASE SCHEMA
-- ==============================================================================

-- 1. EXTENSIONS
create extension if not exists "uuid-ossp";

-- 2. AUTOMATIC UPDATED_AT TRIGGER FUNCTION
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ==============================================================================
-- PROFILES TABLE
-- ==============================================================================
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text not null,
  bio text,
  gender text,
  birth_date date,
  location text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create trigger handle_profiles_updated_at before update on public.profiles
  for each row execute procedure public.handle_updated_at();

-- ==============================================================================
-- PROFILE PHOTOS TABLE
-- ==============================================================================
create table public.profile_photos (
  id uuid default uuid_generate_v4() primary key,
  profile_id uuid references public.profiles(id) on delete cascade not null,
  image_url text not null,
  is_primary boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ==============================================================================
-- PREFERENCES TABLE
-- ==============================================================================
create table public.preferences (
  profile_id uuid references public.profiles(id) on delete cascade primary key,
  min_age integer default 18,
  max_age integer default 99,
  preferred_gender text,
  max_distance integer default 50, -- in miles/kilometers depending on your usage
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create trigger handle_preferences_updated_at before update on public.preferences
  for each row execute procedure public.handle_updated_at();

-- ==============================================================================
-- INTERACTIONS TABLE (Likes and Passes)
-- ==============================================================================
create table public.interactions (
  id uuid default uuid_generate_v4() primary key,
  actor_id uuid references public.profiles(id) on delete cascade not null,
  target_id uuid references public.profiles(id) on delete cascade not null,
  action_type text check (action_type in ('LIKE', 'PASS')) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (actor_id, target_id) -- A user can only like or pass another user once
);

create index interactions_actor_id_idx on public.interactions(actor_id);
create index interactions_target_id_idx on public.interactions(target_id);

-- ==============================================================================
-- MATCHES TABLE
-- ==============================================================================
create table public.matches (
  id uuid default uuid_generate_v4() primary key,
  user1_id uuid references public.profiles(id) on delete cascade not null,
  user2_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  last_interaction_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user1_id, user2_id)
);

-- Ensure user1_id is always less than user2_id to prevent duplicates like (A,B) and (B,A)
alter table public.matches add constraint enforce_user_order check (user1_id < user2_id);

create index matches_user1_id_idx on public.matches(user1_id);
create index matches_user2_id_idx on public.matches(user2_id);

-- ==============================================================================
-- MESSAGES TABLE
-- ==============================================================================
create table public.messages (
  id uuid default uuid_generate_v4() primary key,
  match_id uuid references public.matches(id) on delete cascade not null,
  sender_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  read_at timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index messages_match_id_idx on public.messages(match_id);
create index messages_sender_id_idx on public.messages(sender_id);

-- ==============================================================================
-- BLOCKS TABLE
-- ==============================================================================
create table public.blocks (
  id uuid default uuid_generate_v4() primary key,
  blocker_id uuid references public.profiles(id) on delete cascade not null,
  blocked_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (blocker_id, blocked_id)
);

create index blocks_blocker_id_idx on public.blocks(blocker_id);

-- ==============================================================================
-- REPORTS TABLE
-- ==============================================================================
create table public.reports (
  id uuid default uuid_generate_v4() primary key,
  reporter_id uuid references public.profiles(id) on delete cascade not null,
  reported_id uuid references public.profiles(id) on delete cascade not null,
  reason text not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index reports_reporter_id_idx on public.reports(reporter_id);
