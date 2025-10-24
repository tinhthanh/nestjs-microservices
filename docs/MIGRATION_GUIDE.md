# Database Migration Guide

Complete guide for managing database migrations in the microservices architecture.

## Table of Contents

- [Overview](#overview)
- [Migration Architecture](#migration-architecture)
- [Creating Migrations](#creating-migrations)
- [Running Migrations](#running-migrations)
- [Migration Best Practices](#migration-best-practices)
- [Common Scenarios](#common-scenarios)
- [Troubleshooting](#troubleshooting)

---

## Overview

### Multi-Schema Architecture

The project uses **Database per Service pattern** with PostgreSQL schemas:

```
PostgreSQL Database: postgres
├── auth_schema
│   ├── users
│   └── third_party_integrations
└── post_schema
    └── posts
```

### Migration Tools

- **Prisma Migrate**: Schema migration tool
- **Centralized Migrations**: `migrations/` folder for unified schema management
- **Service-Specific Migrations**: Each service has its own `prisma/migrations/` folder

---

## Migration Architecture

### Directory Structure

```
nestjs-microservices/
├── migrations/                    # Centralized migrations
│   ├── prisma/
│   │   ├── schema.prisma         # Combined schema for all services
│   │   └── migrations/           # Migration history
│   ├── sync-schemas.sh           # Sync script
│   └── migrate-multi-schema.sh   # Migration script
├── auth/
│   ├── prisma/
│   │   ├── schema.prisma         # Auth service schema (auth_schema)
│   │   └── migrations/           # Auth migrations
│   └── docker-entrypoint.sh      # Runs migrations on container start
└── post/
    ├── prisma/
    │   ├── schema.prisma         # Post service schema (post_schema)
    │   └── migrations/           # Post migrations
    └── docker-entrypoint.sh      # Runs migrations on container start
```

### Schema Configuration

#### Centralized Schema (`migrations/prisma/schema.prisma`)

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["multiSchema"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["auth_schema", "post_schema"]
}

model User {
  id          String    @id @default(uuid())
  email       String    @unique
  // ... other fields
  @@map("users")
  @@schema("auth_schema")
}

model Post {
  id        String    @id @default(uuid())
  // ... other fields
  @@map("posts")
  @@schema("post_schema")
}
```

#### Service Schema (`auth/prisma/schema.prisma`)

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["multiSchema"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["auth_schema"]
}

model User {
  id          String    @id @default(uuid())
  email       String    @unique
  // ... other fields
  @@map("users")
  @@schema("auth_schema")
}
```

---

## Creating Migrations

### Step 1: Modify Schema

Edit the Prisma schema file for the service you want to change:

```bash
# For Auth service
vim auth/prisma/schema.prisma

# For Post service
vim post/prisma/schema.prisma
```

Example: Add a new field to User model

```prisma
model User {
  id          String    @id @default(uuid())
  email       String    @unique
  password    String?
  firstName   String?   @map("first_name")
  lastName    String?   @map("last_name")
  phoneNumber String?   @map("phone_number")  // NEW FIELD
  // ... other fields
  
  @@map("users")
  @@schema("auth_schema")
}
```

### Step 2: Create Migration (Development)

```bash
# For Auth service
cd auth
yarn prisma:migrate:local

# For Post service
cd post
yarn prisma:migrate:local
```

Prisma will:
1. Detect schema changes
2. Prompt for migration name
3. Generate SQL migration file
4. Apply migration to database

### Step 3: Sync to Centralized Migrations

```bash
cd migrations
./sync-schemas.sh
```

This script:
1. Copies models from service schemas to centralized schema
2. Adds proper schema annotations
3. Maintains preview features

### Step 4: Commit Changes

```bash
git add auth/prisma/migrations/
git add migrations/prisma/schema.prisma
git commit -m "feat: add phone_number field to User model"
```

---

## Running Migrations

### Development Environment

Migrations run automatically when starting the environment:

```bash
./dev.sh
```

To run migrations manually:

```bash
# Using service containers
docker exec bw-auth-service sh -c "yarn prisma:migrate:dev"
docker exec bw-post-service sh -c "yarn prisma:migrate:dev"

# Using local Prisma CLI
cd auth
yarn prisma:migrate:local

cd ../post
yarn prisma:migrate:local
```

### Production Environment

**✅ Migrations run automatically** via Docker entrypoint scripts when containers start.

#### Automatic Migration on Container Start

```bash
# Start production environment (migrations run automatically)
./prod.sh

# Verify migrations
docker exec bw-postgres psql -U admin -d postgres -c "SELECT migration_name, finished_at FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 5;"
```

#### Manual Migration (if needed)

```bash
# Restart services to trigger migrations
docker restart bw-auth-service bw-post-service

# Or run migrations manually
docker exec bw-auth-service sh -c "yarn prisma:migrate:prod"
docker exec bw-post-service sh -c "yarn prisma:migrate:prod"

# Verify
docker exec bw-postgres psql -U admin -d postgres -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname IN ('auth_schema', 'post_schema') ORDER BY schemaname, tablename;"
```

### Verify Migrations

```bash
# Check migration history
docker exec bw-postgres psql -U admin -d postgres -c "SELECT migration_name, finished_at, applied_steps_count FROM _prisma_migrations ORDER BY finished_at DESC;"

# Check tables
docker exec bw-postgres psql -U admin -d postgres -c "\dt auth_schema.*"
docker exec bw-postgres psql -U admin -d postgres -c "\dt post_schema.*"

# Check specific table structure
docker exec bw-postgres psql -U admin -d postgres -c "\d auth_schema.users"
```

---

## Migration Best Practices

### 1. Always Test Migrations Locally First

```bash
# Test in development
./dev-stop.sh
docker-compose -f docker-compose.dev.yml down -v  # Clean slate
./dev.sh
./dev.run  # Verify tests pass
```

### 2. Use Descriptive Migration Names

```bash
# Good
yarn prisma migrate dev --name add_phone_number_to_users
yarn prisma migrate dev --name create_posts_table
yarn prisma migrate dev --name add_index_to_email

# Bad
yarn prisma migrate dev --name update
yarn prisma migrate dev --name fix
```

### 3. Review Generated SQL

Always review the generated SQL before applying:

```bash
# View migration SQL
cat auth/prisma/migrations/20251024_add_phone_number/migration.sql
```

### 4. Backup Before Production Migrations

```bash
# Backup database
docker exec bw-postgres pg_dump -U admin -d postgres > backup_$(date +%Y%m%d_%H%M%S).sql

# Or use Docker volume backup
docker run --rm -v nestjs-microservices_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz /data
```

### 5. Use Transactions for Complex Migrations

Prisma migrations are transactional by default, but for complex changes:

```sql
-- migrations/20251024_complex_change/migration.sql
BEGIN;

-- Your migration steps here
ALTER TABLE auth_schema.users ADD COLUMN phone_number TEXT;
CREATE INDEX idx_users_phone ON auth_schema.users(phone_number);

COMMIT;
```

### 6. Handle Data Migrations Separately

For migrations that require data transformation:

```bash
# 1. Create schema migration
yarn prisma migrate dev --name add_full_name_column

# 2. Create data migration script
cat > migrations/data-migrations/20251024_populate_full_name.js << 'EOF'
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany();
  
  for (const user of users) {
    await prisma.user.update({
      where: { id: user.id },
      data: {
        fullName: `${user.firstName} ${user.lastName}`.trim()
      }
    });
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
EOF

# 3. Run data migration
docker exec bw-auth-service sh -c "cd /app && node /path/to/data-migration.js"
```

---

## Common Scenarios

### Scenario 1: Add New Table

```bash
# 1. Edit schema
vim auth/prisma/schema.prisma

# Add new model
model RefreshToken {
  id        String   @id @default(uuid())
  token     String   @unique
  userId    String   @map("user_id")
  expiresAt DateTime @map("expires_at")
  createdAt DateTime @default(now()) @map("created_at")
  
  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("refresh_tokens")
  @@schema("auth_schema")
}

# 2. Create migration
cd auth
yarn prisma:migrate:local

# 3. Sync to centralized
cd ../migrations
./sync-schemas.sh

# 4. Test
cd ..
./dev-stop.sh && ./dev.sh && ./dev.run
```

### Scenario 2: Add Column with Default Value

```bash
# 1. Edit schema
vim post/prisma/schema.prisma

# Add field with default
model Post {
  // ... existing fields
  viewCount Int @default(0) @map("view_count")  // NEW
}

# 2. Create migration
cd post
yarn prisma:migrate:local

# 3. Sync and test
cd ../migrations && ./sync-schemas.sh
cd .. && ./dev-stop.sh && ./dev.sh && ./dev.run
```

### Scenario 3: Rename Column

```bash
# 1. Edit schema (use @map to avoid data loss)
model User {
  phoneNumber String? @map("phone")  // Rename from phone_number to phone
}

# 2. Create migration
cd auth
yarn prisma:migrate:local

# Prisma will generate:
# ALTER TABLE auth_schema.users RENAME COLUMN phone_number TO phone;

# 3. Sync and test
cd ../migrations && ./sync-schemas.sh
cd .. && ./dev-stop.sh && ./dev.sh && ./dev.run
```

### Scenario 4: Add Foreign Key

```bash
# 1. Edit schema
model Post {
  // ... existing fields
  authorId String @map("author_id")
  author   User   @relation(fields: [authorId], references: [id])
}

# 2. Create migration
cd post
yarn prisma:migrate:local

# 3. Sync and test
cd ../migrations && ./sync-schemas.sh
cd .. && ./dev-stop.sh && ./dev.sh && ./dev.run
```

---

## Troubleshooting

### Issue: Migration Fails with "Table already exists"

**Cause**: Migration already applied or manual table creation.

**Solution**:
```bash
# Mark migration as applied without running
docker exec bw-auth-service sh -c "yarn prisma migrate resolve --applied <migration_name>"

# Or reset database (DEVELOPMENT ONLY)
docker-compose -f docker-compose.dev.yml down -v
./dev.sh
```

### Issue: "Schema drift detected"

**Cause**: Database schema doesn't match Prisma schema.

**Solution**:
```bash
# Development: Reset and re-migrate
docker-compose -f docker-compose.dev.yml down -v
./dev.sh

# Production: Create new migration to fix drift
cd auth
yarn prisma migrate dev --create-only
# Review and edit generated SQL
yarn prisma migrate deploy
```

### Issue: Prisma Client Out of Sync

**Cause**: Prisma client not regenerated after schema changes.

**Solution**:
```bash
# Regenerate client
docker exec bw-auth-service sh -c "yarn prisma:generate"
docker exec bw-post-service sh -c "yarn prisma:generate"

# Restart services
docker restart bw-auth-service bw-post-service
```

### Issue: Migration Fails in Production

**Cause**: Various reasons (constraints, data issues, etc.).

**Solution**:
```bash
# 1. Check migration logs
docker logs bw-auth-service

# 2. Check database state
docker exec bw-postgres psql -U admin -d postgres -c "SELECT * FROM _prisma_migrations WHERE migration_name = '<failed_migration>';"

# 3. Mark as rolled back
docker exec bw-auth-service sh -c "yarn prisma migrate resolve --rolled-back <migration_name>"

# 4. Fix issue and re-run
docker exec bw-auth-service sh -c "yarn prisma:migrate:prod"
```

---

## Quick Reference

### Development Workflow

```bash
# 1. Edit schema
vim auth/prisma/schema.prisma

# 2. Create migration
cd auth && yarn prisma:migrate:local

# 3. Sync to centralized
cd ../migrations && ./sync-schemas.sh

# 4. Test
cd .. && ./dev-stop.sh && ./dev.sh && ./dev.run

# 5. Commit
git add . && git commit -m "feat: add new field"
```

### Production Deployment

```bash
# 1. Deploy code
git pull origin main

# 2. Rebuild and start (migrations run automatically)
./prod.sh

# 3. Verify migrations
docker exec bw-postgres psql -U admin -d postgres -c "SELECT migration_name FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 5;"

# 4. Test
./prod.run
```

---

## Related Documentation

- [Setup Guide](./SETUP_GUIDE.md)
- [Database Architecture](../DATABASE_ARCHITECTURE.md)
- [Deployment Guide](../DEPLOYMENT_GUIDE.md)

