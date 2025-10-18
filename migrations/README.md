# Centralized Database Migrations

## Overview

This directory contains the **single source of truth** for all database migrations across all microservices.

## Why Centralized?

- ✅ **Prevent data loss**: No service can accidentally drop tables from other services
- ✅ **Single migration history**: One timeline for all schema changes
- ✅ **Easier to manage**: All migrations in one place
- ✅ **Production safety**: Deploy all migrations together

## Structure

```
migrations/
├── prisma/
│   ├── schema.prisma      # Combined schema (all services)
│   └── migrations/        # All migration files
├── .env.local             # Local database URL
├── .env.docker            # Docker database URL
└── package.json           # Migration scripts
```

## Workflow

### 1. Development (Adding new tables/columns)

```bash
cd migrations

# Create a new migration
npm run migrate:dev -- --name add_new_feature

# This will:
# 1. Generate migration SQL
# 2. Apply to local database
# 3. Update Prisma Client
```

### 2. After Migration: Update Service Schemas

```bash
# Copy relevant models to service schemas
# Auth service: Copy User, ThirdPartyIntegration models
# Post service: Copy Post model

# Then regenerate Prisma clients in each service
cd ../auth && npm run prisma:generate:local
cd ../post && npm run prisma:generate:local
```

### 3. Production Deployment

```bash
cd migrations

# Check migration status
npm run migrate:status

# Deploy migrations
npm run migrate:deploy:prod
```

## Commands

| Command | Description |
|---------|-------------|
| `npm run migrate:dev` | Create and apply migration (dev) |
| `npm run migrate:deploy` | Apply pending migrations (local) |
| `npm run migrate:deploy:prod` | Apply pending migrations (prod) |
| `npm run migrate:status` | Check migration status |
| `npm run migrate:reset` | Reset database (⚠️ dev only) |
| `npm run generate` | Generate Prisma Client |
| `npm run studio` | Open Prisma Studio |

## Adding New Models

### Step 1: Add to centralized schema

Edit `migrations/prisma/schema.prisma`:

```prisma
model NewModel {
  id        String   @id @default(uuid())
  name      String
  createdAt DateTime @default(now())
  
  @@map("new_models")
}
```

### Step 2: Create migration

```bash
cd migrations
npm run migrate:dev -- --name add_new_model
```

### Step 3: Update service schema

Copy the model to the relevant service's `prisma/schema.prisma`:

```bash
# For auth service
cp migrations/prisma/schema.prisma auth/prisma/schema.prisma
# Then remove Post model (not needed in auth)

# For post service  
cp migrations/prisma/schema.prisma post/prisma/schema.prisma
# Then remove User, ThirdPartyIntegration models (not needed in post)
```

### Step 4: Regenerate Prisma clients

```bash
cd auth && npm run prisma:generate:local
cd ../post && npm run prisma:generate:local
```

## Production Deployment Process

### Pre-deployment Checklist

- [ ] All migrations tested locally
- [ ] Service schemas updated
- [ ] Prisma clients regenerated
- [ ] Tests passing
- [ ] Backup database

### Deployment Steps

```bash
# 1. Backup database
pg_dump -h <host> -U <user> -d <database> > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. Deploy migrations
cd migrations
npm run migrate:deploy:prod

# 3. Verify migration status
npm run migrate:status

# 4. Deploy services (they will use new schema)
docker-compose up -d --build
```

## Rollback Strategy

If migration fails:

```bash
# 1. Restore from backup
psql -h <host> -U <user> -d <database> < backup_YYYYMMDD_HHMMSS.sql

# 2. Fix migration issue
# Edit schema or create new migration

# 3. Re-deploy
npm run migrate:deploy:prod
```

## Best Practices

### ✅ DO

- Always create migrations from this directory
- Test migrations locally first
- Backup before production deployment
- Use descriptive migration names
- Keep service schemas in sync

### ❌ DON'T

- Don't create migrations from service directories
- Don't manually edit migration files
- Don't skip migrations
- Don't use `migrate reset` in production
- Don't deploy without testing

## Troubleshooting

### Migration drift detected

```bash
# This means service schemas are out of sync
# Solution: Reset and re-apply migrations
npm run migrate:reset
npm run migrate:deploy
```

### Service can't find table

```bash
# Service Prisma client is outdated
# Solution: Regenerate Prisma client
cd auth && npm run prisma:generate:local
cd ../post && npm run prisma:generate:local
```

### Migration failed in production

```bash
# 1. Check migration status
npm run migrate:status

# 2. Check database logs
docker logs bw-postgres

# 3. Restore from backup if needed
psql -h <host> -U <user> -d <database> < backup.sql
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: cd migrations && npm install
      
      - name: Run migrations
        run: cd migrations && npm run migrate:deploy:prod
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
      
      - name: Deploy services
        run: docker-compose up -d --build
```

## Migration History

| Date | Migration | Description |
|------|-----------|-------------|
| 2024-10-31 | `20241031144907_initial` | Initial users table |
| 2025-02-24 | `20250224192746_initial_schema` | Add posts table |
| 2025-10-17 | `20251017195319_add_third_party_integrations` | Add Firebase integration |

## Support

For issues or questions:
1. Check this README
2. Check migration status: `npm run migrate:status`
3. Check Prisma docs: https://www.prisma.io/docs/

