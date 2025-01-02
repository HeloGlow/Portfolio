-- PROBLÉMATIQUE :
-- HéloGlow souhaite développer et commercialiser de nouveaux produits.
-- Pour faire des choix pertinents, je veux m'appuyer sur une analyse du marché des cosmétiques.


--------------------------------------------------------------------------------------------------------------------
-- 1ère ÉTAPE : RECHERCHE D'UN DATASET

-- J'ai trouvé un dataset correspondant à mon besoin sur Kaggle : https://www.kaggle.com/datasets/waqi786/most-used-beauty-cosmetics-products-in-the-world/data
-- "This dataset provides an extensive overview of the most used beauty and cosmetics products across the world, offering insights into global trends, preferences, and popular brands."
-- "It includes detailed information about product names, brands, categories, usage frequency, pricing, user ratings, reviews, and more."


--------------------------------------------------------------------------------------------------------------------
-- 2ème ÉTAPE : VÉRIFICATION DES DONNÉES

-- J'importe mon fichier excel dans Dataiku puis je fais un Sync (visual recipe) pour pouvoir manipuler les données avec SQL.
-- Avant de commencer l'analyse et la préparation des tables sources pour le dashboard Tableau, il faut vérifier les données.

-- 1) Identification d'éventuelles données manquantes
SELECT COUNT(*) AS nb_total_lignes,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Product_Name,
    SUM(CASE WHEN Brand IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Brand,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Category,
    SUM(CASE WHEN Usage_Frequency IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Usage_Frequency,
    SUM(CASE WHEN Price_USD IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Price_USD,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Rating,
    SUM(CASE WHEN Number_of_Reviews IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Number_of_Reviews,
    SUM(CASE WHEN Product_Size IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Product_Size,
    SUM(CASE WHEN Skin_Type IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Skin_Type,
    SUM(CASE WHEN Gender_Target IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Gender_Target,
    SUM(CASE WHEN Packaging_Type IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Packaging_Type,
    SUM(CASE WHEN Main_Ingredient IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Main_Ingredient,
    SUM(CASE WHEN Cruelty_Free IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Cruelty_Free,
    SUM(CASE WHEN Country_of_Origin IS NULL THEN 1 ELSE 0 END) AS nb_valeurs_nulles_Country_of_Origin
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`;
-- Il n'y a pas de valeurs nulles

-- 2) Identification d'éventuels doublons
SELECT *,
    COUNT(*) AS nb_doublons
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY ALL
HAVING nb_doublons > 1;
-- Il n'y a pas de doublons

-- 3) Contrôle des valeurs extrêmes dans les colonnes numériques
SELECT MIN(Price_USD) AS min_Price_USD,
    MAX(Price_USD) AS max_Price_USD,
    AVG(Price_USD) AS moy_Price_USD,
    MIN(Rating) AS min_Rating,
    MAX(Rating) AS max_Rating,
    AVG(Rating) AS moy_Rating,
    MIN(Number_of_Reviews) AS min_Number_of_Reviews,
    MAX(Number_of_Reviews) AS max_Number_of_Reviews,
    AVG(Number_of_Reviews) AS avg_Number_of_Reviews
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`;
-- Les valeurs sont cohérentes :
-- Prix unitaire entre 10$ et 149,99$
-- Notes entre 1/5 et 5/5
-- Nombre d'avis entre 52 et 10 000

-- 4) Détection d'éventuelles anomalies dans les colonnes textuelles
SELECT 'Product_Name' AS colonne, Product_Name AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Brand' AS colonne, Brand AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Category' AS colonne, Category AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Usage_Frequency' AS colonne, Usage_Frequency AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Product_Size' AS colonne, Product_Size AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Skin_Type' AS colonne, Skin_Type AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Gender_Target' AS colonne, Gender_Target AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Packaging_Type' AS colonne, Packaging_Type AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Main_Ingredient' AS colonne, Main_Ingredient AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Cruelty_Free' AS colonne, CAST(Cruelty_Free AS STRING) AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2
UNION ALL
SELECT 'Country_of_Origin' AS colonne, Country_of_Origin AS valeur, COUNT(*) AS nombre
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2;
-- Dans les marques, on détecte une anomalie liée à l'apostrophe :
-- En effet, on a "Juvias Place" au lieu de "Juvia's Place" et "Kiehls" au lieu de "Kiehl's"
-- Il faudra remplacer ces valeurs avant de traiter les données


--------------------------------------------------------------------------------------------------------------------
-- 3ème ÉTAPE : CORRECTION DES DONNÉES

-- Via un script SQL, on va corriger la table `most_used_beauty_products_sql`

-- On initialise la table en output
DROP TABLE `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_data_corrected`;
CREATE TABLE IF NOT EXISTS `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_data_corrected`
LIKE `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`;

-- On corrige l'anomalie textuelle sur les noms de marques
UPDATE `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
SET Brand = REPLACE(REPLACE(Brand,"Juvias Place","Juvia's Place"),"Kiehls","Kiehl's")
WHERE Brand IN ("Juvias Place","Kiehls");
-- La table `most_used_beauty_products_sql` est maintenant corrigée, nous allons pouvoir commencer à traiter les données


--------------------------------------------------------------------------------------------------------------------
-- 4ème ÉTAPE : PRÉPARATION DES TABLES POUR LE DASHBOARD

-- On prépare les tables qui alimenteront le dashboard Tableau.

-- 1) On agrège les données par marque => Création de la table "data_par_marque"

SELECT *,
    -- poids de la marque sur le nombre total de produits
    nb_produits/SUM(nb_produits) OVER() AS poids_nb_produits,
    -- classification du positionnement d'après le quartile de prix moyen
    CASE WHEN NTILE(4) OVER(ORDER BY prix_moyen ASC) = 1 THEN "Entrée de gamme"
         WHEN NTILE(4) OVER(ORDER BY prix_moyen ASC) = 2 THEN "Généraliste"
         WHEN NTILE(4) OVER(ORDER BY prix_moyen ASC) = 3 THEN "Premium"
         WHEN NTILE(4) OVER(ORDER BY prix_moyen ASC) = 4 THEN "Luxe" END AS positionnement
FROM (
    SELECT Brand AS marque,
        COUNT(Product_Name) AS nb_produits,
        AVG(Price_USD) AS prix_moyen,
        SUM(Number_of_Reviews) AS nb_avis,
        AVG(Rating) AS note_moyenne
    FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
    GROUP BY 1)


-- 2) On agrège les données par pays d'origine => Création de la table "data_par_pays"

SELECT Country_of_Origin AS pays_origine,
    COUNT(Product_Name) AS nb_produits,
    -- on crée un score d'excellence : la part des produits notés plus de 4/5 parmi les produits originaires du pays
    COUNT(CASE WHEN Rating >= 4 THEN Product_Name END)/COUNT(Product_Name) AS part_produits_excellents
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1


-- 3) On agrège les données par catégorie de produits => Création de la table "data_par_categorie"

SELECT Category AS categorie,
    Gender_Target AS genre_client,
    Usage_Frequency AS frequence_utilisation,
    COUNT(Product_Name) AS nb_produits,
    AVG(Price_USD) AS prix_moyen_unitaire,
    -- on calcule le prix moyen pour 100mL
    AVG(100*Price_USD/CAST(REGEXP_REPLACE(Product_Size,r'[^0-9]','') AS INT)) AS prix_moyen_100ml
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1,2,3

UNION ALL

SELECT Category AS categorie,
    "All genders" AS genre_client,
    "All frequencies" AS frequence_utilisation,
    COUNT(Product_Name) AS nb_produits,
    AVG(Price_USD) AS prix_moyen_unitaire,
    AVG(100*Price_USD/CAST(REGEXP_REPLACE(Product_Size,r'[^0-9]','') AS INT)) AS prix_moyen_100ml
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY 1


-- 4) On agrège les données par produit => Création de la table "data_par_produit"

SELECT Product_Name AS nom_produit,
    -- on crée un libellé produit plus complet
    CONCAT(Product_Name," - ",Brand," (",Product_Size,")") AS nom_produit_complet,
    -- on identifie des niches de marché
    CONCAT(Usage_Frequency," - ",CONCAT('>=',FLOOR(Price_USD/10)*10,'€ & <',FLOOR(Price_USD/10)*10+10),"€ - ",Skin_Type," skin - ",Gender_Target) AS segment_marche,
    Brand AS marque,
    Category AS categorie,
    Usage_Frequency AS frequence_utilisation,
    Price_USD AS prix_unitaire,
    -- on crée des tranches de prix unitaire
    CONCAT('>=$',FLOOR(Price_USD/10)*10,' & <$',FLOOR(Price_USD/10)*10+10) AS tranche_prix_unitaire,
    -- on calcule le prix pour 100mL
    100*Price_USD/CAST(REGEXP_REPLACE(Product_Size,r'[^0-9]','') AS INT) AS prix_100ml,
    Rating AS note,
    -- on crée des tranches de notes
    CASE WHEN Rating <= 2 THEN "<=2"
         WHEN Rating > 2 AND Rating <= 3 THEN ">2 & <=3"
         WHEN Rating > 3 AND Rating <= 4 THEN ">3 & <=4"
         WHEN Rating > 4 THEN ">4" END AS tranche_note,
    Number_of_Reviews AS nb_avis,
    -- on classe les produits selon leur note (avec prise en compte du nombre d'avis si égalité)
    RANK() OVER (ORDER BY Rating DESC, Number_of_Reviews DESC) AS classement_tops,
    RANK() OVER (ORDER BY Rating ASC, Number_of_Reviews ASC) AS classement_flops,
    Product_Size AS contenance,
    Skin_Type AS type_peau,
    Gender_Target AS genre_client,
    -- le produit est-il utilisable par les femmes ?
    CASE WHEN Gender_Target IN ("Female","Unisex") THEN "Oui" ELSE "Non" END AS utilisable_par_les_femmes,
    -- le produit est-il utilisable par les hommes ?
    CASE WHEN Gender_Target IN ("Male","Unisex") THEN "Oui" ELSE "Non" END AS utilisable_par_les_hommes,
    Packaging_Type AS type_packaging,
    Main_Ingredient AS ingredient_principal,
    Cruelty_Free AS cruelty_free
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`

-- 5) Je veux faire un nuage de mots avec les termes qui apparaissent le plus dans les noms de produits => Création de la table "data_nuage_mots"
-- Je veux exclure les termes qui font référence à une catégorie ("mascara", "blush"...)

WITH exploded_Product_Name
AS (
SELECT TRIM(mots) AS mots_dans_nom_produit
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`,
UNNEST(SPLIT(Product_Name, ' ')) AS mots),

exploded_Category
AS (
SELECT TRIM(mots_a_exclure) AS mots_a_exclure
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`,
UNNEST(SPLIT(Category, ' ')) AS mots_a_exclure)

SELECT a.mots_dans_nom_produit,
    COUNT(*) AS nb_occurences
FROM exploded_Product_Name a
LEFT JOIN exploded_Category b
ON a.mots_dans_nom_produit = b.mots_a_exclure
WHERE b.mots_a_exclure IS NULL
GROUP BY 1


--------------------------------------------------------------------------------------------------------------------
-- 5ème ÉTAPE : RÉALISATION DU DASHBOARD TABLEAU
