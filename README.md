# Spotlite — La preuve par l'action

Plateforme de mise en relation entre **talents** et **employeurs**, basée sur la démonstration concrète des compétences plutôt que sur le CV.

---

## Architecture du projet

```
spotlite/
├── mobile/          # Application Flutter (iOS & Android)
├── web/             # Dashboard employeur Next.js (en cours)
├── backend/         # Schéma PostgreSQL & politiques RLS
│   └── supabase/
│       ├── schema.sql
│       ├── rls_policies.sql
│       └── seed.sql
└── supabase/        # Edge Functions (Deno TypeScript)
    └── functions/
        ├── matching_engine/
        └── notification_trigger/
```

---

## Stack technique

| Couche | Technologie |
|---|---|
| Mobile | Flutter 3 · Dart 3.10+ |
| State management | Riverpod 2.5 |
| Navigation | GoRouter 14 |
| Backend | Supabase (Auth · DB · Storage · Realtime) |
| Base de données | PostgreSQL avec Row Level Security |
| Edge Functions | Deno TypeScript |
| Web (dashboard) | Next.js |

---

## Fonctionnalités

### Côté Talent
- Création de profil avec compétences (niveau + vérification)
- **Spotlite Stages** — portfolio dynamique en blocs personnalisables (image, vidéo, texte, badge, lien)
- Fil social : posts, likes, commentaires
- Exploration des employeurs et gestion des matchs
- **Challenges** — défis de compétences posés par les employeurs
- Notifications en temps réel (Supabase Realtime)

### Côté Employeur
- Découverte de talents via algorithme de scoring
- Swipe / flash sur les profils (tableau de bord style Tinder)
- Système de match bilatéral (les deux parties doivent accepter)
- Création de challenges pour tester les compétences
- Dashboard de gestion des candidatures

---

## Modèle de données (tables principales)

| Table | Description |
|---|---|
| `profiles` | Compte commun talent/employeur |
| `talents` | Profil professionnel du talent |
| `employers` | Profil entreprise |
| `skills` | Compétences liées à un talent |
| `matches` | Connexions talent ↔ employeur |
| `spotlite_stages` | Portfolio dynamique (blocs JSONB) |
| `posts` | Publications du fil social |
| `challenges` | Défis de compétences |
| `challenge_submissions` | Réponses aux challenges |
| `notifications` | Notifications temps réel |

---

## Edge Functions

### `matching_engine`
Invoquée par l'employeur pour découvrir des talents. Applique un scoring :
- Base : `score_qualification` du talent
- +15 si le secteur correspond
- +5 par compétence vérifiée
- Exclut les talents déjà matchés
- Retourne les 20 meilleurs profils

### `notification_trigger`
Crée les notifications lors des événements de match :
- `employer_like` → notifie le talent de l'intérêt
- `match_confirmed` → notifie les deux parties lors d'un match mutuel

---

## Application mobile — structure `lib/`

```
mobile/lib/
├── main.dart                  # Point d'entrée, init Supabase
├── router.dart                # Routes GoRouter
├── models/                    # UserModel, TalentModel, EmployerModel, MatchModel, SkillModel
├── services/                  # auth, supabase, matching, post, media
├── providers/                 # Riverpod providers (auth, user, matching)
├── screens/
│   ├── auth/                  # Login, Signup
│   ├── talent/                # Feed, Profil, Portfolio, Réseau, Matches, Challenges, Notifications
│   └── employer/              # Dashboard swipe, Liste talents
└── widgets/                   # ProfileCard, SpotliteStage, SkillBadge, AnimatedProjector
```

---

## Installation & démarrage

### Prérequis
- Flutter SDK ≥ 3.10
- Compte Supabase avec le schéma déployé
- Deno (pour les Edge Functions)

### Mobile

```bash
cd mobile
cp .env.example .env   # Renseigner SUPABASE_URL et SUPABASE_ANON_KEY
flutter pub get
flutter run
```

### Base de données (Supabase)

Exécuter dans l'ordre dans l'éditeur SQL Supabase :

```
backend/supabase/schema.sql       # Tables et types
backend/supabase/rls_policies.sql # Politiques de sécurité
backend/seed.sql                  # Données de test (optionnel)
```

### Edge Functions

```bash
supabase functions deploy matching_engine
supabase functions deploy notification_trigger
```

---

## Variables d'environnement

Fichier `mobile/.env` :

```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

---

## Thème & design

- Couleur principale : `#1877F2` (Spotlite Blue)
- Design system : Material Design 3
- Police : Segoe UI / Google Fonts
- Fond : `#F0F2F5`

---

## Rôles utilisateur

| Rôle | Accès |
|---|---|
| `talent` | Feed, portfolio, challenges, matchs entrants |
| `employeur` | Dashboard découverte, challenges, matchs sortants |

Le rôle est défini à l'inscription et détermine l'ensemble de l'interface affichée.
