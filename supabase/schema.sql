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
('Smartphone Android','Téléphones','Smartphone moderne pour vos activités quotidiennes.',129,12,'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=700'),
('Ordinateur portable','Informatique','Ordinateur pour les études et le travail.',399,4,'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=700'),
('Écouteurs sans fil','Audio','Écouteurs Bluetooth compacts.',24,20,'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700'),
('Montre connectée','Accessoires','Suivez vos activités avec une montre connectée.',32,14,'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=700'),
('Chargeur rapide','Accessoires','Chargeur mural pour appareils compatibles.',14,30,'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=700'),
('Sac à dos','Mode','Sac polyvalent pour école, travail et sorties.',28,11,'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=700'),
('Lampe de bureau','Maison','Éclairage pratique pour votre espace de travail.',19,8,'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=700'),
('Manette de jeu','Gaming','Manette pour vos sessions de jeu.',29,6,'https://images.unsplash.com/photo-1600080972464-8e5f35f63d08?w=700')
on conflict do nothing;
