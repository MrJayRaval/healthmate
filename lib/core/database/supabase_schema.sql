-- Enable UUID extension if not enabled
create extension if not exists "uuid-ossp";

-- 1. USERS TABLE (Extends Supabase Auth)
create table public.users (
  id uuid references auth.users not null primary key,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for users
alter table public.users enable row level security;

-- Policies for users
create policy "Users can view own profile" on public.users
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.users
  for update using (auth.uid() = id);

create policy "Users can insert own profile" on public.users
  for insert with check (auth.uid() = id);

-- 2. HEALTH LOGS TABLE
create table public.health_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  type text not null, -- 'sleep', 'water', 'steps', 'mood'
  value numeric not null, -- Value (e.g., 8.0 for sleep, 2000 for water)
  unit text, -- 'hours', 'ml', 'count'
  logged_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for health_logs
alter table public.health_logs enable row level security;

-- Policies for health_logs
create policy "Users can view own health logs" on public.health_logs
  for select using (auth.uid() = user_id);

create policy "Users can insert own health logs" on public.health_logs
  for insert with check (auth.uid() = user_id);

create policy "Users can update own health logs" on public.health_logs
  for update using (auth.uid() = user_id);

create policy "Users can delete own health logs" on public.health_logs
  for delete using (auth.uid() = user_id);

-- 3. SYMPTOMS LOGS TABLE
create table public.symptoms_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  symptoms text[] not null, -- Array of symptom names
  urgency_level text not null, -- 'Low', 'Medium', 'High'
  advisory_text text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for symptoms_logs
alter table public.symptoms_logs enable row level security;

-- Policies for symptoms_logs
create policy "Users can view own symptom logs" on public.symptoms_logs
  for select using (auth.uid() = user_id);

create policy "Users can insert own symptom logs" on public.symptoms_logs
  for insert with check (auth.uid() = user_id);

-- 4. REMINDERS TABLE
create table public.reminders (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  title text not null,
  scheduled_time time not null,
  is_active boolean default true,
  days_of_week int[], -- 1=Monday, 7=Sunday
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for reminders
alter table public.reminders enable row level security;

-- Policies for reminders
create policy "Users can view own reminders" on public.reminders
  for select using (auth.uid() = user_id);

create policy "Users can insert own reminders" on public.reminders
  for insert with check (auth.uid() = user_id);

create policy "Users can update own reminders" on public.reminders
  for update using (auth.uid() = user_id);

create policy "Users can delete own reminders" on public.reminders
  for delete using (auth.uid() = user_id);

-- 5. RECOMMENDATIONS TABLE (AI Generated)
create table public.recommendations (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  title text not null,
  description text,
  category text, -- 'sleep', 'hydration', 'general'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for recommendations
alter table public.recommendations enable row level security;

-- Policies for recommendations
create policy "Users can view own recommendations" on public.recommendations
  for select using (auth.uid() = user_id);

-- 6. AI USAGE TRACKING TABLE
create table public.ai_usage (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  feature_name text not null, -- 'chat', 'symptom_checker', 'insights'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for ai_usage
alter table public.ai_usage enable row level security;

-- Policies for ai_usage
create policy "Users can view own ai usage" on public.ai_usage
  for select using (auth.uid() = user_id);

create policy "Users can insert own ai usage" on public.ai_usage
  for insert with check (auth.uid() = user_id);

-- Index for faster daily queries
create index ai_usage_user_feature_date_idx on public.ai_usage(user_id, feature_name, created_at);

-- 7. COMMUNITY TRENDS (Anonymized View) - Placeholder for Phase 4
-- create view public.community_trends ...

-- Handle User Creation (Trigger)
-- Function to automatically create a user profile when a new user signs up via Auth
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, full_name, avatar_url)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger logic
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
