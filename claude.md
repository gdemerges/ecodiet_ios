# EcoDiet - Guide pour Claude

## Vue d'ensemble du projet

EcoDiet est une application iOS native développée en SwiftUI pour YDays (Ynov Academy). C'est une plateforme intelligente de nutrition et durabilité qui aide les utilisateurs à :
- Découvrir des recettes saines et durables
- Gérer leur inventaire de cuisine (frigo)
- Réduire le gaspillage alimentaire et l'empreinte carbone
- Personnaliser leurs préférences alimentaires et allergies
- Suivre leurs habitudes alimentaires avec des métriques d'impact environnemental

**Statistiques du projet** :
- ~14 400 lignes de code Swift
- 49 fichiers Swift
- 8 000+ recettes dans la base PostgreSQL
- Support iOS 17+

## Stack technique

### Frontend (iOS)
- **SwiftUI** - Framework UI déclaratif moderne
- **SwiftData** - Persistance locale iOS 17+
- **@Observable** - Gestion d'état réactive (pas de MVVM)
- **AVFoundation** - Scanner de codes-barres
- **UserNotifications** - Notifications d'expiration
- **URLSession** - Requêtes réseau asynchrones

### Backend
- **Node.js + Express.js** - API REST principale (port 3000)
- **Python + Flask** - Implémentation backend alternative
- **PostgreSQL 15+** - Base de données avec 8000+ recettes de Marmiton

### APIs externes
- **OpenFoodFacts API** - Données produits pour scanner de codes-barres

## Structure du projet

```
EcoDiet/
├── EcoDiet/                              # Application iOS principale
│   ├── Models.swift                      # Modèles de données principaux
│   ├── Ingredient.swift                  # Modèle d'ingrédient
│   ├── QuizModels.swift                  # Modèles de quiz éducatif
│   ├── SwiftDataManager.swift            # Manager central pour données locales
│   ├── FridgeManager.swift               # Gestion optimisée du frigo avec cache
│   ├── PostgreSQLService.swift           # Client API pour recettes backend
│   ├── ImageCache.swift                  # Cache d'images à deux niveaux
│   ├── ExpirationNotificationService.swift # Gestion des notifications
│   ├── ThemeManager.swift                # Gestion dark/light mode
│   ├── Views/                            # Vues principales
│   │   ├── ContentView.swift             # Point d'entrée
│   │   ├── MainTabView.swift             # Navigation à 4 onglets
│   │   ├── HomeView.swift                # Dashboard
│   │   ├── FridgeView.swift              # Gestion du frigo
│   │   ├── FoldersView.swift             # Organisation des recettes
│   │   └── ProfileView.swift             # Paramètres utilisateur
│   └── Components/                       # Composants réutilisables
├── backend/
│   ├── server.js                         # API Express.js
│   ├── server.py                         # Alternative Flask
│   └── package.json
└── database/
    ├── schema.sql                        # Schéma PostgreSQL
    └── test_data.sql

```

## Architecture et patterns

### Pattern de gestion d'état
L'app utilise **@Observable** (iOS 17+) au lieu de MVVM :
- **Source unique de vérité** : `SwiftDataManager` contient toutes les données locales
- **Mises à jour réactives** : Les vues se rafraîchissent automatiquement
- **Managers observables** : `SwiftDataManager`, `FridgeManager`, `UserProfileManager`

### Flux de données
```
SwiftUI Views
    ↓
@Observable Managers (État)
    ↓
SwiftData (Stockage local)
    ↓
SQLite Database
```

Et pour les données réseau :
```
Network Requests
    ↓
PostgreSQLService (Client API)
    ↓
Node.js/Express Backend
    ↓
PostgreSQL Database
```

### Stratégie de cache

**ImageCache** (basé sur Actor pour thread-safety) :
- Cache mémoire : 100 images, limite 50MB
- Cache disque : Système de fichiers
- Promotion automatique du disque vers la mémoire
- **Impact** : Chargement 10x plus rapide (<300ms vs 2-3s)

**FridgeCache** :
- Set<String> pour recherches O(1)
- Mises à jour incrémentales
- Invalidation sur changements d'ingrédients

**Search Debouncing** :
- Délai de 300ms pour réduire les appels API
- **Impact** : 70% de requêtes en moins

## Modèles de données principaux

### Recipe (SwiftData)
```swift
@Model class Recipe {
    var id: UUID
    var title: String
    var imageName: String
    var carbonFootprint: Double        // g CO2eq
    var preparationTime: Int           // minutes
    var dietaryTags: [String]         // Végétarien, Vegan, etc.
    var allergens: [String]
    var requiredIngredients: [RecipeIngredient]
    var ustensiles: [String]
    var etapes: [String]
    var sourceURL: String?
    var folders: [RecipeFolder]
    var ecoScore: EcoScore            // Calculé depuis carbonFootprint
}
```

### Ingredient (SwiftData)
```swift
@Model class Ingredient {
    var id: UUID
    var name: String
    var category: IngredientCategory
    var unit: IngredientUnit
    var quantity: Double
    var expirationDate: Date?
    var isInFridge: Bool
    var imageName: String
}
```

### EcoScore (Enum)
- A : < 500g CO2eq
- B : 500-1000g CO2eq
- C : 1000-2000g CO2eq
- D : 2000-3500g CO2eq
- E : > 3500g CO2eq

## Services clés

### SwiftDataManager
Manager central pour toutes les données locales :
- Chargement/sauvegarde des profils utilisateur
- CRUD des recettes
- Gestion des favoris
- Organisation par dossiers
- Recommandations personnalisées

### FridgeManager
Gestion optimisée de l'inventaire :
- Mises à jour incrémentales (pas de rechargement complet)
- Recherches d'ingrédients en cache
- Suivi des expirations

### PostgreSQLService
Client API pour la base de recettes distante :
- Support de la pagination (page + limit)
- Recherche avec debouncing
- Gestion des erreurs
- **Base URL** : `http://localhost:3000/api`

**Endpoints** :
- `GET /api/recettes?page=1&limit=20` - Liste paginée
- `GET /api/recettes/:id` - Recette unique
- `GET /api/recettes/search?q=pasta` - Recherche

### ExpirationNotificationService
Planification des notifications locales :
- Demande de permissions
- Planification d'alertes (1 jour avant + jour J)
- Annulation de notifications

### ImageCache (Actor)
Cache d'images thread-safe :
- Cache mémoire : NSCache
- Cache disque : Système de fichiers
- Auto-promotion disque → mémoire

## Fonctionnalités principales

### 1. Système de recettes
- 8000+ recettes de Marmiton
- Filtrage par tags et préférences
- Calcul d'empreinte carbone
- Recherche intelligente avec debouncing
- Organisation par dossiers

### 2. Gestion du frigo
- Suivi d'inventaire avec quantités et dates
- Scanner de codes-barres (OpenFoodFacts)
- Notifications d'expiration (1 jour avant + jour J)
- 8 catégories d'ingrédients
- Recommandations de recettes basées sur le frigo

### 3. Profil utilisateur
- Préférences alimentaires
- Gestion des allergies
- Niveau de cuisine (Débutant → Expert)
- Sélection du thème (Système/Clair/Sombre)
- Objectifs de santé

### 4. Fonctionnalités éducatives
- Quiz écologique
- Visualisation de l'impact carbone
- Éducation nutritionnelle

## Optimisations de performance

| Optimisation | Impact | Avant | Après |
|--------------|--------|-------|-------|
| Cache d'images | 10x plus rapide | 2-3s | <300ms |
| Debouncing recherche | 70% moins de requêtes | Chaque frappe | Tous les 300ms |
| Pagination | 5x plus rapide | 100+ items | 20 items |
| Cache frigo | Filtrage instantané | O(n) | O(1) |

## Conventions de code

### Nommage
- **Types** : PascalCase (`Recipe`, `FridgeManager`)
- **Variables/fonctions** : camelCase (`addIngredient`, `carbonFootprint`)
- **Constantes** : camelCase avec let (`defaultRecipes`)

### Organisation des fichiers
- **Models** : Structures de données pures
- **Services** : Appels API, cache, notifications
- **Managers** : Logique métier et gestion d'état
- **Views** : Rendu UI uniquement (pas de logique métier)
- **Components** : Composants réutilisables

### Gestion d'état
- Utiliser `@Observable` pour les managers
- `@Environment` pour injecter les managers dans les vues
- `@State` pour l'état local de la vue
- `@Binding` pour partager l'état entre parent/enfant

## Commandes utiles

### Backend
```bash
# Démarrer le serveur Node.js
cd backend
npm install
npm start                    # Port 3000

# Alternative Python
pip install -r requirements.txt
python server.py             # Port 5000
```

### Base de données
```bash
# Se connecter à PostgreSQL
psql -U postgres -d ecodiet

# Créer le schéma
psql -U postgres -d ecodiet -f database/schema.sql

# Charger des données de test
psql -U postgres -d ecodiet -f database/test_data.sql
```

### iOS
```bash
# Ouvrir le projet
open EcoDiet.xcodeproj

# Build depuis la ligne de commande
xcodebuild -scheme EcoDiet -destination 'platform=iOS Simulator,name=iPhone 15'

# Lancer les tests
xcodebuild test -scheme EcoDiet -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Git
```bash
# Branche principale
git checkout main

# Voir l'historique récent
git log --oneline -10
```

## Points d'attention pour le développement

### Ne PAS faire
- Ne pas créer de fichiers Markdown (.md) sans demande explicite
- Ne pas utiliser d'emojis sans demande de l'utilisateur
- Ne pas sur-ingénierer : garder les solutions simples
- Ne pas ajouter de fonctionnalités non demandées
- Ne pas ajouter de docstrings/commentaires au code non modifié
- Ne pas créer d'abstractions prématurées
- Ne pas utiliser `git commit --amend` sauf conditions strictes

### À faire
- Toujours lire un fichier avant de le modifier
- Utiliser les outils spécialisés (Read, Edit, Write) au lieu de bash
- Préférer éditer des fichiers existants plutôt que d'en créer de nouveaux
- Tester les changements qui affectent la logique métier
- Vérifier les vulnérabilités de sécurité (injection SQL, XSS, etc.)
- Utiliser TodoWrite pour planifier les tâches complexes
- Faire des commits avec des messages descriptifs

### Patterns de référence du code
Quand vous référencez du code, utilisez le format `file_path:line_number` :
```
La fonction connectToServer est définie dans src/services/process.ts:712
```

## Documentation complémentaire

Consultez les fichiers suivants pour plus de détails :
- `docs/COMPLETE_GUIDE.md` - Guide complet de l'application
- `docs/QUICKSTART.md` - Démarrage rapide
- `docs/ARCHITECTURE.md` - Détails architecturaux
- `docs/README_PostgreSQL.md` - Configuration PostgreSQL
- `docs/BACKEND_CHOICE.md` - Choix du backend

## Environnement de développement

- **Xcode** : 15+ requis
- **iOS** : 17+ minimum
- **Node.js** : 14+ recommandé
- **PostgreSQL** : 15+ recommandé
- **OS** : macOS (pour développement iOS)

## État actuel du projet

**Branche** : main (propre, pas de changements non commités)

**Derniers commits** :
- f4ed0e0 - update readme
- 85863f4 - update
- 3052c7e - change background
- 8444285 - update logo and colors
- 225b0a0 - fix bug fridge

**Fonctionnalités récentes (v2)** :
- Scanner de codes-barres avec OpenFoodFacts
- Système de notifications d'expiration
- Support du mode sombre
- Cache d'images optimisé
- Recherche avec debouncing
- Pagination des recettes

## Notes pour l'IA

### Contexte des tâches
- L'app est en production active pour YDays
- Les performances sont critiques (cache, pagination, debouncing)
- La sécurité alimentaire est importante (notifications d'expiration)
- L'UX doit être fluide (animations, feedback haptique)

### Approche de développement
- Toujours explorer le codebase avant de proposer des changements
- Utiliser EnterPlanMode pour les tâches non triviales
- Privilégier les patterns existants du projet
- Tester l'impact sur les performances
- Considérer l'impact sur l'empreinte carbone (thème de l'app)

### Technologies à connaître
- SwiftUI est déclaratif (pas de ViewControllers)
- SwiftData remplace Core Data
- @Observable remplace ObservableObject/MVVM
- Actor assure la thread-safety (ImageCache)
- async/await pour les opérations asynchrones

### Dépendances système
- OpenFoodFacts API pour les codes-barres
- PostgreSQL doit être en cours d'exécution (localhost:5432)
- Backend doit être actif (localhost:3000)
- Permissions caméra pour scanner
- Permissions notifications pour alertes
