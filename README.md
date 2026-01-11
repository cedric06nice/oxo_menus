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
- 📋 Browse published menu templates
- ✏️ Create menus from templates
- 🎨 Customize styling (colors, fonts, spacing)
- 🍽️ Add dish widgets with prices, descriptions, allergens
- 📝 Add sections, text, and images
- 📄 Generate professional PDF menus
- 💾 Save and manage personal menus

### For Administrators
- 🏗️ Create and edit menu templates
- 📐 Define page layouts (pages, containers, columns)
- 🎯 Publish templates for users
- 👥 Manage users and permissions
- ⚙️ Configure system settings

### Technical Features
- 🧪 78.59% test coverage with 417 passing tests
- 🏛️ Clean Architecture with domain-driven design
- 🔄 State management with Riverpod
- 🎨 Extensible widget system
- 🐳 Docker deployment ready
- 🚀 CI/CD with GitHub Actions
- 📚 Comprehensive documentation

## Quick Start

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24.0+)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (for backend)
- Git

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd oxo_menus

# Run setup script (recommended)
./scripts/setup.sh

# Or manually:
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
cp .env.example .env
```

### Running the Application

```bash
# Start backend services
./scripts/start.sh

# Run the app in development mode
./scripts/dev.sh --watch

# Or run Flutter directly
flutter run -d chrome --dart-define=DIRECTUS_URL=http://localhost:8055
```

The application will be available at:
- **Web App**: http://localhost:8080 (if using Docker)
- **Directus Admin**: http://localhost:8055

**Default Credentials**:
- Email: `admin@example.com`
- Password: `admin`

⚠️ **Change these credentials immediately!**

## Project Structure

```
oxo_menus/
├── lib/
│   ├── core/              # Core utilities (errors, result type)
│   ├── domain/            # Business logic (entities, repositories, use cases)
│   ├── data/              # Data layer (DTOs, mappers, implementations)
│   └── presentation/      # UI (pages, widgets, providers)
├── test/
│   ├── unit/              # Unit tests
│   ├── widget/            # Widget tests
│   └── integration_test/  # Integration tests
├── scripts/               # Deployment and utility scripts
├── docs/                  # Documentation
└── docker-compose.yml     # Docker services configuration
```

## Scripts

Helper scripts for common tasks:

| Script | Purpose |
|--------|---------|
| `./scripts/setup.sh` | Initial project setup |
| `./scripts/start.sh` | Start backend services |
| `./scripts/stop.sh` | Stop services |
| `./scripts/dev.sh` | Development mode with hot reload |
| `./scripts/test.sh` | Run tests (with coverage option) |
| `./scripts/build.sh` | Build for production |
| `./scripts/backup.sh` | Backup database and uploads |
| `./scripts/restore.sh` | Restore from backup |

See [scripts/README.md](scripts/README.md) for detailed usage.

## Development

### Code Generation

The project uses code generation for Freezed, JSON serialization, and Riverpod:

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
./scripts/test.sh

# With coverage
./scripts/test.sh --coverage

# Unit tests only
./scripts/test.sh --unit

# Specific file
./scripts/test.sh --file test/unit/domain/usecases/fetch_menu_tree_usecase_test.dart
```

**Current Coverage**: 78.59% (1,813 / 2,307 lines)

### Code Quality

```bash
# Check linting issues
flutter analyze

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

### Building

```bash
# Web
./scripts/build.sh --platform web

# Android APK
./scripts/build.sh --platform apk

# Android App Bundle (for Play Store)
./scripts/build.sh --platform appbundle

# iOS (macOS only)
./scripts/build.sh --platform ios
```

## Documentation

Comprehensive documentation is available:

- **[USER_GUIDE.md](USER_GUIDE.md)** - User documentation (how to use the app)
- **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - Technical documentation for developers
- **[DIRECTUS_SETUP.md](DIRECTUS_SETUP.md)** - Backend setup and configuration
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment guide with Docker
- **[scripts/README.md](scripts/README.md)** - Helper scripts documentation
- **[CLAUDE.md](CLAUDE.md)** - Complete migration guide and architecture

## Architecture

OXO Menus follows **Clean Architecture** with three main layers:

### Domain Layer (Business Logic)
- Pure Dart, no external dependencies
- Entities, repository interfaces, use cases
- Result type for error handling

### Data Layer (Data Access)
- Repository implementations
- DTOs (Data Transfer Objects)
- Directus API integration
- Error mapping

### Presentation Layer (UI)
- Flutter widgets and pages
- Riverpod state management
- Widget system with registry
- PDF generation

**Key Principles**:
- Dependency inversion (dependencies point inward)
- Test-Driven Development (TDD)
- Railway-oriented programming (Result type)
- Immutability (Freezed entities)

## Technology Stack

- **Frontend**: Flutter 3.24.0, Dart 3.0+
- **State Management**: Riverpod
- **Backend**: Directus (headless CMS)
- **Database**: SQLite (development), PostgreSQL/MySQL (production)
- **API**: RESTful API via directus_api_manager
- **PDF**: pdf package with custom rendering
- **Testing**: flutter_test, mocktail
- **Code Generation**: freezed, json_serializable, riverpod_generator
- **CI/CD**: GitHub Actions
- **Deployment**: Docker, nginx

## Contributing

1. Read the [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow TDD (write tests first!)
4. Run tests and linting (`./scripts/test.sh && flutter analyze`)
5. Commit with conventional commits (`feat: add amazing feature`)
6. Push and create a Pull Request

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Troubleshooting

### Common Issues

**Build runner fails**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Docker services won't start**:
```bash
docker-compose down -v
docker-compose up -d --build
```

**API returns 401**:
- Check `DIRECTUS_URL` in environment
- Verify Directus is running
- Check CORS settings in Directus

**Tests fail**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for more troubleshooting tips.

## License

This project is proprietary software. All rights reserved.

## Support

For issues and questions:
- Check documentation in `docs/` directory
- Review [Troubleshooting](#troubleshooting) section
- Contact the development team

## Roadmap

- [x] Phase 1-14: Foundation, domain, data, widget system, testing
- [x] Phase 15: Deployment setup, CI/CD, documentation
- [ ] Phase 16+: Additional features, mobile optimizations, performance tuning

## Acknowledgments

Built with:
- [Flutter](https://flutter.dev) - UI framework
- [Directus](https://directus.io) - Headless CMS
- [Riverpod](https://riverpod.dev) - State management
- [Freezed](https://pub.dev/packages/freezed) - Code generation
- [PDF](https://pub.dev/packages/pdf) - PDF generation

---

**Version**: 1.0.0
**Last Updated**: January 2024

For detailed information, see the [documentation](docs/) directory.
