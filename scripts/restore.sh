#!/bin/sh
# Restaure la base à partir d'un fichier de sauvegarde.
# Utilisation : sh /scripts/restore.sh /backups/stageflow_AAAAMMJJ_HHMMSS.sql.gz
set -eu

if [ $# -ne 1 ]; then
  echo "Utilisation : restore.sh <fichier .sql.gz>"
  exit 1
fi

# la sauvegarde contient "DROP TABLE" puis "CREATE TABLE" : les tables actuelles sont remplacées
gunzip -c "$1" | mysql -h "$MYSQL_HOST" -u root "$MYSQL_DATABASE"
echo "Base restaurée depuis : $1"
