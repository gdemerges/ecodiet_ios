#!/bin/bash

# 🚀 Script de démarrage rapide pour EcoDiet + PostgreSQL

echo "🍽️  EcoDiet - Configuration PostgreSQL"
echo "======================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Vérifier PostgreSQL
echo "📊 Étape 1/4 : Vérification de PostgreSQL..."
if command -v psql &> /dev/null; then
    echo -e "${GREEN}✓${NC} PostgreSQL est installé"
    
    # Vérifier la connexion
    if psql -U postgres -d marmiton -c "SELECT 1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} Connexion à la base de données réussie"
    else
        echo -e "${RED}✗${NC} Impossible de se connecter à la base 'marmiton'"
        echo "Créez la base avec : createdb -U postgres marmiton"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} PostgreSQL n'est pas installé"
    exit 1
fi

echo ""

# 2. Créer la table si nécessaire
echo "🗄️  Étape 2/4 : Vérification de la table..."
TABLE_EXISTS=$(psql -U postgres -d marmiton -t -c "SELECT to_regclass('marmiton_recettes');")

if [[ $TABLE_EXISTS == *"marmiton_recettes"* ]]; then
    echo -e "${GREEN}✓${NC} Table 'marmiton_recettes' existe"
else
    echo "Création de la table..."
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
    echo -e "${GREEN}✓${NC} Table créée avec succès"
fi

echo ""

# 3. Insérer des données de test
echo "📝 Étape 3/4 : Insertion de données de test..."
COUNT=$(psql -U postgres -d marmiton -t -c "SELECT COUNT(*) FROM marmiton_recettes;")

if [ "$COUNT" -eq 0 ]; then
    echo "Insertion de 5 recettes d'exemple..."
    psql -U postgres -d marmiton -f test_data.sql > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} Données de test insérées"
else
    echo -e "${BLUE}ℹ${NC} La base contient déjà $COUNT recette(s)"
fi

echo ""

# 4. Vérifier Node.js et installer les dépendances
echo "📦 Étape 4/4 : Configuration du serveur Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js est installé ($NODE_VERSION)"
    
    # Installer les dépendances
    if [ ! -d "node_modules" ]; then
        echo "Installation des dépendances..."
        npm install > /dev/null 2>&1
        echo -e "${GREEN}✓${NC} Dépendances installées"
    else
        echo -e "${GREEN}✓${NC} Dépendances déjà installées"
    fi
else
    echo -e "${RED}✗${NC} Node.js n'est pas installé"
    echo "Téléchargez-le sur https://nodejs.org/"
    exit 1
fi

echo ""
echo "======================================"
echo -e "${GREEN}✨ Configuration terminée !${NC}"
echo ""
echo "Pour démarrer le serveur :"
echo "  npm start"
echo ""
echo "Le serveur sera disponible sur :"
echo "  http://localhost:3000"
echo ""
echo "Testez l'API avec :"
echo "  curl http://localhost:3000/api/recettes"
echo ""
echo "📱 Dans l'app iOS :"
echo "  1. Allez sur l'onglet Accueil"
echo "  2. Cliquez sur le bouton 'PostgreSQL'"
echo "  3. Importez vos recettes"
echo ""
