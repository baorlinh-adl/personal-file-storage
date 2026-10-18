-- Kho riêng: schema for Supabase project personal-file-storage
-- Applied to project xypljfuxdokpefbxvrry on 2026-10-18.
-- Do not put service_role/secret keys in frontend code.

create table public.folders (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 80),
  parent_id uuid null,
  created_at timestamptz not null default now(),
  constraint folders_id_owner_unique unique (id, owner_id),
  constraint folders_parent_owner_fk foreign key (parent_id, owner_id)
    references public.folders(id, owner_id) on delete cascade
);

create table public.files (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  folder_id uuid null,
  name text not null check (char_length(trim(name)) between 1 and 255),
  storage_path text not null unique,
  mime_type text not null check (mime_type like 'image/%' or mime_type like 'video/%'),
  size_bytes bigint not null default 0 check (size_bytes >= 0),
  created_at timestamptz not null default now(),
  constraint files_folder_owner_fk foreign key (folder_id, owner_id)
    references public.folders(id, owner_id) on delete cascade
);

create index folders_owner_parent_idx on public.folders(owner_id, parent_id);
create index folders_parent_owner_fk_idx on public.folders(parent_id, owner_id);
create index files_owner_folder_idx on public.files(owner_id, folder_id);
create index files_folder_owner_fk_idx on public.files(folder_id, owner_id);
create index files_owner_created_idx on public.files(owner_id, created_at desc);

alter table public.folders enable row level security;
alter table public.files enable row level security;

create policy "folders_select_own" on public.folders for select to authenticated using ((select auth.uid()) = owner_id);
create policy "folders_insert_own" on public.folders for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "folders_update_own" on public.folders for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "folders_delete_own" on public.folders for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "files_select_own" on public.files for select to authenticated using ((select auth.uid()) = owner_id);
create policy "files_insert_own" on public.files for insert to authenticated with check ((select auth.uid()) = owner_id and storage_path like ((select auth.uid())::text || '/%'));
create policy "files_update_own" on public.files for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id and storage_path like ((select auth.uid())::text || '/%'));
create policy "files_delete_own" on public.files for delete to authenticated using ((select auth.uid()) = owner_id);

grant select, insert, update, delete on public.folders to authenticated;
grant select, insert, update, delete on public.files to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('personal-files', 'personal-files', false, 52428800, array[
  'image/jpeg','image/png','image/gif','image/webp','image/avif','image/heic','image/heif','image/bmp','image/svg+xml',
  'video/mp4','video/webm','video/quicktime','video/x-m4v','video/3gpp','video/x-msvideo','video/mpeg'
])
on conflict (id) do update set public = false, file_size_limit = 52428800,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "personal_storage_select_own" on storage.objects for select to authenticated
using (bucket_id = 'personal-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "personal_storage_insert_own" on storage.objects for insert to authenticated
with check (bucket_id = 'personal-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "personal_storage_update_own" on storage.objects for update to authenticated
using (bucket_id = 'personal-files' and (storage.foldername(name))[1] = (select auth.uid())::text)
with check (bucket_id = 'personal-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "personal_storage_delete_own" on storage.objects for delete to authenticated
using (bucket_id = 'personal-files' and (storage.foldername(name))[1] = (select auth.uid())::text);
