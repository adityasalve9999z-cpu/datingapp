-- ==============================================================================
-- PHASE 3: ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- ENABLE RLS ON ALL TABLES
alter table public.profiles enable row level security;
alter table public.profile_photos enable row level security;
alter table public.preferences enable row level security;
alter table public.interactions enable row level security;
alter table public.matches enable row level security;
alter table public.messages enable row level security;
alter table public.blocks enable row level security;
alter table public.reports enable row level security;

-- ==============================================================================
-- PROFILES POLICIES
-- ==============================================================================
-- Anyone authenticated can view profiles
create policy "Profiles are viewable by authenticated users" 
on public.profiles for select 
using (auth.role() = 'authenticated');

-- Users can insert their own profile
create policy "Users can insert their own profile" 
on public.profiles for insert 
with check (auth.uid() = id);

-- Users can update their own profile
create policy "Users can update their own profile" 
on public.profiles for update 
using (auth.uid() = id);

-- ==============================================================================
-- PROFILE PHOTOS POLICIES
-- ==============================================================================
-- Anyone authenticated can view profile photos
create policy "Profile photos are viewable by authenticated users" 
on public.profile_photos for select 
using (auth.role() = 'authenticated');

-- Users can manage their own photos
create policy "Users can insert their own photos" 
on public.profile_photos for insert 
with check (auth.uid() = profile_id);

create policy "Users can update their own photos" 
on public.profile_photos for update 
using (auth.uid() = profile_id);

create policy "Users can delete their own photos" 
on public.profile_photos for delete 
using (auth.uid() = profile_id);

-- ==============================================================================
-- PREFERENCES POLICIES
-- ==============================================================================
-- Users can only view and edit their own preferences
create policy "Users can view own preferences" 
on public.preferences for select 
using (auth.uid() = profile_id);

create policy "Users can insert own preferences" 
on public.preferences for insert 
with check (auth.uid() = profile_id);

create policy "Users can update own preferences" 
on public.preferences for update 
using (auth.uid() = profile_id);

-- ==============================================================================
-- INTERACTIONS POLICIES
-- ==============================================================================
-- Users can view interactions where they are the actor or target
create policy "Users can view their interactions" 
on public.interactions for select 
using (auth.uid() = actor_id or auth.uid() = target_id);

-- Users can only create interactions as themselves
create policy "Users can insert own interactions" 
on public.interactions for insert 
with check (auth.uid() = actor_id);

-- Users can delete their own interactions (e.g. unliking)
create policy "Users can delete own interactions" 
on public.interactions for delete 
using (auth.uid() = actor_id);

-- ==============================================================================
-- MATCHES POLICIES
-- ==============================================================================
-- Users can view matches they are a part of
create policy "Users can view own matches" 
on public.matches for select 
using (auth.uid() = user1_id or auth.uid() = user2_id);

-- System usually handles inserts via triggers, but if from client:
create policy "Users can insert matches they are part of" 
on public.matches for insert 
with check (auth.uid() = user1_id or auth.uid() = user2_id);

create policy "Users can delete own matches (unmatch)" 
on public.matches for delete 
using (auth.uid() = user1_id or auth.uid() = user2_id);

-- ==============================================================================
-- MESSAGES POLICIES
-- ==============================================================================
-- Users can view messages of matches they belong to
create policy "Users can view messages of their matches" 
on public.messages for select 
using (
  exists (
    select 1 from public.matches m
    where m.id = match_id
    and (m.user1_id = auth.uid() or m.user2_id = auth.uid())
  )
);

-- Users can send messages only as themselves, and only to their matches
create policy "Users can insert messages to their matches" 
on public.messages for insert 
with check (
  auth.uid() = sender_id and
  exists (
    select 1 from public.matches m
    where m.id = match_id
    and (m.user1_id = auth.uid() or m.user2_id = auth.uid())
  )
);

-- Users can update read_at status for messages in their matches
create policy "Users can update messages in their matches" 
on public.messages for update
using (
  exists (
    select 1 from public.matches m
    where m.id = match_id
    and (m.user1_id = auth.uid() or m.user2_id = auth.uid())
  )
);

-- ==============================================================================
-- BLOCKS POLICIES
-- ==============================================================================
-- Users can view users they have blocked
create policy "Users can view own blocks" 
on public.blocks for select 
using (auth.uid() = blocker_id);

create policy "Users can insert own blocks" 
on public.blocks for insert 
with check (auth.uid() = blocker_id);

create policy "Users can delete own blocks" 
on public.blocks for delete 
using (auth.uid() = blocker_id);

-- ==============================================================================
-- REPORTS POLICIES
-- ==============================================================================
-- Users can create reports
create policy "Users can insert reports" 
on public.reports for insert 
with check (auth.uid() = reporter_id);

-- We intentionally DO NOT create a SELECT policy for reports.
-- Regular users should not be able to view reports. They are for admin only.
