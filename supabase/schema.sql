-- NEXORA STORE — schéma initial Supabase
create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Autres',
  description text not null default '',
  price numeric(12,2) not null check (price > 0),
  stock integer not null default 0 check (stock >= 0),
  image text not null default '',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.store_settings (
  key text primary key,
  value text not null default ''
);

alter table public.products enable row level security;
alter table public.store_settings enable row level security;

grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;
grant select on public.store_settings to anon, authenticated;
grant insert, update on public.store_settings to authenticated;

-- Catalogue et paramètres : lecture publique seulement.
create policy "Public can read active products"
on public.products for select
using (active = true or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can insert products"
on public.products for insert to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can update products"
on public.products for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can delete products"
on public.products for delete to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Public can read store settings"
on public.store_settings for select
using (true);

create policy "Admins can insert store settings"
on public.store_settings for insert to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy "Admins can update store settings"
on public.store_settings for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Données d'exemple : modifiez les prix, stocks et photos depuis l'administration.
insert into public.products (name,category,description,price,stock,image) values
('Pack de modèles CV professionnels','CV et emploi','Modèles de CV modernes à personnaliser pour vos candidatures.',250,999,''),
('Kit de démarrage pour petit business','Business','Checklist et outils pour organiser une petite activité.',400,999,''),
('Pack de flyers modifiables','Design et réseaux sociaux','Modèles de publications et flyers pour promouvoir une activité.',350,999,''),
('Guide pratique pour réussir un entretien','Guides pratiques','Conseils et exemples pour préparer un entretien d embauche.',200,999,''),
('Pack fiches de révision','Éducation','Fiches structurées pour organiser ses révisions.',150,999,''),
('Modèles de factures et devis','Business','Documents simples pour gérer les ventes et prestations.',300,999,'')
on conflict do nothing;
