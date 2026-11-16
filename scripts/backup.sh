#!/bin/sh
# Fait UNE sauvegarde de la base StageFlow dans /backups et supprime les anciennes.
set -eu

DOSSIER=/backups
FICHIER="$DOSSIER/stageflow_$(date +%Y%m%d_%H%M%S).sql.gz"

# mysqldump écrit toute la base en texte SQL, qu'on compresse avec gzip
mysqldump -h "$MYSQL_HOST" -u root --single-transaction "$MYSQL_DATABASE" | gzip > "$FICHIER"
echo "Sauvegarde créée : $FICHIER"

# suppression des sauvegardes plus vieilles que BACKUP_RETENTION_DAYS jours
find "$DOSSIER" -name 'stageflow_*.sql.gz' -mtime +"${BACKUP_RETENTION_DAYS:-7}" -delete
