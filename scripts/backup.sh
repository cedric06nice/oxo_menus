#!/bin/bash
# OXO Menus - Backup Script
# Creates backups of Directus data and uploads

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

echo "💾 OXO Menus Backup Script"
echo "=========================="
echo ""

# Create backup directory
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="oxo_menus_backup_$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

mkdir -p "$BACKUP_PATH"

print_info "Creating backup: $BACKUP_NAME"
echo ""

# Check if Directus is running
if ! docker-compose ps directus | grep -q "Up"; then
    print_warning "Directus is not running. Starting it temporarily..."
    docker-compose up -d directus
    sleep 5
fi

# Backup database
print_info "Backing up database..."
docker-compose exec -T directus sqlite3 /directus/database/data.db .dump > "$BACKUP_PATH/database.sql"
print_success "Database backed up: database.sql"

# Backup uploads
print_info "Backing up uploads..."
docker cp oxo_menus_directus:/directus/uploads "$BACKUP_PATH/uploads" 2>/dev/null || {
    print_warning "No uploads found (this is normal for new installations)"
}

# Create backup info file
cat > "$BACKUP_PATH/backup_info.txt" <<EOF
OXO Menus Backup
================

Backup Date: $(date)
Backup Name: $BACKUP_NAME

Contents:
- database.sql: SQLite database dump
- uploads/: User uploaded files

Restore Instructions:
1. Stop services: ./scripts/stop.sh
2. Restore: ./scripts/restore.sh $BACKUP_NAME
3. Start services: ./scripts/start.sh
EOF

print_success "Backup info created: backup_info.txt"

# Create compressed archive
print_info "Compressing backup..."
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"
cd ..

BACKUP_SIZE=$(du -h "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" | cut -f1)
print_success "Backup compressed: ${BACKUP_NAME}.tar.gz ($BACKUP_SIZE)"

echo ""
echo "========================================="
print_success "Backup completed successfully!"
echo "========================================="
echo ""
echo "Backup location: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "Backup size:     $BACKUP_SIZE"
echo ""
echo "To restore this backup:"
echo "  ./scripts/restore.sh $BACKUP_NAME"
echo ""
echo "To list all backups:"
echo "  ls -lh $BACKUP_DIR/"
echo ""
