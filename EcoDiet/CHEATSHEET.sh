#!/bin/bash

# 📝 Commandes pratiques pour EcoDiet PostgreSQL
# Copiez-collez ces commandes dans votre terminal

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║         🍽️  EcoDiet - Commandes pratiques                ║
╚════════════════════════════════════════════════════════════╝

📋 COMMANDES RAPIDES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 VÉRIFICATION
──────────────────────────────────────────────────────────

# Vérifier l'environnement complet
./check_env.sh

# Vérifier PostgreSQL
psql -U postgres -d marmiton -c "SELECT COUNT(*) FROM marmiton_recettes;"

# Vérifier Node.js
node -v && npm -v

# Vérifier Python
python3 --version && pip3 --version

# Vérifier si le serveur tourne
lsof -i :3000


🚀 INSTALLATION
──────────────────────────────────────────────────────────

# Rendre les scripts exécutables
chmod +x setup.sh check_env.sh test_api.sh

# Installation automatique
./setup.sh

# Installation manuelle Node.js
npm install

# Installation manuelle Python
pip install -r requirements.txt


🗄️  BASE DE DONNÉES
──────────────────────────────────────────────────────────

# Créer la base de données
createdb -U postgres marmiton

# Se connecter à PostgreSQL
psql -U postgres -d marmiton

# Créer la table (dans psql)
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

# Insérer les données de test
psql -U postgres -d marmiton -f test_data.sql

# Voir toutes les recettes
psql -U postgres -d marmiton -c "SELECT id, titre, duree FROM marmiton_recettes;"

# Compter les recettes
psql -U postgres -d marmiton -c "SELECT COUNT(*) FROM marmiton_recettes;"

# Supprimer toutes les recettes (⚠️ ATTENTION)
psql -U postgres -d marmiton -c "TRUNCATE marmiton_recettes RESTART IDENTITY;"


🖥️  SERVEUR
──────────────────────────────────────────────────────────

# Démarrer Node.js
npm start

# Démarrer Node.js en mode dev (avec rechargement auto)
npm run dev

# Démarrer Python
python3 server.py

# Arrêter le serveur (Ctrl+C dans le terminal)

# Trouver et tuer le processus sur le port 3000
lsof -ti:3000 | xargs kill -9


🧪 TESTS API
──────────────────────────────────────────────────────────

# Lancer tous les tests
./test_api.sh

# Health check
curl http://localhost:3000/health

# Statistiques
curl http://localhost:3000/api/stats

# Toutes les recettes (formaté avec jq)
curl http://localhost:3000/api/recettes | jq

# 5 premières recettes
curl "http://localhost:3000/api/recettes?limit=5" | jq

# Recette par ID
curl http://localhost:3000/api/recettes/1 | jq

# Recherche
curl "http://localhost:3000/api/recettes/search?q=poulet" | jq

# Recettes aléatoires
curl "http://localhost:3000/api/recettes/random?count=3" | jq

# Test de performance (si wrk installé)
wrk -t4 -c100 -d10s http://localhost:3000/api/recettes


📱 iOS
──────────────────────────────────────────────────────────

# Ouvrir le projet dans Xcode
open EcoDiet.xcodeproj

# Build depuis le terminal (si vous avez xcodebuild)
xcodebuild -scheme EcoDiet -configuration Debug

# Voir les logs du simulateur
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "EcoDiet"'


🔧 DÉVELOPPEMENT
──────────────────────────────────────────────────────────

# Surveiller les logs du serveur Node.js
npm start | tee server.log

# Surveiller les logs PostgreSQL (Mac avec Homebrew)
tail -f /usr/local/var/log/postgres.log

# Formater le code Swift (si swiftformat installé)
swiftformat .

# Linter JavaScript (si eslint installé)
npx eslint server.js

# Formater Python (si black installé)
black server.py


📊 MONITORING
──────────────────────────────────────────────────────────

# Voir les connexions PostgreSQL actives
psql -U postgres -d marmiton -c "SELECT * FROM pg_stat_activity WHERE datname = 'marmiton';"

# Taille de la base de données
psql -U postgres -d marmiton -c "SELECT pg_size_pretty(pg_database_size('marmiton'));"

# Performance des requêtes (activer dans postgresql.conf)
psql -U postgres -d marmiton -c "SELECT query, calls, total_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"


🔒 SÉCURITÉ (Production)
──────────────────────────────────────────────────────────

# Générer un secret pour JWT
openssl rand -base64 32

# Tester HTTPS (si configuré)
curl https://your-domain.com/api/recettes

# Vérifier les variables d'environnement
cat .env

# Ne JAMAIS commit .env
echo ".env" >> .gitignore


🧹 NETTOYAGE
──────────────────────────────────────────────────────────

# Nettoyer node_modules
rm -rf node_modules && npm install

# Nettoyer le cache npm
npm cache clean --force

# Nettoyer Python
find . -type d -name "__pycache__" -exec rm -r {} +

# Reset PostgreSQL (⚠️ ATTENTION : supprime tout)
dropdb marmiton && createdb marmiton


📦 DÉPLOIEMENT
──────────────────────────────────────────────────────────

# Build pour production (Node.js)
NODE_ENV=production npm start

# Déployer sur Heroku
heroku create ecodiet-api
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main

# Déployer sur Vercel (Node.js)
npm install -g vercel
vercel

# Déployer sur Railway
railway login
railway init
railway up


🐛 DEBUG
──────────────────────────────────────────────────────────

# Activer les logs détaillés PostgreSQL
export PGOPTIONS='-c log_statement=all'
psql -U postgres -d marmiton

# Debug Node.js
node --inspect server.js

# Debug avec variables d'environnement
DEBUG=* npm start

# Voir les erreurs PostgreSQL
psql -U postgres -d marmiton -c "SELECT * FROM pg_stat_activity WHERE state = 'idle in transaction';"


📚 DOCUMENTATION
──────────────────────────────────────────────────────────

# Ouvrir le README principal
cat README.md

# Ouvrir le guide complet
cat COMPLETE_GUIDE.md

# Voir tous les fichiers disponibles
ls -la *.md


🎓 AIDE
──────────────────────────────────────────────────────────

# PostgreSQL
psql --help

# Node.js
npm --help

# Python
python3 --help

# Curl
curl --help

# Git
git --help


╔════════════════════════════════════════════════════════════╗
║  💡 ASTUCE : Créez des alias pour les commandes fréquentes ║
╚════════════════════════════════════════════════════════════╝

# Ajoutez dans votre ~/.bashrc ou ~/.zshrc :

alias ecodiet-start="npm start"
alias ecodiet-test="./test_api.sh"
alias ecodiet-check="./check_env.sh"
alias ecodiet-db="psql -U postgres -d marmiton"
alias ecodiet-logs="tail -f server.log"

# Puis : source ~/.bashrc

╔════════════════════════════════════════════════════════════╗
║              📞 COMMANDES PAR SCÉNARIO                     ║
╚════════════════════════════════════════════════════════════╝

🎯 PREMIER DÉMARRAGE
────────────────────────────────────────────────────────────
1. chmod +x *.sh
2. ./check_env.sh
3. ./setup.sh
4. npm start
5. Ouvrir Xcode


🔧 DÉVELOPPEMENT QUOTIDIEN
────────────────────────────────────────────────────────────
1. npm start (dans un terminal)
2. Xcode → Cmd+R
3. Tester dans l'app


🐛 RÉSOLUTION DE PROBLÈMES
────────────────────────────────────────────────────────────
1. ./check_env.sh
2. lsof -i :3000
3. curl http://localhost:3000/health
4. Consulter la doc dans INDEX.md


🧪 TESTS
────────────────────────────────────────────────────────────
1. ./test_api.sh
2. psql -U postgres -d marmiton -c "SELECT COUNT(*) FROM marmiton_recettes;"
3. Tester dans l'app iOS


📚 BESOIN D'AIDE ?
────────────────────────────────────────────────────────────
1. cat INDEX.md          (trouver le bon document)
2. cat QUICKSTART.md     (démarrage rapide)
3. cat COMPLETE_GUIDE.md (guide complet)

EOF

echo ""
echo -e "${GREEN}✅ Commandes copiées !${NC}"
echo ""
echo "💡 Conseil : Ajoutez ce fichier à vos favoris !"
echo ""
