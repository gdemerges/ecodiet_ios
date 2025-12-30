#!/bin/bash

# Script pour rendre tous les scripts shell exécutables

echo "🔧 Configuration des permissions..."
echo ""

chmod +x setup.sh
echo "✅ setup.sh"

chmod +x check_env.sh
echo "✅ check_env.sh"

chmod +x test_api.sh
echo "✅ test_api.sh"

chmod +x CHEATSHEET.sh
echo "✅ CHEATSHEET.sh"

echo ""
echo "🎉 Tous les scripts sont maintenant exécutables !"
echo ""
echo "Vous pouvez maintenant exécuter :"
echo "  ./check_env.sh   - Vérifier l'environnement"
echo "  ./setup.sh       - Installation automatique"
echo "  ./test_api.sh    - Tester l'API"
echo "  ./CHEATSHEET.sh  - Voir toutes les commandes"
echo ""
