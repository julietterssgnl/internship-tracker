-- À exécuter dans Supabase > SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.applications (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 company text not null, position text not null,
 country text not null default '', location text not null default '',
 url text not null default '', description text not null default '',
 status text not null default 'À préparer' check(status in ('À préparer','Envoyée','Entretien','Offre','Refusée')),
 applied_at date, follow_up_at date, notes text not null default '',
 created_at timestamptz not null default now()
);
create table if not exists public.profiles (
 user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
 full_name text not null default '',email text not null default '',phone text not null default '',
 linkedin text not null default '',education text not null default '',experience text not null default '',
 skills text not null default '',languages text not null default '',projects text not null default '',preferences text not null default ''
);
create table if not exists public.documents (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 application_id uuid not null references public.applications(id) on delete cascade,
 kind text not null check(kind in ('cv','letter')),content text not null,created_at timestamptz not null default now()
);
create index if not exists applications_owner_created on public.applications(user_id,created_at desc);
create index if not exists documents_owner_application on public.documents(user_id,application_id);
alter table public.applications enable row level security;
alter table public.profiles enable row level security;
alter table public.documents enable row level security;
drop policy if exists "own apps read" on public.applications;
drop policy if exists "own apps insert" on public.applications;
drop policy if exists "own apps update" on public.applications;
drop policy if exists "own apps delete" on public.applications;
create policy "own apps read" on public.applications for select to authenticated using ((select auth.uid())=user_id);
create policy "own apps insert" on public.applications for insert to authenticated with check ((select auth.uid())=user_id);
create policy "own apps update" on public.applications for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "own apps delete" on public.applications for delete to authenticated using ((select auth.uid())=user_id);
drop policy if exists "own profile read" on public.profiles;
drop policy if exists "own profile insert" on public.profiles;
drop policy if exists "own profile update" on public.profiles;
create policy "own profile read" on public.profiles for select to authenticated using ((select auth.uid())=user_id);
create policy "own profile insert" on public.profiles for insert to authenticated with check ((select auth.uid())=user_id);
create policy "own profile update" on public.profiles for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
drop policy if exists "own docs read" on public.documents;
drop policy if exists "own docs insert" on public.documents;
drop policy if exists "own docs delete" on public.documents;
create policy "own docs read" on public.documents for select to authenticated using ((select auth.uid())=user_id);
create policy "own docs insert" on public.documents for insert to authenticated with check ((select auth.uid())=user_id and exists(select 1 from public.applications a where a.id=application_id and a.user_id=(select auth.uid())));
create policy "own docs delete" on public.documents for delete to authenticated using ((select auth.uid())=user_id);
