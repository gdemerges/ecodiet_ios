# 🍃 EcoDiet

> Application iOS intelligente pour une alimentation saine et durable

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)
[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org/)

Application iOS developpee dans le cadre des YDays, a l'occasion de mon Mastere 1 Data Engineer a Ynov.

## 📋 Table des matieres

- [À propos](#-à-propos)
- [Fonctionnalites](#-fonctionnalites)
- [Technologies](#-technologies)
- [Architecture](#️-architecture)
- [Installation](#️-installation)
- [Utilisation](#-utilisation)
- [Ameliorations recentes](#-ameliorations-recentes)
- [Structure du projet](#-structure-du-projet)
- [Backend](#-backend)
- [Documentation](#-documentation)
- [Contribution](#-contribution)
- [Licence](#-licence)

## 🌱 À propos

EcoDiet est une application iOS moderne qui vous aide a :
- 📖 Decouvrir des recettes saines et durables
- 🥗 Gerer votre frigo et eviter le gaspillage alimentaire
- 🌍 Reduire votre empreinte carbone
- 🎯 Adapter vos repas a vos preferences dietetiques
- 📊 Suivre vos habitudes alimentaires

## ✨ Fonctionnalites

### 🔥 Fonctionnalites principales

#### Recettes intelligentes
- **Catalogue de recettes** avec filtres avances (vegetarien, vegan, sans gluten, etc.)
- **Recommandations personnalisees** selon vos ingredients disponibles
- **Calcul automatique de l'empreinte carbone** de chaque recette
- **Import depuis PostgreSQL** - Integration avec base de donnees Marmiton
- **Organisation par dossiers** - Classez vos recettes favorites
- **Recherche intelligente** avec debouncing optimise

#### Gestion du frigo
- **Inventaire complet** de vos ingredients
- **Scanner de code-barres** - Ajout rapide via OpenFoodFacts API
- **Dates d'expiration** avec notifications intelligentes
- **Suggestions de recettes** basees sur vos ingredients
- **Categories personnalisables** (legumes, proteines, produits laitiers, etc.)

#### Experience utilisateur optimisee
- **Mode sombre** - Support complet du theme clair/sombre
- **Animations fluides** - Feedback visuel et haptique
- **Cache d'images** - Chargement rapide et mode hors-ligne partiel
- **États vides personalises** - Interface intuitive
- **Infinite scroll** - Pagination automatique

#### Profil et parametres
- **Preferences dietetiques** personnalisables
- **Allergenes** - Filtrage automatique
- **Objectifs durables** - Suivi de votre impact
- **Quiz educatifs** - Ecologie et nutrition sportive
- **Themes personnalisables** - Systeme, clair, ou sombre

### 🆕 Ameliorations de performance

- ✅ **Cache d'images** (memoire + disque) pour chargement instantane
- ✅ **Pagination** des recettes PostgreSQL (20 items par page)
- ✅ **Debouncing** de la recherche (300ms) pour reduire les requetes
- ✅ **Optimisation FridgeManager** avec cache incremental
- ✅ **Mise a jour incrementale** des listes (pas de rechargement complet)

### 🎯 Fonctionnalites ajoutees

- ✅ **Scanner de code-barres** integre avec OpenFoodFacts
- ✅ **Notifications d'expiration** (1 jour avant et jour J)
- ✅ **États vides** avec illustrations pour toutes les sections
- ✅ **Animations de feedback** (bounce, shake, pulse, confetti)
- ✅ **Support du mode sombre** complet
- ✅ **Refactorisation HomeView** en composants reutilisables

## 🛠 Technologies

### Frontend (iOS)
- **SwiftUI** - Interface declarative moderne
- **SwiftData** - Persistence locale (iOS 17+)
- **@Observable** - Gestion d'etat reactive
- **AVFoundation** - Scanner de code-barres
- **UserNotifications** - Notifications locales
- **URLSession** - Requetes reseau asynchrones

### Backend
- **Node.js + Express** - API REST
- **Python + Flask** - Alternative backend
- **PostgreSQL** - Base de donnees relationnelle
- **OpenFoodFacts API** - Donnees produits alimentaires

### Outils & Services
- **Xcode 15+** - Environnement de developpement
- **Git** - Gestion de version
- **npm/pip** - Gestionnaires de dependances

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App (SwiftUI)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Home    │  │  Recipes │  │  Fridge  │  │  Profile │  │
│  │  View    │  │  View    │  │  View    │  │  View    │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       │             │              │             │         │
│  ┌────▼─────────────▼──────────────▼─────────────▼─────┐  │
│  │           SwiftDataManager (Observable)            │  │
│  └────┬────────────────────────────────────────┬──────┘  │
│       │                                        │         │
│  ┌────▼──────┐  ┌──────────────┐  ┌──────────▼──────┐  │
│  │ SwiftData │  │  ImageCache  │  │  FridgeManager  │  │
│  │  Context  │  │   (Actor)    │  │   (Observable)  │  │
│  └───────────┘  └──────────────┘  └─────────────────┘  │
└────────┬────────────────────────────────────────────────┘
         │ HTTP/REST
         │
┌────────▼────────────────────────────────────────────────┐
│              Backend API (Express.js/Flask)             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  /recettes   │  │  /recettes/  │  │  /recettes/  │ │
│  │              │  │    search    │  │     :id      │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │
          └──────────────────┴──────────────────┘
                             │
┌────────────────────────────▼────────────────────────────┐
│               PostgreSQL Database                       │
│  ┌──────────────────────────────────────────────────┐  │
│  │  marmiton_recettes                               │  │
│  │  - id, url, titre, photo, duree                  │  │
│  │  - ingredients (JSONB)                           │  │
│  │  - ustensiles (JSONB)                            │  │
│  │  - etapes (JSONB)                                │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘

External APIs:
┌─────────────────────┐
│  OpenFoodFacts API  │ ──> Barcode scanning
└─────────────────────┘
```

### Flux de donnees

1. **Recettes** : SwiftData (local) + PostgreSQL (distant)
2. **Images** : Cache memoire + disque + AsyncImage
3. **Ingredients** : SwiftData avec cache optimise
4. **Notifications** : UserNotifications framework

## 🚀 Installation

### Prerequis

- **macOS** 13.0+ (pour developper l'app iOS)
- **Xcode** 15.0+
- **Swift** 5.9+
- **Node.js** 16+ OU **Python** 3.8+ (pour le backend)
- **PostgreSQL** 15+ (optionnel, pour l'import de recettes)

### Installation rapide

1. **Cloner le depot**
   ```bash
   git clone https://github.com/votre-username/EcoDiet.git
   cd EcoDiet
   ```

2. **Configuration du backend** (optionnel)
   ```bash
   cd backend

   # Option A: Node.js
   npm install
   cp .env.example .env
   # Editer .env avec vos credentials PostgreSQL
   npm start

   # Option B: Python
   pip install -r requirements.txt
   cp .env.example .env
   # Editer .env avec vos credentials PostgreSQL
   python server.py
   ```

3. **Configuration PostgreSQL** (optionnel)
   ```bash
   # Creer la base de donnees
   createdb -U postgres marmiton

   # Importer le schema
   psql -U postgres -d marmiton -f database/schema.sql

   # Importer les donnees de test
   psql -U postgres -d marmiton -f database/test_data.sql
   ```

4. **Lancer l'app iOS**
   - Ouvrir `EcoDiet.xcodeproj` dans Xcode
   - Selectionner un simulateur iOS 17+
   - Appuyer sur `Cmd + R` pour build & run

### Scripts utilitaires

```bash
# Verifier l'environnement
./check_env.sh

# Installation automatique
./setup.sh

# Tester l'API
./test_api.sh
```

## 📱 Utilisation

### Decouvrir des recettes

1. Ouvrir l'app
2. Parcourir les recettes sur la page d'accueil
3. Filtrer par tags dietetiques (vegetarien, vegan, etc.)
4. Consulter l'empreinte carbone de chaque recette
5. Importer des recettes depuis PostgreSQL

### Gerer votre frigo

1. Aller dans l'onglet "Frigo"
2. Ajouter des ingredients :
   - Manuellement avec le bouton "+"
   - Scanner un code-barres avec le bouton scanner
3. Definir les dates d'expiration
4. Recevoir des notifications avant expiration
5. Voir les recettes realisables avec vos ingredients

### Scanner un produit

1. Cliquer sur le bouton scanner (icone code-barres)
2. Pointer la camera vers le code-barres
3. L'ingredient est automatiquement ajoute avec ses informations
4. Ajuster la quantite et la date d'expiration

### Personnaliser votre profil

1. Aller dans l'onglet "Profil"
2. Definir vos preferences dietetiques
3. Indiquer vos allergenes
4. Choisir votre theme (clair, sombre, systeme)
5. Passer les quiz educatifs

## 🎨 Ameliorations recentes

### Performance

| Amelioration | Impact | Avant | Apres |
|-------------|--------|-------|-------|
| Cache d'images | Chargement 10x plus rapide | 2-3s | <300ms |
| Debouncing recherche | 70% moins de requetes | Chaque frappe | Toutes les 300ms |
| Pagination | Chargement initial 5x plus rapide | 100+ items | 20 items |
| Cache FridgeManager | Filtrage instantane | O(n) a chaque fois | O(1) avec cache |

### Nouvelles fonctionnalites

1. **Scanner de code-barres** (`BarcodeScanIngredientView.swift`)
   - Integration OpenFoodFacts API
   - Detection automatique des codes-barres
   - Ajout rapide au frigo

2. **Notifications d'expiration** (`ExpirationNotificationService.swift`)
   - Notification 1 jour avant expiration
   - Notification le jour de l'expiration
   - Badge visuel sur les ingredients perimes

3. **Mode sombre** (`ThemeManager.swift`)
   - Support complet clair/sombre/systeme
   - Couleurs adaptatives
   - Persistance des preferences

4. **Animations** (`FeedbackAnimations.swift`)
   - Bounce, shake, pulse, confetti
   - Feedback haptique
   - États de chargement fluides

## 📁 Structure du projet

```
EcoDiet/
├── EcoDiet/                          # Application iOS
│   ├── Models.swift                  # Modeles de donnees (Recipe, Ingredient, etc.)
│   ├── SwiftDataManager.swift        # Gestion SwiftData
│   ├── FridgeManager.swift           # Logique frigo optimisee
│   │
│   ├── Views/                        # Vues principales
│   │   ├── HomeView.swift
│   │   ├── HomeComponents.swift      # Composants Home extraits
│   │   ├── RecipesView.swift
│   │   ├── FridgeView.swift
│   │   ├── ProfileView.swift
│   │   └── RecettesPostgreSQLView.swift
│   │
│   ├── Components/                   # Composants reutilisables
│   │   ├── RecipeCard.swift
│   │   ├── EmptyStateView.swift      # États vides
│   │   └── ExpirationBadge.swift
│   │
│   ├── Services/                     # Services
│   │   ├── PostgreSQLService.swift   # API PostgreSQL
│   │   ├── ImageCache.swift          # Cache d'images
│   │   ├── ExpirationNotificationService.swift
│   │   └── ThemeManager.swift
│   │
│   ├── Utils/                        # Utilitaires
│   │   ├── Debouncer.swift           # Debouncing
│   │   └── FeedbackAnimations.swift  # Animations
│   │
│   └── Barcode/
│       └── BarcodeScanIngredientView.swift
│
├── backend/                          # API Backend
│   ├── server.js                     # Express.js server
│   ├── server.py                     # Flask server (alternative)
│   ├── package.json
│   ├── requirements.txt
│   └── .env                          # Configuration
│
├── database/                         # SQL
│   ├── schema.sql                    # Schema PostgreSQL
│   └── test_data.sql                 # Donnees de test
│
├── docs/                             # Documentation
│   ├── COMPLETE_GUIDE.md
│   ├── QUICKSTART.md
│   ├── ARCHITECTURE.md
│   ├── README_PostgreSQL.md
│   └── BACKEND_CHOICE.md
│
└── scripts/                          # Scripts utilitaires
    ├── setup.sh
    ├── check_env.sh
    └── test_api.sh
```

## 🔧 Backend

### API Endpoints

| Endpoint | Methode | Description |
|----------|---------|-------------|
| `/health` | GET | Health check |
| `/api/recettes` | GET | Liste toutes les recettes (avec pagination) |
| `/api/recettes/:id` | GET | Details d'une recette |
| `/api/recettes/search?q=...` | GET | Recherche de recettes |

### Demarrer le backend

```bash
cd backend

# Node.js
npm start

# Python
python server.py
```

Le serveur demarre sur `http://localhost:3000`

### Variables d'environnement

Creer un fichier `.env` dans le dossier `backend/` :

```env
# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=marmiton
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe

# Server
PORT=3000
NODE_ENV=development
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [COMPLETE_GUIDE.md](EcoDiet/COMPLETE_GUIDE.md) | Guide complet avec diagrammes |
| [QUICKSTART.md](EcoDiet/QUICKSTART.md) | Demarrage rapide (5 min) |
| [ARCHITECTURE.md](EcoDiet/ARCHITECTURE.md) | Architecture technique detaillee |
| [README_PostgreSQL.md](EcoDiet/README_PostgreSQL.md) | Integration PostgreSQL |
| [BACKEND_CHOICE.md](EcoDiet/BACKEND_CHOICE.md) | Choix Node.js vs Python |

## 🧪 Tests

### Verifier l'environnement
```bash
./check_env.sh
```

### Tester l'API
```bash
./test_api.sh

# OU manuellement
curl http://localhost:3000/health
curl http://localhost:3000/api/recettes?page=1&limit=10
```

### Tests iOS
- Lancer l'app dans le simulateur
- Tester les fonctionnalites principales
- Verifier les animations et le mode sombre

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. Fork le projet
2. Creer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Guidelines

- Suivre les conventions Swift (camelCase, etc.)
- Commenter le code complexe
- Tester avant de commit
- Mettre a jour la documentation si necessaire

## 🐛 Problemes connus

| Probleme | Solution |
|----------|----------|
| **Missing package product 'AsyncAlgorithms'** | Supprimer la dependance dans Xcode projet settings |
| **Connection refused** | Verifier que le backend est demarre (`npm start`) |
| **Scanner ne fonctionne pas** | Verifier les permissions camera dans Settings |
| **Notifications non recues** | Autoriser les notifications dans Settings iOS |

## 📊 Statistiques

- **~8,000 lignes de code** Swift
- **30+ fichiers** Swift
- **8 nouveaux fichiers** pour les ameliorations
- **3 services** optimises (Cache, Notifications, Theme)
- **2 options backend** (Node.js + Python)

## 🗺️ Roadmap

### À venir
- [ ] Mode hors-ligne complet
- [ ] Synchronisation iCloud
- [ ] Widget iOS
- [ ] Apple Watch companion
- [ ] Partage de recettes entre utilisateurs
- [ ] Integration HealthKit
- [ ] Export/Import de donnees
- [ ] Themes personnalisables avances

### En cours
- [x] Scanner de code-barres
- [x] Notifications d'expiration
- [x] Mode sombre
- [x] Cache d'images
- [x] Optimisations performance

## 📄 Licence

Ce projet est developpe dans le cadre des YDays - Mastere 1 Data Engineer a Ynov.

## 🙏 Remerciements

- **Apple** - SwiftUI, SwiftData, et les frameworks iOS
- **OpenFoodFacts** - API de donnees alimentaires
- **PostgreSQL** - Base de donnees robuste
- **Express.js / Flask** - Frameworks backend
- **Ynov** - Formation et encadrement du projet

## 👤 Auteur

**Guillaume Demerges**
- Mastere 1 Data Engineer @ Ynov
- Projet YDays 2025-2026

## 📞 Support

Pour toute question ou probleme :
1. Consulter la [documentation](docs/)
2. Verifier les [problemes connus](#-problemes-connus)
3. Ouvrir une issue sur GitHub

---

**Cree avec ❤️ pour une alimentation saine et durable**

🍃 EcoDiet - Mangez sainement, naturellement
