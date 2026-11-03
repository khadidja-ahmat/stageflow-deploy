#!/usr/bin/env bash
# Test de bout en bout : attend que l'application réponde, puis crée, lit et supprime une candidature.
set -euo pipefail

BASE="${BASE_URL:-http://localhost:8080}"

echo "Attente de l'application sur $BASE ..."
for i in $(seq 1 60); do
  if [ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/applications")" = "200" ]; then
    echo "L'application répond (tentative $i)."
    break
  fi
  if [ "$i" = "60" ]; then echo "ECHEC : l'application ne répond pas."; exit 1; fi
  sleep 3
done

echo "Test : la page d'accueil (frontend) est servie"
curl -fsS "$BASE/" | grep -q '<div id="root"' || { echo "ECHEC : page d'accueil inattendue"; exit 1; }

echo "Test : création d'une candidature"
BODY='{"company":"Smoke Test SA","position":"Testeur","applicationDate":"2026-01-01","status":"TO_APPLY"}'
RESPONSE=$(curl -fsS -X POST "$BASE/api/applications" -H 'Content-Type: application/json' -d "$BODY")
ID=$(echo "$RESPONSE" | sed -n 's/.*"id": *\([0-9]*\).*/\1/p')
[ -n "$ID" ] || { echo "ECHEC : pas d'identifiant dans la réponse : $RESPONSE"; exit 1; }

echo "Test : la candidature $ID est dans la liste"
curl -fsS "$BASE/api/applications" | grep -q 'Smoke Test SA' || { echo "ECHEC : candidature absente de la liste"; exit 1; }

echo "Test : suppression"
[ "$(curl -s -o /dev/null -w '%{http_code}' -X DELETE "$BASE/api/applications/$ID")" = "204" ] || { echo "ECHEC : suppression"; exit 1; }
[ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/api/applications/$ID")" = "404" ] || { echo "ECHEC : la candidature existe encore"; exit 1; }

echo "OK : tous les tests de bout en bout passent."
