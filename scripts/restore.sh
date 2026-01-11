#!/bin/bash
# OXO Menus - Restore Script
# Restores Directus data from backup

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo "♻️  OXO Menus Restore Script"
echo "============================"
echo ""

# Check argument
if [ $# -eq 0 ]; then
    echo "Usage: ./scripts/restore.sh BACKUP_NAME"
    echo ""
    echo "Available backups:"
    ls -1 backups/*.tar.gz 2>/dev/null | sed 's/backups\//  - /' | sed 's/.tar.gz//' || echo "  No backups found"
    echo ""
    echo "Example:"
    echo "  ./scripts/restore.sh oxo_menus_backup_20240111_120000"
    exit 1
fi

BACKUP_NAME="$1"
BACKUP_DIR="backups"
BACKUP_FILE="$BACKUP_DIR/${BACKUP_NAME}.tar.gz"

# Check if backup exists
if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup not found: $BACKUP_FILE"
    echo ""
    echo "Available backups:"
    ls -1 backups/*.tar.gz 2>/dev/null | sed 's/backups\//  - /' | sed 's/.tar.gz//' || echo "  No backups found"
    exit 1
fi

print_warning "WARNING: This will replace all current data with the backup!"
read -p "Are you sure you want to restore from $BACKUP_NAME? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Stop services
print_info "Stopping services..."
docker-compose down
print_success "Services stopped"

# Extract backup
print_info "Extracting backup..."
cd "$BACKUP_DIR"
tar -xzf "${BACKUP_NAME}.tar.gz"
cd ..
print_success "Backup extracted"

# Start Directus temporarily
print_info "Starting Directus..."
docker-compose up -d directus
sleep 5

# Restore database
print_info "Restoring database..."
cat "$BACKUP_DIR/$BACKUP_NAME/database.sql" | docker-compose exec -T directus sqlite3 /directus/database/data.db
print_success "Database restored"

# Restore uploads
if [ -d "$BACKUP_DIR/$BACKUP_NAME/uploads" ]; then
    print_info "Restoring uploads..."
    docker cp "$BACKUP_DIR/$BACKUP_NAME/uploads" oxo_menus_directus:/directus/
    print_success "Uploads restored"
else
    print_info "No uploads to restore"
fi

# Cleanup extracted backup
rm -rf "$BACKUP_DIR/$BACKUP_NAME"

# Restart services
print_info "Restarting services..."
docker-compose restart
print_success "Services restarted"

echo ""
echo "========================================="
print_success "Restore completed successfully!"
echo "========================================="
echo ""
echo "Services are running:"
echo "  - Directus: http://localhost:8055"
echo "  - Web App:  http://localhost:8080 (if started)"
echo ""
echo "View logs: ./scripts/logs.sh"
echo ""
