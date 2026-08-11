-- ==============================================================================
-- PHASE 4: AUTH SETUP & TRIGGERS
-- ==============================================================================

-- Create a function to handle new user signups
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, created_at, updated_at)
  values (
    new.id, 
    coalesce(new.raw_user_meta_data->>'full_name', 'New User'), -- Default to 'New User' if not provided
    now(),
    now()
  );
  
  -- Automatically create empty preferences for the user
  insert into public.preferences (profile_id)
  values (new.id);
  
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Create the trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
