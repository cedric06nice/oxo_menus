# OXO Menus

A professional menu template builder and PDF generator built with Flutter and Directus.

## Overview

OXO Menus is a comprehensive menu management application that allows:
- **Admins** to create reusable menu templates with customizable layouts
- **Users** to create menus from templates by adding and editing widgets
- **Everyone** to generate beautiful, print-ready PDF menus

Built with Clean Architecture, Test-Driven Development, and modern Flutter best practices.

## Features

### For Regular Users
- Browse published menu templates
- Create menus from templates
- Customize styling (colors, fonts, spacing)
- Add dish widgets with prices, descriptions, allergens
- Add sections, text, wine, and image widgets
- Generate professional PDF menus
- Real-time collaboration with presence tracking

### For Administrators
- Create and edit menu templates
- Define page layouts (pages, containers, columns)
- Publish templates for users
- Manage page sizes
- Configure system settings

### Technical Highlights
- Clean Architecture with domain-driven design
- State management with Riverpod
- Extensible widget plugin system (dish, section, text, wine, image)
- Real-time collaboration via WebSockets
- Connectivity monitoring with auto-retry
- UK FSA allergen compliance
- CI/CD with GitHub Actions
- Docker deployment with blue/green strategy

## Getting Started

### Prerequisites

- Flutter SDK >= 3.8.0 (stable channel)
- Dart SDK >= 3.11.0
- Docker & Docker Compose (for local Directus backend)

### Local Development

```bash
# Clone and install dependencies
git clone <repo-url>
cd oxo_menus
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run with local Directus
flutter run --dart-define=DIRECTUS_URL=http://localhost:8055

# Run tests
flutter test
```

## Deployment

### VPS Setup

The `deploy/` folder is self-contained. Copy it to your VPS to set up the infrastructure:

```bash
# 1. Copy deploy files to VPS
scp -r deploy/* directus@<VPS_HOST>:~/oxo-menus/

# 2. SSH into VPS
ssh directus@<VPS_HOST>
cd ~/oxo-menus

# 3. Configure environment
cp .env.example .env
# Edit .env with your actual values (see .env Reference below)

# 4. Create the external Docker network
docker network create oxo-network

# 5. Start all services
docker compose up -d
```

This starts:
- **Traefik** reverse proxy with automatic Let's Encrypt TLS
- **PostgreSQL** databases (production + dev)
- **Directus** CMS instances (production + dev)
- **Flutter Web** blue/green production slots

### GitHub Variables

Configure this variable in your GitHub repository (Settings > Secrets and variables > Actions > Variables):

| Variable | Description |
|----------|-------------|
| `DOMAIN_FLUTTER_PROD` | Production Flutter domain (e.g. `oxo-menus.your-domain.com`) — used for PR preview comment URLs |

### GitHub Secrets

Configure these secrets in your GitHub repository (Settings > Secrets and variables > Actions > Secrets):

| Secret | Description |
|--------|-------------|
| `DIRECTUS_URL_DEV` | Dev Directus API URL (e.g. `https://api-dev.your-domain.com`) |
| `DIRECTUS_URL_PROD` | Production Directus API URL (e.g. `https://api.your-domain.com`) |
| `VPS_HOST` | VPS IP address or hostname |
| `SSH_PRIVATE_KEY` | SSH private key for the `directus` user on the VPS |
| `MATCH_GIT_URL` | Fastlane Match certificates repo URL |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64-encoded `user:token` for Match repo |
| `MATCH_PASSWORD` | Encryption password for Match certificates |
| `ASC_KEY_ID` | Apple App Store Connect API key ID |
| `ASC_ISSUER_ID` | Apple App Store Connect issuer ID |
| `ASC_KEY_CONTENT` | Apple App Store Connect API key content (`.p8` file contents) |

`GITHUB_TOKEN` is automatically provided by GitHub Actions.

### CI/CD Pipeline

Workflow (daily practice)
```
  git checkout -b feature/my-change main
  # ... work, commit ...
  git push origin feature/my-change
  # Open PR → CI runs → review → merge to main → auto-deploy
```

The CI/CD uses reusable workflows (prefixed with `_`) called by two orchestrators:

```
.github/
  actions/
    setup-flutter/action.yml    # Composite: resolve version + SDK + pub get + build_runner
  workflows/
    _ci.yml                     # Reusable: analyze + test (75% coverage gate)
    _build-web-docker.yml       # Reusable: flutter build web -> Docker ARM64 -> artifact
    _deploy-vps.yml             # Reusable: SCP image + SSH run script
    _build-apple.yml            # Reusable: iOS + macOS matrix via Fastlane
    _build-android.yml          # Reusable: APK build + artifact upload
    pr.yml                      # PR orchestrator
    deploy.yml                  # Production orchestrator
    cleanup.yml                 # PR preview cleanup
```

**PR Pipeline** (`pr.yml` — on pull_request to `main`):
1. **CI** — lint, format check, analyze, test with coverage gate
2. **Build Web** — Flutter web build, Docker ARM64 image, upload artifact
3. **Deploy Preview** — SCP image to VPS, run `pr-deploy.sh`
4. **Comment PR** — post preview URL on the pull request
5. **Build Mobile** (optional, `deploy-mobile` label) — iOS/macOS TestFlight + Android APK

**Production Pipeline** (`deploy.yml` — on push to `main`):
1. **CI** — same analyze + test
2. **Version** — semantic version bump + git tag
3. **Build Web** — Docker image with version tag
4. **Deploy Web** — blue/green switch on VPS
5. **Build Apple** — iOS + macOS App Store release
6. **Build Android** — APK artifact
7. **GitHub Release** — create release with changelog + APK
8. **Export Schema** — snapshot Directus schema as artifact

**Cleanup** (`cleanup.yml` — on PR close):
- Removes the preview container and image from VPS

### .env Reference

All variables for `deploy/.env` on the VPS:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ACME_EMAIL` | Yes | — | Email for Let's Encrypt certificate registration |
| `DOMAIN_FLUTTER_PROD` | Yes | — | Production Flutter web domain (e.g. `oxo-menus.your-domain.com`) |
| `DOMAIN_API_PROD` | Yes | — | Production Directus API domain (e.g. `api.your-domain.com`) |
| `DOMAIN_API_DEV` | Yes | — | Dev Directus API domain (e.g. `api-dev.your-domain.com`) |
| `PROD_DB_PASSWORD` | Yes | — | Production PostgreSQL password |
| `PROD_DIRECTUS_KEY` | Yes | — | Production Directus app key (UUID) |
| `PROD_DIRECTUS_SECRET` | Yes | — | Production Directus app secret (UUID) |
| `PROD_ADMIN_EMAIL` | No | `admin@example.com` | Production Directus admin email |
| `PROD_ADMIN_PASSWORD` | Yes | — | Production Directus admin password |
| `PROD_DB_NAME` | No | `directus_prod` | Production database name |
| `PROD_DB_USER` | No | `directus` | Production database user |
| `DEV_DB_PASSWORD` | Yes | — | Dev PostgreSQL password |
| `DEV_DIRECTUS_KEY` | Yes | — | Dev Directus app key (UUID) |
| `DEV_DIRECTUS_SECRET` | Yes | — | Dev Directus app secret (UUID) |
| `DEV_ADMIN_EMAIL` | No | `admin@example.com` | Dev Directus admin email |
| `DEV_ADMIN_PASSWORD` | Yes | — | Dev Directus admin password |
| `DEV_DB_NAME` | No | `directus_dev` | Dev database name |
| `DEV_DB_USER` | No | `directus` | Dev database user |
| `BLUE_ENABLED` | No | `true` | Enable blue production slot |
| `GREEN_ENABLED` | No | `false` | Enable green production slot |

### Blue/Green Deployment

Production uses a blue/green strategy managed by `deploy/scripts/blue-green-switch.sh`:

1. New Docker image is loaded
2. The inactive slot is enabled, the active slot is disabled (via `.env`)
3. Both containers are recreated
4. Health check verifies the new slot
5. On success: slot file updated, image cleanup
6. On failure: automatic rollback to previous slot

The active slot is tracked in `~/oxo-menus/.active-slot`.

### PR Previews

Each PR gets a preview deployment at `https://pr-<number>.<DOMAIN_FLUTTER_PROD>/`. The preview container runs on the VPS alongside production, routed by Traefik with automatic TLS. Previews are cleaned up when the PR is closed.
