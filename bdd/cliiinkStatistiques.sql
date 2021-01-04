/*
 * Triggers et tâches planifiées (events annuels) 
 * pour la génération d'une table de statistiques utilisable dans la dataviz
 *
 * Note : on ne considérera que les collecteurs qui sont en quantité et les plus enclins à changer en quantité, contrairement aux déchèteries
 */
USE cliiink;

# Suppression des éventuels triggers
DROP TRIGGER IF EXISTS decompteCollecteursInsert;
DROP TRIGGER IF EXISTS decompteCollecteursDelete;

# Suppression des éventuelles tâches planifiées
DROP EVENT IF EXISTS statsAnnuelles;

# Suppression des éventuelles tables
DROP TABLE IF EXISTS statsPartielles;

# Création de la table recueillant les statistiques partielles
# avec le nombre de sites de collecte et le nombre de collecteurs par ville (via le code INSEE) et type de tri
CREATE TABLE statsPartielles AS 
	SELECT codeInsee, tri.type AS typeTri, COUNT(collecteur.objectid) AS nbSites, SUM(quantite) AS nbCollecteurs FROM collecteur 
		JOIN tri ON collecteur.idTri = tri.id 
        LEFT JOIN marque ON collecteur.idMarque = marque.id 
        LEFT JOIN categorie ON collecteur.idCategorie = categorie.id
		GROUP BY codeInsee, typeTri 
        ORDER BY codeInsee, typeTri;

/* 
 * TRIGGERS
 */
 
# Création du trigger pour l'actualisation des statistiques partielles après l'ajout de collecteurs
CREATE TRIGGER decompteCollecteursInsert
	AFTER INSERT ON collecteur
    FOR EACH ROW
		UPDATE statsPartielles
			SET nbSites = nbSites + 1,
				nbCollecteurs = nbCollecteurs + NEW.quantite
				WHERE codeInsee = NEW.codeInsee AND typeTri = (SELECT type FROM tri WHERE tri.id = NEW.idTri);
    
# Création du trigger pour l'actualisation des statistiques partielles après la suppression de collecteurs    
CREATE TRIGGER decompteCollecteursDelete
	AFTER DELETE ON collecteur
    FOR EACH ROW
		UPDATE statsPartielles
			SET nbSites = nbSites - 1,
				nbCollecteurs = nbCollecteurs - OLD.quantite
				WHERE codeInsee = OLD.codeInsee AND typeTri = (SELECT type FROM tri WHERE tri.id = OLD.idTri);

/*
 * EVENTS (Tâches planifiées)
 */

# On change le délimiteur de la fin d'une instruction (; remplacé par $$)
# pour que MySQL lise chaque tâche planifiée d'un bloc
DELIMITER $$

# Création de la tâche planifiée annuellement pour l'actualisation des statistiques complètes
CREATE EVENT statsAnnuelles 
	ON SCHEDULE EVERY 1 YEAR
	STARTS "2020-01-01 04:00:00" # Heure de la nuit à privilégier (moins de charge)
    DO
		BEGIN
			DROP TABLE IF EXISTS statsCompletes;
            # Statistiques complètes avec le nombre de sites de collecteurs et le nombre de collecteuus 
			# par ville (via le code INSEE), type de tri, marque, type de collecteur et volume
			CREATE TABLE statsCompletes AS
				SELECT codeInsee, tri.type AS typeTri, marque.nom AS marque, categorie.type AS typeCollecteur, volume, COUNT(collecteur.objectid) AS nbSites, SUM(quantite) AS nbCollecteurs FROM collecteur 
					JOIN tri ON collecteur.idTri = tri.id 
					LEFT JOIN marque ON collecteur.idMarque = marque.id 
					LEFT JOIN categorie ON collecteur.idCategorie = categorie.id
					GROUP BY codeInsee, typeTri, typeCollecteur, marque, volume 
					ORDER BY codeInsee, typeTri;
		END$$