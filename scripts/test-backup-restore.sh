#!/usr/bin/env bash
# Prouve que la sauvegarde SERT : crée une candidature, sauvegarde, la supprime, restaure, vérifie qu'elle est revenue.
# L'application doit déjà tourner (docker compose up -d).
set -euo pipefail

BASE="${BASE_URL:-http://localhost:8080}"
RUN=(docker compose --profile sauvegarde run --rm --no-deps --entrypoint sh backup)

echo "1. Création d'une candidature"
BODY='{"company":"Backup Test SA","position":"Testeur","applicationDate":"2026-01-01","status":"TO_APPLY"}'
RESPONSE=$(curl -fsS -X POST "$BASE/api/applications" -H 'Content-Type: application/json' -d "$BODY")
ID=$(echo "$RESPONSE" | sed -n 's/.*"id": *\([0-9]*\).*/\1/p')
[ -n "$ID" ] || { echo "ECHEC : pas d'identifiant"; exit 1; }

echo "2. Sauvegarde"
"${RUN[@]}" /scripts/backup.sh
FICHIER=$(find backups -name 'stageflow_*.sql.gz' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
echo "   fichier : $FICHIER"

echo "3. Suppression de la candidature (simulation d'une perte de données)"
curl -fsS -o /dev/null -X DELETE "$BASE/api/applications/$ID"
[ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/applications/$ID")" = "404" ] || { echo "ECHEC : suppression"; exit 1; }

echo "4. Restauration"
"${RUN[@]}" /scripts/restore.sh "/backups/$(basename "$FICHIER")"

echo "5. Vérification : la candidature est revenue"
curl -fsS "$BASE/api/applications" | grep -q 'Backup Test SA' || { echo "ECHEC : candidature absente après restauration"; exit 1; }

# nettoyage
curl -fsS -o /dev/null -X DELETE "$BASE/api/applications/$ID" || true
echo "OK : la sauvegarde et la restauration fonctionnent."
