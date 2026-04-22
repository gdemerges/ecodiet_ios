-- Migration: index trigram pour la recherche ILIKE sur le titre
-- Prérequis: extension pg_trgm (incluse dans PostgreSQL par défaut)
-- Exécuter une seule fois : psql -U postgres -d marmiton -f search_index_migration.sql

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_recettes_titre_trgm
    ON marmiton_recettes
    USING gin(titre gin_trgm_ops);
