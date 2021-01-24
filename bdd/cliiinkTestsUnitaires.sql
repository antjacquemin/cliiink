/*
 * Tests unitaires pour le CRUD
 */
USE cliiink;

/*
 * Test unitaires TABLE categorie
 */
 
-- Test unitaire PI_Categorie

# Test insertion classique
# Une nouvelle ligne doit apparaître
START TRANSACTION;
	# Détermination des variables
	SET @nouvelleCategorieId = (SELECT max(id) + 1 from categorie);
	SET @nouvelleCategorieType = "Nouveau Type";
    # Vérification que le type n'existe pas
    SELECT * FROM categorie WHERE type = @nouvelleCategorieType;
    # Vérification que l'id n'est pas déjà attribué
	SELECT * FROM categorie WHERE id = @nouvelleCategorieId;
    # Insertion de la ligne témoin via la procédure
	CALL PI_Categorie(@nouvelleCategorieId, @nouvelleCategorieType);
    # Vérification de l'insertion de la ligne
	SELECT * FROM categorie WHERE id = @nouvelleCategorieId;
ROLLBACK;
# Réinitialisation de l'auto-incrémentation au plus haut ID + 1
ALTER TABLE categorie AUTO_INCREMENT = 1;

-- Test unitaire PI_CategorieSimple

# Test insertion classique
# Une nouvelle ligne doit apparaître
START TRANSACTION;
	# Détermination de la variable
	SET @nouvelleCategorieType = "Nouveau Type";
    # Vérification que le type n'existe pas
    SELECT * FROM categorie WHERE type = @nouvelleCategorieType;
    # Insertion de la ligne témoin via la procédure
	CALL PI_CategorieSimple("Nouveau Type");
    # Vérification de l'insertion de la ligne
	SELECT * FROM categorie WHERE type = @nouvelleCategorieType;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;

-- Test unitaire PSGetCategorie

# Test lecture classique
# La différence doit apparaître
START TRANSACTION;
	# Insertion d'une ligne au cas où la table serait vide
	INSERT INTO categorie(type) VALUES ("Type d'essai");
    # Récupération de l'identifiant de la dernière catégorie insérée
	SET @derniereCategorieId = (SELECT max(id) from categorie);
	# Appel de la procédure
    CALL PSGetCategorie(@derniereCategorieId);
    # Insertion de la ligne témoin
	INSERT INTO categorie(type) VALUES ("Type d'essai 2");
	# Récupération de l'identifiant de la dernière catégorie insérée
	SET @derniereCategorieId = (SELECT max(id) from categorie);
    # Appel de la procédure pour vérifier la différence
	CALL PSGetCategorie(@derniereCategorieId);
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;

-- Test unitaire PL_Categorie

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	# Affiche la totalité des lignes
	CALL PL_Categorie();
    # Décompte du nombre de catégories
    SELECT count(*) FROM film;
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO categorie(type) VALUES ("Type d'essai"), ("Type d'essai2");
	# Affiche la totalité des lignes (dont les 2 nouvelles)
    CALL PL_Categorie();
	# Décompte du nouveau nombre de catégories
    SELECT count(*) FROM film;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;

-- Test unitaire PU_Categorie

# Test modification classique
# La ligne modifiée doit apparaître
START TRANSACTION;
	# Insertion de la ligne témoin
    INSERT INTO categorie(type) VALUES ("Type d'essai");
    # Récupération de l'identifiant de la dernière catégorie insérée	
    SET @derniereCategorieId = (SELECT max(id) from categorie);
	# Affichage de la ligne témoin avant modification
    SELECT * FROM categorie where id = @derniereCategorieId;
    # Modification de la ligne témoin par la procédure
    CALL PU_Categorie(@derniereCategorieId, "Type d'essai modifié");
    # Affichage de la ligne témoin après modification
    SELECT * FROM categorie where id = @derniereCategorieId;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;

-- Test unitaire PD_Categorie

# Test suppression classique
# La ligne ne doit plus apparaître
START TRANSACTION;
	# Insertion de la ligne témoin
    INSERT INTO categorie(type) VALUES ("Type d'essai");
    # Récupération de l'identifiant de la dernière catégorie insérée	
    SET @derniereCategorieId = (SELECT max(id) from categorie);
	# Affichage de la ligne insérée
    SELECT * FROM categorie where id = @derniereCategorieId;
    # Suppression de la ligne via la procédure
    CALL PD_Categorie(@derniereCategorieId);
    # Tentative d'affichage de la ligne témoin supprimée
    SELECT * FROM categorie where id = @derniereCategorieId;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;

-- Test unitaire PD_CategorieCascade

# Test suppression classique avec cascade
# La ligne ne doit plus apparaître
START TRANSACTION;
	# Insertion de la ligne témoin
    INSERT INTO categorie(type) VALUES ("Type d'essai");
    # Récupération de l'identifiant de la dernière catégorie insérée	
    SET @derniereCategorieId = (SELECT max(id) from categorie);
    # Insertion d'un nouveau tri
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion d'un nouveau collecteur témoin pour la clé étrangère
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idTri) 
		VALUES (1, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @derniereCategorieId, @dernierTriId);
	# Récupération de l'identifiant du dernier collecteur inséré
	SET @dernierCollecteurId = (SELECT max(objectid) from collecteur);
    # Affichage de la ligne insérée
    SELECT * FROM categorie where id = @derniereCategorieId;
    # Affichage du collecteur l'utilisant
	SELECT * FROM collecteur where objectid = @dernierCollecteurId;
    # Suppression de la ligne via la procédure
    CALL PD_CategorieCascade(@derniereCategorieId);
    # Tentative d'affichage de la ligne témoin supprimée
    SELECT * FROM categorie where id = @derniereCategorieId;
    # Affichage du collecteur ne référençant plus la catégorie
	SELECT * FROM collecteur where objectid = @dernierCollecteurId;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;
ALTER TABLE collecteur AUTO_INCREMENT = 1;
ALTER TABLE tri AUTO_INCREMENT = 1;

-- Test unitaire PD_CategorieByType

# Test suppression classique
# La ligne ne doit plus apparaître
START TRANSACTION;
	SET @nouvelleCategorieType = "Type d'essai";
	# Insertion de la ligne témoin
    INSERT INTO categorie(type) VALUES (@nouvelleCategorieType);
    # Récupération de l'identifiant de la dernière catégorie insérée	
    SET @nouvelleCategorieId = (SELECT max(id) from categorie);
    # Affichage de la ligne insérée
    SELECT * FROM categorie where id = @nouvelleCategorieId;
    # Suppression de la ligne via la procédure
    CALL PD_CategorieByType(@nouvelleCategorieType);
    # Tentative d'affichage de la ligne témoin supprimée
    SELECT * FROM categorie where id = @nouvelleCategorieId;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;
    
-- Test unitaire PD_CategorieByTypeCascade

# Test suppression classique avec cascade
# La ligne ne doit plus apparaître    
START TRANSACTION;
	SET @nouvelleCategorieType = "Type d'essai";
	# Insertion de la ligne témoin
    INSERT INTO categorie(type) VALUES (@nouvelleCategorieType);
    # Récupération de l'identifiant de la dernière catégorie insérée	
    SET @nouvelleCategorieId = (SELECT max(id) from categorie);
    # Insertion d'un nouveau tri
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @nouveauTriId = (SELECT max(id) from tri);    
    # Insertion d'un nouveau collecteur témoin pour la clé étrangère
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idTri) 
		VALUES (1, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @nouvelleCategorieId, @nouveauTriId);
	# Récupération de l'identifiant du dernier collecteur inséré
	SET @nouveauCollecteurId = (SELECT max(objectid) from collecteur);
    # Affichage de la ligne insérée
    SELECT * FROM categorie where id = @nouvelleCategorieId;
    # Affichage du collecteur l'utilisant
	SELECT * FROM collecteur where objectid = @nouveauCollecteurId;
    # Suppression de la ligne via la procédure
    CALL PD_CategorieByTypeCascade(@nouvelleCategorieType);
    # Tentative d'affichage de la ligne témoin supprimée
    SELECT * FROM categorie where id = @nouvelleCategorieId;
    # Affichage du collecteur ne référençant plus la catégorie
	SELECT * FROM collecteur where objectid = @nouveauCollecteurId;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;
ALTER TABLE collecteur AUTO_INCREMENT = 1;
ALTER TABLE tri AUTO_INCREMENT = 1;
    	
-- Test unitaire PIU_Categorie

# Test insertion puis modification classique avec cascade
# Une nouvelle ligne doit apparaître puis la modification
# Insertion de la ligne témoin
START TRANSACTION;
    # Détermination des variables
    SET @nouvelleCategorieId = (SELECT max(id) + 1 from categorie);
	SET @nouvelleCategorieType = "Nouveau Type";
    # Vérification que le type n'existe pas
    SELECT * FROM categorie WHERE type = @nouvelleCategorieType;
    # Vérification que l'id n'est pas déjà attribué
	SELECT * FROM categorie WHERE id = @nouvelleCategorieId;
    # Insertion de la ligne témoin via la procédure
	CALL PIU_Categorie(@nouvelleCategorieId, @nouvelleCategorieType);
    # Vérification de l'insertion de la ligne
	SELECT * FROM categorie WHERE id = @nouvelleCategorieId;
    # Modification de la ligne témoin via la même procédure
	CALL PIU_Categorie(@nouvelleCategorieId, CONCAT(@nouvelleCategorieType, " modifié"));
	# Vérification de la modification de la ligne
	SELECT * FROM categorie WHERE id = @nouvelleCategorieId;
ROLLBACK;
ALTER TABLE categorie AUTO_INCREMENT = 1;

/*
 * Test unitaires TABLE collecteur
 */

-- Test unitaire PI_Collecteur

# Test insertion classique
# Une nouvelle ligne doit apparaître
START TRANSACTION;
	# Détermination des variables
	SET @nouveauCollecteurId = (SELECT max(objectid) + 1 from collecteur);
    # Vérification que l'id n'est pas déjà attribué
	SELECT * FROM collecteur WHERE objectid = @nouveauCollecteurId;
	# Insertion d'un nouveau tri
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de la ligne témoin via la procédure
	CALL PI_Collecteur(@nouveauCollecteurId, NULL, 660, 1, NOW(), "Quelque part", NULL, "06138", NULL, "ajacquemin", "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, NULL, @dernierTriId, NULL);
    # Vérification de l'insertion de la ligne
	SELECT * FROM collecteur WHERE objectid = @nouveauCollecteurId;
ROLLBACK;
# Réinitialisation de l'auto-incrémentation au plus haut ID + 1
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PI_CollecteurSimple

# Test insertion classique
# Une nouvelle ligne doit apparaître
START TRANSACTION;
	# Détermination des variables
	SET @nouveauCollecteurId = (SELECT max(objectid) + 1 from collecteur);
    # Vérification que l'id n'est pas déjà attribué
	SELECT * FROM collecteur WHERE objectid = @nouveauCollecteurId;
	# Insertion d'un nouveau tri
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de la ligne témoin via la procédure
	CALL PI_CollecteurSimple(NULL, 660, 1, NOW(), "Quelque part", NULL, "06138", NULL, "ajacquemin", "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, NULL, @dernierTriId, NULL);
    # Vérification de l'insertion de la ligne
	SELECT * FROM collecteur WHERE objectid = @nouveauCollecteurId;
ROLLBACK;
# Réinitialisation de l'auto-incrémentation au plus haut ID + 1
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PI_CollecteurMin

# Test insertion classique
# Une nouvelle ligne doit apparaître
START TRANSACTION;
	# Détermination des variables
	SET @nouveauCollecteurId = (SELECT max(objectid) + 1 from collecteur);
    # Vérification que l'id n'est pas déjà attribué
	SELECT * FROM collecteur WHERE objectid = @nouveauCollecteurId;
	# Insertion d'un nouveau tri
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de la ligne témoin via la procédure
	CALL PI_CollecteurMin(1, "06138", "ajacquemin", "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId);
    # Vérification de l'insertion de la ligne
	SELECT * FROM collecteur WHERE objectid = @nouveauCollecteurId;
ROLLBACK;
# Réinitialisation de l'auto-incrémentation au plus haut ID + 1
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PSGetCollecteur

# Test lecture classique
# La différence doit apparaître
START TRANSACTION;
	INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion d'une ligne au cas où la table serait vide
	INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId);
    # Récupération de l'identifiant du dernier collecteur inséré
	SET @dernierCollecteurId = (SELECT max(objectid) from collecteur);
	# Appel de la procédure
    CALL PSGetCollecteur(@dernierCollecteurId);
    # Insertion de la ligne témoin
	INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(3, "06250", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ}", 6.9, 43.5, @dernierTriId);
	# Récupération de l'identifiant de la dernière catégorie insérée
	SET @dernierCollecteurId = (SELECT max(objectid) from collecteur);
    # Appel de la procédure pour vérifier la différence
	CALL PSGetCollecteur(@dernierCollecteurId);
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_Collecteur

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	# Affiche la totalité des lignes
	CALL PL_Collecteur();
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiant du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06400", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes (dont les 2 nouvelles)
    CALL PL_Collecteur();
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByVolume

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurVolume = 700;
	# Affiche la totalité des lignes pour ce volume
	CALL PL_CollecteurByVolume(@nouveauCollecteurVolume);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE volume = @nouveauCollecteurVolume;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(volume, quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(@nouveauCollecteurVolume, 1, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (@nouveauCollecteurVolume, 2, "06400", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour ce volume (dont les 2 nouvelles)
	CALL PL_CollecteurByVolume(@nouveauCollecteurVolume);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE volume = @nouveauCollecteurVolume;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByQuantite

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurQuantite = 5;
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByQuantite(@nouveauCollecteurQuantite);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE quantite = @nouveauCollecteurQuantite;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(@nouveauCollecteurQuantite, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (@nouveauCollecteurQuantite, "06400", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByQuantite(@nouveauCollecteurQuantite);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE quantite = @nouveauCollecteurQuantite;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByDateInstallation

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurDate = CURDATE();
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByDateInstallation(@nouveauCollecteurDate);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateInstallation = @nouveauCollecteurDate;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, dateInstallation, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, @nouveauCollecteurDate, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, @nouveauCollecteurDate, "06400", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByDateInstallation(@nouveauCollecteurDate);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateInstallation = @nouveauCollecteurDate;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByDateInstallationInterval

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurDateFin = CURDATE();
    SET @nouveauCollecteurDateDebut = @nouveauCollecteurDateFin - INTERVAL 1 DAY;
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByDateInstallationInterval(@nouveauCollecteurDateDebut, @nouveauCollecteurDateFin);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateInstallation BETWEEN @nouveauCollecteurDateDebut AND @nouveauCollecteurDateFin;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure considère les 2 extrêmes
    INSERT INTO collecteur(quantite, dateInstallation, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, @nouveauCollecteurDateDebut, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, @nouveauCollecteurDateFin, "06400", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByDateInstallationInterval(@nouveauCollecteurDateDebut, @nouveauCollecteurDateFin);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateInstallation BETWEEN @nouveauCollecteurDateDebut AND @nouveauCollecteurDateFin;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByAdresse

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurAdresse = "quelque part";
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByAdresse(@nouveauCollecteurAdresse);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE adresse LIKE CONCAT('%', @nouveauCollecteurAdresse, '%');
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 4 lignes pour assurer que la procédure considère les cas avec motif seul, motif à gauche à droite et au centre d'un texte
    INSERT INTO collecteur(quantite, adresse, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, @nouveauCollecteurAdresse, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, CONCAT("debut", @nouveauCollecteurAdresse), "06400", "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId),
              (1, CONCAT(@nouveauCollecteurAdresse, "fin"), "06138", "cjacquemin", NOW(), "cjacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
              (2, CONCAT("debut", @nouveauCollecteurAdresse, "fin"), "06138", "djacquemin", NOW(), "djacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 4 nouvelles)
	CALL PL_CollecteurByAdresse(@nouveauCollecteurAdresse);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE adresse LIKE CONCAT('%', @nouveauCollecteurAdresse, '%');
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByCodeInsee

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurCode = "06000";
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByCodeInsee(@nouveauCollecteurCode);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE codeInsee = @nouveauCollecteurCode;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, @nouveauCollecteurCode, "ajacquemin", NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, @nouveauCollecteurCode, "bjacquemin", NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByCodeInsee(@nouveauCollecteurCode);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE codeInsee = @nouveauCollecteurCode;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByCreateur

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurCreateur = "ajacquemin";
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByCreateur(@nouveauCollecteurCreateur);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE createur = @nouveauCollecteurCreateur;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", @nouveauCollecteurCreateur, NOW(), "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06138", @nouveauCollecteurCreateur, NOW(), "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByCreateur(@nouveauCollecteurCreateur);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE createur = @nouveauCollecteurCreateur;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByDateCreation

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurDateCreation = NOW();
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByDateCreation(@nouveauCollecteurDateCreation);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateCreation BETWEEN @nouveauCollecteurDateCreation AND DATE_ADD(@nouveauCollecteurDateCreation, INTERVAL 1 DAY);
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", @nouveauCollecteurDateCreation, "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06138", "bjacquemin", @nouveauCollecteurDateCreation, "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByDateCreation(@nouveauCollecteurDateCreation);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateCreation BETWEEN @nouveauCollecteurDateCreation AND DATE_ADD(@nouveauCollecteurDateCreation, INTERVAL 1 DAY);
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByDateCreationInterval

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurDateFin = CURDATE();
    SET @nouveauCollecteurDateDebut = @nouveauCollecteurDateFin - INTERVAL 1 DAY;
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByDateCreationInterval(@nouveauCollecteurDateDebut, @nouveauCollecteurDateFin);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateCreation BETWEEN @nouveauCollecteurDateDebut AND DATE_ADD(@nouveauCollecteurDateFin, INTERVAL 1 DAY);
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure considère les 2 extrêmes
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", @nouveauCollecteurDateDebut, "ajacquemin", NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06138", "bjacquemin", @nouveauCollecteurDateFin, "bjacquemin", NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByDateCreationInterval(@nouveauCollecteurDateDebut, @nouveauCollecteurDateFin);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateCreation BETWEEN @nouveauCollecteurDateDebut AND DATE_ADD(@nouveauCollecteurDateFin, INTERVAL 1 DAY);
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByModificateur

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurModificateur = "ajacquemin";
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByModificateur(@nouveauCollecteurModificateur);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE modificateur = @nouveauCollecteurModificateur;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", NOW(), @nouveauCollecteurModificateur, NOW(), "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06138", "bjacquemin", NOW(), @nouveauCollecteurModificateur, NOW(), "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByModificateur(@nouveauCollecteurModificateur);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE modificateur = @nouveauCollecteurModificateur;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByDateModification

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurDateModification = NOW();
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByDateModification(@nouveauCollecteurDateModification);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateModification BETWEEN @nouveauCollecteurDateModification AND DATE_ADD(@nouveauCollecteurDateModification, INTERVAL 1 DAY);
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", NOW(), "ajacquemin", @nouveauCollecteurDateModification, "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06138", "bjacquemin", NOW(), "bjacquemin", @nouveauCollecteurDateModification, "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByDateModification(@nouveauCollecteurDateModification);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateModification BETWEEN @nouveauCollecteurDateModification AND DATE_ADD(@nouveauCollecteurDateModification, INTERVAL 1 DAY);
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByDateModificationInterval

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurDateFin = CURDATE();
    SET @nouveauCollecteurDateDebut = @nouveauCollecteurDateFin - INTERVAL 1 DAY;
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByDateModificationInterval(@nouveauCollecteurDateDebut, @nouveauCollecteurDateFin);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateModification BETWEEN @nouveauCollecteurDateDebut AND DATE_ADD(@nouveauCollecteurDateFin, INTERVAL 1 DAY);
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure considère les 2 extrêmes
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", NOW(), "ajacquemin", @nouveauCollecteurDateDebut, "{AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA}", 6.9, 43.5, @dernierTriId),
			  (2, "06138", "bjacquemin", NOW(), "bjacquemin", @nouveauCollecteurDateFin, "{ABABABAB-ABAB-ABAB-ABAB-ABABABABABAB}", 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByDateModificationInterval(@nouveauCollecteurDateDebut, @nouveauCollecteurDateFin);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE dateModification BETWEEN @nouveauCollecteurDateDebut AND DATE_ADD(@nouveauCollecteurDateFin, INTERVAL 1 DAY);
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

-- Test unitaire PL_CollecteurByGlobalid

# Test lecture classique
# Toutes les lignes doivent apparaître (sous réserve des LIMIT)
START TRANSACTION;
	SET @nouveauCollecteurGlobalId = "{ABCDEFGH-AAAA-AAAA-AAAA-AAAAAAAAAAAA}";
	# Affiche la totalité des lignes pour cette quantité
	CALL PL_CollecteurByGlobalid(@nouveauCollecteurGlobalId);
    # Décompte du nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE globalid = @nouveauCollecteurGlobalId;
    INSERT INTO tri(type) VALUES ("Type de tri");
	# Récupération de l'identifiants du dernier tri inséré	
	SET @dernierTriId = (SELECT max(id) from tri);    
    # Insertion de 2 lignes pour assurer que la procédure renvoie plus d'une ligne
    INSERT INTO collecteur(quantite, codeInsee, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idTri)
		VALUES(1, "06138", "ajacquemin", NOW(), "ajacquemin", NOW(), @nouveauCollecteurGlobalId, 6.9, 43.5, @dernierTriId),
			  (2, "06138", "bjacquemin", NOW(), "bjacquemin", NOW(), @nouveauCollecteurGlobalId, 6.9, 43.5, @dernierTriId);
	# Affiche la totalité des lignes pour cette quantité (dont les 2 nouvelles)
	CALL PL_CollecteurByGlobalid(@nouveauCollecteurGlobalId);
	# Décompte du nouveau nombre de collecteurs
    SELECT count(*) FROM collecteur WHERE globalid = @nouveauCollecteurGlobalId;
ROLLBACK;
ALTER TABLE collecteur AUTO_INCREMENT = 1;  
ALTER TABLE tri AUTO_INCREMENT = 1;  

