# OXO Menus - Deployment Guide

This guide covers deploying the OXO Menus application locally using Docker.

## Prerequisites

- Docker Desktop installed ([download here](https://www.docker.com/products/docker-desktop))
- Docker Compose (included with Docker Desktop)
- At least 4GB of free disk space

## Quick Start (Local Development)

### 1. Start All Services

```bash
# Start both Directus backend and web app
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### 2. Access the Application

- **Web App**: http://localhost:8080
- **Directus Admin**: http://localhost:8055

### 3. Initial Directus Setup

On first run, Directus will be accessible at http://localhost:8055.

**Default Credentials**:
- Email: `admin@example.com`
- Password: `admin`

**IMPORTANT**: Change these credentials immediately in production!

### 4. Configure Directus Schema

The application requires specific Directus collections. Import the schema:

1. Log into Directus admin panel
2. Go to Settings → Data Model
3. Import the schema from `directus-schema.json` (see [Directus Setup Guide](DIRECTUS_SETUP.md))

### 5. Stop Services

```bash
# Stop services but keep data
docker-compose stop

# Stop and remove containers (keeps volumes)
docker-compose down

# Stop and remove everything including data
docker-compose down -v
```

## Environment Configuration

### Development Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your settings:

```env
# Directus Configuration
DIRECTUS_URL=http://localhost:8055
DIRECTUS_KEY=your-random-key-here
DIRECTUS_SECRET=your-random-secret-here
DIRECTUS_ADMIN_EMAIL=admin@example.com
DIRECTUS_ADMIN_PASSWORD=your-secure-password

# Database (SQLite for local, Postgres/MySQL for production)
DB_CLIENT=sqlite3
DB_FILENAME=/directus/database/data.db
```

### Production Environment

For production, use a proper database and secure credentials:

```env
# Directus Configuration
DIRECTUS_URL=https://api.yourdomain.com
DIRECTUS_KEY=<generate-with-openssl-rand-base64-32>
DIRECTUS_SECRET=<generate-with-openssl-rand-base64-32>

# PostgreSQL Database
DB_CLIENT=postgres
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=oxo_menus
DB_USER=directus
DB_PASSWORD=<secure-password>
```

## Building for Production

### Build Web App Only

```bash
# Build web app with production settings
flutter build web --release --dart-define=DIRECTUS_URL=https://your-production-url.com

# Output will be in build/web/
```

### Build Docker Image

```bash
# Build with custom Directus URL
docker build --build-arg DIRECTUS_URL=https://your-api.com -t oxo-menus-web .

# Run the container
docker run -d -p 8080:80 --name oxo-menus oxo-menus-web
```

## CI/CD with GitHub Actions

The repository includes GitHub Actions workflows for automated testing and building.

### Setup GitHub Secrets

Add these secrets to your GitHub repository:

1. Go to Settings → Secrets and variables → Actions
2. Add the following secrets:

```
DIRECTUS_URL=https://your-production-directus.com
```

### Workflow Triggers

The CI pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

### Pipeline Stages

1. **Analyze & Lint**: Code formatting and static analysis
2. **Test**: Run all tests with coverage reporting
3. **Build Web**: Build Flutter web app
4. **Build Android**: Build Android APK
5. **Build iOS**: Build iOS app (macOS runner)

### Artifacts

Build artifacts are uploaded and available for download:
- Web build (7 days retention)
- Android APK (7 days retention)

## Health Checks

### Web App Health Check

```bash
curl http://localhost:8080/health
# Expected: "healthy"
```

### Directus Health Check

```bash
curl http://localhost:8055/server/health
# Expected: JSON response with status "ok"
```

## Troubleshooting

### Directus Not Starting

**Issue**: Directus container exits immediately

**Solution**:
```bash
# Check logs
docker-compose logs directus

# Verify database permissions
docker-compose down -v
docker-compose up -d
```

### Web App Shows Connection Error

**Issue**: Web app cannot connect to Directus

**Solution**:
1. Verify Directus is running: `docker-compose ps`
2. Check DIRECTUS_URL in environment
3. Ensure CORS is enabled in Directus
4. Check network connectivity: `docker-compose exec web ping directus`

### Build Fails with "Out of Memory"

**Solution**:
Increase Docker memory allocation in Docker Desktop settings (recommended: 4GB+)

### Port Already in Use

**Issue**: Port 8080 or 8055 already in use

**Solution**:
Edit `docker-compose.yml` to use different ports:
```yaml
ports:
  - "8081:80"  # Change 8080 to 8081
```

## Performance Optimization

### Enable Gzip Compression

Already configured in `nginx.conf`. Reduces asset sizes by ~70%.

### Enable Browser Caching

Static assets cached for 1 year (configured in nginx).

### Production Database

For production, use PostgreSQL or MySQL instead of SQLite:

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: oxo_menus
      POSTGRES_USER: directus
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  directus:
    environment:
      DB_CLIENT: postgres
      DB_HOST: postgres
      DB_PORT: 5432
      DB_DATABASE: oxo_menus
      DB_USER: directus
      DB_PASSWORD: ${DB_PASSWORD}
```

## Monitoring

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
docker-compose logs -f directus

# Last 100 lines
docker-compose logs --tail=100 web
```

### Resource Usage

```bash
# Check CPU/memory usage
docker stats

# Container details
docker-compose ps
```

## Backup and Restore

### Backup Directus Data

```bash
# Backup database
docker-compose exec directus sqlite3 /directus/database/data.db .dump > backup.sql

# Backup uploads
docker cp oxo_menus_directus:/directus/uploads ./uploads_backup
```

### Restore Directus Data

```bash
# Restore database
cat backup.sql | docker-compose exec -T directus sqlite3 /directus/database/data.db

# Restore uploads
docker cp ./uploads_backup oxo_menus_directus:/directus/uploads
```

## Security Checklist

- [ ] Change default Directus admin password
- [ ] Generate random KEY and SECRET for Directus
- [ ] Use HTTPS in production (configure reverse proxy)
- [ ] Enable Directus access control
- [ ] Restrict CORS origins in production
- [ ] Keep Docker images updated
- [ ] Use environment variables for sensitive data
- [ ] Enable firewall rules
- [ ] Regular backups

## Next Steps

1. Configure Directus collections (see [DIRECTUS_SETUP.md](DIRECTUS_SETUP.md))
2. Read user documentation (see [USER_GUIDE.md](USER_GUIDE.md))
3. Read developer documentation (see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md))

## Support

For issues and questions:
- Check [Troubleshooting](#troubleshooting) section
- Review [Directus documentation](https://docs.directus.io)
- Review [Flutter documentation](https://docs.flutter.dev)
