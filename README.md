# NEXORA STORE

Boutique responsive avec catalogue, panier WhatsApp et espace administrateur connecté à Supabase.

## Fonctionnalités
- Catalogue de produits, recherche et filtres par catégorie.
- Prix, stock, images et descriptions modifiables.
- Panier et commande par WhatsApp.
- Connexion administrateur par Supabase Auth.
- Administration des produits (ajout, modification, suppression).
- Paramètres partagés : nom, description, devise, WhatsApp, e-mail et informations de livraison.
- Sécurité des données par Row Level Security (RLS).

## Mise en service Supabase

1. Créez un projet sur https://supabase.com/.
2. Dans le SQL Editor du projet, exécutez le contenu de `supabase/schema.sql`.
3. Dans Supabase > Authentication > Users, créez un utilisateur administrateur. Désactivez les inscriptions publiques si elles ne sont pas nécessaires.
4. Dans SQL Editor, attribuez le rôle admin à cet utilisateur (remplacez l'UUID) :

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where id = 'UUID_DE_L_UTILISATEUR_ADMIN';
```

5. Récupérez l'URL du projet et la clé publishable/anon dans Project Settings > API.
6. Ouvrez `config.js` et remplacez les deux valeurs d'exemple par l'URL et la clé publique de votre projet.
7. Dans GitHub, ouvrez Settings > Pages > Build and deployment > Deploy from a branch, sélectionnez `main` et `/(root)`, puis enregistrez. GitHub affichera l'adresse publique du site lorsque le déploiement sera prêt.
8. Ouvrez le site, cliquez sur Administration et connectez-vous avec l'utilisateur créé à l'étape 3.

## Sécurité
- La clé publishable/anon est conçue pour être publique lorsque RLS est activé. Ne mettez jamais la clé `service_role`, un mot de passe ou un secret serveur dans le navigateur ou dans GitHub.
- Le rôle administrateur doit être attribué dans `app_metadata` par un administrateur du projet, jamais dans `user_metadata` modifiable par le client.
- Les politiques RLS du fichier SQL autorisent les modifications uniquement aux utilisateurs dont le JWT contient `app_metadata.role = admin`.
- Les produits de démonstration affichés sans configuration Supabase ne sont pas des offres garanties. Confirmez produits, prix, stocks, frais de livraison et conditions avant toute vente.
- Les paiements en ligne MonCash/NatCash ne sont pas encore activés : ils nécessitent des identifiants marchands et une intégration serveur sécurisée. Le bouton actuel passe par WhatsApp.

## Paramètres
Connectez-vous comme administrateur > Paramètres. Les changements sont stockés dans `store_settings` et partagés avec tous les visiteurs.

## Dépannage
- Si la connexion échoue, vérifiez l'URL et la clé dans `config.js`.
- Si l'administrateur ne peut pas modifier le catalogue, vérifiez le rôle dans `auth.users.raw_app_meta_data`, puis déconnectez/reconnectez-vous pour renouveler le JWT.
