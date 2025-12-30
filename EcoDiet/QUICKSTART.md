# 🚀 Guide de Démarrage Rapide

## Étapes à suivre

### 1️⃣ Préparation de la base de données

```bash
# Se connecter à PostgreSQL
psql -U postgres

# Créer la base de données (si elle n'existe pas)
CREATE DATABASE marmiton;

# Se connecter à la base
\c marmiton

# Créer la table
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

# Insérer des données de test
\i test_data.sql

# Vérifier
SELECT COUNT(*) FROM marmiton_recettes;
```

### 2️⃣ Installation du serveur Node.js

```bash
# Installer les dépendances
npm install

# Démarrer le serveur
npm start
```

Vous devriez voir :
```
✅ Connecté à PostgreSQL
🚀 Serveur démarré sur http://localhost:3000
📊 API disponible sur http://localhost:3000/api/recettes
```

### 3️⃣ Test de l'API

Ouvrez un nouveau terminal et testez :

```bash
# Test de santé
curl http://localhost:3000/health

# Récupérer toutes les recettes
curl http://localhost:3000/api/recettes

# Statistiques
curl http://localhost:3000/api/stats

# Recherche
curl "http://localhost:3000/api/recettes/search?q=poulet"
```

### 4️⃣ Configuration de l'app iOS

**Si vous testez sur le simulateur :**
- Aucune modification nécessaire, `localhost` fonctionne

**Si vous testez sur un appareil physique :**

1. Trouvez l'adresse IP de votre Mac :
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. Dans Xcode, ouvrez `PostgreSQLService.swift`

3. Modifiez la ligne 29 :
   ```swift
   // Remplacez localhost par l'IP de votre Mac
   private let baseURL = "http://192.168.1.XXX:3000/api"
   ```

4. Assurez-vous que votre iPhone/iPad est sur le même réseau Wi-Fi

### 5️⃣ Utilisation dans l'app

1. **Lancez l'application iOS** dans Xcode
2. **Naviguez** vers l'onglet **Accueil**
3. **Scrollez** jusqu'à la section "Nos recettes"
4. **Cliquez** sur le bouton vert **"PostgreSQL"**
5. **Vous verrez** la liste des recettes de votre base de données
6. **Cliquez** sur l'icône de téléchargement pour importer une recette

## 📱 Capture d'écran de l'interface

```
┌─────────────────────────────┐
│  ← Recettes PostgreSQL   ⋯  │
├─────────────────────────────┤
│                             │
│  🔍 Rechercher...           │
│                             │
│  ┌────────────────────────┐ │
│  │ 🖼️  Salade de Quinoa  ⬇│ │
│  │     ⏱️  25 min         │ │
│  │     8 ingrédients      │ │
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │ 🖼️  Poulet Rôti       ⬇│ │
│  │     ⏱️  1h15          │ │
│  │     8 ingrédients      │ │
│  └────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

## 🎯 Menu actions (⋯)

- **Charger toutes** : Recharge toutes les recettes
- **Charger aléatoires** : Récupère un échantillon aléatoire
- **Synchroniser tout** : Importe TOUTES les recettes en une fois

## ⚙️ Configuration avancée

### Modifier le nombre de recettes affichées

Dans `server.js`, ligne 29 :
```javascript
const { limit = 50, offset = 0 } = req.query;
```

### Changer le port du serveur

Dans `.env` :
```
PORT=8080
```

Puis dans `PostgreSQLService.swift` :
```swift
private let baseURL = "http://localhost:8080/api"
```

### Ajouter un timeout

Dans `PostgreSQLService.swift`, ajoutez après `URLSession.shared.data(from: url)` :

```swift
var request = URLRequest(url: url)
request.timeoutInterval = 30 // 30 secondes

let (data, response) = try await URLSession.shared.data(for: request)
```

## 🔍 Débogage

### Le serveur ne démarre pas

```bash
# Vérifier que PostgreSQL est lancé
pg_ctl status

# Tester la connexion
psql -U postgres -d marmiton -c "SELECT 1"

# Vérifier les logs
tail -f /var/log/postgresql/postgresql-*.log
```

### L'app iOS ne se connecte pas

1. Vérifiez que le serveur est bien démarré
2. Testez l'URL dans Safari sur votre Mac
3. Si c'est un appareil physique, vérifiez l'adresse IP
4. Désactivez temporairement le firewall pour tester

### Les recettes ne s'importent pas

1. Vérifiez les logs dans la console Xcode
2. Assurez-vous que `SwiftDataManager` est bien configuré
3. Vérifiez que le modèle `Recipe` a bien les nouveaux champs

## 📊 Structure des données

### Format JSONB dans PostgreSQL

**Ingrédients :**
```json
[
  {
    "nom": "Tomate",
    "quantite": "500",
    "unite": "g"
  }
]
```

**Ustensiles :**
```json
["Four", "Casserole", "Couteau"]
```

**Étapes :**
```json
[
  "Préchauffer le four à 180°C",
  "Couper les tomates",
  "Enfourner 30 minutes"
]
```

## 🚨 Problèmes courants

| Problème | Solution |
|----------|----------|
| `ECONNREFUSED` | PostgreSQL n'est pas démarré |
| `404 Not Found` | Vérifiez l'URL de l'API |
| `CORS error` | Le serveur Node.js n'est pas lancé |
| `Timeout` | Augmentez le `timeoutInterval` |
| `Duplicate key` | Recette déjà importée (vérifiez les IDs) |

## 💡 Astuces

1. **Mode développement** : Utilisez `npm run dev` pour le rechargement auto
2. **Logs détaillés** : Ajoutez `console.log()` dans `server.js`
3. **Cache** : Implémentez un cache côté client pour les performances
4. **Images** : Téléchargez les images en arrière-plan avec `URLSession.shared.download`

## 📚 Prochaines étapes

- [ ] Ajouter l'authentification JWT
- [ ] Implémenter la pagination
- [ ] Créer des filtres avancés
- [ ] Ajouter la synchronisation en arrière-plan
- [ ] Implémenter un cache local
- [ ] Supporter le mode hors-ligne

---

**Besoin d'aide ?** Consultez le `README_PostgreSQL.md` pour plus de détails !
