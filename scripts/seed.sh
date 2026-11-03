#!/usr/bin/env bash
# Ajoute des candidatures FICTIVES (entreprises inventées) pour avoir une démo remplie.
set -euo pipefail

BASE="${BASE_URL:-http://localhost:8080}"

post() {
  curl -fsS -o /dev/null -X POST "$BASE/api/applications" -H 'Content-Type: application/json' -d "$1"
}

post '{"company":"Acme Logiciels","position":"Développeur Java","location":"Bordeaux","applicationDate":"2026-10-12","status":"INTERVIEW","notes":"Entretien technique prévu la semaine prochaine."}'
post '{"company":"Exemple Cloud","position":"Stagiaire DevOps","location":"Paris","applicationDate":"2026-10-15","status":"APPLIED","notes":"Relancer dans une semaine."}'
post '{"company":"Démo Systèmes","position":"Développeur full-stack","location":"Toulouse","applicationDate":"2026-10-20","status":"TO_APPLY","notes":"Adapter la lettre de motivation."}'
post '{"company":"Société Fictive","position":"Ingénieur logiciel","location":"Lyon","applicationDate":"2026-09-30","status":"REJECTED","notes":"Réponse négative."}'
post '{"company":"Test & Cie","position":"Développeur backend","location":"Nantes","applicationDate":"2026-10-05","status":"ACCEPTED","notes":"Offre reçue."}'

echo "5 candidatures fictives ajoutées."
