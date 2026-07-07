-- 1. Buat Tabel Profiles (Sinkron dengan auth.users Supabase)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  full_name text not null,
  role text default 'User' check (role in ('User', 'Helpdesk', 'Admin')),
  avatar_url text
);

-- Aktifkan Row Level Security (RLS) untuk keamanan
alter table public.profiles enable row level security;

-- Policy agar user dapat membaca semua profile, tapi hanya bisa update miliknya sendiri
create policy "Public profiles are viewable by everyone." on public.profiles
  for select using (true);

create policy "Users can update their own profile." on public.profiles
  for update using (auth.uid() = id);

-- Trigger untuk otomatis memasukkan data ke profiles setiap kali ada User baru mendaftar di Auth
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name, role, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', substring(new.email from '^[^@]+')),
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'User'),
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80' -- Default avatar
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. Buat Tabel Tickets
create table public.tickets (
  id text primary key,
  title text not null,
  description text not null,
  category text not null,
  priority text not null,
  status text not null default 'Open',
  creator_email text not null,
  creator_name text not null,
  assigned_to_email text,
  assigned_to_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  image_url text
);

alter table public.tickets enable row level security;
create policy "Allow read access for authenticated users" on public.tickets for select using (auth.role() = 'authenticated');
create policy "Allow insert access for authenticated users" on public.tickets for insert with check (auth.role() = 'authenticated');
create policy "Allow update access for authenticated users" on public.tickets for update using (auth.role() = 'authenticated');


-- 3. Buat Tabel Comments
create table public.comments (
  id text primary key,
  ticket_id text references public.tickets(id) on delete cascade not null,
  sender_email text not null,
  sender_name text not null,
  sender_role text not null,
  message text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  image_url text
);

alter table public.comments enable row level security;
create policy "Allow read comments for authenticated users" on public.comments for select using (auth.role() = 'authenticated');
create policy "Allow insert comments for authenticated users" on public.comments for insert with check (auth.role() = 'authenticated');


-- 4. Buat Tabel Ticket Activity Logs
create table public.ticket_activity_logs (
  id text primary key,
  ticket_id text references public.tickets(id) on delete cascade not null,
  title text not null,
  description text not null,
  actor_name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.ticket_activity_logs enable row level security;
create policy "Allow read logs for authenticated users" on public.ticket_activity_logs for select using (auth.role() = 'authenticated');
create policy "Allow insert logs for authenticated users" on public.ticket_activity_logs for insert with check (auth.role() = 'authenticated');
