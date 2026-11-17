-- AI DIGITAL SHOP HAITI — commandes de produits numériques
-- Exécuter après supabase/schema.sql dans Supabase SQL Editor.

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  customer_name text not null,
  customer_whatsapp text not null,
  customer_email text not null default '',
  payment_method text not null check (payment_method in ('MonCash','NatCash','Autre')),
  amount numeric(12,2) not null check (amount > 0),
  status text not null default 'pending' check (status in ('pending','paid','delivered','cancelled')),
  delivery_url text not null default '',
  created_at timestamptz not null default now()
);

alter table public.orders enable row level security;

grant insert on public.orders to anon, authenticated;
grant select, update on public.orders to authenticated;

drop policy if exists "Customers can create pending orders" on public.orders;
create policy "Customers can create pending orders"
on public.orders for insert to anon, authenticated
with check (
  status = 'pending'
  and amount > 0
  and length(trim(customer_name)) > 1
  and length(trim(customer_whatsapp)) > 5
);

drop policy if exists "Admins can read orders" on public.orders;
create policy "Admins can read orders"
on public.orders for select to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Admins can update orders" on public.orders;
create policy "Admins can update orders"
on public.orders for update to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Les fichiers payants doivent rester dans un bucket Supabase Storage PRIVÉ.
-- Ne stockez jamais un lien public de téléchargement dans le catalogue.
-- Après confirmation manuelle du paiement, créez un lien signé à durée limitée
-- dans Supabase Storage et envoyez-le au client.
