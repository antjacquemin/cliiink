/*
 * Propositions de mise en place d'événements pour respecter les contraintes d'intégrité
 */
Use cliiink;

/*
 * Contraintes d'intégrité TABLE traitement
 * avec la modification ou la suppression des traitements lors de la modification ou de la suppression des déchèteries ou des déchets correspondants
 */

# Suppression des clés étrangères existantes
ALTER TABLE traitement 
	DROP FOREIGN KEY fk_traitement_dechet,
	DROP FOREIGN KEY fk_traitement_decheterie;

# Création des nouvelles clés étrangères avec événement lors de la suppresion ou de la mise à jour des clés primaires
ALTER TABLE traitement 
	ADD CONSTRAINT fk_traitement_dechet
		FOREIGN KEY (idDechet)
		REFERENCES dechet(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_traitement_decheterie
		FOREIGN KEY (objectidDecheterie)
		REFERENCES decheterie (objectid)
		ON DELETE CASCADE
		ON UPDATE CASCADE;

/*
 * Contraintes d'intégrité TABLE collecteur
 * avec la modification des collecteurs lors de la modification des types de collecteur, des marques ou des types de tri correspondants
 * avec la modification des collecteurs lors de la suppression des types de collecteur ou des marques correspondants (qui peuvent être NULL)
 * et la suppression des collecteurs lors de la suppression des types de tri correspondants (qui sont indispensables)
 *
 * Note : le dernier point peut être retiré (la contrainte redevenant RESTRICT) si la contrainte est considérée comme trop forte (la suppression d'un collecteur étant critique)
 */
 
# Suppression des clés étrangères existantes
ALTER TABLE collecteur 
	DROP FOREIGN KEY fk_collecteur_categorie,
	DROP FOREIGN KEY fk_collecteur_marque,
	DROP FOREIGN KEY fk_collecteur_tri;
    
# Création des nouvelles clés étrangères avec événement lors de la suppresion ou de la mise à jour des clés primaires
ALTER TABLE collecteur 
	ADD CONSTRAINT fk_collecteur_categorie
		FOREIGN KEY (idCategorie)
		REFERENCES categorie(id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_collecteur_marque
		FOREIGN KEY (idMarque)
		REFERENCES marque(id)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	ADD CONSTRAINT fk_collecteur_tri
		FOREIGN KEY (idTri)
		REFERENCES tri(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE;