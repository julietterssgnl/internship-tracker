# Internship Tracker

Application React gratuite pour suivre les candidatures de stage à l'étranger et générer des CV et lettres de motivation personnalisés en anglais.

**Fonctions :** connexion Supabase, tableau de bord, ajout et modification d'offres, statuts, relances, profil professionnel, génération Gemini, historique, export PDF.

## Installation et configuration

### 1. Supabase (offre gratuite sous quotas)

Crée un projet sur https://supabase.com/dashboard puis, dans **SQL Editor**, exécute le contenu de [supabase/schema.sql](supabase/schema.sql).

Dans **Project Settings > API** (ou **Connect**), récupère :
- Project URL : `https://xxxx.supabase.co`
- La clé **publique** `anon` ou `publishable`.

Crée ton compte utilisateur via l'application avec une adresse e-mail et un mot de passe.

### 2. GitHub Actions et Pages

Dans **Settings > Secrets and variables > Actions**, crée les secrets de dépôt suivants :

| Nom | Valeur |
| --- | --- |
| `VITE_SUPABASE_URL` | URL du projet Supabase |
| `VITE_SUPABASE_ANON_KEY` | Clé publique du projet Supabase |

**Attention : ces valeurs sont intégrées au JavaScript client et doivent être publiques par conception.** Ne mets jamais de clé `service_role` / `secret` ou de clé Gemini dans `VITE_...`. La confidentialité repose sur l'authentification et les politiques RLS du SQL.

Dans **Settings > Pages > Build and deployment**, sélectionne **GitHub Actions**. Relance le workflow **Deploy GitHub Pages** dans l'onglet Actions si nécessaire.

URL prévue : https://julietterssgnl.github.io/internship-tracker/

Dans **Supabase > Authentication > URL Configuration**, définis **Site URL** sur cette URL et ajoute-la également dans **Redirect URLs**. Ajoute `http://localhost:5173/**` pour les essais locaux.

### 3. Génération IA sécurisée

Crée une clé Gemini via https://aistudio.google.com/apikey (quota gratuit éventuel, à vérifier sur ton compte). **Ne colle jamais la clé API dans GitHub ni dans le navigateur.**

Avec Node.js installé sur ton PC et un terminal dans le dossier :

```bash
npx supabase login
npx supabase link --project-ref TON_PROJECT_REF
npx supabase secrets set GEMINI_API_KEY=TA_CLE_GEMINI
npx supabase functions deploy generate
```

La fonction est dans `supabase/functions/generate/index.ts`. Elle authentifie l'utilisateur et lit uniquement son offre et son profil. Par défaut elle utilise `gemini-2.5-flash`. Pour changer :

```bash
npx supabase secrets set GEMINI_MODEL=MODELE_COMPATIBLE
npx supabase functions deploy generate
```

La passerelle Supabase doit accepter le jeton de connexion et la clé publique utilisés. Avec les nouveaux modèles de clés Supabase, la configuration de vérification JWT de l'Edge Function peut nécessiter une adaptation. Ne désactive pas la vérification JWT sans protection équivalente.

### 4. Développement local

```bash
npm install
cp .env.example .env
```

Sur Windows PowerShell : `Copy-Item .env.example .env`. Dans `.env`, mets l'URL et la clé publique de ton projet Supabase. Puis :

```bash
npm run dev
```

Pour vérifier le build : `npm run build`.

## Confidentialité et limites

- Le dépôt est **public**, mais **aucune donnée de candidature personnelle n'est dans le code**. Les données se trouvent dans Supabase, protégées par RLS.
- La génération transmet le profil et la description d'offre à Google Gemini. Relis les documents produits : l'IA peut se tromper.
- Export PDF textuel simple, pas de modèle de CV visuel sophistiqué.
- Pas de récupération automatique du contenu des liens d'offres : colle la description.
- Des quotas s'appliquent aux offres gratuites GitHub Pages, Supabase et Gemini ; la gratuité ne garantit pas un accès illimité.
- Ajoute une limite de fréquence à la fonction IA si le site doit être utilisé par plusieurs personnes.
- Le déploiement effectif nécessite ta configuration des comptes et des secrets.
