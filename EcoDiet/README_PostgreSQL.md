# Connexion PostgreSQL pour EcoDiet

Ce guide explique comment connecter votre application iOS EcoDiet à votre base de données PostgreSQL Marmiton.

## 🏗️ Architecture

```
iOS App (SwiftUI) ←→ Node.js API ←→ PostgreSQL
```

Comme iOS ne peut pas se connecter directement à PostgreSQL, nous utilisons un backend Node.js comme intermédiaire.

## 📋 Prérequis

- Node.js installé (version 16 ou supérieure)
- PostgreSQL en cours d'exécution avec la base de données `marmiton`
- Xcode pour l'application iOS

## 🚀 Installation

### 1. Configuration du Backend

Dans le dossier du projet, installez les dépendances Node.js :

```bash
npm install
```

### 2. Configuration de l'environnement

Le fichier `.env` contient déjà vos identifiants :

```
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
PGPASSWORD=postgres
PGDATABASE=marmiton
PORT=3000
```

### 3. Démarrage du serveur

```bash
npm start
```

Ou pour le mode développement avec rechargement automatique :

```bash
npm run dev
```

Le serveur démarre sur `http://localhost:3000`

## 🧪 Test de l'API

### Vérifier que le serveur fonctionne

```bash
curl http://localhost:3000/health
```

### Récupérer toutes les recettes

```bash
curl http://localhost:3000/api/recettes
```

### Récupérer une recette spécifique

```bash
curl http://localhost:3000/api/recettes/1
```

### Rechercher des recettes

```bash
curl "http://localhost:3000/api/recettes/search?q=poulet"
```

### Statistiques

```bash
curl http://localhost:3000/api/stats
```

## 📱 Utilisation dans l'application iOS

### 1. Dans l'interface

1. Lancez l'application iOS
2. Allez sur l'onglet **Accueil**
3. Dans la section "Nos recettes", cliquez sur le bouton **PostgreSQL**
4. Vous verrez la liste des recettes de votre base de données
5. Cliquez sur le bouton de téléchargement pour importer une recette

### 2. Synchronisation complète

Pour importer toutes les recettes d'un coup :

1. Sur l'écran des recettes PostgreSQL
2. Cliquez sur les 3 points en haut à droite
3. Sélectionnez **Synchroniser tout**
4. Confirmez l'action

## 🔧 Configuration avancée

### Modifier l'URL de l'API

Dans `PostgreSQLService.swift`, ligne 29 :

```swift
private let baseURL = "http://localhost:3000/api"
```

Pour tester sur un appareil iOS physique, remplacez `localhost` par l'adresse IP de votre Mac :

```swift
private let baseURL = "http://192.168.1.XXX:3000/api"
```

### Pagination

Par défaut, l'API retourne 50 recettes. Pour en récupérer plus :

```bash
curl "http://localhost:3000/api/recettes?limit=100&offset=0"
```

## 📊 Structure de la base de données

```sql
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
);
```

### Format des ingrédients JSONB

```json
[
  {
    "nom": "Poulet",
    "quantite": "500",
    "unite": "g"
  },
  {
    "nom": "Riz",
    "quantite": "200",
    "unite": "g"
  }
]
```

## 🔄 Conversion des données

Le service `PostgreSQLService.swift` effectue automatiquement :

- ✅ Conversion des recettes PostgreSQL → SwiftData
- ✅ Parsing des temps de préparation (ex: "45 min", "1h30")
- ✅ Estimation de l'empreinte carbone
- ✅ Détection automatique des tags diététiques (Vegan, Végétarien, Sans gluten)
- ✅ Détection des allergènes
- ✅ Calcul de l'Eco-Score

## 🐛 Dépannage

### Le serveur ne démarre pas

Vérifiez que PostgreSQL est bien lancé :

```bash
psql -U postgres -d marmiton -c "SELECT COUNT(*) FROM marmiton_recettes;"
```

### L'app iOS ne peut pas se connecter

1. Vérifiez que le serveur Node.js est bien démarré
2. Si vous testez sur un appareil physique, utilisez l'IP de votre Mac au lieu de `localhost`
3. Assurez-vous que le firewall autorise les connexions sur le port 3000

### Erreur CORS

Le serveur est configuré pour accepter toutes les origines. Si vous avez des problèmes, vérifiez le middleware CORS dans `server.js`.

## 🔐 Sécurité (Production)

Pour un déploiement en production :

1. **Ne commitez jamais le fichier `.env`** (ajoutez-le à `.gitignore`)
2. Utilisez des variables d'environnement sécurisées
3. Ajoutez une authentification JWT
4. Configurez CORS pour autoriser uniquement votre domaine
5. Utilisez HTTPS
6. Ajoutez un rate limiting

## 📚 API Endpoints

| Méthode | Endpoint | Description | Paramètres |
|---------|----------|-------------|------------|
| GET | `/health` | Vérifier l'état du serveur | - |
| GET | `/api/stats` | Statistiques de la base | - |
| GET | `/api/recettes` | Liste des recettes | `limit`, `offset` |
| GET | `/api/recettes/:id` | Une recette par ID | - |
| GET | `/api/recettes/search` | Rechercher des recettes | `q`, `limit` |
| GET | `/api/recettes/random` | Recettes aléatoires | `count` |

## 💡 Améliorations futures

- [ ] Ajouter un cache côté serveur (Redis)
- [ ] Implémenter la pagination dans l'app iOS
- [ ] Ajouter des filtres (temps de préparation, type de cuisine, etc.)
- [ ] Synchronisation en arrière-plan
- [ ] Mode hors-ligne avec mise en cache locale
- [ ] Upload de nouvelles recettes depuis l'app

## 📞 Support

Pour toute question, consultez la documentation de :
- [Node.js](https://nodejs.org/)
- [Express](https://expressjs.com/)
- [node-postgres](https://node-postgres.com/)
- [SwiftUI](https://developer.apple.com/documentation/swiftui/)

---

Créé avec ❤️ pour EcoDiet
