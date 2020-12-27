/*
 * Procédures stockées suivant le principe CRUD
 * pour la persistance des objets
 */
USE cliiink;

# Suppression des éventuelles procédures exitantes
DROP PROCEDURE IF EXISTS PI_Categorie; 
DROP PROCEDURE IF EXISTS PI_CategorieSimple; 
DROP PROCEDURE IF EXISTS PSGetCategorie; 
DROP PROCEDURE IF EXISTS PL_Categorie;
DROP PROCEDURE IF EXISTS PU_Categorie; 
DROP PROCEDURE IF EXISTS PD_Categorie; 
DROP PROCEDURE IF EXISTS PD_CategorieCascade; 
DROP PROCEDURE IF EXISTS PD_CategorieByType; 
DROP PROCEDURE IF EXISTS PD_CategorieByTypeCascade; 
DROP PROCEDURE IF EXISTS PIU_Categorie; 
DROP PROCEDURE IF EXISTS PI_Collecteur;
DROP PROCEDURE IF EXISTS PI_CollecteurSimple;
DROP PROCEDURE IF EXISTS PI_CollecteurMin;
DROP PROCEDURE IF EXISTS PSGetCollecteur;
DROP PROCEDURE IF EXISTS PL_Collecteur;
DROP PROCEDURE IF EXISTS PL_CollecteurByVolume;
DROP PROCEDURE IF EXISTS PL_CollecteurByQuantite;
DROP PROCEDURE IF EXISTS PL_CollecteurByDateInstallation;
DROP PROCEDURE IF EXISTS PL_CollecteurByDateInstallationInterval;
DROP PROCEDURE IF EXISTS PL_CollecteurByAdresse;
DROP PROCEDURE IF EXISTS PL_CollecteurByCodeInsee;
DROP PROCEDURE IF EXISTS PL_CollecteurByCreateur;
DROP PROCEDURE IF EXISTS PL_CollecteurByDateCreation;
DROP PROCEDURE IF EXISTS PL_CollecteurByDateCreationInterval;
DROP PROCEDURE IF EXISTS PL_CollecteurByModificateur;
DROP PROCEDURE IF EXISTS PL_CollecteurByDateModification;
DROP PROCEDURE IF EXISTS PL_CollecteurByDateModificationInterval;
DROP PROCEDURE IF EXISTS PL_CollecteurByGlobalid;
DROP PROCEDURE IF EXISTS PL_CollecteurByCoordonnees;
DROP PROCEDURE IF EXISTS PL_CollecteurByCoordonneesMarge;
DROP PROCEDURE IF EXISTS PL_CollecteurByIdCategorie;
DROP PROCEDURE IF EXISTS PL_CollecteurByIdTri;
DROP PROCEDURE IF EXISTS PL_CollecteurByIdMarque;
DROP PROCEDURE IF EXISTS PU_Collecteur;
DROP PROCEDURE IF EXISTS PD_Collecteur;
DROP PROCEDURE IF EXISTS PIU_Collecteur;
DROP PROCEDURE IF EXISTS PI_Dechet; 
DROP PROCEDURE IF EXISTS PI_DechetSimple; 
DROP PROCEDURE IF EXISTS PSGetDechet; 
DROP PROCEDURE IF EXISTS PL_Dechet;
DROP PROCEDURE IF EXISTS PU_Dechet; 
DROP PROCEDURE IF EXISTS PD_Dechet; 
DROP PROCEDURE IF EXISTS PD_DechetCascade; 
DROP PROCEDURE IF EXISTS PD_DechetByType; 
DROP PROCEDURE IF EXISTS PD_DechetByTypeCascade; 
DROP PROCEDURE IF EXISTS PIU_Dechet; 
DROP PROCEDURE IF EXISTS PI_Decheterie;
DROP PROCEDURE IF EXISTS PI_DecheterieSimple;
DROP PROCEDURE IF EXISTS PI_DecheterieMin;
DROP PROCEDURE IF EXISTS PSGetDecheterie;
DROP PROCEDURE IF EXISTS PL_Decheterie;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateInstallation;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateInstallationInterval;
DROP PROCEDURE IF EXISTS PL_DecheterieByAdresse;
DROP PROCEDURE IF EXISTS PL_DecheterieByCodeInsee;
DROP PROCEDURE IF EXISTS PL_DecheterieByCreateur;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateCreation;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateCreationInterval;
DROP PROCEDURE IF EXISTS PL_DecheterieByModificateur;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateModification;
DROP PROCEDURE IF EXISTS PL_DecheterieByDateModificationInterval;
DROP PROCEDURE IF EXISTS PL_DecheterieByGlobalid;
DROP PROCEDURE IF EXISTS PL_DecheterieByCoordonnees;
DROP PROCEDURE IF EXISTS PL_DecheterieByCoordonneesMarge;
DROP PROCEDURE IF EXISTS PU_Decheterie;
DROP PROCEDURE IF EXISTS PD_Decheterie;
DROP PROCEDURE IF EXISTS PD_DecheterieCascade;
DROP PROCEDURE IF EXISTS PIU_Decheterie;
DROP PROCEDURE IF EXISTS PI_Marque; 
DROP PROCEDURE IF EXISTS PI_MarqueSimple; 
DROP PROCEDURE IF EXISTS PSGetMarque; 
DROP PROCEDURE IF EXISTS PL_Marque;
DROP PROCEDURE IF EXISTS PU_Marque; 
DROP PROCEDURE IF EXISTS PD_Marque; 
DROP PROCEDURE IF EXISTS PD_MarqueCascade; 
DROP PROCEDURE IF EXISTS PD_MarqueByNom; 
DROP PROCEDURE IF EXISTS PD_MarqueByNomCascade; 
DROP PROCEDURE IF EXISTS PIU_Marque; 
DROP PROCEDURE IF EXISTS PI_Traitement;
DROP PROCEDURE IF EXISTS PL_Traitement;
DROP PROCEDURE IF EXISTS PL_TraitementByObjectidDecheterie;
DROP PROCEDURE IF EXISTS PL_TraitementByIdDecheterie;
DROP PROCEDURE IF EXISTS PD_Traitement;
DROP PROCEDURE IF EXISTS PI_Tri; 
DROP PROCEDURE IF EXISTS PI_TriSimple; 
DROP PROCEDURE IF EXISTS PSGetTri; 
DROP PROCEDURE IF EXISTS PL_Tri;
DROP PROCEDURE IF EXISTS PU_Tri; 
DROP PROCEDURE IF EXISTS PD_Tri; 
DROP PROCEDURE IF EXISTS PD_TriCascade; 
DROP PROCEDURE IF EXISTS PD_TriByType; 
DROP PROCEDURE IF EXISTS PD_TriByTypeCascade; 
DROP PROCEDURE IF EXISTS PIU_Tri; 

# On change le délimiteur de la fin d'une instruction (; remplacé par $$)
# pour que MySQL lise chaque procédure d'un bloc
DELIMITER $$

/* 
CRUD TABLE categorie
*/

-- CREATE 

# Ajoute une catégorie avec un identifiant et un type 
CREATE PROCEDURE PI_Categorie(IN idCategorie SMALLINT, IN typeCategorie VARCHAR(30))
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le type existe déjà
		IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce type existe déjà";
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO categorie VALUES(idCategorie, typeCategorie);
		END IF;
    # Fin du 1er IF    
	END IF$$

# Ajoute une catégorie avec juste son type (l'identifiant est autoincrémenté)
CREATE PROCEDURE PI_CategorieSimple(IN typeCategorie VARCHAR(30))
	# On vérifie que le type n'existe pas déjà
    IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Le type existe déjà";
	ELSE
		INSERT INTO categorie(type) VALUES(typeCategorie);
	END IF$$

-- RETRIEVE

# Affiche la catégorie d'identifiant idCategorie
CREATE PROCEDURE PSGetCategorie(IN idCategorie SMALLINT)
	SELECT id, type FROM categorie 
    WHERE id = idCategorie$$

# Affiche toutes les catégories
CREATE PROCEDURE PL_Categorie()
	SELECT id, type FROM categorie$$

-- UPDATE

# Change le type de la catégorie d'identifiant idCategorie
CREATE PROCEDURE PU_Categorie(IN idCategorie SMALLINT, IN typeCategorie VARCHAR(30))
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    # Alors
	THEN 
		# On vérifie que le type n'existe pas déjà
		IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Le type existe déjà";
		ELSE
		# On met à jour le type
			UPDATE categorie
				SET type = typeCategorie
			# de la catégorie d'identifiant idCategorie         
			WHERE id = idCategorie;
		END IF;
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de modifier n'existe pas";
	END IF$$

-- DELETE

# Supprime la catégorie d'identifiant idCategorie
CREATE PROCEDURE PD_Categorie(IN idCategorie SMALLINT)
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    THEN
		# Si l'identifiant de la catégorie est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idCategorie (colonne dans collecteur) = idCategorie (entrée de la procédure)
		IF EXISTS(SELECT * FROM collecteur WHERE idCategorie = idCategorie)
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La catégorie a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM categorie WHERE id = idCategorie;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la catégorie d'identifiant idCategorie et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_CategorieCascade(IN idCategorie SMALLINT)
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
    THEN
		# Réinitialisation à NULL des références à cette catégorie dans collecteur
		UPDATE collecteur 
			SET idCategorie = NULL
        WHERE idCategorie = idCategorie;
        # Suppresion de la catégorie
		DELETE FROM categorie WHERE id = idCategorie;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la catégorie selon le type
CREATE PROCEDURE PD_CategorieByType(IN typeCategorie VARCHAR(30))
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
    THEN
		# Si l'identifiant associé au type de la catégorie est référencé dans la table collecteur
        -- Test à supprimer si DELETE SET NULL
        -- idCategorie (colonne dans collecteur) = id associé au type de la catégorie
		IF EXISTS(SELECT * FROM collecteur WHERE idCategorie = (SELECT id FROM categorie WHERE type = typeCategorie))
        THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "La catégorie a son identifiant référencé dans la table collecteur; toutes ces entrées sont à rectifier au préalable";
		ELSE
			DELETE FROM categorie WHERE type = typeCategorie;
		END IF;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
    
# Supprime la catégorie selon le type et réinitialise toutes ses références (dans collecteur) à NULL
-- A utiliser avec précaution
CREATE PROCEDURE PD_CategorieByTypeCascade(IN typeCategorie VARCHAR(30))
	# Si la catégorie existe
	IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
    THEN
		# Réinitialisation à NULL des références à cette catégorie dans collecteur
		UPDATE collecteur 
			SET idCategorie = NULL
		WHERE idCategorie = (SELECT id FROM categorie WHERE type = typeCategorie);
        # Suppresion de la catégorie
        DELETE FROM categorie WHERE type = typeCategorie;
	ELSE
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La catégorie que vous essayez de supprimer n'existe pas";
	END IF$$
	
-- BONUS

# Ajoute une catégorie si elle n'existe pas, la met à jour sinon
CREATE PROCEDURE PIU_Categorie(IN idCategorie SMALLINT, IN typeCategorie VARCHAR(30))
	# Si le type existe déjà
	IF EXISTS(SELECT * FROM categorie WHERE type = typeCategorie)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce type existe déjà";
	ELSE
		# Si la catégorie existe déjà
		IF EXISTS(SELECT * FROM categorie WHERE id = idCategorie)
		THEN 	
			# On la met à jour
			UPDATE categorie
				SET type = typeCategorie WHERE id = idCategorie;
		ELSE
			# On insère la nouvelle catégorie dans la table
			INSERT INTO categorie VALUES(idCategorie, typeCategorie);
		END IF;
	END IF$$

/* 
CRUD TABLE collecteur
*/

# Ajoute un collecteur avec toutes les informations
-- A la création du collecteur, le créateur est aussi le modificateur initial
-- Les dates de création et de modification correpondent à l'instant présent
-- Pour des raisons de sécurité, les points ci-dessus ne doivent pas être éditables
CREATE PROCEDURE PI_Collecteur(IN objectidCollecteur SMALLINT, IN idCollecteur VARCHAR(30), IN volumeCollecteur SMALLINT, IN quantiteCollecteur SMALLINT, IN dateInstallationCollecteur DATE, 
								IN adresseCollecteur VARCHAR(50), IN adresseComplementCollecteur VARCHAR(40), IN codeInseeCollecteur CHAR(5), IN observationsCollecteur VARCHAR(70), IN createurCollecteur VARCHAR(20),
                                IN globalIdCollecteur VARCHAR(38), IN _xCollecteur FLOAT, IN _yCollecteur FLOAT, IN idCategorie SMALLINT, IN idTri SMALLINT, IN idMarque SMALLINT)
	# Si l'identifiant est déjà attribué
    IF EXISTS(SELECT * FROM collecteur WHERE objectid = objectidCollecteur)
    # Alors on renvoie un message d'erreur
	THEN 
		# un numéro d'erreur bidon
		SIGNAL SQLSTATE '45000'
			# avec son message perso
			SET MESSAGE_TEXT = "L'identifiant existe déjà";
	# Sinon
	ELSE
		# Si le globalid existe déjà
		IF EXISTS(SELECT * FROM collecteur WHERE globalid = globalIdCollecteur)
		THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
		ELSE
			# Si un collecteur existe à cette adresse ou pour ces coordonnées
			IF EXISTS(SELECT * FROM collecteur WHERE adresse = adresseCollecteur) OR EXISTS(SELECT * FROM collecteur WHERE _x = _xCollecteur AND _y = _yCollecteur)
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
							INSERT INTO collecteur
							VALUES(objectidCollecteur, idCollecteur, volumeCollecteur, quantiteCollecteur, dateInstallationCollecteur, adresseCollecteur, adresseComplementCollecteur, codeInseeCollecteur, observationsCollecteur, 
													createurCollecteur, NOW(), createurCollecteur, NOW(), globalIdCollecteur, _xCollecteur, _yCollecteur, idCategorie, idTri, idMarque);
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
	END IF$$

# Ajoute un collecteur avec les informations suffisantes
-- objectid est autoincrémenté
-- A la création de la déchèterie, le créateur est aussi le modificateur initial
-- Les dates de création et de modification correpondent à l'instant présent
-- Pour des raisons de sécurité, les points ci-dessus ne doivent pas être éditables
CREATE PROCEDURE PI_CollecteurSimple(IN idCollecteur VARCHAR(30), IN volumeCollecteur SMALLINT, IN quantiteCollecteur SMALLINT, IN dateInstallationCollecteur DATE, 
								IN adresseCollecteur VARCHAR(50), IN adresseComplementCollecteur VARCHAR(40), IN codeInseeCollecteur CHAR(5), IN observationsCollecteur VARCHAR(70), IN createurCollecteur VARCHAR(20),
                                IN globalIdCollecteur VARCHAR(38), IN _xCollecteur FLOAT, IN _yCollecteur FLOAT, IN idCategorie SMALLINT, IN idTri SMALLINT, IN idMarque SMALLINT)
	# Si le globalid existe déjà
	IF EXISTS(SELECT * FROM collecteur WHERE globalid = globalIdCollecteur)
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Ce globalid est déjà attribué";
	ELSE
		# Si un collecteur existe à cette adresse ou pour ces coordonnées
		IF EXISTS(SELECT * FROM collecteur WHERE adresse = adresseCollecteur) OR EXISTS(SELECT * FROM collecteur WHERE _x = _xCollecteur AND _y = _yCollecteur)
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
						INSERT INTO collecteur(id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, 
												createur, dateCreation, modificateur, dateModificiation, globalId, _x, _y, idCategorie, idTri, idMarque)
						VALUES(idCollecteur, volumeCollecteur, quantiteCollecteur, dateInstallationCollecteur, adresseCollecteur, adresseComplementCollecteur, codeInseeCollecteur, observationsCollecteur, 
													createurCollecteur, NOW(), createurCollecteur, NOW(), globalIdCollecteur, _xCollecteur, _yCollecteur, idCategorie, idTri, idMarque);
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
                        
# Ajoute un collecteur avec les informations nécessaires au minimum
CREATE PROCEDURE PI_CollecteurMin(IN quantiteCollecteur SMALLINT, IN codeInseeCollecteur CHAR(5), IN createurCollecteur VARCHAR(20), IN globalIdCollecteur VARCHAR(38),
									IN _xCollecteur FLOAT, IN _yCollecteur FLOAT, IN idTri SMALLINT)
	CALL PI_CollecteurSimple(NULL, NULL, quantiteCollecteur, NULL, NULL, NULL, codeInseeCollecteur, NULL, createurCollecteur, globalIdCollecteur, _xCollecteur, _yCollecteur, NULL, idTri, NULL);

-- RETRIEVE

# Affiche le collecteur d'identifiant idCollecteur
CREATE PROCEDURE PSGetCollecteur(IN objectidCollecteur SMALLINT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE objectid = objectidCollecteur$$

# Affiche tous les collecteurs
CREATE PROCEDURE PL_Collecteur()
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur$$

# Affiche les collecteurs selon le volume
CREATE PROCEDURE PL_CollecteurByVolume(IN volumeCollecteur SMALLINT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE volume = volumeCollecteur$$

# Affiche les collecteurs selon la quantité
CREATE PROCEDURE PL_CollecteurByQuantite(IN quantiteCollecteur SMALLINT)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE quantite = quantiteCollecteur$$

# Affiche les collecteurs selon la date d'installation
CREATE PROCEDURE PL_CollecteurByDateInstallation(IN dateInstallationCollecteur DATE)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE dateInstallation = dateInstallationCollecteur$$

# Affiche les collecteurs installés après dateDebut et avant dateFin
CREATE PROCEDURE PL_CollecteurByDateInstallationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE dateInstallation BETWEEN dateDebut AND dateFin$$

# Affiche les collecteurs selon l'adresse
-- (qui contiennent adresseCollecteur dans leur adresse) 
CREATE PROCEDURE PL_CollecteurByAdresse(IN adresseCollecteur VARCHAR(50))
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE adresse LIKE CONCAT('%', adresseCollecteur, '%')$$

# Affiche les collecteurs selon le code INSEE
CREATE PROCEDURE PL_CollecteurByCodeInsee(IN codeInseeCollecteur CHAR(5))
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE codeInsee = codeInseeCollecteur$$

# Affiche les collecteurs enregistrés par createurCollecteur
CREATE PROCEDURE PL_CollecteurByCreateur(IN createurCollecteur VARCHAR(20))
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    WHERE createur = createurCollecteur$$

# Affiche les collecteurs selon la date de création de la ligne
CREATE PROCEDURE PL_CollecteurByDateCreation(IN dateCreationCollecteur DATE)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur 
    # où la date de création se situe entre le jour indiqué (dateCreationCollecteur à minuit) et le jour suivant (minuit) pour comprendre la journée entière
    WHERE dateCreation BETWEEN dateCreationCollecteur AND DATE_ADD(dateCreationCollecteur, INTERVAL 1 DAY)$$

# Affiche les collecteurs dont les lignes ont été créées entre dateDebut et dateFin (inclus)
CREATE PROCEDURE PL_CollecteurByDateCreationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    WHERE dateInstallation BETWEEN dateDebut AND DATE_ADD(dateFin, INTERVAL 1 DAY)$$

# Affiche les collecteurs modifiés en dernier par modificateurCollecteur
CREATE PROCEDURE PL_CollecteurByModificateur(IN modificateurCollecteur VARCHAR(20))
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    WHERE modificateur = modificateurCollecteur$$

# Affiche les collecteurs selon la dernière date de modification de la ligne
CREATE PROCEDURE PL_CollecteurByDateModification(IN dateModificationCollecteur DATE)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    # où la date de création se situe entre le jour indiqué (dateCreationDecheterie à minuit) et le jour suivant (minuit) pour comprendre la journée entière
    WHERE dateModification BETWEEN dateModificationCollecteur AND DATE_ADD(dateModificationCollecteur, INTERVAL 1 DAY)$$

# Affiche les collecteurs dont les lignes ont été dernièrement modifiées entre dateDebut et dateFin (inclus)
CREATE PROCEDURE PL_CollecteurByDateModificationInterval(IN dateDebut DATE, IN dateFin DATE)
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    WHERE dateModification BETWEEN dateDebut AND DATE_ADD(dateFin, INTERVAL 1 DAY)$$    

# Affiche le collecteur d'UUID globalid
CREATE PROCEDURE PL_CollecteurByGlobalid(IN globalidCollecteur VARCHAR(38))
	SELECT objectid, id, volume, quantite, dateInstallation, adresse, adresseComplement, codeInsee, observations, createur, dateCreation, modificateur, dateModification, globalid, _x, _y, idCategorie, idtri, idMarque FROM collecteur
    WHERE globalid = globalidCollecteur$$    
    
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