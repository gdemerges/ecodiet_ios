#!/bin/bash

# 🧪 Script de test de l'API EcoDiet

BASE_URL="http://localhost:3000"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🧪 Tests de l'API EcoDiet"
echo "========================"
echo ""

# Test 1: Health check
echo -e "${BLUE}Test 1:${NC} Health Check"
echo "GET $BASE_URL/health"
curl -s "$BASE_URL/health" | python3 -m json.tool
echo ""
echo ""

# Test 2: Statistiques
echo -e "${BLUE}Test 2:${NC} Statistiques"
echo "GET $BASE_URL/api/stats"
curl -s "$BASE_URL/api/stats" | python3 -m json.tool
echo ""
echo ""

# Test 3: Liste des recettes (limitée à 3)
echo -e "${BLUE}Test 3:${NC} Liste des recettes (limit=3)"
echo "GET $BASE_URL/api/recettes?limit=3"
curl -s "$BASE_URL/api/recettes?limit=3" | python3 -m json.tool
echo ""
echo ""

# Test 4: Une recette spécifique
echo -e "${BLUE}Test 4:${NC} Récupérer la recette #1"
echo "GET $BASE_URL/api/recettes/1"
curl -s "$BASE_URL/api/recettes/1" | python3 -m json.tool
echo ""
echo ""

# Test 5: Recherche
echo -e "${BLUE}Test 5:${NC} Recherche 'poulet'"
echo "GET $BASE_URL/api/recettes/search?q=poulet"
curl -s "$BASE_URL/api/recettes/search?q=poulet" | python3 -m json.tool
echo ""
echo ""

# Test 6: Recettes aléatoires
echo -e "${BLUE}Test 6:${NC} 2 recettes aléatoires"
echo "GET $BASE_URL/api/recettes/random?count=2"
curl -s "$BASE_URL/api/recettes/random?count=2" | python3 -m json.tool
echo ""
echo ""

# Test 7: Pagination
echo -e "${BLUE}Test 7:${NC} Pagination (page 2, limit=2)"
echo "GET $BASE_URL/api/recettes?limit=2&offset=2"
curl -s "$BASE_URL/api/recettes?limit=2&offset=2" | python3 -m json.tool
echo ""
echo ""

# Résumé
echo "========================"
echo -e "${GREEN}✓${NC} Tests terminés"
echo ""
echo "Pour tester dans l'app iOS :"
echo "1. Lancez l'application"
echo "2. Allez sur l'onglet Accueil"
echo "3. Cliquez sur 'PostgreSQL'"
echo ""
