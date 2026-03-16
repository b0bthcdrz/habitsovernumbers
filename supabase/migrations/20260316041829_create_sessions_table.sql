-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  avatar_url text,
  website text,

  constraint username_length check (char_length(username) >= 3)
);

-- Create sessions table
create table public.sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  started_at timestamp with time zone not null,
  ended_at timestamp with time zone not null,
  duration integer not null, -- in seconds
  label text,
  created_at timestamp with time zone default now() not null
);

-- Set up Row Level Security (RLS)
alter table public.profiles enable row level security;
alter table public.sessions enable row level security;

-- Profiles policies
create policy "Public profiles are viewable by everyone." on public.profiles
  for select using (true);

create policy "Users can insert their own profile." on public.profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on public.profiles
  for update using (auth.uid() = id);

-- Sessions policies
create policy "Users can view their own sessions." on public.sessions
  for select using (auth.uid() = user_id);

create policy "Users can insert their own sessions." on public.sessions
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own sessions." on public.sessions
  for update using (auth.uid() = user_id);

create policy "Users can delete their own sessions." on public.sessions
  for delete using (auth.uid() = user_id);

-- Create a function to handle new user signups
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

-- Create a trigger to call the function on user signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
