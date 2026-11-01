-- =====================================================================
--  Carnet auto : tables à ajouter dans le projet Supabase de Nos photos
--  SQL Editor → New query → coller tout → Run
--  Réutilise les comptes et la table « members » déjà en place.
--  Chaque personne ne voit que SES véhicules et SES interventions.
-- =====================================================================

-- 1. Les véhicules
create table if not exists public.car_vehicles (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name          text not null check (char_length(name) between 1 and 40),
  model         text check (char_length(model) <= 80),
  year          int,
  plate         text check (char_length(plate) <= 12),
  km            int not null default 0 check (km >= 0),
  km_updated_at timestamptz,
  created_at    timestamptz not null default now()
);

-- 2. Les interventions (vidange, CT, pneus, réparations…)
create table if not exists public.car_entries (
  id          uuid primary key default gen_random_uuid(),
  vehicle_id  uuid not null references public.car_vehicles (id) on delete cascade,
  owner_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  date        date not null,
  km          int check (km >= 0),
  kind        text not null,
  title       text check (char_length(title) <= 100),
  garage      text check (char_length(garage) <= 60),
  cost        numeric(10, 2),
  notes       text check (char_length(notes) <= 500),
  next_km     int,          -- prochain rappel au kilométrage
  next_date   date,         -- prochain rappel à la date
  created_at  timestamptz not null default now()
);
create index if not exists car_entries_vehicle_idx on public.car_entries (vehicle_id, date desc);

-- Prix et date d'achat (pour le coût réel de la voiture)
alter table public.car_vehicles add column if not exists purchase_price numeric(10, 2);
alter table public.car_vehicles add column if not exists purchase_date  date;

-- 3. Les cotes (valeur estimée de la voiture, relevée à la main sur La Centrale, l'Argus…)
create table if not exists public.car_valuations (
  id          uuid primary key default gen_random_uuid(),
  vehicle_id  uuid not null references public.car_vehicles (id) on delete cascade,
  owner_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  date        date not null,
  km          int check (km >= 0),
  value       numeric(10, 2) not null check (value >= 0),
  source      text check (char_length(source) <= 40),
  created_at  timestamptz not null default now()
);
create index if not exists car_valuations_vehicle_idx on public.car_valuations (vehicle_id, date desc);

-- 4. Sécurité : uniquement ses propres données, et uniquement pour les membres
alter table public.car_vehicles   enable row level security;
alter table public.car_entries    enable row level security;
alter table public.car_valuations enable row level security;

drop policy if exists "cotes : les siennes" on public.car_valuations;
create policy "cotes : les siennes" on public.car_valuations
  for all to authenticated
  using (owner_id = auth.uid() and public.is_member())
  with check (
    owner_id = auth.uid() and public.is_member()
    and exists (select 1 from public.car_vehicles v where v.id = vehicle_id and v.owner_id = auth.uid())
  );

drop policy if exists "vehicules : les siens" on public.car_vehicles;
create policy "vehicules : les siens" on public.car_vehicles
  for all to authenticated
  using (owner_id = auth.uid() and public.is_member())
  with check (owner_id = auth.uid() and public.is_member());

drop policy if exists "interventions : les siennes" on public.car_entries;
create policy "interventions : les siennes" on public.car_entries
  for all to authenticated
  using (owner_id = auth.uid() and public.is_member())
  with check (
    owner_id = auth.uid() and public.is_member()
    and exists (select 1 from public.car_vehicles v where v.id = vehicle_id and v.owner_id = auth.uid())
  );

notify pgrst, 'reload schema';
