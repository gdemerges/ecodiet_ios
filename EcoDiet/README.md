# 🍽️ EcoDiet - Intégration PostgreSQL

> Connectez votre application iOS EcoDiet à une base de données PostgreSQL pour importer des recettes Marmiton

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![Node.js](https://img.shields.io/badge/Node.js-16+-green.svg)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)

## 📋 Table des matières

- [🚀 Quick Start](#-quick-start)
- [📚 Documentation](#-documentation)
- [✨ Fonctionnalités](#-fonctionnalités)
- [🏗️ Architecture](#️-architecture)
- [📸 Captures d'écran](#-captures-décran)
- [🛠️ Installation](#️-installation)
- [🧪 Tests](#-tests)
- [🤝 Contribution](#-contribution)

## 🚀 Quick Start

### En 3 étapes

1. **Vérifier l'environnement**
   ```bash
   chmod +x check_env.sh
   ./check_env.sh
   ```

2. **Installer automatiquement**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Démarrer le serveur**
   ```bash
   npm start  # ou: python server.py
   ```

4. **Lancer l'app iOS dans Xcode**
   - Ouvrir le projet
   - Cmd+R pour build & run
   - Accueil → Bouton "PostgreSQL"

### 📺 Vidéo de démo

```
[Insérez ici un lien vers une vidéo de démo si vous en créez une]
```

## 📚 Documentation

| Document | Description | Pour qui |
|----------|-------------|----------|
| **[📖 INDEX.md](INDEX.md)** | Index complet de tous les fichiers | Tout le monde |
| **[🚀 COMPLETE_GUIDE.md](COMPLETE_GUIDE.md)** | Guide complet avec diagrammes | Débutants |
| **[⚡ QUICKSTART.md](QUICKSTART.md)** | Démarrage en 5 minutes | Pressés |
| **[🏗️ ARCHITECTURE.md](ARCHITECTURE.md)** | Architecture technique | Développeurs |
| **[📝 README_PostgreSQL.md](README_PostgreSQL.md)** | Documentation détaillée | Référence |

## ✨ Fonctionnalités

### ✅ Implémenté

- [x] **Connexion PostgreSQL** via API REST
- [x] **Affichage des recettes** de la base de données
- [x] **Recherche locale** dans les recettes
- [x] **Import individuel** de recettes
- [x] **Synchronisation complète** (import en masse)
- [x] **Conversion automatique** des données
- [x] **Détection des tags diététiques** (Vegan, Végétarien, etc.)
- [x] **Calcul de l'empreinte carbone**
- [x] **Images distantes** (AsyncImage)
- [x] **Feedback haptique**
- [x] **Gestion des états** (loading, error, success)

### 🚧 À venir

- [ ] Téléchargement et cache des images
- [ ] Mode hors-ligne
- [ ] Pagination côté client
- [ ] Filtres avancés
- [ ] Notifications push
- [ ] Upload de nouvelles recettes

## 🏗️ Architecture

```
┌─────────────┐
│  iOS App    │ SwiftUI + SwiftData
│  (Swift)    │
└──────┬──────┘
       │ HTTP/REST
       │
┌──────▼──────┐
│ Backend API │ Express.js / Flask
│ (Node/Py)   │
└──────┬──────┘
       │ SQL
       │
┌──────▼──────┐
│ PostgreSQL  │ Recettes Marmiton
│  Database   │
└─────────────┘
```

**Détails** : Voir [ARCHITECTURE.md](ARCHITECTURE.md)

## 📸 Captures d'écran

### HomeView avec bouton PostgreSQL
```
┌─────────────────────────────────┐
│  Bonjour Jean !                 │
│  🍃 Mangez sainement...         │
│                                 │
│  📖 Nos recettes                │
│  [PostgreSQL] [Voir tout]  ← 🆕│
└─────────────────────────────────┘
```

### Liste des recettes PostgreSQL
```
┌─────────────────────────────────┐
│  🔍 Rechercher...               │
│                                 │
│  🖼️ Salade de Quinoa        ⬇│
│     ⏱️ 25 min | 8 ingrédients │
│                                 │
│  🖼️ Poulet Rôti             ⬇│
│     ⏱️ 1h15 | 8 ingrédients  │
└─────────────────────────────────┘
```

## 🛠️ Installation

### Prérequis

- **PostgreSQL** 15+ installé et en cours d'exécution
- **Node.js** 16+ OU **Python** 3.8+
- **Xcode** 15+ avec Swift 5.9+
- **macOS** pour développer l'app iOS

### Installation manuelle

#### 1. PostgreSQL

```bash
# Créer la base de données
createdb -U postgres marmiton

# Créer la table
psql -U postgres -d marmiton -c "
CREATE TABLE marmiton_recettes (
    id SERIAL PRIMARY KEY,
    url TEXT UNIQUE NOT NULL,
    titre TEXT,
    photo TEXT,
    duree TEXT,
    ingredients JSONB,
    ustensiles JSONB,
    etapes JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);"

# Insérer des données de test
psql -U postgres -d marmiton -f test_data.sql
```

#### 2. Backend (choisir l'un)

**Option A : Node.js**
```bash
npm install
npm start
```

**Option B : Python**
```bash
pip install -r requirements.txt
python server.py
```

#### 3. iOS

1. Ouvrir le projet dans Xcode
2. Ajouter dans `Info.plist` :
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsLocalNetworking</key>
       <true/>
   </dict>
   ```
3. Build & Run (Cmd+R)

### Installation automatique

```bash
./setup.sh
```

## 🧪 Tests

### Vérifier l'environnement

```bash
./check_env.sh
```

### Tester l'API

```bash
./test_api.sh
```

### Tester manuellement

```bash
# Health check
curl http://localhost:3000/health

# Toutes les recettes
curl http://localhost:3000/api/recettes

# Une recette
curl http://localhost:3000/api/recettes/1

# Recherche
curl "http://localhost:3000/api/recettes/search?q=poulet"
```

### Tests iOS

1. Lancer l'app
2. Accueil → Bouton "PostgreSQL"
3. Vérifier l'affichage des recettes
4. Tester l'import (icône ⬇)
5. Vérifier le feedback (✅ + vibration)

## 📊 Statistiques

```
📦 21 fichiers créés/modifiés
📝 ~4750 lignes de code
🔧 3 langages (Swift, JavaScript/Python, SQL)
📚 8 fichiers de documentation
🧪 3 scripts de test/installation
```

## 🤝 Contribution

### Structure du projet

```
EcoDiet/
├── iOS/                          # Application Swift
│   ├── PostgreSQLService.swift
│   ├── RecettesPostgreSQLView.swift
│   ├── RecipeMigration.swift
│   ├── Models.swift             # Modifié
│   └── HomeView.swift           # Modifié
├── backend/                      # Serveur API
│   ├── server.js                # Node.js
│   ├── server.py                # Python
│   ├── package.json
│   ├── requirements.txt
│   └── .env                     # Configuration
├── database/
│   └── test_data.sql            # Données de test
├── docs/                         # Documentation
│   ├── INDEX.md
│   ├── COMPLETE_GUIDE.md
│   ├── QUICKSTART.md
│   ├── ARCHITECTURE.md
│   ├── README_PostgreSQL.md
│   ├── BACKEND_CHOICE.md
│   ├── iOS_HTTP_CONFIG.md
│   └── SUMMARY.md
└── scripts/                      # Scripts utilitaires
    ├── setup.sh
    ├── check_env.sh
    └── test_api.sh
```

## 🐛 Problèmes connus

| Problème | Solution |
|----------|----------|
| Connection refused | Vérifier que le serveur est démarré |
| ATS blocked | Configurer `Info.plist` (voir [iOS_HTTP_CONFIG.md](iOS_HTTP_CONFIG.md)) |
| Table not found | Exécuter `./setup.sh` |
| CORS error | Vérifier que le serveur autorise CORS |

## 📝 TODO

- [ ] Ajouter des tests unitaires Swift
- [ ] Implémenter le cache d'images
- [ ] Ajouter la pagination
- [ ] Créer des filtres avancés
- [ ] Implémenter l'authentification
- [ ] Ajouter des webhooks
- [ ] Support du mode sombre
- [ ] Localisation (EN, FR)

## 📄 Licence

Ce projet est créé pour **EcoDiet** dans le cadre d'une démonstration d'intégration PostgreSQL.

## 🙏 Remerciements

- **Apple** pour SwiftUI et SwiftData
- **PostgreSQL** pour la base de données
- **Express.js** / **Flask** pour les frameworks backend
- **Marmiton** pour l'inspiration des données

## 📞 Support

**Besoin d'aide ?**

1. Consultez [INDEX.md](INDEX.md) pour trouver le bon document
2. Lisez [QUICKSTART.md](QUICKSTART.md) pour les bases
3. Vérifiez [ARCHITECTURE.md](ARCHITECTURE.md) pour comprendre le fonctionnement

## 🌟 Étoiles

Si ce projet vous a aidé, n'oubliez pas de lui donner une étoile ⭐ !

---

**Créé avec ❤️ pour une alimentation saine et durable**

🍃 EcoDiet - Mangez sainement, naturellement
