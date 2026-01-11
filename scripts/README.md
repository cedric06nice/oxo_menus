# OXO Menus - Deployment Scripts

This directory contains helper scripts for managing the OXO Menus application.

## Quick Reference

| Script | Purpose | Example |
|--------|---------|---------|
| [setup.sh](#setupsh) | Initial project setup | `./scripts/setup.sh` |
| [start.sh](#startsh) | Start services | `./scripts/start.sh --web` |
| [stop.sh](#stopsh) | Stop services | `./scripts/stop.sh` |
| [restart.sh](#restartsh) | Restart services | `./scripts/restart.sh` |
| [logs.sh](#logssh) | View service logs | `./scripts/logs.sh --directus` |
| [dev.sh](#devsh) | Development mode | `./scripts/dev.sh --watch` |
| [test.sh](#testsh) | Run tests | `./scripts/test.sh --coverage` |
| [build.sh](#buildsh) | Build for platforms | `./scripts/build.sh --platform web` |
| [backup.sh](#backupsh) | Backup data | `./scripts/backup.sh` |
| [restore.sh](#restoresh) | Restore data | `./scripts/restore.sh <backup_name>` |

---

## setup.sh

**Purpose**: Initial project setup - installs dependencies, runs code generation, creates .env file, and verifies installation.

**Usage**:
```bash
./scripts/setup.sh
```

**What it does**:
1. Checks prerequisites (Flutter, Docker)
2. Installs Flutter dependencies
3. Runs code generation
4. Creates .env from template
5. Runs tests
6. Checks code quality

**First time setup**: Run this before anything else!

---

## start.sh

**Purpose**: Starts backend services (Directus) and optionally the web app.

**Usage**:
```bash
# Start Directus only
./scripts/start.sh

# Start all services
./scripts/start.sh --web

# Rebuild and start all services
./scripts/start.sh --build-web

# Show help
./scripts/start.sh --help
```

**Options**:
- `--web` - Also start the web app container
- `--build-web` - Rebuild Docker images before starting

**Services started**:
- Directus backend at http://localhost:8055
- Web app at http://localhost:8080 (if `--web` used)

---

## stop.sh

**Purpose**: Stops all running services.

**Usage**:
```bash
# Stop services, keep data
./scripts/stop.sh

# Stop services and delete all data (WARNING!)
./scripts/stop.sh --remove-data

# Show help
./scripts/stop.sh --help
```

**Options**:
- `--remove-data` - Also removes all volumes (database, uploads)

**Warning**: Using `--remove-data` permanently deletes all menus, users, and uploads!

---

## restart.sh

**Purpose**: Restarts running services.

**Usage**:
```bash
# Quick restart
./scripts/restart.sh

# Rebuild and restart
./scripts/restart.sh --rebuild

# Show help
./scripts/restart.sh --help
```

**Options**:
- `--rebuild` - Rebuild Docker images before restarting

**Use case**: Apply configuration changes or clear service state.

---

## logs.sh

**Purpose**: View logs from running services.

**Usage**:
```bash
# Follow all service logs
./scripts/logs.sh

# Follow Directus logs only
./scripts/logs.sh --directus

# Show recent web logs (no follow)
./scripts/logs.sh --web --no-follow

# Show last 50 lines
./scripts/logs.sh --tail 50

# Show help
./scripts/logs.sh --help
```

**Options**:
- `--directus` - Show Directus logs only
- `--web` - Show web app logs only
- `--no-follow` - Don't follow logs (just show recent)
- `--tail N` - Show last N lines (default: 100)

**Tip**: Press Ctrl+C to exit follow mode.

---

## dev.sh

**Purpose**: Start development environment with hot reload.

**Usage**:
```bash
# Run on Chrome (default)
./scripts/dev.sh

# Run with code generation watch
./scripts/dev.sh --watch

# Run on specific device
./scripts/dev.sh --device macos

# Show help
./scripts/dev.sh --help
```

**Options**:
- `--device <name>` - Target device (chrome, macos, android, ios)
- `--watch` - Run build_runner in watch mode for auto code generation

**What it does**:
1. Checks if backend is running (starts if not)
2. Optionally starts build_runner watch
3. Runs Flutter app with hot reload enabled

**Hot reload shortcuts**:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

---

## test.sh

**Purpose**: Run tests with various options.

**Usage**:
```bash
# Run all tests
./scripts/test.sh

# Run with coverage report
./scripts/test.sh --coverage

# Run unit tests only
./scripts/test.sh --unit

# Run widget tests only
./scripts/test.sh --widget

# Run integration tests
./scripts/test.sh --integration

# Run specific test file
./scripts/test.sh --file test/unit/domain/usecases/fetch_menu_tree_usecase_test.dart

# Show help
./scripts/test.sh --help
```

**Options**:
- `--coverage` - Generate coverage report (HTML + summary)
- `--watch` - Watch mode (requires `entr` package)
- `--integration` - Run integration tests
- `--unit` - Run unit tests only
- `--widget` - Run widget tests only
- `--file PATH` - Run specific test file

**Coverage report**: When using `--coverage`, HTML report is generated at `coverage/html/index.html`

---

## build.sh

**Purpose**: Build the application for various platforms.

**Usage**:
```bash
# Build web (release)
./scripts/build.sh

# Build Android APK
./scripts/build.sh --platform apk

# Build Android App Bundle (for Play Store)
./scripts/build.sh --platform appbundle

# Build iOS (macOS only)
./scripts/build.sh --platform ios

# Build with custom Directus URL
./scripts/build.sh --directus-url https://api.example.com

# Build in debug mode
./scripts/build.sh --debug

# Show help
./scripts/build.sh --help
```

**Options**:
- `--platform <name>` - Target platform: `web`, `apk`, `appbundle`, `ios`
- `--directus-url <url>` - Backend URL (default: http://localhost:8055)
- `--debug` - Build in debug mode (default: release)

**Platforms**:
- `web` - Flutter web app (build/web/)
- `apk` - Android APK (build/app/outputs/flutter-apk/)
- `appbundle` - Android App Bundle for Play Store
- `ios` - iOS app (macOS only, requires Xcode)

**Output locations**:
- Web: `build/web/`
- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- Android AAB: `build/app/outputs/bundle/release/app-release.aab`
- iOS: `build/ios/iphoneos/`

---

## backup.sh

**Purpose**: Create backup of Directus database and uploads.

**Usage**:
```bash
./scripts/backup.sh
```

**What it does**:
1. Backs up SQLite database
2. Backs up uploaded files
3. Creates compressed archive (.tar.gz)
4. Saves to `backups/` directory

**Backup contents**:
- `database.sql` - SQLite dump
- `uploads/` - User uploaded files
- `backup_info.txt` - Backup metadata

**Backup naming**: `oxo_menus_backup_YYYYMMDD_HHMMSS.tar.gz`

**Schedule**: Run regularly (e.g., daily cron job) for production.

---

## restore.sh

**Purpose**: Restore data from backup.

**Usage**:
```bash
# List available backups
./scripts/restore.sh

# Restore specific backup
./scripts/restore.sh oxo_menus_backup_20240111_120000
```

**What it does**:
1. Stops services
2. Extracts backup archive
3. Restores database
4. Restores uploads
5. Restarts services

**Warning**: This replaces ALL current data with the backup!

**Confirmation**: Script asks for confirmation before proceeding.

---

## Common Workflows

### First Time Setup

```bash
# 1. Initial setup
./scripts/setup.sh

# 2. Start backend
./scripts/start.sh

# 3. Run development mode
./scripts/dev.sh --watch
```

### Daily Development

```bash
# Start dev environment with hot reload and code gen watch
./scripts/dev.sh --watch

# In another terminal, view logs
./scripts/logs.sh --directus
```

### Before Committing

```bash
# Run tests with coverage
./scripts/test.sh --coverage

# Check for linting issues
flutter analyze

# Format code
dart format .
```

### Production Build

```bash
# Build web app
./scripts/build.sh --platform web --directus-url https://api.example.com

# Output is in build/web/
```

### Backup Routine

```bash
# Create backup
./scripts/backup.sh

# Verify backup
ls -lh backups/

# If needed, restore
./scripts/restore.sh oxo_menus_backup_20240111_120000
```

### Troubleshooting

```bash
# View logs
./scripts/logs.sh

# Restart services
./scripts/restart.sh --rebuild

# Reset everything (WARNING: deletes data!)
./scripts/stop.sh --remove-data
./scripts/start.sh --build-web
```

---

## Requirements

**All scripts**:
- Bash shell
- Docker and Docker Compose (for service management)
- Flutter SDK (for build/dev/test scripts)

**Optional**:
- `entr` - For test watch mode (`brew install entr` on macOS)
- `lcov` - For HTML coverage reports (`brew install lcov` on macOS)

---

## Script Permissions

All scripts are already executable. If needed, make them executable with:

```bash
chmod +x scripts/*.sh
```

---

## Environment Variables

Scripts use the `.env` file for configuration. Key variables:

- `DIRECTUS_URL` - Backend URL
- `DIRECTUS_KEY` - Directus key (for Docker)
- `DIRECTUS_SECRET` - Directus secret (for Docker)

See `.env.example` for all available options.

---

## Troubleshooting

### "Permission denied"

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### "Docker is not running"

Start Docker Desktop before running scripts.

### "Command not found: flutter"

Install Flutter SDK: https://docs.flutter.dev/get-started/install

### "Port already in use"

Stop conflicting services or change ports in `docker-compose.yml`.

---

## Getting Help

Each script has a `--help` option:

```bash
./scripts/start.sh --help
./scripts/test.sh --help
./scripts/build.sh --help
# etc.
```

For more information, see:
- [DEPLOYMENT.md](../DEPLOYMENT.md) - Full deployment guide
- [DEVELOPER_GUIDE.md](../DEVELOPER_GUIDE.md) - Developer documentation
- [USER_GUIDE.md](../USER_GUIDE.md) - User documentation

---

**Happy coding! 🚀**
