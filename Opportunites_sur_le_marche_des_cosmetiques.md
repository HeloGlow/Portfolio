# Bienvenue sur mon portfolio de Data Analyse !

description projet
slide io ? dataiku kaggle tableau sql google trends
---

### :hibiscus: Recherche d'un dataset

J'ai recherché des datasets gratuits sur le marché des cosmétiques = Kaggle

> This dataset provides an extensive overview of the most used beauty and cosmetics products across the world, offering insights into global trends, preferences, and popular brands. It includes detailed information about product names, brands, categories, usage frequency, pricing, user ratings, reviews, and more.<br>
> Whether you're a researcher, marketer, or beauty enthusiast, this dataset serves as a valuable resource for understanding consumer behavior, brand popularity, and market trends within the beauty industry.

Schéma complet dispo ici https://www.kaggle.com/datasets/waqi786/most-used-beauty-cosmetics-products-in-the-world/data

---

### :hibiscus: Vérification des données

J'ai choisi de travailler en SQL, sur Dataiku. J'importe l'excel et je fais une recipe Sync afin de stocker le dataset dans SQL (?).

-- Avant de commencer l'analyse et la préparation des tables sources pour le dashboard, il faut vérifier les données

<blockquote>
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
</blockquote>
-- Il n'y a pas de valeurs nulles

/*
-- 2) Identification d'éventuels doublons
SELECT *,
    COUNT(*) AS nb_doublons
FROM `pit-edh0labue-p-arrm.prod_lab_ue_etudes.HV_ANALYSES_PONCTUELLES_most_used_beauty_products_sql`
GROUP BY ALL
HAVING nb_doublons > 1;
-- Il n'y a pas de doublons
*/
/*
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
*/
/*
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
*/
