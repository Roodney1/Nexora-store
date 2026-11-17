# AI DIGITAL SHOP HAITI

Boutique en ligne de produits numériques construite en HTML/CSS/JavaScript avec Supabase.

## Fonctionnalités préparées
- Catalogue de modèles CV, ressources business, flyers, guides et fiches éducatives (exemples à remplacer par de vrais fichiers).
- Recherche et filtres par catégorie.
- Formulaire de commande avec nom, WhatsApp, e-mail et choix MonCash/NatCash/autre.
- Enregistrement des commandes dans Supabase.
- Espace administrateur pour publier, modifier et supprimer des produits.
- Tableau des commandes : consulter, marquer comme payé/livré et contacter le client sur WhatsApp.
- Interface adaptée aux téléphones et ordinateurs.

## Installation
1. Créez un projet sur https://supabase.com/.
2. Dans le SQL Editor, exécutez d'abord `supabase/schema.sql`.
3. Exécutez ensuite `supabase/digital-shop.sql` pour créer la table des commandes et ses règles de sécurité.
4. Dans Supabase > Authentication > Users, créez votre compte administrateur.
5. Dans SQL Editor, attribuez le rôle admin (remplacez l'UUID par celui de votre compte) :

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where id = 'UUID_DE_VOTRE_COMPTE';
```

6. Dans Supabase > Project Settings > API, copiez l'URL du projet et la clé publishable (ou anon).
7. Dans le fichier `config.js` du dépôt GitHub, remplacez les valeurs d'exemple par ces deux valeurs publiques.
8. Dans GitHub > Settings > Pages, sélectionnez Deploy from a branch, branche `main`, dossier `/(root)`, puis enregistrez.
9. Ouvrez l'adresse publiée par GitHub Pages, puis connectez-vous dans Administration.

## Ajouter vos vrais produits
Dans Administration > Produits, ajoutez un nom, une catégorie, une description, un prix en GDS et une image de couverture. Les produits visibles dans la boutique avant configuration sont des exemples : ils ne sont pas des fichiers réels prêts à vendre. Préparez vos propres fichiers PDF/DOCX/templates avant de publier les offres.

## Fonctionnement des commandes actuellement
Le client choisit un produit, remplit ses coordonnées et choisit MonCash ou NatCash. La commande est enregistrée avec le statut `pending`, puis WhatsApp s'ouvre pour contacter la boutique. Dans Administration > Commandes, vous vérifiez manuellement le paiement, marquez la commande comme payée, ajoutez si besoin un lien de livraison sécurisé, puis contactez le client sur WhatsApp.

**Important : le paiement et la livraison ne sont pas encore entièrement automatisés.** Aucune transaction MonCash/NatCash n'est encaissée ou vérifiée automatiquement par cette version. Pour une automatisation réelle, il faut un compte marchand, les identifiants/API officiels du fournisseur et une fonction serveur/webhook qui vérifie le paiement avant de créer un lien de téléchargement temporaire.

## Protéger les fichiers payants
- Ne placez jamais les fichiers payants dans un dépôt GitHub public ou un lien de stockage public.
- Utilisez un bucket privé Supabase Storage.
- Après vérification du paiement, générez un lien signé avec une durée d'expiration courte et envoyez-le au client.
- Ne mettez jamais une clé `service_role`, un mot de passe ou un secret de paiement dans `config.js` ou dans le code du navigateur.

## Mise en garde
Les revenus ne sont pas garantis. Il faudra publier des produits utiles, fixer les prix, promouvoir la boutique et répondre aux clients. GitHub Pages héberge le site statique ; Supabase fournit la base de données et l'authentification.
