# Setup Guide

Complete guide for setting up Development and Production environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Environment](#development-environment)
- [Production Environment](#production-environment)
- [Database Migrations](#database-migrations)
- [Database Seeding](#database-seeding)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Node.js** >= 18 (for local development)
- **Yarn** >= 1.22

### Verify Installation

```bash
docker --version
docker-compose --version
node --version
yarn --version
```

---

## Development Environment

### 1. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd nestjs-microservices

# Install dependencies for migrations
cd migrations
yarn install
cd ..
```

### 2. Start Development Environment

```bash
./dev.sh
```

This script will:
- ✅ Start PostgreSQL, Redis, DUFS, Auth, Post services
- ✅ Start Traefik API Gateway with Dashboard
- ✅ Initialize database schemas (`auth_schema`, `post_schema`)
- ✅ Run database migrations automatically

**Services will be available at:**
- API Gateway: http://localhost:8000
- Traefik Dashboard: http://localhost:8080
- Auth Service (internal): http://localhost:3001
- Post Service (internal): http://localhost:3002
- PostgreSQL: localhost:5435
- Redis: localhost:6380

### 3. Run Tests

```bash
./dev.run
```

Expected output:
```
✅ ALL 17 TESTS PASSED
```

### 4. Stop Development Environment

```bash
./dev-stop.sh
```

Or with volume cleanup:
```bash
docker-compose -f docker-compose.dev.yml down -v
```

---

## Production Environment

### 1. Start Production Environment

```bash
./prod.sh
```

This script will:
- ✅ Build production Docker images
- ✅ Start all services in production mode
- ✅ Initialize database schemas
- ✅ Run database migrations automatically via Docker entrypoint

**Services will be available at:**
- API Gateway: http://localhost:8000
- Auth Service (internal): http://auth:9001
- Post Service (internal): http://post:9002
- PostgreSQL (internal): postgres:5432
- Redis (internal): redis:6379

### 2. Run Tests

**Note**: Test users are automatically created by k6 tests if they don't exist. No manual seeding required.

```bash
./prod.run
```

Expected output:
```
✅ ALL 17 TESTS PASSED
```

### 3. Stop Production Environment

```bash
docker-compose -f docker-compose.yml down
```

Or with volume cleanup:
```bash
docker-compose -f docker-compose.yml down -v
```

---

## Database Migrations

### Architecture

The project uses **Database per Service pattern** with PostgreSQL schemas:

- **`auth_schema`**: Auth Service tables (users, third_party_integrations)
- **`post_schema`**: Post Service tables (posts)
- **Single PostgreSQL instance**: All services share one database with logical separation

### Migration Workflow

#### Development

Migrations run automatically when starting services via `./dev.sh`.

To create new migrations:

```bash
# For Auth service
cd auth
yarn prisma:migrate:local

# For Post service
cd post
yarn prisma:migrate:local

# Sync to centralized migrations folder
cd migrations
./sync-schemas.sh
```

#### Production

Migrations run automatically via Docker entrypoint scripts when containers start.

To manually trigger migrations if needed:

```bash
# Restart services to trigger migrations
docker restart bw-auth-service bw-post-service

# Or run migrations manually
docker exec bw-auth-service sh -c "yarn prisma:migrate:prod"
docker exec bw-post-service sh -c "yarn prisma:migrate:prod"
```

### Verify Migrations

```bash
# Check migration history
docker exec bw-postgres psql -U admin -d postgres -c "SELECT migration_name, finished_at FROM _prisma_migrations ORDER BY finished_at DESC;"

# Check tables in schemas
docker exec bw-postgres psql -U admin -d postgres -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname IN ('auth_schema', 'post_schema') ORDER BY schemaname, tablename;"
```

Expected output:
```
 schemaname  |        tablename         
-------------+--------------------------
 auth_schema | third_party_integrations
 auth_schema | users
 post_schema | posts
```

---

## Test Users

### Automatic Creation

Test users are automatically created by k6 tests when running `./dev.run` or `./prod.run`. No manual seeding required.

The k6 test suite creates these users if they don't exist:

| Email | Password | Role | Purpose |
|-------|----------|------|---------|
| user@example.com | User123456 | USER | K6 integration tests |
| admin@example.com | Admin123456 | ADMIN | Admin operations |

### Verify Test Users

```bash
docker exec bw-postgres psql -U admin -d postgres -c "SELECT email, role, is_verified FROM auth_schema.users;"
```

Expected output:
```
       email        | role  | is_verified 
--------------------+-------+-------------
 user@example.com   | USER  | t
 admin@example.com  | ADMIN | t
```

---

## Troubleshooting

### Issue: Tests Fail with "User not found"

**Cause**: Test users not created automatically (rare).

**Solution**:
```bash
# Simply re-run tests - they will create users automatically
./dev.run  # for development
./prod.run # for production
```

### Issue: "Table does not exist" Error

**Cause**: Migrations not run.

**Solution**:
```bash
# Development - restart environment
./dev-stop.sh
./dev.sh

# Production - run migrations manually
docker exec bw-auth-service sh -c "yarn prisma:migrate:prod"
docker exec bw-post-service sh -c "yarn prisma:migrate:prod"
```

### Issue: Prisma Client Out of Sync

**Cause**: Prisma client not regenerated after schema changes.

**Solution**:
```bash
# Regenerate Prisma client
docker exec bw-auth-service sh -c "yarn prisma:generate"
docker exec bw-post-service sh -c "yarn prisma:generate"

# Restart services
docker restart bw-auth-service bw-post-service
```

### Issue: Port Already in Use

**Cause**: Previous containers still running.

**Solution**:
```bash
# Stop all containers
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.yml down

# Check for orphaned containers
docker ps -a | grep bw-

# Remove if needed
docker rm -f $(docker ps -a -q --filter "name=bw-")
```

### Issue: Database Connection Failed

**Cause**: PostgreSQL not ready or wrong credentials.

**Solution**:
```bash
# Check PostgreSQL status
docker logs bw-postgres

# Verify connection
docker exec bw-postgres psql -U admin -d postgres -c "SELECT version();"

# Check credentials in .env files
cat auth/.env.docker
cat post/.env.docker
```

### View Service Logs

```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker logs bw-auth-service -f
docker logs bw-post-service -f
docker logs bw-traefik -f
docker logs bw-postgres -f
```

---

## Quick Reference

### Development Commands

```bash
./dev.sh          # Start development environment
./dev.run         # Run tests
./dev-stop.sh     # Stop environment
```

### Production Commands

```bash
./prod.sh         # Start production environment
./prod.run        # Run tests
docker-compose -f docker-compose.yml down  # Stop environment
```

### Database Commands

```bash
# Migrations (run automatically on container start, or manually if needed)
docker exec bw-auth-service sh -c "yarn prisma:migrate:prod"
docker exec bw-post-service sh -c "yarn prisma:migrate:prod"

# Verify migrations
docker exec bw-postgres psql -U admin -d postgres -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname IN ('auth_schema', 'post_schema');"

# Verify test users (created automatically by k6 tests)
docker exec bw-postgres psql -U admin -d postgres -c "SELECT email, role FROM auth_schema.users;"
```

---

## Next Steps

- [Architecture Documentation](../ARCHITECTURE.md)
- [Database Architecture](../DATABASE_ARCHITECTURE.md)
- [Deployment Guide](../DEPLOYMENT_GUIDE.md)
- [Traefik Migration Guide](../TRAEFIK_MIGRATION.md)

