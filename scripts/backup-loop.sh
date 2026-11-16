#!/bin/sh
# Lance une sauvegarde au démarrage, puis une toutes les BACKUP_INTERVAL secondes.
while true; do
  sh /scripts/backup.sh || echo "Échec de la sauvegarde"
  sleep "${BACKUP_INTERVAL:-86400}"
done
