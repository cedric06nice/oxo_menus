# OXO Menus - Directus Backend Setup Guide

This guide explains how to set up and configure Directus as the backend for OXO Menus.

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Initial Configuration](#initial-configuration)
4. [Schema Setup](#schema-setup)
5. [User Management](#user-management)
6. [Access Control](#access-control)
7. [API Configuration](#api-configuration)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### What is Directus?

Directus is an open-source headless CMS that provides:
- **RESTful API** for data access
- **Admin interface** for data management
- **User authentication** and authorization
- **Flexible data modeling** with custom fields
- **File management** for images and uploads

### Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (OXO Menus)    │
└────────┬────────┘
         │ REST API
         │
┌────────▼────────┐
│    Directus     │
│   API Server    │
└────────┬────────┘
         │
┌────────▼────────┐
│    Database     │
│ (SQLite/MySQL/  │
│   PostgreSQL)   │
└─────────────────┘
```

### OXO Menus Collections

The application uses these Directus collections:

| Collection | Purpose | Key Fields |
|-----------|---------|------------|
| `menu` | Menu templates and instances | id, name, status, version, style_json |
| `page` | Pages within menus | id, menu_id, name, index |
| `container` | Sections on pages | id, page_id, index, layout_json |
| `column` | Columns in containers | id, container_id, index, flex, width |
| `widget` | Widget instances | id, column_id, type, version, props |

---

## Installation

### Option 1: Docker (Recommended)

Use the included `docker-compose.yml`:

```bash
# Start Directus and database
docker-compose up -d directus

# View logs
docker-compose logs -f directus

# Access admin panel
open http://localhost:8055
```

### Option 2: Manual Installation

#### Prerequisites

- Node.js 18+ and npm
- Database (PostgreSQL, MySQL, or SQLite)

#### Install Directus

```bash
# Install Directus globally
npm install -g directus

# Create project directory
mkdir oxo-menus-backend
cd oxo-menus-backend

# Initialize Directus
npx directus init

# Follow prompts:
# - Database: Choose your database type
# - Admin Email: your-email@example.com
# - Admin Password: choose a strong password

# Start Directus
npx directus start
```

### Verify Installation

1. Open browser to http://localhost:8055
2. Log in with admin credentials
3. You should see the Directus admin interface

---

## Initial Configuration

### 1. Environment Variables

Edit `.env` file in Directus directory:

```env
####################################################################################################
## General

KEY="your-random-key-here"
SECRET="your-random-secret-here"

####################################################################################################
## Database

DB_CLIENT="sqlite3"
DB_FILENAME="./data.db"

# For PostgreSQL:
# DB_CLIENT="pg"
# DB_HOST="localhost"
# DB_PORT="5432"
# DB_DATABASE="oxo_menus"
# DB_USER="directus"
# DB_PASSWORD="your-password"

####################################################################################################
## Security

CORS_ENABLED="true"
CORS_ORIGIN="*"
# In production, set specific origin:
# CORS_ORIGIN="https://your-app.com"

####################################################################################################
## Admin Account

ADMIN_EMAIL="admin@example.com"
ADMIN_PASSWORD="your-secure-password"

####################################################################################################
## Server

PUBLIC_URL="http://localhost:8055"
# In production:
# PUBLIC_URL="https://api.your-domain.com"

####################################################################################################
## Files & Uploads

STORAGE_LOCATIONS="local"
STORAGE_LOCAL_ROOT="./uploads"
FILE_METADATA_ALLOW_LIST="*"

####################################################################################################
## Rate Limiting

RATE_LIMITER_ENABLED="true"
RATE_LIMITER_POINTS="50"
RATE_LIMITER_DURATION="1"

####################################################################################################
## Cache

CACHE_ENABLED="true"
CACHE_TTL="10m"
```

### 2. Generate Secure Keys

Generate random keys for `KEY` and `SECRET`:

```bash
# Linux/macOS
openssl rand -base64 32

# Or use Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

### 3. Restart Directus

```bash
# If using Docker
docker-compose restart directus

# If manual installation
npx directus restart
```

---

## Schema Setup

### Automated Schema Import

The recommended way to set up the schema is using Directus snapshots.

#### 1. Create Schema Snapshot File

Create a file `directus-schema.json` with the following content:

```json
{
  "version": 1,
  "directus": "10.x.x",
  "collections": [
    {
      "collection": "menu",
      "meta": {
        "collection": "menu",
        "icon": "restaurant_menu",
        "note": "Menu templates and instances",
        "display_template": "{{name}}",
        "hidden": false,
        "singleton": false,
        "translations": null,
        "archive_field": null,
        "archive_app_filter": true,
        "archive_value": null,
        "unarchive_value": null,
        "sort_field": null,
        "accountability": "all",
        "color": null,
        "item_duplication_fields": null,
        "sort": 1,
        "group": null,
        "collapse": "open"
      },
      "schema": {
        "name": "menu"
      }
    },
    {
      "collection": "page",
      "meta": {
        "collection": "page",
        "icon": "description",
        "note": "Pages within menus",
        "display_template": "{{name}}",
        "hidden": false,
        "singleton": false,
        "translations": null,
        "archive_field": null,
        "archive_app_filter": true,
        "archive_value": null,
        "unarchive_value": null,
        "sort_field": "index",
        "accountability": "all",
        "color": null,
        "item_duplication_fields": null,
        "sort": 2,
        "group": null,
        "collapse": "open"
      },
      "schema": {
        "name": "page"
      }
    },
    {
      "collection": "container",
      "meta": {
        "collection": "container",
        "icon": "view_agenda",
        "note": "Containers/sections on pages",
        "display_template": "Container {{index}}",
        "hidden": false,
        "singleton": false,
        "translations": null,
        "archive_field": null,
        "archive_app_filter": true,
        "archive_value": null,
        "unarchive_value": null,
        "sort_field": "index",
        "accountability": "all",
        "color": null,
        "item_duplication_fields": null,
        "sort": 3,
        "group": null,
        "collapse": "open"
      },
      "schema": {
        "name": "container"
      }
    },
    {
      "collection": "column",
      "meta": {
        "collection": "column",
        "icon": "view_column",
        "note": "Columns within containers",
        "display_template": "Column {{index}}",
        "hidden": false,
        "singleton": false,
        "translations": null,
        "archive_field": null,
        "archive_app_filter": true,
        "archive_value": null,
        "unarchive_value": null,
        "sort_field": "index",
        "accountability": "all",
        "color": null,
        "item_duplication_fields": null,
        "sort": 4,
        "group": null,
        "collapse": "open"
      },
      "schema": {
        "name": "column"
      }
    },
    {
      "collection": "widget",
      "meta": {
        "collection": "widget",
        "icon": "widgets",
        "note": "Widget instances in columns",
        "display_template": "{{type}} widget",
        "hidden": false,
        "singleton": false,
        "translations": null,
        "archive_field": null,
        "archive_app_filter": true,
        "archive_value": null,
        "unarchive_value": null,
        "sort_field": "index",
        "accountability": "all",
        "color": null,
        "item_duplication_fields": null,
        "sort": 5,
        "group": null,
        "collapse": "open"
      },
      "schema": {
        "name": "widget"
      }
    }
  ],
  "fields": [
    // Menu fields
    {
      "collection": "menu",
      "field": "id",
      "type": "uuid",
      "schema": {
        "is_primary_key": true,
        "has_auto_increment": false
      },
      "meta": {
        "hidden": true,
        "readonly": true,
        "interface": "input",
        "special": ["uuid"]
      }
    },
    {
      "collection": "menu",
      "field": "status",
      "type": "string",
      "schema": {
        "default_value": "draft",
        "is_nullable": false
      },
      "meta": {
        "interface": "select-dropdown",
        "options": {
          "choices": [
            {"text": "Draft", "value": "draft"},
            {"text": "Published", "value": "published"},
            {"text": "Archived", "value": "archived"}
          ]
        },
        "width": "half",
        "display": "labels"
      }
    },
    {
      "collection": "menu",
      "field": "name",
      "type": "string",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "input",
        "required": true,
        "width": "full"
      }
    },
    {
      "collection": "menu",
      "field": "version",
      "type": "string",
      "schema": {
        "default_value": "1.0.0"
      },
      "meta": {
        "interface": "input",
        "width": "half"
      }
    },
    {
      "collection": "menu",
      "field": "style_json",
      "type": "json",
      "schema": {},
      "meta": {
        "interface": "input-code",
        "options": {
          "language": "json"
        }
      }
    },
    {
      "collection": "menu",
      "field": "area",
      "type": "string",
      "schema": {},
      "meta": {
        "interface": "input",
        "width": "half"
      }
    },
    {
      "collection": "menu",
      "field": "size",
      "type": "json",
      "schema": {},
      "meta": {
        "interface": "input-code",
        "options": {
          "language": "json"
        }
      }
    },
    // Page fields
    {
      "collection": "page",
      "field": "id",
      "type": "uuid",
      "schema": {
        "is_primary_key": true
      },
      "meta": {
        "hidden": true,
        "readonly": true,
        "special": ["uuid"]
      }
    },
    {
      "collection": "page",
      "field": "menu_id",
      "type": "uuid",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "select-dropdown-m2o",
        "required": true,
        "special": ["m2o"]
      }
    },
    {
      "collection": "page",
      "field": "name",
      "type": "string",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "input",
        "required": true
      }
    },
    {
      "collection": "page",
      "field": "index",
      "type": "integer",
      "schema": {
        "is_nullable": false,
        "default_value": 0
      },
      "meta": {
        "interface": "input",
        "required": true
      }
    },
    // Container fields
    {
      "collection": "container",
      "field": "id",
      "type": "uuid",
      "schema": {
        "is_primary_key": true
      },
      "meta": {
        "hidden": true,
        "readonly": true,
        "special": ["uuid"]
      }
    },
    {
      "collection": "container",
      "field": "page_id",
      "type": "uuid",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "select-dropdown-m2o",
        "required": true,
        "special": ["m2o"]
      }
    },
    {
      "collection": "container",
      "field": "index",
      "type": "integer",
      "schema": {
        "is_nullable": false,
        "default_value": 0
      },
      "meta": {
        "interface": "input"
      }
    },
    {
      "collection": "container",
      "field": "name",
      "type": "string",
      "schema": {},
      "meta": {
        "interface": "input"
      }
    },
    {
      "collection": "container",
      "field": "layout_json",
      "type": "json",
      "schema": {},
      "meta": {
        "interface": "input-code",
        "options": {
          "language": "json"
        }
      }
    },
    // Column fields
    {
      "collection": "column",
      "field": "id",
      "type": "uuid",
      "schema": {
        "is_primary_key": true
      },
      "meta": {
        "hidden": true,
        "readonly": true,
        "special": ["uuid"]
      }
    },
    {
      "collection": "column",
      "field": "container_id",
      "type": "uuid",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "select-dropdown-m2o",
        "required": true,
        "special": ["m2o"]
      }
    },
    {
      "collection": "column",
      "field": "index",
      "type": "integer",
      "schema": {
        "is_nullable": false,
        "default_value": 0
      },
      "meta": {
        "interface": "input"
      }
    },
    {
      "collection": "column",
      "field": "flex",
      "type": "integer",
      "schema": {},
      "meta": {
        "interface": "input"
      }
    },
    {
      "collection": "column",
      "field": "width",
      "type": "float",
      "schema": {},
      "meta": {
        "interface": "input"
      }
    },
    // Widget fields
    {
      "collection": "widget",
      "field": "id",
      "type": "uuid",
      "schema": {
        "is_primary_key": true
      },
      "meta": {
        "hidden": true,
        "readonly": true,
        "special": ["uuid"]
      }
    },
    {
      "collection": "widget",
      "field": "column_id",
      "type": "uuid",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "select-dropdown-m2o",
        "required": true,
        "special": ["m2o"]
      }
    },
    {
      "collection": "widget",
      "field": "type",
      "type": "string",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "select-dropdown",
        "options": {
          "choices": [
            {"text": "Dish", "value": "dish"},
            {"text": "Section", "value": "section"},
            {"text": "Text", "value": "text"},
            {"text": "Image", "value": "image"}
          ]
        }
      }
    },
    {
      "collection": "widget",
      "field": "version",
      "type": "string",
      "schema": {
        "default_value": "1.0.0"
      },
      "meta": {
        "interface": "input"
      }
    },
    {
      "collection": "widget",
      "field": "index",
      "type": "integer",
      "schema": {
        "is_nullable": false,
        "default_value": 0
      },
      "meta": {
        "interface": "input"
      }
    },
    {
      "collection": "widget",
      "field": "props",
      "type": "json",
      "schema": {
        "is_nullable": false
      },
      "meta": {
        "interface": "input-code",
        "options": {
          "language": "json"
        },
        "required": true
      }
    },
    {
      "collection": "widget",
      "field": "style_json",
      "type": "json",
      "schema": {},
      "meta": {
        "interface": "input-code",
        "options": {
          "language": "json"
        }
      }
    }
  ],
  "relations": [
    {
      "collection": "page",
      "field": "menu_id",
      "related_collection": "menu",
      "meta": {
        "one_field": "pages",
        "sort_field": "index",
        "junction_field": null
      },
      "schema": {
        "on_delete": "CASCADE"
      }
    },
    {
      "collection": "container",
      "field": "page_id",
      "related_collection": "page",
      "meta": {
        "one_field": "containers",
        "sort_field": "index",
        "junction_field": null
      },
      "schema": {
        "on_delete": "CASCADE"
      }
    },
    {
      "collection": "column",
      "field": "container_id",
      "related_collection": "container",
      "meta": {
        "one_field": "columns",
        "sort_field": "index",
        "junction_field": null
      },
      "schema": {
        "on_delete": "CASCADE"
      }
    },
    {
      "collection": "widget",
      "field": "column_id",
      "related_collection": "column",
      "meta": {
        "one_field": "widgets",
        "sort_field": "index",
        "junction_field": null
      },
      "schema": {
        "on_delete": "CASCADE"
      }
    }
  ]
}
```

#### 2. Apply Schema

**Via Directus CLI**:
```bash
# Import schema
npx directus schema apply --yes ./directus-schema.json
```

**Via Directus Admin UI**:
1. Log into Directus admin
2. Go to Settings → Data Model
3. Click "Import Schema"
4. Upload `directus-schema.json`
5. Click "Apply"

#### 3. Verify Schema

1. Go to Content in Directus admin
2. You should see: menu, page, container, column, widget collections
3. Open each collection to verify fields

---

## User Management

### Creating Users

#### Via Admin UI

1. Go to User Directory
2. Click "Create User"
3. Fill in details:
   - Email
   - Password
   - First Name / Last Name
   - Role (see below)
4. Click "Save"

#### User Roles

**Admin Role** (full access):
- Can create/edit/delete templates
- Can modify system settings
- Can manage other users
- Can see all menus

**User Role** (restricted):
- Can create menus from templates
- Can only see published templates
- Can only see own menus
- Cannot access admin settings

### Setting Up Roles

#### 1. Create "Admin" Role

1. Go to Settings → Roles & Permissions
2. Click "Create Role"
3. Name: "Admin"
4. Admin Access: ✓ Enabled
5. Save

#### 2. Create "User" Role

1. Go to Settings → Roles & Permissions
2. Click "Create Role"
3. Name: "User"
4. Configure permissions (see [Access Control](#access-control))
5. Save

---

## Access Control

### Permissions Configuration

#### Menu Collection

**Admin**:
- Create: ✓
- Read: ✓ All
- Update: ✓ All
- Delete: ✓ All

**User**:
- Create: ✓
- Read: ✓ (Filter: `status = published` OR `user_created = $CURRENT_USER`)
- Update: ✓ (Filter: `user_created = $CURRENT_USER`)
- Delete: ✓ (Filter: `user_created = $CURRENT_USER`)

#### Page, Container, Column Collections

**Admin**:
- Full access (CRUD all)

**User**:
- Create: ✓
- Read: ✓ (via menu relation)
- Update: ✓ (Filter: menu's `user_created = $CURRENT_USER`)
- Delete: ✓ (Filter: menu's `user_created = $CURRENT_USER`)

#### Widget Collection

**Admin**:
- Full access (CRUD all)

**User**:
- Create: ✓
- Read: ✓ (via menu relation)
- Update: ✓ (Filter: menu's `user_created = $CURRENT_USER`)
- Delete: ✓ (Filter: menu's `user_created = $CURRENT_USER`)

### Setting Permissions

1. Go to Settings → Roles & Permissions
2. Select role (Admin or User)
3. For each collection, click to configure
4. Set permissions as described above
5. Use filters for conditional access
6. Save changes

---

## API Configuration

### CORS Settings

For the Flutter app to connect, configure CORS:

```env
# Allow all origins (development only!)
CORS_ENABLED=true
CORS_ORIGIN=*

# Production (specific origin)
CORS_ENABLED=true
CORS_ORIGIN=https://your-app.com,https://admin.your-app.com
```

### Rate Limiting

Prevent API abuse:

```env
RATE_LIMITER_ENABLED=true
RATE_LIMITER_POINTS=50      # Max requests
RATE_LIMITER_DURATION=1     # Per minute
```

### File Uploads

Configure storage for images:

```env
STORAGE_LOCATIONS=local
STORAGE_LOCAL_ROOT=./uploads
FILE_METADATA_ALLOW_LIST=*
MAX_PAYLOAD_SIZE=10mb
```

### API Endpoints

The Flutter app uses these endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/login` | POST | User login |
| `/auth/logout` | POST | User logout |
| `/auth/refresh` | POST | Refresh token |
| `/users/me` | GET | Get current user |
| `/items/menu` | GET, POST | List/create menus |
| `/items/menu/:id` | GET, PATCH, DELETE | Get/update/delete menu |
| `/items/page` | GET, POST | List/create pages |
| `/items/container` | GET, POST | List/create containers |
| `/items/column` | GET, POST | List/create columns |
| `/items/widget` | GET, POST | List/create widgets |

---

## Troubleshooting

### Directus Won't Start

**Check logs**:
```bash
docker-compose logs directus
# or
npx directus logs
```

**Common issues**:
- Database connection failed: Check DB credentials
- Port 8055 in use: Change `PORT` in `.env`
- Permission denied: Check file permissions

### Schema Import Failed

**Error**: "Collection already exists"

**Solution**:
```bash
# Drop existing collections first
npx directus database migrate:latest --down

# Then re-import schema
npx directus schema apply ./directus-schema.json
```

### API Returns 401 Unauthorized

**Possible causes**:
- Token expired
- Invalid credentials
- CORS not configured

**Solutions**:
1. Check CORS settings in `.env`
2. Verify user credentials
3. Check token expiration settings
4. Review access permissions

### Can't Create Menu Items

**Check**:
1. User has correct role and permissions
2. Collection permissions are set
3. Relational fields have proper settings
4. Database constraints are satisfied

### File Uploads Fail

**Check**:
```env
STORAGE_LOCATIONS=local
STORAGE_LOCAL_ROOT=./uploads
MAX_PAYLOAD_SIZE=10mb
FILE_METADATA_ALLOW_LIST=*
```

**Verify**:
- Upload directory exists and is writable
- File size under MAX_PAYLOAD_SIZE
- Correct permissions on storage folder

---

## Maintenance

### Backup Database

**SQLite**:
```bash
# Backup
cp ./data.db ./backups/data_$(date +%Y%m%d).db

# Or via docker
docker cp oxo_menus_directus:/directus/database/data.db ./backups/
```

**PostgreSQL**:
```bash
pg_dump -U directus oxo_menus > backup_$(date +%Y%m%d).sql
```

### Update Directus

**Docker**:
```bash
docker-compose pull directus
docker-compose up -d directus
```

**Manual**:
```bash
npm update -g directus
npx directus database migrate:latest
```

### Monitor Performance

```bash
# Check API response times
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8055/server/ping

# Monitor database size
du -sh ./data.db

# Check logs for slow queries
docker-compose logs directus | grep "WARN"
```

---

## Next Steps

1. ✅ Directus installed and configured
2. ✅ Schema applied
3. ✅ Users and roles set up
4. → Connect Flutter app (see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md))
5. → Create first menu template
6. → Test API integration

## Resources

- [Directus Documentation](https://docs.directus.io)
- [Directus API Reference](https://docs.directus.io/reference/introduction)
- [OXO Menus User Guide](USER_GUIDE.md)
- [OXO Menus Developer Guide](DEVELOPER_GUIDE.md)

---

**Version**: 1.0.0
**Last Updated**: January 2024
