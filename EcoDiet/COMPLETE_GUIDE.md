# 🚀 EcoDiet + PostgreSQL - Guide Complet

```
 _____ ____  ____  ____  ____  ____  _____
| ____|  _ \|  _ \|  _ \/ ___|  _ \| ____|
|  _| | |_) | | | | | | \___ \| | | |  _|  
| |___|  __/| |_| | |_| |___) | |_| | |___ 
|_____|_|   |____/|____/|____/|____/|_____|
                                           
     +  PostgreSQL Integration
```

## 📦 Fichiers créés

Voici tous les fichiers que j'ai créés pour vous :

### 🔧 Backend (Serveur API)

```
backend/
├── server.js              ← Serveur Node.js (recommandé) ⭐
├── server.py              ← Serveur Python (alternatif)
├── package.json           ← Dépendances Node.js
├── requirements.txt       ← Dépendances Python
├── .env                   ← Configuration (NE PAS COMMIT)
└── .gitignore             ← Fichiers à ignorer
```

### 📱 iOS (Application Swift)

```
iOS/
├── PostgreSQLService.swift        ← Service API
├── RecettesPostgreSQLView.swift   ← Interface utilisateur
├── RecipeMigration.swift          ← Helper migration SwiftData
├── Models.swift                   ← ✏️ Modifié (+ 3 champs)
└── HomeView.swift                 ← ✏️ Modifié (+ bouton)
```

### 🗄️ Base de données

```
database/
└── test_data.sql          ← 5 recettes d'exemple
```

### 📚 Documentation

```
docs/
├── README_PostgreSQL.md   ← Documentation complète
├── QUICKSTART.md          ← Guide de démarrage rapide
├── ARCHITECTURE.md        ← Architecture système
├── BACKEND_CHOICE.md      ← Node.js vs Python
├── iOS_HTTP_CONFIG.md     ← Configuration ATS
└── SUMMARY.md             ← Résumé complet
```

### 🛠️ Scripts

```
scripts/
├── setup.sh               ← Installation automatique
└── test_api.sh            ← Tests de l'API
```

## 🎯 Quick Start (5 minutes)

### Étape 1 : Base de données (1 min)

```bash
# Créer la table
psql -U postgres -d marmiton -c "
CREATE TABLE IF NOT EXISTS marmiton_recettes (
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

### Étape 2 : Backend (2 min)

**Option A : Node.js** (recommandé)

```bash
npm install
npm start
```

**Option B : Python**

```bash
pip install -r requirements.txt
python server.py
```

Vous devriez voir :
```
✅ Connecté à PostgreSQL
🚀 Serveur démarré sur http://localhost:3000
```

### Étape 3 : iOS (2 min)

1. **Ouvrez le projet dans Xcode**

2. **Configurez Info.plist** pour autoriser HTTP :

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

3. **Build & Run** (Cmd+R)

4. **Testez** :
   - Accueil → Bouton "PostgreSQL"
   - Parcourez les recettes
   - Cliquez sur ⬇ pour importer

## 🎨 Interface visuelle

```
┌─────────────────────────────────┐
│         📱 HomeView             │
├─────────────────────────────────┤
│  Bonjour Jean !                 │
│  🍃 Mangez sainement...         │
│                                 │
│  ✨ Juste pour vous             │
│  ┌─────┐ ┌─────┐ ┌─────┐      │
│  │ 🥗 │ │ 🍜 │ │ 🥙 │      │
│  └─────┘ └─────┘ └─────┘      │
│                                 │
│  📖 Nos recettes                │
│  [PostgreSQL] [Voir tout]       │ ← Nouveau bouton ici !
│  ┌─────┐ ┌─────┐ ┌─────┐      │
│  │ 🥗 │ │ 🍜 │ │ 🥙 │      │
│  └─────┘ └─────┘ └─────┘      │
└─────────────────────────────────┘

         Cliquez sur [PostgreSQL]
                    ↓

┌─────────────────────────────────┐
│  ← Recettes PostgreSQL     ⋯   │
├─────────────────────────────────┤
│  🔍 Rechercher...               │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🖼️                       ⬇│ │
│  │ Salade de Quinoa          │ │
│  │ ⏱️ 25 min                 │ │
│  │ 8 ingrédients             │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🖼️                       ⬇│ │
│  │ Poulet Rôti aux Herbes    │ │
│  │ ⏱️ 1h15                   │ │
│  │ 8 ingrédients             │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🖼️                       ⬇│ │
│  │ Gâteau au Chocolat        │ │
│  │ ⏱️ 45 min                 │ │
│  │ 6 ingrédients             │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

## 🔄 Flux de données complet

```
┌─────────────────────────────────────────────────────┐
│                     USER                            │
│              Tap "PostgreSQL"                       │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│              RecettesPostgreSQLView                 │
│              • Affiche loading spinner              │
│              • Appelle PostgreSQLService            │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│            PostgreSQLService.swift                  │
│         func fetchRecettes() async throws           │
│              • Crée URLRequest                      │
│              • HTTP GET                             │
└────────────────┬────────────────────────────────────┘
                 ↓
         HTTP GET Request
  http://localhost:3000/api/recettes
                 ↓
┌─────────────────────────────────────────────────────┐
│              server.js / server.py                  │
│         GET /api/recettes route                     │
│              • Parse query params                   │
│              • Execute SQL query                    │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│                  PostgreSQL                         │
│      SELECT * FROM marmiton_recettes                │
│      ORDER BY created_at DESC                       │
│      LIMIT 50                                       │
└────────────────┬────────────────────────────────────┘
                 ↓
         JSON Response
┌─────────────────────────────────────────────────────┐
│ [{                                                  │
│   "id": 1,                                         │
│   "titre": "Salade de Quinoa",                     │
│   "duree": "25 min",                               │
│   "ingredients": [...],                            │
│   "ustensiles": [...],                             │
│   "etapes": [...]                                  │
│ }]                                                  │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│         PostgreSQLService.swift                     │
│              • Decode JSON                          │
│              • Map to MarmitonRecette               │
│              • Return array                         │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│         RecettesPostgreSQLView                      │
│              • Hide loading                         │
│              • Display list                         │
│              • Show images                          │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│                   USER                              │
│          Sees list of recipes                       │
│          Taps download icon ⬇                      │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│         PostgreSQLService.swift                     │
│       func convertToLocalRecipe()                   │
│              • Parse ingredients                    │
│              • Calculate carbon footprint           │
│              • Detect dietary tags                  │
│              • Create Recipe object                 │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│            SwiftDataManager                         │
│         func addRecipe(recipe)                      │
│              • Insert into context                  │
│              • Save to SwiftData                    │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│                 SwiftData                           │
│           Recipe saved locally                      │
│           Available everywhere in app               │
└────────────────┬────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│                   USER                              │
│         ✅ Checkmark animation                      │
│         📳 Haptic feedback                          │
│         Recipe now in local database                │
└─────────────────────────────────────────────────────┘
```

## 🧪 Tests

### Test 1 : Connexion PostgreSQL

```bash
psql -U postgres -d marmiton -c "SELECT COUNT(*) FROM marmiton_recettes;"
```

Résultat attendu :
```
 count 
-------
     5
```

### Test 2 : API Backend

```bash
curl http://localhost:3000/api/recettes
```

Résultat attendu : JSON avec 5 recettes

### Test 3 : App iOS

1. Launch app
2. Tap "PostgreSQL"
3. Should see 5 recipes
4. Tap download icon
5. Should show checkmark ✅

## 🐛 Dépannage

### Problème : "Connection refused"

**Cause** : Backend pas démarré

**Solution** :
```bash
# Vérifier si le serveur tourne
lsof -i :3000

# Si rien, démarrer le serveur
npm start
```

### Problème : "App Transport Security blocked"

**Cause** : Info.plist pas configuré

**Solution** : Voir `iOS_HTTP_CONFIG.md`

### Problème : "relation 'marmiton_recettes' does not exist"

**Cause** : Table pas créée

**Solution** :
```bash
./setup.sh
```

### Problème : Recettes vides dans l'app

**Cause** : URL incorrecte ou serveur down

**Solution** :
1. Vérifier dans `PostgreSQLService.swift` :
   ```swift
   private let baseURL = "http://localhost:3000/api"
   ```
2. Test curl :
   ```bash
   curl http://localhost:3000/api/recettes
   ```

## 📊 Statistiques du projet

```
Langage       Fichiers    Lignes
────────────────────────────────
Swift              4      ~800
JavaScript         1      ~200
Python             1      ~250
SQL                1      ~100
Markdown           7     ~2000
Bash               2      ~150
────────────────────────────────
Total             16     ~3500
```

## 🎓 Ce que vous avez appris

✅ Communication REST API avec Swift
✅ Async/await en Swift
✅ Express.js ou Flask
✅ PostgreSQL avec JSONB
✅ SwiftData persistence
✅ Conversion de données complexes
✅ Architecture client-serveur
✅ Gestion d'états SwiftUI

## 🚀 Prochaines étapes

1. **Images** : Télécharger et cacher localement
2. **Hors-ligne** : Mode offline
3. **Pagination** : Charger par lots
4. **Filtres** : Filtres avancés
5. **Upload** : Créer des recettes
6. **Share** : Partager des recettes

## 📚 Ressources

- **Node.js** : https://nodejs.org/
- **Express** : https://expressjs.com/
- **Flask** : https://flask.palletsprojects.com/
- **PostgreSQL** : https://www.postgresql.org/
- **SwiftUI** : https://developer.apple.com/documentation/swiftui/
- **SwiftData** : https://developer.apple.com/documentation/swiftdata/

## 💬 Support

Si vous avez des questions :

1. Consultez `README_PostgreSQL.md`
2. Vérifiez `QUICKSTART.md`
3. Lisez `ARCHITECTURE.md`
4. Testez avec `test_api.sh`

## 🎉 Félicitations !

Votre app EcoDiet est maintenant connectée à PostgreSQL ! 

```
    _____ 
   /     \    Recettes PostgreSQL
  |  O O  |   ↓
  |   >   |   SwiftUI App
  |  \_/  |   ↓
   \_____/    Users happy! 🎉
```

---

**Créé avec ❤️ pour EcoDiet**

*Une app qui connecte alimentation saine et environnement durable*
