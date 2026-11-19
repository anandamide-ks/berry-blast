-- Berry Blast partner sharing: database setup for Supabase.  anandamide.ks
-- Paste this whole file into Supabase > SQL Editor > New query, then click Run.
-- It is safe to run more than once.

-- What one person shares. Only the categories they ticked are ever stored here.
create table if not exists public.shares (
  owner_id     uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  payload      jsonb not null default '{}'::jsonb,
  updated_at   timestamptz not null default now()
);

-- Who may see whose share.
create table if not exists public.partners (
  owner_id      uuid not null references auth.users (id) on delete cascade,
  partner_id    uuid not null references auth.users (id) on delete cascade,
  partner_email text,
  created_at    timestamptz not null default now(),
  primary key (owner_id, partner_id),
  constraint partners_not_self check (owner_id <> partner_id)
);

-- One-time invite codes, valid for 24 hours.
create table if not exists public.invites (
  code       text primary key,
  owner_id   uuid not null references auth.users (id) on delete cascade,
  expires_at timestamptz not null default now() + interval '24 hours'
);

alter table public.shares   enable row level security;
alter table public.partners enable row level security;
alter table public.invites  enable row level security;

-- Signed-out visitors get nothing; signed-in users are limited by the policies below.
revoke all on public.shares, public.partners, public.invites from anon;
grant select, insert, update, delete on public.shares   to authenticated;
grant select, delete                 on public.partners to authenticated;
grant select, insert, delete         on public.invites  to authenticated;

drop policy if exists "owner manages own share"  on public.shares;
drop policy if exists "partners read share"      on public.shares;
drop policy if exists "see own partner links"    on public.partners;
drop policy if exists "remove own partner links" on public.partners;
drop policy if exists "owner manages own invites" on public.invites;

-- A person reads and writes only their own share.
create policy "owner manages own share" on public.shares
  for all to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

-- A partner can only read the share of someone who invited them.
create policy "partners read share" on public.shares
  for select to authenticated
  using (exists (
    select 1 from public.partners p
    where p.owner_id = shares.owner_id and p.partner_id = auth.uid()
  ));

-- Both sides of a link can see it, and either side can end it.
create policy "see own partner links" on public.partners
  for select to authenticated
  using (owner_id = auth.uid() or partner_id = auth.uid());

create policy "remove own partner links" on public.partners
  for delete to authenticated
  using (owner_id = auth.uid() or partner_id = auth.uid());

-- Invite codes are visible only to the person who made them.
create policy "owner manages own invites" on public.invites
  for all to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

-- The only way to become someone's partner: redeem a valid code they gave you.
create or replace function public.redeem_invite(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me  uuid := auth.uid();
  c   text := upper(trim(invite_code));
  own uuid;
begin
  if me is null then
    raise exception 'Sign in first.';
  end if;
  delete from invites where expires_at <= now();
  select owner_id into own from invites where code = c;
  if own is null then
    raise exception 'That code is wrong or has expired. Ask for a new one.';
  end if;
  if own = me then
    raise exception 'That is your own code. Send it to your partner instead.';
  end if;
  insert into partners (owner_id, partner_id, partner_email)
  values (own, me, auth.jwt() ->> 'email')
  on conflict (owner_id, partner_id) do nothing;
  delete from invites where code = c;
  return own;
end;
$$;

revoke all on function public.redeem_invite(text) from public, anon;
grant execute on function public.redeem_invite(text) to authenticated;

-- Live updates for partners.
do $$
declare t text;
begin
  foreach t in array array['shares', 'partners'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
