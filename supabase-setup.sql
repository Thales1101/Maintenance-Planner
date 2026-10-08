-- Maintenance Planner · WEIG Terminal — Supabase setup
-- Run this whole file once in Supabase: SQL Editor → New query → paste → Run. No changes needed.
-- Afterwards, make yourself administrator with one more query (see the end of this file).

-- 1. Tables --------------------------------------------------------------------
create table if not exists public.docs (
  path        text primary key,              -- e.g. tickets/abc123, people/p1, tickets/abc123/log/x
  col         text not null,                 -- the collection part of the path, e.g. tickets
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now(),
  updated_by  uuid default auth.uid()
);
create index if not exists docs_col_idx on public.docs (col);

create table if not exists public.app_admins (
  email text primary key
);

-- 2. Who may edit ----------------------------------------------------------------
-- Administrators, plus anyone whose sign-in email is entered in "Responsible people"
-- with access "Can create and edit" (and who is active). Everyone else signed in can only view.
create or replace function public.mp_is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from app_admins where lower(email) = lower(coalesce(auth.jwt()->>'email','')));
$$;

create or replace function public.mp_can_edit() returns boolean
language sql stable security definer set search_path = public as $$
  select mp_is_admin() or exists (
    select 1 from docs
    where col = 'people'
      and lower(trim(coalesce(data->>'email',''))) = lower(coalesce(auth.jwt()->>'email',''))
      and coalesce(data->>'access','edit') <> 'view'
      and coalesce(data->>'active','true') <> 'false'
  );
$$;

-- Merge fields into a record (used when one field of an order changes)
create or replace function public.mp_merge(p text, c text, d jsonb) returns void
language sql security invoker set search_path = public as $$
  insert into docs (path, col, data) values (p, c, d)
  on conflict (path) do update
    set data = docs.data || excluded.data, updated_at = now(), updated_by = auth.uid();
$$;

-- 3. Row-level security ------------------------------------------------------------
alter table public.docs enable row level security;
alter table public.app_admins enable row level security;

drop policy if exists "mp read"   on public.docs;
drop policy if exists "mp insert" on public.docs;
drop policy if exists "mp update" on public.docs;
drop policy if exists "mp delete" on public.docs;
drop policy if exists "mp admins see themselves" on public.app_admins;

-- Signed-in users can read everything; nobody who is not signed in can read anything.
create policy "mp read" on public.docs for select to authenticated using (true);
-- Editors write everything. Every user may keep their own profile row (users/<id>)
-- and mark their notifications as read.
create policy "mp insert" on public.docs for insert to authenticated
  with check (public.mp_can_edit() or path = 'users/' || auth.uid()::text or col = 'notifications');
create policy "mp update" on public.docs for update to authenticated
  using      (public.mp_can_edit() or path = 'users/' || auth.uid()::text or col = 'notifications')
  with check (public.mp_can_edit() or path = 'users/' || auth.uid()::text or col = 'notifications');
create policy "mp delete" on public.docs for delete to authenticated
  using (public.mp_can_edit());
create policy "mp admins see themselves" on public.app_admins for select to authenticated
  using (lower(email) = lower(coalesce(auth.jwt()->>'email','')));

grant select, insert, update, delete on public.docs to authenticated;
grant select on public.app_admins to authenticated;
grant execute on function public.mp_merge(text, text, jsonb) to authenticated;
grant execute on function public.mp_can_edit() to authenticated;
grant execute on function public.mp_is_admin() to authenticated;
revoke all on public.docs from anon;
revoke all on public.app_admins from anon;

-- 4. Live updates ------------------------------------------------------------------
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- 5. File storage (drawings, layout, photos) — private bucket ------------------------
insert into storage.buckets (id, name, public) values ('files', 'files', false)
on conflict (id) do nothing;

drop policy if exists "mp files read"   on storage.objects;
drop policy if exists "mp files add"    on storage.objects;
drop policy if exists "mp files change" on storage.objects;
drop policy if exists "mp files delete" on storage.objects;
create policy "mp files read"   on storage.objects for select to authenticated using (bucket_id = 'files');
create policy "mp files add"    on storage.objects for insert to authenticated with check (bucket_id = 'files' and public.mp_can_edit());
create policy "mp files change" on storage.objects for update to authenticated using (bucket_id = 'files' and public.mp_can_edit());
create policy "mp files delete" on storage.objects for delete to authenticated using (bucket_id = 'files' and public.mp_can_edit());

-- Done. Now make yourself administrator: open a NEW query, paste the line below with
-- your own sign-in email between the quotes, and click Run. Repeat for other administrators.
--   insert into public.app_admins (email) values (lower('your.name@weig-bft.com'));
