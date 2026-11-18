-- Al-Lughah Explorer: jalankan seluruh skrip ini di Supabase SQL Editor.
-- Role default selalu student. Administrator harus mempromosikan akun guru secara manual.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default 'Pengguna',
  role text not null default 'student' check (role in ('student','teacher','admin')),
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name','Pengguna'), 'student')
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.student_progress (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  progress jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create or replace function public.current_app_role()
returns text language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid();
$$;

alter table public.profiles enable row level security;
alter table public.student_progress enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles for select to authenticated
using (id = auth.uid() or public.current_app_role() in ('teacher','admin'));
drop policy if exists "Users can update own name" on public.profiles;
create policy "Users can update own name" on public.profiles for update to authenticated
using (id = auth.uid()) with check (id = auth.uid() and role = public.current_app_role());

drop policy if exists "Students read own progress, teachers read all" on public.student_progress;
create policy "Students read own progress, teachers read all" on public.student_progress for select to authenticated
using (user_id = auth.uid() or public.current_app_role() in ('teacher','admin'));
drop policy if exists "Students insert own progress" on public.student_progress;
create policy "Students insert own progress" on public.student_progress for insert to authenticated
with check (user_id = auth.uid() and public.current_app_role() = 'student');
drop policy if exists "Students update own progress" on public.student_progress;
create policy "Students update own progress" on public.student_progress for update to authenticated
using (user_id = auth.uid() and public.current_app_role() = 'student')
with check (user_id = auth.uid() and public.current_app_role() = 'student');

-- Aktifkan Realtime untuk pemantauan perubahan progres.
alter publication supabase_realtime add table public.student_progress;

-- Setelah membuat akun melalui halaman register, promosikan akun guru secara manual:
-- update public.profiles set role = 'teacher' where id = 'UUID_AKUN_GURU';
