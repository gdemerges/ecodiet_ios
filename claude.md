# EcoDiet

Application iOS (SwiftUI + SwiftData) de nutrition et durabilité alimentaire. ~14 400 lignes Swift, 8 000+ recettes PostgreSQL, iOS 17+.

## Stack

- **iOS** : SwiftUI, SwiftData, @Observable, AVFoundation, URLSession
- **Backend** : Node.js/Express (port 3000), PostgreSQL 15+
- **API externe** : OpenFoodFacts (codes-barres)

## Fichiers clés

| Fichier | Rôle |
|---------|------|
| `EcoDiet/SwiftDataManager.swift` | Source unique de vérité — CRUD local, favoris, dossiers |
| `EcoDiet/FridgeManager.swift` | Inventaire frigo avec cache O(1) |
| `EcoDiet/PostgreSQLService.swift` | Client API recettes (`localhost:3000/api`) |
| `EcoDiet/ImageCache.swift` | Cache mémoire + disque (Actor, thread-safe) |
| `backend/server.js` | API Express.js |

## Règles

**Ne pas faire :**
- Créer des fichiers `.md` sans demande explicite
- Utiliser des emojis sans demande
- Ajouter des commentaires au code non modifié
- Sur-ingénierer ou ajouter des fonctionnalités non demandées
- `git commit --amend` sauf demande explicite

**Toujours faire :**
- Lire un fichier avant de le modifier
- Référencer le code avec `fichier:ligne`
- Explorer le codebase avant de proposer des changements
- Utiliser EnterPlanMode pour les tâches non triviales

## Détails

- Architecture & patterns : `EcoDiet/ARCHITECTURE.md`
- Guide complet : `EcoDiet/COMPLETE_GUIDE.md`
- Démarrage rapide : `EcoDiet/QUICKSTART.md`
- Config PostgreSQL : `EcoDiet/README_PostgreSQL.md`
- Config réseau iOS : `EcoDiet/iOS_HTTP_CONFIG.md`
