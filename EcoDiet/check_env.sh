#!/bin/bash

# 🔍 Script de vérification pré-démarrage

echo "🔍 EcoDiet - Vérification de l'environnement"
echo "==========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SUCCESS=0
WARNINGS=0
ERRORS=0

# Fonction de vérification
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((SUCCESS++))
    else
        echo -e "${RED}✗${NC} $1"
        ((ERRORS++))
    fi
}

check_warning() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((SUCCESS++))
    else
        echo -e "${YELLOW}⚠${NC} $2"
        ((WARNINGS++))
    fi
}

# 1. Vérifier PostgreSQL
echo "📊 PostgreSQL"
echo "─────────────"
if command -v psql &> /dev/null; then
    check "PostgreSQL installé"
    
    if psql -U postgres -d marmiton -c "SELECT 1" &> /dev/null 2>&1; then
        check "Connexion à la base 'marmiton' OK"
        
        COUNT=$(psql -U postgres -d marmiton -t -c "SELECT COUNT(*) FROM marmiton_recettes" 2>/dev/null | tr -d ' ')
        if [ ! -z "$COUNT" ]; then
            echo -e "${BLUE}ℹ${NC} $COUNT recette(s) dans la base"
            check "Table 'marmiton_recettes' existe"
        else
            echo -e "${YELLOW}⚠${NC} Table 'marmiton_recettes' n'existe pas"
            echo "  → Exécutez: ./setup.sh"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}✗${NC} Impossible de se connecter à la base 'marmiton'"
        echo "  → Créez la base: createdb -U postgres marmiton"
        ((ERRORS++))
    fi
else
    echo -e "${RED}✗${NC} PostgreSQL n'est pas installé"
    echo "  → Installez PostgreSQL: https://www.postgresql.org/download/"
    ((ERRORS++))
fi
echo ""

# 2. Vérifier Node.js
echo "📦 Node.js (Option 1)"
echo "─────────────────────"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    check "Node.js installé ($NODE_VERSION)"
    
    if [ -f "package.json" ]; then
        check "package.json trouvé"
        
        if [ -d "node_modules" ]; then
            check "Dependencies installées"
        else
            echo -e "${YELLOW}⚠${NC} Dependencies non installées"
            echo "  → Exécutez: npm install"
            ((WARNINGS++))
        fi
    else
        echo -e "${YELLOW}⚠${NC} package.json non trouvé"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Node.js n'est pas installé (optionnel si vous utilisez Python)"
    ((WARNINGS++))
fi
echo ""

# 3. Vérifier Python
echo "🐍 Python (Option 2)"
echo "────────────────────"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    check "Python installé ($PYTHON_VERSION)"
    
    if [ -f "requirements.txt" ]; then
        check "requirements.txt trouvé"
        
        if python3 -c "import flask" &> /dev/null; then
            check "Flask installé"
        else
            echo -e "${YELLOW}⚠${NC} Flask non installé"
            echo "  → Exécutez: pip install -r requirements.txt"
            ((WARNINGS++))
        fi
    else
        echo -e "${YELLOW}⚠${NC} requirements.txt non trouvé"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} Python n'est pas installé (optionnel si vous utilisez Node.js)"
    ((WARNINGS++))
fi
echo ""

# 4. Vérifier les fichiers essentiels
echo "📄 Fichiers"
echo "───────────"

FILES=(
    ".env:Configuration"
    "server.js:Serveur Node.js"
    "server.py:Serveur Python"
    "PostgreSQLService.swift:Service Swift"
    "RecettesPostgreSQLView.swift:Vue Swift"
    "test_data.sql:Données de test"
)

for file_info in "${FILES[@]}"; do
    IFS=':' read -r file desc <<< "$file_info"
    if [ -f "$file" ]; then
        check "$desc ($file)"
    else
        echo -e "${YELLOW}⚠${NC} $desc ($file) non trouvé"
        ((WARNINGS++))
    fi
done
echo ""

# 5. Vérifier Xcode (iOS)
echo "📱 iOS"
echo "──────"
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -n 1)
    check "Xcode installé ($XCODE_VERSION)"
else
    echo -e "${YELLOW}⚠${NC} Xcode non trouvé"
    echo "  → Installez depuis l'App Store"
    ((WARNINGS++))
fi
echo ""

# 6. Vérifier le serveur (si en cours d'exécution)
echo "🌐 Serveur"
echo "──────────"
if lsof -i :3000 &> /dev/null; then
    echo -e "${GREEN}✓${NC} Serveur en cours d'exécution sur le port 3000"
    ((SUCCESS++))
    
    # Test de l'API
    if curl -s http://localhost:3000/health &> /dev/null; then
        check "Health check OK"
        
        STATS=$(curl -s http://localhost:3000/api/stats 2>/dev/null)
        if [ ! -z "$STATS" ]; then
            check "API fonctionnelle"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Le serveur ne répond pas"
        ((WARNINGS++))
    fi
else
    echo -e "${BLUE}ℹ${NC} Aucun serveur détecté sur le port 3000 (normal s'il n'est pas démarré)"
fi
echo ""

# Résumé
echo "==========================================="
echo "📊 Résumé"
echo "───────────"
echo -e "${GREEN}✓${NC} Succès:      $SUCCESS"
echo -e "${YELLOW}⚠${NC} Avertissements: $WARNINGS"
echo -e "${RED}✗${NC} Erreurs:     $ERRORS"
echo ""

# Conclusion
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Tout est prêt ! Vous pouvez démarrer.${NC}"
    echo ""
    echo "Prochaines étapes :"
    echo "1. Démarrer le serveur : npm start (ou python server.py)"
    echo "2. Lancer l'app iOS dans Xcode"
    echo "3. Tester l'import de recettes"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Presque prêt ! Quelques avertissements à vérifier.${NC}"
    echo ""
    echo "Actions recommandées :"
    if ! command -v node &> /dev/null && ! command -v python3 &> /dev/null; then
        echo "• Installez Node.js OU Python"
    fi
    if [ ! -d "node_modules" ] && command -v node &> /dev/null; then
        echo "• Exécutez: npm install"
    fi
    if ! python3 -c "import flask" &> /dev/null 2>&1 && command -v python3 &> /dev/null; then
        echo "• Exécutez: pip install -r requirements.txt"
    fi
else
    echo -e "${RED}❌ Des erreurs doivent être corrigées avant de continuer.${NC}"
    echo ""
    echo "Actions requises :"
    if ! command -v psql &> /dev/null; then
        echo "• Installez PostgreSQL"
    fi
    if ! psql -U postgres -d marmiton -c "SELECT 1" &> /dev/null 2>&1; then
        echo "• Créez la base 'marmiton': createdb -U postgres marmiton"
    fi
fi

echo ""
echo "📚 Documentation :"
echo "• Guide complet:   COMPLETE_GUIDE.md"
echo "• Quick start:     QUICKSTART.md"
echo "• Architecture:    ARCHITECTURE.md"
echo ""

exit $ERRORS
