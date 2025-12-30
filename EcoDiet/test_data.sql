-- Script SQL pour insérer des recettes de test dans PostgreSQL
-- Utilisation : psql -U postgres -d marmiton -f test_data.sql

-- Insertion de recettes d'exemple

INSERT INTO marmiton_recettes (url, titre, photo, duree, ingredients, ustensiles, etapes) VALUES 
(
    'https://www.marmiton.org/recettes/recette_salade-de-quinoa_123456.aspx',
    'Salade de Quinoa aux Légumes',
    'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=400',
    '25 min',
    '[
        {"nom": "Quinoa", "quantite": "200", "unite": "g"},
        {"nom": "Tomates cerises", "quantite": "150", "unite": "g"},
        {"nom": "Concombre", "quantite": "1", "unite": "pièce"},
        {"nom": "Avocat", "quantite": "1", "unite": "pièce"},
        {"nom": "Citron", "quantite": "1", "unite": "pièce"},
        {"nom": "Huile d''olive", "quantite": "3", "unite": "cuillères à soupe"},
        {"nom": "Sel", "quantite": "1", "unite": "pincée"},
        {"nom": "Poivre", "quantite": "1", "unite": "pincée"}
    ]'::jsonb,
    '["Casserole", "Saladier", "Couteau", "Planche à découper"]'::jsonb,
    '[
        "Rincer le quinoa sous l''eau froide",
        "Faire cuire le quinoa dans deux fois son volume d''eau pendant 15 minutes",
        "Laisser refroidir le quinoa",
        "Couper les tomates cerises en deux",
        "Découper le concombre en petits dés",
        "Couper l''avocat en dés",
        "Mélanger tous les ingrédients dans un saladier",
        "Presser le citron sur la salade",
        "Ajouter l''huile d''olive, le sel et le poivre",
        "Mélanger délicatement et servir frais"
    ]'::jsonb
),
(
    'https://www.marmiton.org/recettes/recette_poulet-roti-aux-herbes_234567.aspx',
    'Poulet Rôti aux Herbes de Provence',
    'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
    '1h15',
    '[
        {"nom": "Poulet entier", "quantite": "1", "unite": "kg"},
        {"nom": "Beurre", "quantite": "50", "unite": "g"},
        {"nom": "Herbes de Provence", "quantite": "2", "unite": "cuillères à soupe"},
        {"nom": "Ail", "quantite": "4", "unite": "gousses"},
        {"nom": "Citron", "quantite": "1", "unite": "pièce"},
        {"nom": "Pommes de terre", "quantite": "500", "unite": "g"},
        {"nom": "Sel", "quantite": "1", "unite": "cuillère à café"},
        {"nom": "Poivre", "quantite": "1", "unite": "cuillère à café"}
    ]'::jsonb,
    '["Four", "Plat à rôtir", "Pinceau de cuisine", "Couteau"]'::jsonb,
    '[
        "Préchauffer le four à 200°C",
        "Laver et sécher le poulet",
        "Mélanger le beurre avec les herbes de Provence",
        "Badigeonner le poulet avec le beurre aux herbes",
        "Éplucher et couper les pommes de terre en quartiers",
        "Disposer les pommes de terre autour du poulet",
        "Ajouter les gousses d''ail non épluchées",
        "Couper le citron en deux et le placer dans le poulet",
        "Saler et poivrer généreusement",
        "Enfourner pour 1h en arrosant régulièrement",
        "Laisser reposer 10 minutes avant de découper"
    ]'::jsonb
),
(
    'https://www.marmiton.org/recettes/recette_gateau-au-chocolat_345678.aspx',
    'Gâteau au Chocolat Fondant',
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
    '45 min',
    '[
        {"nom": "Chocolat noir", "quantite": "200", "unite": "g"},
        {"nom": "Beurre", "quantite": "100", "unite": "g"},
        {"nom": "Sucre", "quantite": "150", "unite": "g"},
        {"nom": "Oeufs", "quantite": "4", "unite": "pièces"},
        {"nom": "Farine", "quantite": "50", "unite": "g"},
        {"nom": "Levure chimique", "quantite": "1", "unite": "sachet"}
    ]'::jsonb,
    '["Four", "Moule à gâteau", "Saladier", "Fouet", "Bain-marie"]'::jsonb,
    '[
        "Préchauffer le four à 180°C",
        "Faire fondre le chocolat et le beurre au bain-marie",
        "Dans un saladier, battre les œufs avec le sucre",
        "Ajouter le mélange chocolat-beurre",
        "Incorporer délicatement la farine et la levure",
        "Beurrer et fariner un moule",
        "Verser la préparation dans le moule",
        "Enfourner pendant 25-30 minutes",
        "Le centre doit rester légèrement coulant",
        "Laisser refroidir avant de démouler"
    ]'::jsonb
),
(
    'https://www.marmiton.org/recettes/recette_risotto-champignons_456789.aspx',
    'Risotto aux Champignons',
    'https://images.unsplash.com/photo-1476124369491-c68d5abf1e3d?w=400',
    '35 min',
    '[
        {"nom": "Riz arborio", "quantite": "300", "unite": "g"},
        {"nom": "Champignons de Paris", "quantite": "300", "unite": "g"},
        {"nom": "Bouillon de légumes", "quantite": "1", "unite": "litre"},
        {"nom": "Vin blanc", "quantite": "10", "unite": "cl"},
        {"nom": "Oignon", "quantite": "1", "unite": "pièce"},
        {"nom": "Parmesan", "quantite": "80", "unite": "g"},
        {"nom": "Beurre", "quantite": "40", "unite": "g"},
        {"nom": "Huile d''olive", "quantite": "2", "unite": "cuillères à soupe"}
    ]'::jsonb,
    '["Casserole", "Poêle", "Louche", "Cuillère en bois"]'::jsonb,
    '[
        "Faire chauffer le bouillon de légumes",
        "Émincer l''oignon et le faire revenir dans l''huile",
        "Nettoyer et couper les champignons en lamelles",
        "Faire sauter les champignons dans une poêle",
        "Ajouter le riz et nacrer pendant 2 minutes",
        "Déglacer avec le vin blanc",
        "Ajouter le bouillon louche par louche en remuant",
        "Continuer pendant 18-20 minutes",
        "Incorporer les champignons",
        "Ajouter le parmesan et le beurre hors du feu",
        "Mélanger et servir immédiatement"
    ]'::jsonb
),
(
    'https://www.marmiton.org/recettes/recette_smoothie-bowl_567890.aspx',
    'Smoothie Bowl Fruits Rouges',
    'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400',
    '10 min',
    '[
        {"nom": "Banane congelée", "quantite": "2", "unite": "pièces"},
        {"nom": "Fruits rouges congelés", "quantite": "200", "unite": "g"},
        {"nom": "Lait d''amande", "quantite": "100", "unite": "ml"},
        {"nom": "Miel", "quantite": "1", "unite": "cuillère à soupe"},
        {"nom": "Granola", "quantite": "50", "unite": "g"},
        {"nom": "Fruits frais", "quantite": "100", "unite": "g"},
        {"nom": "Graines de chia", "quantite": "1", "unite": "cuillère à soupe"}
    ]'::jsonb,
    '["Blender", "Bol", "Couteau"]'::jsonb,
    '[
        "Mettre les bananes congelées dans le blender",
        "Ajouter les fruits rouges congelés",
        "Verser le lait d''amande",
        "Ajouter le miel",
        "Mixer jusqu''à obtenir une texture crémeuse",
        "Verser dans un bol",
        "Décorer avec le granola",
        "Ajouter les fruits frais coupés",
        "Saupoudrer de graines de chia",
        "Servir immédiatement"
    ]'::jsonb
);

-- Vérifier l'insertion
SELECT id, titre, duree FROM marmiton_recettes ORDER BY id DESC LIMIT 5;

-- Afficher le nombre total de recettes
SELECT COUNT(*) as total_recettes FROM marmiton_recettes;
