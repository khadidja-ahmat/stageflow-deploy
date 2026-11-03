# stageflow-deploy

Pipeline **DevOps** pour [StageFlow](https://github.com/khadidja-ahmat/StageFlow), mon application de suivi de candidatures de stage
(Java 21, Spring Boot, React, MySQL).

Ce dépôt ne contient **pas** le code de l'application : il contient tout ce qui permet de la **construire, la lancer, la tester et la livrer**
automatiquement. Le code de StageFlow est récupéré depuis son propre dépôt (séparation entre le code applicatif et le déploiement).

[![CI/CD](https://github.com/khadidja-ahmat/stageflow-deploy/actions/workflows/ci.yml/badge.svg)](https://github.com/khadidja-ahmat/stageflow-deploy/actions/workflows/ci.yml)

## Le pipeline

```text
git push ─▶ GitHub Actions
              1. récupère le code de StageFlow
              2. construit les images Docker (backend, frontend)
              3. démarre toute l'application (MySQL + backend + frontend)
              4. test de bout en bout : créer, lire, supprimer une candidature
              5. branche main uniquement : publie les images sur ghcr.io
```

```text
Navigateur ─▶ [ frontend : nginx + React ] ─ /api ─▶ [ backend : Spring Boot ] ─▶ [ db : MySQL + volume ]
```

| Fichier | Rôle |
|---|---|
| `Dockerfile.backend` | compile avec Maven (JDK 21), puis image finale légère avec le JRE seul, sans root |
| `Dockerfile.frontend` | build React avec Node, puis nginx qui sert le site et redirige `/api` vers le backend |
| `nginx.conf` | configuration du serveur web et du proxy vers le backend |
| `docker-compose.yml` | 3 services ; MySQL démarre d'abord (healthcheck), données persistantes (volume) |
| `scripts/smoke-test.sh` | test de bout en bout, utilisé en local et dans la CI |
| `scripts/seed.sh` | ajoute des candidatures **fictives** pour avoir une démo remplie |
| `.github/workflows/ci.yml` | le pipeline ci-dessus |

## Lancer en local

Prérequis : Docker et Git.

```bash
git clone https://github.com/khadidja-ahmat/stageflow-deploy.git
cd stageflow-deploy
git clone https://github.com/khadidja-ahmat/StageFlow.git stageflow   # le code de l'application
docker compose up --build
```

L'application est disponible sur <http://localhost:8080>.

```bash
./scripts/smoke-test.sh   # vérifie que tout fonctionne
./scripts/seed.sh         # ajoute 5 candidatures fictives
```

Arrêt : `docker compose down` (ajouter `-v` pour supprimer aussi les données).
Le mot de passe MySQL est une valeur de démonstration locale ; il peut être changé avec `MYSQL_ROOT_PASSWORD=... docker compose up --build`.

## Images publiées

Après un push sur `main`, les images sont disponibles sur GitHub Container Registry :

- `ghcr.io/khadidja-ahmat/stageflow-deploy/backend`
- `ghcr.io/khadidja-ahmat/stageflow-deploy/frontend`

Chaque image porte le tag `latest` et un tag `stageflow-<commit>` qui indique la version de StageFlow utilisée.

## Choix et limites

- **Aucune donnée réelle** : la démo utilise uniquement des candidatures fictives.
- StageFlow n'a pas d'authentification : cette configuration est prévue pour un usage local ou de démonstration, pas pour un hébergement public.
- Pas de déploiement sur un serveur pour l'instant : la livraison s'arrête à la publication des images. Une étape de déploiement (SSH sur un VPS, par exemple) pourrait être ajoutée.

## Auteur

Khadidja Ahmat Hassan
