:: Script pour la maintenance de la BDD cliiink
mysqlcheck --login-path=myhostalias cliiink
mysqldump --login-path=myhostalias cliiink > sauvegardeCliiink.sql
mysql --login-path=myhostalias -A -Dsakila2 < sauvegardeSakila.sql