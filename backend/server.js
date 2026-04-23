// Backend Node.js/Express pour se connecter à PostgreSQL
// Installez les dépendances : npm install express pg cors dotenv

const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const compression = require('compression');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Configuration PostgreSQL
const pool = new Pool({
  host: process.env.PGHOST || 'localhost',
  port: process.env.PGPORT || 5432,
  user: process.env.PGUSER || 'postgres',
  password: process.env.PGPASSWORD || 'postgres',
  database: process.env.PGDATABASE || 'marmiton'
});

// Middleware
app.use(compression());
app.use(cors());
app.use(express.json());

// Test de connexion
pool.on('connect', () => {
  console.log('✅ Connecté à PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ Erreur PostgreSQL:', err);
});

// ROUTES

// GET /api/recettes - Récupérer toutes les recettes
app.get('/api/recettes', async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;

    const result = await pool.query(
      'SELECT * FROM marmiton_recettes ORDER BY created_at DESC LIMIT $1 OFFSET $2',
      [limit, offset]
    );

    res.set('Cache-Control', 'public, max-age=3600');
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des recettes:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/recettes/search - Rechercher des recettes
app.get('/api/recettes/search', async (req, res) => {
  try {
    const { q, limit = 20 } = req.query;

    if (!q) {
      return res.status(400).json({ error: 'Paramètre de recherche manquant' });
    }

    const result = await pool.query(
      `SELECT id, url, titre, photo, duree, created_at
       FROM marmiton_recettes
       WHERE titre ILIKE $1
       ORDER BY created_at DESC
       LIMIT $2`,
      [`%${q}%`, limit]
    );

    res.set('Cache-Control', 'public, max-age=600');
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la recherche:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/recettes/random - Récupérer des recettes aléatoires
app.get('/api/recettes/random', async (req, res) => {
  try {
    const { count = 10 } = req.query;
    const n = Math.min(parseInt(count) || 10, 50);

    const result = await pool.query(
      `SELECT id, url, titre, photo, duree, created_at
       FROM marmiton_recettes
       OFFSET floor(random() * (SELECT GREATEST(count(*) - $1, 0) FROM marmiton_recettes))::int
       LIMIT $1`,
      [n]
    );

    res.set('Cache-Control', 'public, max-age=600');
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des recettes aléatoires:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/recettes/:id - Récupérer une recette par ID
app.get('/api/recettes/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'SELECT * FROM marmiton_recettes WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Recette non trouvée' });
    }

    res.set('Cache-Control', 'public, max-age=3600');
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération de la recette:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/stats - Statistiques de la base de données
app.get('/api/stats', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT COUNT(*) as total FROM marmiton_recettes'
    );
    
    res.json({
      totalRecettes: parseInt(result.rows[0].total),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${port}`);
  console.log(`📊 API disponible sur http://localhost:${port}/api/recettes`);
});

// Gestion de la fermeture propre
process.on('SIGTERM', () => {
  console.log('SIGTERM reçu, fermeture de la connexion PostgreSQL...');
  pool.end(() => {
    console.log('Pool PostgreSQL fermé');
    process.exit(0);
  });
});
