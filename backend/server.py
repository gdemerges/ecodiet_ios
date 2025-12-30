# API Flask alternative pour PostgreSQL
# Installation : pip install flask psycopg2-binary python-dotenv flask-cors

from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import psycopg2.extras
import os
from dotenv import load_dotenv
from datetime import datetime

# Charger les variables d'environnement
load_dotenv()

app = Flask(__name__)
CORS(app)  # Activer CORS

# Configuration PostgreSQL
DB_CONFIG = {
    'host': os.getenv('PGHOST', 'localhost'),
    'port': os.getenv('PGPORT', 5432),
    'user': os.getenv('PGUSER', 'postgres'),
    'password': os.getenv('PGPASSWORD', 'postgres'),
    'database': os.getenv('PGDATABASE', 'marmiton')
}

def get_db_connection():
    """Crée une connexion à PostgreSQL"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"❌ Erreur de connexion PostgreSQL: {e}")
        return None

def dict_factory(cursor, row):
    """Convertit les résultats en dictionnaire"""
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col.name] = row[idx]
    return d

# ROUTES

@app.route('/health', methods=['GET'])
def health_check():
    """Vérifier l'état du serveur"""
    return jsonify({
        'status': 'OK',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Statistiques de la base de données"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT COUNT(*) FROM marmiton_recettes')
        total = cursor.fetchone()[0]
        
        return jsonify({
            'totalRecettes': total,
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/recettes', methods=['GET'])
def get_recettes():
    """Récupérer toutes les recettes avec pagination"""
    limit = request.args.get('limit', default=50, type=int)
    offset = request.args.get('offset', default=0, type=int)
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute(
            'SELECT * FROM marmiton_recettes ORDER BY created_at DESC LIMIT %s OFFSET %s',
            (limit, offset)
        )
        recettes = cursor.fetchall()
        
        # Convertir les dates en ISO format
        for recette in recettes:
            if recette.get('created_at'):
                recette['created_at'] = recette['created_at'].isoformat()
            if recette.get('updated_at'):
                recette['updated_at'] = recette['updated_at'].isoformat()
        
        return jsonify(recettes)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/recettes/<int:recette_id>', methods=['GET'])
def get_recette(recette_id):
    """Récupérer une recette par ID"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute('SELECT * FROM marmiton_recettes WHERE id = %s', (recette_id,))
        recette = cursor.fetchone()
        
        if not recette:
            return jsonify({'error': 'Recette non trouvée'}), 404
        
        # Convertir les dates
        if recette.get('created_at'):
            recette['created_at'] = recette['created_at'].isoformat()
        if recette.get('updated_at'):
            recette['updated_at'] = recette['updated_at'].isoformat()
        
        return jsonify(recette)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/recettes/search', methods=['GET'])
def search_recettes():
    """Rechercher des recettes"""
    query = request.args.get('q')
    limit = request.args.get('limit', default=20, type=int)
    
    if not query:
        return jsonify({'error': 'Paramètre de recherche manquant'}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        search_pattern = f'%{query}%'
        
        cursor.execute('''
            SELECT * FROM marmiton_recettes 
            WHERE titre ILIKE %s 
            OR ingredients::text ILIKE %s
            ORDER BY created_at DESC
            LIMIT %s
        ''', (search_pattern, search_pattern, limit))
        
        recettes = cursor.fetchall()
        
        # Convertir les dates
        for recette in recettes:
            if recette.get('created_at'):
                recette['created_at'] = recette['created_at'].isoformat()
            if recette.get('updated_at'):
                recette['updated_at'] = recette['updated_at'].isoformat()
        
        return jsonify(recettes)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/recettes/random', methods=['GET'])
def get_random_recettes():
    """Récupérer des recettes aléatoires"""
    count = request.args.get('count', default=10, type=int)
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute('SELECT * FROM marmiton_recettes ORDER BY RANDOM() LIMIT %s', (count,))
        recettes = cursor.fetchall()
        
        # Convertir les dates
        for recette in recettes:
            if recette.get('created_at'):
                recette['created_at'] = recette['created_at'].isoformat()
            if recette.get('updated_at'):
                recette['updated_at'] = recette['updated_at'].isoformat()
        
        return jsonify(recettes)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# Gestion des erreurs
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Route non trouvée'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Erreur serveur interne'}), 500

if __name__ == '__main__':
    # Tester la connexion au démarrage
    conn = get_db_connection()
    if conn:
        print("✅ Connecté à PostgreSQL")
        conn.close()
        
        port = int(os.getenv('PORT', 3000))
        print(f"🚀 Serveur démarré sur http://localhost:{port}")
        print(f"📊 API disponible sur http://localhost:{port}/api/recettes")
        
        app.run(host='0.0.0.0', port=port, debug=True)
    else:
        print("❌ Impossible de démarrer le serveur : connexion PostgreSQL échouée")
