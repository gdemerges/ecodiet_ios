# 🏗️ Architecture EcoDiet + PostgreSQL

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App (Swift)                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              HomeView.swift                         │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │   "PostgreSQL" Button                       │   │   │
│  │  │   ↓                                         │   │   │
│  │  │   RecettesPostgreSQLView                   │   │   │
│  │  │   ↓                                         │   │   │
│  │  │   PostgreSQLService                        │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ HTTP/REST API
┌─────────────────────────────────────────────────────────────┐
│              Node.js Backend (server.js)                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Express Server (Port 3000)                        │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  Routes                                      │  │   │
│  │  │  • GET /api/recettes                        │  │   │
│  │  │  • GET /api/recettes/:id                    │  │   │
│  │  │  • GET /api/recettes/search?q=...           │  │   │
│  │  │  • GET /api/recettes/random                 │  │   │
│  │  │  • GET /api/stats                           │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ SQL Queries
┌─────────────────────────────────────────────────────────────┐
│                     PostgreSQL Database                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Database: marmiton                                │   │
│  │  ┌──────────────────────────────────────────────┐  │   │
│  │  │  Table: marmiton_recettes                   │  │   │
│  │  │  • id (SERIAL PRIMARY KEY)                  │  │   │
│  │  │  • url (TEXT UNIQUE)                        │  │   │
│  │  │  • titre (TEXT)                             │  │   │
│  │  │  • photo (TEXT)                             │  │   │
│  │  │  • duree (TEXT)                             │  │   │
│  │  │  • ingredients (JSONB)                      │  │   │
│  │  │  • ustensiles (JSONB)                       │  │   │
│  │  │  • etapes (JSONB)                           │  │   │
│  │  │  • created_at (TIMESTAMP)                   │  │   │
│  │  │  • updated_at (TIMESTAMP)                   │  │   │
│  │  └──────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Flux de données

### 1. Récupération des recettes

```
User Action
    ↓
HomeView: Tap "PostgreSQL" button
    ↓
RecettesPostgreSQLView: onAppear
    ↓
PostgreSQLService.fetchRecettes()
    ↓
HTTP GET → http://localhost:3000/api/recettes
    ↓
Express Server: /api/recettes route
    ↓
PostgreSQL Query: SELECT * FROM marmiton_recettes
    ↓
JSON Response ← [MarmitonRecette]
    ↓
PostgreSQLService: Decode JSON
    ↓
RecettesPostgreSQLView: Display list
    ↓
User sees recipes
```

### 2. Import d'une recette

```
User Action: Tap download icon
    ↓
PostgreSQLRecetteCard.onImport()
    ↓
PostgreSQLService.convertToLocalRecipe()
    ↓
┌─────────────────────────────────────┐
│  Conversion des données            │
│  • Parse ingredients (JSONB → Array)│
│  • Parse duree (String → Int)      │
│  • Calculate carbon footprint      │
│  • Detect dietary tags             │
│  • Detect allergens                │
└─────────────────────────────────────┘
    ↓
Recipe (SwiftData model)
    ↓
SwiftDataManager.addRecipe()
    ↓
ModelContext.insert()
    ↓
SwiftData persistence
    ↓
Recipe saved locally
    ↓
User feedback (checkmark + haptic)
```

### 3. Synchronisation complète

```
User Action: Tap "Synchroniser tout"
    ↓
Confirmation Alert
    ↓
PostgreSQLService.syncRecipesToSwiftData()
    ↓
┌─────────────────────────────────────┐
│  For each MarmitonRecette:         │
│    1. Convert to Recipe            │
│    2. Add to SwiftDataManager      │
│    3. Save to ModelContext         │
└─────────────────────────────────────┘
    ↓
All recipes imported
    ↓
Success feedback
```

## Modèles de données

### PostgreSQL → Swift

```swift
// PostgreSQL JSONB
{
  "nom": "Tomate",
  "quantite": "500",
  "unite": "g"
}

// Swift Codable
struct MarmitonIngredient: Codable {
    let nom: String
    let quantite: String?
    let unite: String?
}

// SwiftData Model
struct RecipeIngredient {
    let name: String
    let quantity: Double
    let unit: String
    let isOptional: Bool
}
```

## Composants clés

### 1. PostgreSQLService.swift

Responsabilités :
- ✅ Communication HTTP avec l'API
- ✅ Décodage JSON
- ✅ Conversion MarmitonRecette → Recipe
- ✅ Logique métier (parsing, calculs)
- ✅ Détection automatique des tags

### 2. server.js

Responsabilités :
- ✅ Routes API REST
- ✅ Connexion PostgreSQL
- ✅ Gestion des requêtes SQL
- ✅ Gestion des erreurs
- ✅ CORS

### 3. RecettesPostgreSQLView.swift

Responsabilités :
- ✅ Interface utilisateur
- ✅ Recherche locale
- ✅ Affichage des recettes
- ✅ Gestion des états (loading, error)
- ✅ Actions utilisateur

### 4. Models.swift

Responsabilités :
- ✅ Définition du modèle Recipe
- ✅ Ajout des champs (ustensiles, etapes, sourceURL)
- ✅ SwiftData @Model
- ✅ Computed properties

## Sécurité

### Actuellement (Développement)

```
iOS App → HTTP → localhost:3000 → PostgreSQL
```

⚠️ Pas de chiffrement
⚠️ Pas d'authentification
⚠️ CORS ouvert

### Recommandations (Production)

```
iOS App → HTTPS → API Gateway → Backend (Auth) → PostgreSQL
         JWT      SSL/TLS        JWT Verify      Encrypted
```

✅ Chiffrement end-to-end
✅ Authentification JWT
✅ CORS restreint
✅ Rate limiting
✅ Validation des entrées
✅ Logs d'audit

## Performance

### Optimisations actuelles

- ✅ Pagination côté serveur (limit/offset)
- ✅ Recherche ILIKE avec index recommandé
- ✅ Connection pooling PostgreSQL

### Optimisations futures

- [ ] Cache Redis pour requêtes fréquentes
- [ ] CDN pour images
- [ ] Lazy loading des images iOS
- [ ] Background sync
- [ ] Compression gzip
- [ ] Database indexing

## Scalabilité

### Base de données

```sql
-- Index pour améliorer les performances
CREATE INDEX idx_titre ON marmiton_recettes(titre);
CREATE INDEX idx_ingredients_gin ON marmiton_recettes USING gin(ingredients);
CREATE INDEX idx_created_at ON marmiton_recettes(created_at DESC);
```

### Serveur

```javascript
// Clustering Node.js
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
} else {
  // Worker process
  app.listen(port);
}
```

### Client iOS

```swift
// Pagination
func fetchRecettesPage(_ page: Int) async throws {
    let limit = 20
    let offset = page * limit
    // ...
}

// Cache local
actor RecipeCache {
    private var cache: [Int: MarmitonRecette] = [:]
    // ...
}
```

## Monitoring

### Logs serveur

```javascript
// Morgan middleware pour logs HTTP
const morgan = require('morgan');
app.use(morgan('combined'));
```

### Métriques

- Nombre de requêtes par endpoint
- Temps de réponse moyen
- Taux d'erreur
- Connexions actives PostgreSQL
- Utilisation mémoire

### Alertes

- Serveur down
- Temps de réponse > 2s
- Erreur rate > 5%
- Connection pool saturé

## Tests

### Backend

```javascript
// Jest
describe('GET /api/recettes', () => {
  it('should return all recipes', async () => {
    const res = await request(app).get('/api/recettes');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
```

### iOS

```swift
@Test("Conversion de recette PostgreSQL")
func testConvertToLocalRecipe() async throws {
    let marmitonRecette = MarmitonRecette(/* ... */)
    let recipe = service.convertToLocalRecipe(marmitonRecette)
    
    #expect(recipe.title == "Test Recipe")
    #expect(recipe.requiredIngredients.count > 0)
}
```

## Déploiement

### Backend (Heroku exemple)

```bash
# Créer app
heroku create ecodiet-api

# Ajouter PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Déployer
git push heroku main

# Migrer DB
heroku run psql -f schema.sql
```

### iOS (App Store)

1. Modifier `baseURL` en production
2. Build pour release
3. Archive
4. Upload via Xcode

---

**Note** : Cette architecture est modulaire et peut être étendue avec des microservices, caching, CDN, etc.
