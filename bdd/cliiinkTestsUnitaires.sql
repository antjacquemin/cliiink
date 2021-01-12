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




    
# Affiche le collecteur selon les coordonnées
-- La précision de la localisation dépendra de la précision des coordonnées 
CREATE PROCEDURE PL_CollecteurByCoordonnees(IN _xCollecteur FLOAT, IN _yCollecteur FLOAT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    WHERE _x = _xCollecteur AND _y = _yCollecteur$$      
    
# Affiche le collecteur selon les coordonnées avec une marge d'erreur
-- Affiche les collecteurs dans une zone centrée sur les coordonnées données 
-- avec une marge de +-8m en longitude et +-11m en latitude 
-- (marge correspodant à 1° en longitude et latitude pour une latitude approximatice de Cannes à 45° et une précision 0.0001)
CREATE PROCEDURE PL_CollecteurByCoordonneesMarge(IN _xCollecteur FLOAT, IN _yCollecteur FLOAT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    WHERE _x > _xCollecteur - 0.0001 AND _x < _xCollecteur + 0.0001 AND _y > _yCollecteur - 0.0001 AND _y < _yCollecteur + 0.0001$$      

# Affiche les collecteurs selon l'ientifiant de catégorie
CREATE PROCEDURE PL_CollecteurByIdCategorie(IN idCategorie SMALLINT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE idCategorie = idCategorie$$

# Affiche les collecteurs selon l'ientifiant de tri
CREATE PROCEDURE PL_CollecteurByIdTri(IN idTri SMALLINT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE idTri = idTri$$

# Affiche les collecteurs selon l'ientifiant de marque
CREATE PROCEDURE PL_CollecteurByIdMarque(IN idMarque SMALLINT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE idMarque = idMarque$$

-- UPDATE

# Change les informations sur le collecteur d'identifiant objectidCollecteur
-- La date de modification correpond à l'instant présent
-- Pour des raisons de sécurité, createurDecheterie et dateCreationDecheterie (établis à l'insertion) ainsi que dateModificationDecheterie ne doivent pas être éditables
CREATE PROCEDURE PU_Collecteur(IN objectidCollecteur SMALLINT, IN idCollecteur VARCHAR(30), IN volumeCollecteur SMALLINT, IN quantiteCollecteur SMALLINT, IN dateInstallationCollecteur DATE, 
								IN adresseCollecteur VARCHAR(50), IN adresseComplementCollecteur VARCHAR(40), IN codeInseeCollecteur CHAR(5), IN observationsCollecteur VARCHAR(70), IN modificateurCollecteur VARCHAR(20),
                                IN globalIdCollecteur VARCHAR(38), IN _xCollecteur FLOAT, IN _yCollecteur FLOAT, IN idCategorie SMALLINT, IN idTri SMALLINT, IN idMarque SMALLINT)
	# Si le collecteur existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    # Alors
	THEN 
		# On vérifie que le globalid que l'on veut rentrer n'existe pas déjà dans une autre ligne
        -- c'est-à-dire s'il existe un identifiant de ligne, différent de celui qu'on veut modifier, qui possède le même globalid
		IF EXISTS(SELECT objectid FROM collecteur WHERE globalid = globalIdCollecteur AND objectid != objectidCollecteur)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# On vérifie que l'adresse ou les coordonnées que l'on veut rentrer n'existe pas déjà dans une autre ligne
            IF (EXISTS(SELECT objectid FROM collecteur WHERE adresse = adresseCollecteur AND objectid != objectidCollecteur)
			OR EXISTS(SELECT objectid FROM collecteur WHERE _x = _xCollecteur AND _y = _yCollecteur AND objectid != objectidCollecteur))
            THEN
				SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = "Un collecteur existe déjà à cette adresse ou pour ces coordonnées";
            ELSE
				# On vérifie que l'identifiant de catégorie existe bien
				IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
				THEN
					# On vérifie que l'identifiant de tri existe bien
					IF EXISTS(SELECT * FROM tri WHERE id = idTri)
					THEN
						# On vérifie que l'identifiant de marque existe bien
						IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
                        THEN
							# On met à jour le collecteur
							UPDATE collecteur
								SET id = idCollecteur,
									volume = volumeCollecteur,
                                    quantite = quantiteCollecteur,
									dateInstallation = dateInstallationCollecteur,
									adresse = adresseCollecteur,
									adresseComplement = adresseComplementCollecteur,
									codeInsee = codeInseeCollecteur,
									observations = observationsCollecteur,
									modificateur = modificateurCollecteur,
									dateModification = NOW(), 
									globalid = globalIdCollecteur, 
									_x =_xCollecteur,
									_y = _yCollecteur,
                                    idCategorie = idCategorie,
                                    idTri = idTri,
                                    idMarque = idMarque
							WHERE objectid = objectidCollecteur;
						ELSE
							SIGNAL SQLSTATE '45000'
								SET MESSAGE_TEXT = "L'identifiant de marque n'existe pas dans la table marque";
						END IF;
					ELSE
						SIGNAL SQLSTATE '45000'
							SET MESSAGE_TEXT = "L'identifiant de tri n'existe pas dans la table tri";
					END IF;
				ELSE
					SIGNAL SQLSTATE '45000'
						SET MESSAGE_TEXT = "L'identifiant de catégorie n'existe pas dans la table catégorie";
				END IF;
			END IF;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le collecteur que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime le collecteur d'identifiant objectidCollecteur
CREATE PROCEDURE PD_Collecteur(IN objectidCollecteur SMALLINT)
	# Si le collecteur existe
	IF EXISTS(SELECT * FROM collecteur WHERE objectid = objectidCollecteur)
    THEN
		DELETE FROM decheterie WHERE objectid = objectidCollecteur;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le collecteur que vous essayez de supprimer n'existe pas";
	END IF$$

-- Ajouter éventuellement des PD_CollecteurBy__ 

-- BONUS

# Ajoute le collecteur si il n'existe pas, le met à jour sinon
CREATE PROCEDURE PIU_Collecteur(IN objectidCollecteur SMALLINT, IN idCollecteur VARCHAR(30), IN volumeCollecteur SMALLINT, IN quantiteCollecteur SMALLINT, IN dateInstallationCollecteur DATE, 
								IN adresseCollecteur VARCHAR(50), IN adresseComplementCollecteur VARCHAR(40), IN codeInseeCollecteur CHAR(5), IN observationsCollecteur VARCHAR(70), IN editeurCollecteur VARCHAR(20),
                                IN globalIdCollecteur VARCHAR(38), IN _xCollecteur FLOAT, IN _yCollecteur FLOAT, IN idCategorie SMALLINT, IN idTri SMALLINT, IN idMarque SMALLINT)
	# On vérifie que le globalid que l'on veut rentrer n'existe pas déjà dans une autre ligne
	-- c'est-à-dire s'il existe un identifiant de ligne, différent de celui qu'on veut modifier, qui possède le même globalid
	IF EXISTS(SELECT objectid FROM collecteur WHERE globalid = globalIdCollecteur AND objectid != objectidCollecteur)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
	ELSE
		# On vérifie que l'adresse ou les coordonnées que l'on veut rentrer n'existe pas déjà dans une autre ligne
		IF (EXISTS(SELECT objectid FROM collecteur WHERE adresse = adresseCollecteur AND objectid != objectidCollecteur)
		OR EXISTS(SELECT objectid FROM collecteur WHERE _x = _xCollecteur AND _y = _yCollecteur AND objectid != objectidCollecteur))
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Un collecteur existe déjà à cette adresse ou pour ces coordonnées";
		ELSE
			# On vérifie que l'identifiant de catégorie existe bien
			IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
			THEN
				# On vérifie que l'identifiant de tri existe bien
				IF EXISTS(SELECT * FROM tri WHERE id = idTri)
				THEN
					# On vérifie que l'identifiant de marque existe bien
					IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
					THEN
						# Si l'identifiant est déjà attribué
						IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
						THEN
							# On met à jour le collecteur
							UPDATE collecteur
								SET id = idCollecteur,
									volume = volumeCollecteur,
									quantite = quantiteCollecteur,
									dateInstallation = dateInstallationCollecteur,
									adresse = adresseCollecteur,
									adresseComplement = adresseComplementCollecteur,
									codeInsee = codeInseeCollecteur,
									observations = observationsCollecteur,
									modificateur = modificateurCollecteur,
									dateModification = NOW(), 
									globalid = globalIdCollecteur, 
									_x =_xCollecteur,
									_y = _yCollecteur,
									idCategorie = idCategorie,
									idTri = idTri,
									idMarque = idMarque
							WHERE objectid = objectidCollecteur;
						ELSE
							# Sinon on encrée un
							INSERT INTO collecteur
							VALUES(objectidCollecteur, idCollecteur, volumeCollecteur, quantiteCollecteur, dateInstallationCollecteur, adresseCollecteur, adresseComplementCollecteur, codeInseeCollecteur, 
									observationsCollecteur,	createurCollecteur, NOW(), createurCollecteur, NOW(), globalIdCollecteur, _xCollecteur, _yCollecteur, idCategorie, idTri, idMarque);
						END IF;
					ELSE
						SIGNAL SQLSTATE '45000'
							SET MESSAGE_TEXT = "L'identifiant de marque n'existe pas dans la table marque";
					END IF;
				ELSE
					SIGNAL SQLSTATE '45000'
						SET MESSAGE_TEXT = "L'identifiant de tri n'existe pas dans la table tri";
				END IF;
			ELSE
				SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = "L'identifiant de catégorie n'existe pas dans la table catégorie";
			END IF;
		END IF;
	END IF$$

/* 
CRUD TABLE dechet
*/

-- CREATE 

# Ajoute un déchet avec un identifiant et un type 
CREATE PROCEDURE PI_Dechet(IN idDechet SMALLINT, IN typeDechet VARCHAR(30))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le type existe déjà
		IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce type existe déjà";
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO dechet VALUES(idDechet, typeDechet);
		END IF;
    # Fin du 1er IF    
	END IF$$

# Ajoute un déchet avec juste son type (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_DechetSimple(IN typeDechet VARCHAR(30))
	# On vérifie que le type n'existe pas déjà
    IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le type existe déjà";
	ELSE
		INSERT INTO dechet(type) VALUES(typeDechet);
	END IF$$

-- RETRIEVE

# Affiche le déchet d'identifiant idDechet
CREATE PROCEDURE PSGetDechet(IN idDechet SMALLINT)
	SELECT id, type FROM dechet 
    WHERE id = idDechet$$

# Affiche tous les déchets
CREATE PROCEDURE PL_Dechet()
	SELECT id, type FROM dechet$$

-- UPDATE

# Change le type de déchet d'identifiant idDechet
CREATE PROCEDURE PU_Dechet(IN idDechet SMALLINT, IN typeDechet VARCHAR(30))
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    # Alors
	THEN 
		# On vérifie que le type n'existe pas déjà
		IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE dechet
				SET type = typeDechet
			# du déchet d'identifiant idDechet         
			WHERE id = idDechet;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime le déchet d'identifiant idDechet
CREATE PROCEDURE PD_Dechet(IN idDechet SMALLINT)
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    THEN
        # Si l'identifiant du déchet est référencé dans la table traitement
        -- Test à supprimer si DELETE ON CASCADE
        -- idDechet (colonne dans traitement) = idDechet (entrée de la procédure)
		IF EXISTS(SELECT * FROM traitement WHERE idDechet = idDechet)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le déchet a son identifiant référencé dans la table traitement; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM dechet WHERE id = idDechet;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$
 
 # Supprime le déchet d'identifiant idDechet et toutes ses références (dans traitement)
 -- A utiliser avec précaution
CREATE PROCEDURE PD_DechetCascade(IN idDechet SMALLINT)
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
    THEN
        # Suppression de toutes les dépendances dans traitement
		DELETE FROM traitement WHERE idDechet = idDechet;
        DELETE FROM dechet WHERE id = idDechet;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime le déchet selon le type
CREATE PROCEDURE PD_DechetByType(IN typeDechet VARCHAR(30))
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
    THEN
        # Si l'identifiant du déchet est référencé dans la table traitement
        -- Test à supprimer si DELETE ON CASCADE
        -- idDechet (colonne dans traitement) = id associé au type de déchet
		IF EXISTS(SELECT * FROM traitement WHERE idDechet = (SELECT id FROM dechet WHERE type = typeDechet))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le déchet a son identifiant référencé dans la table traitement; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM dechet WHERE type = typeDechet;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$    

# Supprime le déchet selon le type et toutes ses références (dans traitement)
 -- A utiliser avec précaution
CREATE PROCEDURE PD_DechetByTypeCascade(IN typeDechet VARCHAR(30))
	# Si le déchet existe
	IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
    THEN
		# Suppression de toutes les dépendances dans traitement
        DELETE FROM traitement WHERE idDechet = (SELECT id FROM dechet WHERE type = typeDechet);
        # Suppression du déchet
        DELETE FROM dechet WHERE type = typeDechet;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le déchet que vous essayez de supprimer n'existe pas";
	END IF$$ 

-- BONUS

# Ajoute le déchet si il n'existe pas, le met à jour sinon
CREATE PROCEDURE PIU_Dechet(IN idDechet SMALLINT, IN typeDechet VARCHAR(30))
	# Si le type existe déjà
	IF EXISTS(SELECT * FROM dechet WHERE type = typeDechet)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce type existe déjà";
	ELSE
		# Si le déchet existe déjà
		IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
		THEN 	
			# On la met à jour
			UPDATE dechet
				SET type = typeDechet WHERE id = idDechet;
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO dechet VALUES(idDechet, typeDechet);
		END IF;
	END IF$$

/* 
CRUD TABLE decheterie
*/

-- CREATE 

# Ajoute une déchèterie avec toutes les informations
-- A la création de la déchèterie, le créateur est aussi le modificateur initial
-- Les dates de création et de modification correpondent à l'instant présent
-- Pour des raisons de sécurité, les points ci-dessus ne doivent pas être éditables
CREATE PROCEDURE PI_Decheterie(IN objectidDecheterie SMALLINT, IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN createurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le globalid existe déjà
		IF EXISTS(SELECT * FROM decheterie WHERE globalid = globalIdDecheterie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# Si une déchèterie existe à cette adresse ou pour ces coordonnées
			IF EXISTS(SELECT * FROM decheterie WHERE adresse = adresseDecheterie) OR EXISTS(SELECT * FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie)
            THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
            ELSE
				INSERT INTO decheterie
                VALUES(objectidDecheterie, idDecheterie, dateInstallationDecheterie, adresseDecheterie, adresseComplementDecheterie, codeInseeDecheterie, observationsDecheterie, 
													createurDecheterie, NOW(), createurDecheterie, NOW(), globalIdDecheterie, _xDecheterie, _yDecheterie);
			END IF;
		END IF;
	END IF$$

# Ajoute une déchèterie avec les informations suffisantes
-- objectid est autoincrémenté
-- A la création de la déchèterie, le créateur est aussi le modificateur initial
-- Les dates de création et de modification correpondent à l'instant présent
-- Pour des raisons de sécurité, les points ci-dessus ne doivent pas être éditables
CREATE PROCEDURE PI_DecheterieSimple(IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN createurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# Si le globalid existe déjà
	IF EXISTS(SELECT * FROM decheterie WHERE globalid = globalIdDecheterie)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
	ELSE
		# Si une déchèterie existe à cette adresse ou pour ces coordonnées
		IF EXISTS(SELECT * FROM decheterie WHERE adresse = adresseDecheterie) OR EXISTS(SELECT * FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie)
		THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
		ELSE
			# On insère la nouvelle déchèterie dans la table
			INSERT INTO decheterie(id, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y)
			VALUES(idDecheterie, dateInstallationDecheterie, adresseDecheterie, adresseComplementDecheterie, codeInseeDecheterie, observationsDecheterie, 
					createurDecheterie, NOW(), createurDecheterie, NOW(), globalIdDecheterie, _xDecheterie, _yDecheterie);
		END IF;
	END IF$$
                        
# Ajoute une déchèterie avec les informations nécessaires au minimum
CREATE PROCEDURE PI_DecheterieMin(IN codeInseeDecheterie CHAR(5), IN createurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	CALL PI_DecheterieSimple(NULL, NULL, NULL, NULL, codeInseeDecheterie, NULL, createurDecheterie, NOW(), createurDecheterie, NOW(), globalIdDecheterie, _xDecheterie, _yDecheterie);

-- RETRIEVE

# Affiche la déchèterie d'identifiant idDecheterie
CREATE PROCEDURE PSGetDecheterie(IN objectidDecheterie SMALLINT)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie 
    WHERE objectid = objectidDecheterie$$

# Affiche toutes les déchèteries
CREATE PROCEDURE PL_Decheterie()
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie$$

# Affiche les déchèteries selon la date d'installation
CREATE PROCEDURE PL_DecheterieByDateInstallation(IN dateInstallationDecheterie DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateInstallation = dateInstallationDecheterie$$

# Affiche les déchèteries installées après dateDebut et avant dateFin
CREATE PROCEDURE PL_DecheterieByDateInstallationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateInstallation BETWEEN dateDebut AND dateFin$$

# Affiche les déchèteries selon l'adresse
-- (qui contiennent adresseDecheterie dans leur adresse) 
CREATE PROCEDURE PL_DecheterieByAdresse(IN adresseDecheterie VARCHAR(50))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE adresse LIKE CONCAT('%', adresseDecheterie, '%')$$

# Affiche les déchèteries selon le code INSEE
CREATE PROCEDURE PL_DecheterieByCodeInsee(IN codeInseeDecheterie CHAR(5))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE codeInsee = codeInseeDecheterie$$

# Affiche les déchèteries enregistrées par createurDecheterie
CREATE PROCEDURE PL_DecheterieByCreateur(IN createurDecheterie VARCHAR(20))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE createur = createurDecheterie$$

# Affiche les déchèteries selon la date de création de la ligne
CREATE PROCEDURE PL_DecheterieByDateCreation(IN dateCreationDecheterie DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    # où la date de création se situe entre le jour indiqué (dateCreationDecheterie à minuit) et le jour suivant (minuit) pour comprendre la journée entière
    WHERE dateCreation BETWEEN dateCreationDecheterie AND DATE_ADD(dateCreationDecheterie, INTERVAL 1 DAY)$$

# Affiche les déchèteries dont les lignes ont été créées entre dateDebut et dateFin (inclus)
CREATE PROCEDURE PL_DecheterieByDateCreationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateInstallation BETWEEN dateDebut AND DATE_ADD(dateFin, INTERVAL 1 DAY)$$

# Affiche les déchèteries modifiées en dernier par modificateurDecheterie
CREATE PROCEDURE PL_DecheterieByModificateur(IN modificateurDecheterie VARCHAR(20))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE modificateur = modificateurDecheterie$$

# Affiche les déchèteries selon la dernière date de modification de la ligne
CREATE PROCEDURE PL_DecheterieByDateModification(IN dateModificationDecheterie DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    # où la date de création se situe entre le jour indiqué (dateCreationDecheterie à minuit) et le jour suivant (minuit) pour comprendre la journée entière
    WHERE dateModification BETWEEN dateModificationDecheterie AND DATE_ADD(dateModificationDecheterie, INTERVAL 1 DAY)$$

# Affiche les déchèteries dont les lignes ont été dernièrement modifiées entre dateDebut et dateFin (inclus)
CREATE PROCEDURE PL_DecheterieByDateModificationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE dateModification BETWEEN dateDebut AND DATE_ADD(dateFin, INTERVAL 1 DAY)$$    

# Affiche la déchèterie d'UUID globalid
CREATE PROCEDURE PL_DecheterieByGlobalid(IN globalidDecheterie VARCHAR(38))
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE globalid = globalidDecheterie$$    
    
# Affiche la déchèterie selon les coordonnées
-- La précision de la localisation dépendra de la précision des coordonnées 
CREATE PROCEDURE PL_DecheterieByCoordonnees(IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE _x = _xDecheterie AND _y = _yDecheterie$$      
    
# Affiche la déchèterie selon les coordonnées avec une marge d'erreur
-- Affiche les déchèteries dans une zone centrée sur les coordonnées données 
-- avec une marge de +-8m en longitude et +-11m en latitude 
-- (marge correspodant à 1° en longitude et latitude pour une latitude approximatice de Cannes à 45° et une précision 0.0001)
CREATE PROCEDURE PL_DecheterieByCoordonneesMarge(IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	SELECT objectid, id, dateInstallation, adresse, adresseComplement, codeInsee, observations,	createur, dateCreation, modificateur, dateModification, globalid, _x, _y FROM decheterie
    WHERE _x > _xDecheterie - 0.0001 AND _x < _xDecheterie + 0.0001 AND _y > _yDecheterie - 0.0001 AND _y < _yDecheterie + 0.0001$$      

-- UPDATE

# Change les informations sur la déchèterie d'identifiant objectidDecheterie
-- La date de modification correpond à l'instant présent
-- Pour des raisons de sécurité, createurDecheterie et dateCreationDecheterie (établis à l'insertion) ainsi que dateModificationDecheterie ne doivent pas être éditables
CREATE PROCEDURE PU_Decheterie(IN objectidDecheterie SMALLINT, IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN modificateurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# Si la déchèterie existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    # Alors
	THEN 
		# On vérifie que le globalid que l'on veut rentrer n'existe pas déjà dans une autre ligne
        -- c'est-à-dire s'il existe un identifiant de ligne, différent de celui qu'on veut modifier, qui possède le même globalid
		IF EXISTS(SELECT objectid FROM decheterie WHERE globalid = globalIdDecheterie AND objectid != objectidDecheterie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# On vérifie que l'adresse ou les coordonnées que l'on veut rentrer n'existe pas déjà dans une autre ligne
            IF (EXISTS(SELECT objectid FROM decheterie WHERE adresse = adresseDecheterie AND objectid != objectidDecheterie)
			OR EXISTS(SELECT objectid FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie AND objectid != objectidDecheterie))
            THEN
				SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
            ELSE
				# On met à jour la déchèterie
				UPDATE decheterie
					SET id = idDecheterie,
						dateInstallation = dateInstallationDecheterie,
						adresse = adresseDecheterie,
						adresseComplement = adresseComplementDecheterie,
						codeInsee = codeInseeDecheterie,
						observations = observationsDecheterie,
						modificateur = modificateurDecheterie,
						dateModification = NOW(), 
						globalid = globalIdDecheterie, 
						_x =_xDecheterie,
						_y = _yDecheterie
				WHERE objectid = objectidDecheterie;
			END IF;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La déchèterie que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime la déchèterie d'identifiant objectidDecheterie
CREATE PROCEDURE PD_Decheterie(IN objectidDecheterie SMALLINT)
	# Si la déchèterie existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    THEN
		# Si l'objectid de la déchèterie est référencée dans la table traitement
        -- Test à supprimer si DELETE ON CASCADE
        -- objectidDecheterie (colonne dans traitement) = objectidDecheterie (entrée de la procédure)
		IF EXISTS(SELECT * FROM traitement WHERE objectidDecheterie = objectidDecheterie)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La déchèterie a son identifiant référencé dans la table traitement; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM decheterie WHERE objectid = objectidDecheterie;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La déchèterie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la déchèterie d'identifiant objectidDecheterie et toutes ses références (dans traitement)
-- A utiliser avec précaution
CREATE PROCEDURE PD_DecheterieCascade(IN objectidDecheterie SMALLINT)
	# Si la déchèterie existe
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    THEN
		# Suppression de toutes les dépendances dans traitement
		DELETE FROM traitement WHERE objectidDecheterie = objectidDecheterie;
		DELETE FROM decheterie WHERE objectid = objectidDecheterie;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La déchèterie que vous essayez de supprimer n'existe pas";
	END IF$$

-- Ajouter éventuellement des PD_DecheterieBy__ et PD_DecheterieBy__Cascade

-- BONUS

# Ajoute la déchèterie si elle n'existe pas, la met à jour sinon
CREATE PROCEDURE PIU_Decheterie(IN objectidDecheterie SMALLINT, IN idDecheterie VARCHAR(10), IN dateInstallationDecheterie DATE, IN adresseDecheterie VARCHAR(50), IN adresseComplementDecheterie VARCHAR(40), IN codeInseeDecheterie CHAR(5),
								IN observationsDecheterie VARCHAR(70), IN editeurDecheterie VARCHAR(20), IN globalIdDecheterie VARCHAR(38), IN _xDecheterie FLOAT, IN _yDecheterie FLOAT)
	# On vérifie que le globalid que l'on veut rentrer n'existe pas déjà dans une autre ligne
	-- c'est-à-dire s'il existe un identifiant de ligne, différent de celui qu'on veut modifier, qui possède le même globalid
	IF EXISTS(SELECT objectid FROM decheterie WHERE globalid = globalIdDecheterie AND objectid != objectidDecheterie)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
	ELSE
		# On vérifie que l'adresse ou les coordonnées que l'on veut rentrer n'existe pas déjà dans une autre ligne
		IF (EXISTS(SELECT objectid FROM decheterie WHERE adresse = adresseDecheterie AND objectid != objectidDecheterie)
		OR EXISTS(SELECT objectid FROM decheterie WHERE _x = _xDecheterie AND _y = _yDecheterie AND objectid != objectidDecheterie))
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Une déchèterie existe déjà à cette adresse ou pour ces coordonnées";
		ELSE
			# Si l'identifiant est déjà attribué
			IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
			THEN
				# On met à jour la déchèterie
				UPDATE decheterie
					SET id = idDecheterie,
						dateInstallation = dateInstallationDecheterie,
						adresse = adresseDecheterie,
						adresseComplement = adresseComplementDecheterie,
						codeInsee = codeInseeDecheterie,
						observations = observationsDecheterie,
						modificateur = editeurDecheterie,
						dateModification = NOW(), 
						globalid = globalIdDecheterie, 
						_x =_xDecheterie,
						_y = _yDecheterie  
				WHERE objectid = objectidDecheterie;
			ELSE 
				# sinon, on en crée une
				INSERT INTO decheterie
				VALUES(objectidDecheterie, idDecheterie, dateInstallationDecheterie, adresseDecheterie, adresseComplementDecheterie, codeInseeDecheterie, observationsDecheterie, 
						editeurDecheterie, NOW(), editeurDecheterie, NOW(), globalIdDecheterie, _xDecheterie, _yDecheterie);
			END IF;
		END IF;
	END IF$$

/* 
CRUD TABLE marque
*/

-- CREATE 

# Ajoute une marque avec un identifiant et un nom 
CREATE PROCEDURE PI_Marque(IN idMarque SMALLINT, IN nomMarque VARCHAR(15))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si la marque existe déjà
		IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce nom existe déjà";
		ELSE
			# On insère la nouvelle marque dans la table
			INSERT INTO marque VALUES(idMarque, nomMarque);
		END IF;
    # Fin du 1er IF    
	END IF$$

# Ajoute une marque avec juste son nom (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_MarqueSimple(IN nomMarque VARCHAR(15))
	# On vérifie que la marque n'existe pas déjà
    IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le nom existe déjà";
	ELSE
		INSERT INTO marque(nom) VALUES(nomMarque);
	END IF$$

-- RETRIEVE

# Affiche la marque d'identifiant idMarque
CREATE PROCEDURE PSGetMarque(IN idMarque SMALLINT)
	SELECT id, nom FROM marque 
    WHERE id = idMarque$$

# Affiche toutes les marques
CREATE PROCEDURE PL_Marque()
	SELECT id, nom FROM marque$$

-- UPDATE

# Change le nom de la marque d'identifiant idMarque
CREATE PROCEDURE PU_Marque(IN idMarque SMALLINT, IN nomMarque VARCHAR(15))
	# Si la marque existe
	IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    # Alors
	THEN 
		# On vérifie que le nom de la marque n'existe pas déjà
		IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le nom de la marque existe déjà";
		ELSE
		# On met à jour le nom
			UPDATE marque
				SET nom = nomMarque
			# de la marque d'identifiant idMarque         
			WHERE id = idMarque;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime la marque d'identifiant idMarque
CREATE PROCEDURE PD_Marque(IN idMarque SMALLINT)
	# Si la marque existe
	IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    THEN
		# Si l'identifiant de la marque est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idMarque (colonne dans collecteur) = idMarque (entrée de la procédure)
		IF EXISTS(SELECT * FROM collecteur WHERE idMarque = idMarque)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La marque a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM marque WHERE id = idMarque;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$
    
   
# Supprime la marque d'identifiant idMarque et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_MarqueCascade(IN idMarque SMALLINT)
	# Si la marque existe
	IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
    THEN
		# Réinitialisation à NULL des références à cette marque dans collecteur
		UPDATE collecteur 
			SET idMarque = NULL
        WHERE idMarque = idMarque;
        # Suppresion de la catégorie
		DELETE FROM marque WHERE id = idMarque;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$   
    
# Supprime la marque selon le nom
CREATE PROCEDURE PD_MarqueByNom(IN nomMarque VARCHAR(15))
	# Si le nom existe
	IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
    THEN
		# Si l'identifiant associé au nom de la marque est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idMarque (colonne dans collecteur) = id associé au type de la catégorie
		IF EXISTS(SELECT * FROM collecteur WHERE idMarque = (SELECT id FROM marque WHERE nom = nomMarque))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La marque a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM marque WHERE nom = nomMarque;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la marque selon le nom et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_MarqueByNomCascade(IN nomMarque VARCHAR(15))
	# Si le nom existe
	IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
    THEN
		# Réinitialisation à NULL des références à cette marque dans collecteur
		UPDATE collecteur
			SET idMarque = NULL
        WHERE idMarque = (SELECT id FROM marque WHERE nom = nomMarque);
		DELETE FROM marque WHERE nom = nomMarque;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La marque que vous essayez de supprimer n'existe pas";
	END IF$$   
    
-- BONUS

# Ajoute la marque si elle n'existe pas, la met à jour sinon
CREATE PROCEDURE PIU_Marque(IN idMarque SMALLINT, IN nomMarque VARCHAR(15))
	# Si le nom existe déjà
	IF EXISTS(SELECT * FROM marque WHERE nom = nomMarque)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce nom existe déjà";
	ELSE
		# Si la marque existe déjà
		IF EXISTS(SELECT * FROM marque WHERE id = idMarque)
		THEN 	
			# On la met à jour
			UPDATE marque
				SET nom = nomMarque WHERE id = idMarque;
		ELSE
			# On insère la nouvelle marque dans la table
			INSERT INTO marque VALUES(idMarque, nomMarque);
		END IF;
	END IF$$

/* 
CRUD TABLE traitement
*/

-- CREATE

# Ajoute un traitement avec les identifiants de déchèterie et de déchet 
CREATE PROCEDURE PI_Traitement(IN objectidDecheterie SMALLINT, IN idDechet SMALLINT)
	IF EXISTS(SELECT * FROM decheterie WHERE objectid = objectidDecheterie)
    THEN
		IF EXISTS(SELECT * FROM dechet WHERE id = idDechet)
        THEN
			INSERT INTO traitement VALUES(objectidDecheterie, idDechet);
		ELSE
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "L'identifiant de déchet n'existe pas dans la table déchet";
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "L'identifiant de déchèterie n'existe pas dans la table déchèterie";
	END IF;
    
-- RETRIEVE

# Affiche tous les traitements
CREATE PROCEDURE PL_Traitement()
	SELECT objectidDecheterie, idDechet FROM traitement$$    

# Affiche les traitements selon l'identifiant de déchèterie
CREATE PROCEDURE PL_TraitementByObjectidDecheterie(IN objectidDecheterie SMALLINT)
	SELECT objectidDecheterie, idDechet FROM traitement WHERE objectidDecheterie = objectidDecheterie$$
    
# Affiche les traitements selon l'identifiant de déchet
CREATE PROCEDURE PL_TraitementByIdDecheterie(IN idDechet SMALLINT)
	SELECT objectidDecheterie, idDechet FROM traitement WHERE idDechet = idDechet$$
    
-- UPDATE (à éviter car 2 clés primaires)

-- DELETE

# Supprime le traitement d'identifiant (objectidDecheterie, idDechet)
CREATE PROCEDURE PD_Traitement(IN objectidDecheterie SMALLINT, IN idDechet SMALLINT)
	# Si le traitement existe
	IF EXISTS(SELECT * FROM traitement WHERE objectidDecheterie = objectidDecheterie AND idDechet = idDechet)
    THEN
		DELETE FROM traitement WHERE objectidDecheterie = objectidDecheterie AND idDechet = idDechet;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le traitement que vous essayez de supprimer n'existe pas";
	END IF$$

/* 
CRUD TABLE tri
*/

-- CREATE 

# Ajoute un tri avec un identifiant et un type 
CREATE PROCEDURE PI_Tri(IN idTri SMALLINT, IN typeTri VARCHAR(30))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM tri WHERE id = idTri)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le type existe déjà
		IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce tri existe déjà";
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO tri VALUES(idtri, typeTri);
		END IF;
	END IF$$

# Ajoute un tri avec juste son type (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_TriSimple(IN typeTri VARCHAR(30))
	# On vérifie que le type n'existe pas déjà
    IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le type existe déjà";
	ELSE
		INSERT INTO tri(type) VALUES(typeTri);
	END IF$$

-- RETRIEVE

# Affiche le tri d'identifiant idTri
CREATE PROCEDURE PSGetTri(IN idTri SMALLINT)
	SELECT id, type FROM tri 
    WHERE id = idTri$$

# Affiche tous les tris
CREATE PROCEDURE PL_Tri()
	SELECT id, type FROM tri$$

-- UPDATE

# Change le type de tri d'identifiant idCategorie
CREATE PROCEDURE PU_Tri(IN idTri SMALLINT, IN typeTri VARCHAR(30))
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE id = idTri)
    # Alors
	THEN 
		# On vérifie que le type n'existe pas déjà
		IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE tri
				SET type = typeTri
			# du tri d'identifiant idTri         
			WHERE id = idTri;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime le tri d'identifiant idTri
CREATE PROCEDURE PD_Tri(IN idTri SMALLINT)
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE id = idtri)
    THEN
		# Si l'identifiant du tri est référencé dans la table collecteur
        -- Test à supprimer si DELETE ON CASCADE
        -- idTri (colonne dans collecteur) = idTri (entrée de la procédure)
		IF EXISTS(SELECT * FROM collecteur WHERE idTri = idTri)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le tri a son identifiant référencé dans la table collecteur; toutes ces entrées sont à supprimer au préalable";
		ELSE
			DELETE FROM tri WHERE id = idTri;
		END IF;
    ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$
 
 # Supprime le tri d'identifiant idTri et toutes ses références (dans collecteur)
-- A utiliser avec précaution
CREATE PROCEDURE PD_TriCascade(IN idTri SMALLINT)
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE id = idtri)
    THEN
		# Suppression de toutes les dépendances dans collecteur
		DELETE FROM collecteur WHERE idTri = idTri;
        # Suppresion du tri
		DELETE FROM tri WHERE id = idtri;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$   
    
# Supprime le tri selon le type
CREATE PROCEDURE PD_TriByType(IN typeTri VARCHAR(30))
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
    THEN
    
		# Si l'identifiant du tri est référencé dans la table collecteur
        -- Test à supprimer si DELETE ON CASCADE
        -- idTri (colonne dans collecteur) = id associé au type de la catégorie
		IF EXISTS(SELECT * FROM collecteur WHERE idTri = (SELECT id FROM tri WHERE type = typeTri))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le tri a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM tri WHERE type = typeTri;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$
    
 # Supprime le tri selon le type et et toutes ses références (dans collecteur)
 -- A utiliser avec précaution
CREATE PROCEDURE PD_TriByTypeCascade(IN typeTri VARCHAR(30))
	# Si le tri existe
	IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
    THEN
		# Suppression de toutes les dépendances dans collecteur
		DELETE FROM collecteur WHERE idTri = (SELECT id FROM tri WHERE type = typeTri);
        # Suppresion du tri
		DELETE FROM tri WHERE type = typeTri;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le tri que vous essayez de supprimer n'existe pas";
	END IF$$   

-- BONUS

# Ajoute le tri si il n'existe pas, le met à jour sinon
CREATE PROCEDURE PIU_Tri(IN idTri SMALLINT, IN typeTri VARCHAR(30))
	# Si le type existe déjà
	IF EXISTS(SELECT * FROM tri WHERE type = typeTri)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce type existe déjà";
	ELSE
		# Si le tri existe déjà
		IF EXISTS(SELECT * FROM tri WHERE id = idTri)
		THEN 	
			# On le met à jour
			UPDATE tri
				SET type = typeTri WHERE id = idTri;
		ELSE
			# On insère le nouveau tri dans la table
			INSERT INTO tri VALUES(idTri, typeTri);
		END IF;
	END IF$$            
