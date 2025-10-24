# Quick Reference Card

Fast reference for common commands and workflows.

## 🚀 Environment Management

### Development

```bash
# Start
./dev.sh

# Run tests
./dev.run

# Stop
./dev-stop.sh

# Clean restart
docker-compose -f docker-compose.dev.yml down -v
./dev.sh
```

### Production

```bash
# Start (migrations run automatically)
./prod.sh

# Run tests (test users created automatically)
./prod.run

# Stop
docker-compose -f docker-compose.yml down

# Clean restart
docker-compose -f docker-compose.yml down -v
./prod.sh
```

---

## 🗄️ Database Operations

### Migrations

```bash
# Development - Create new migration
cd auth  # or cd post
yarn prisma:migrate:local

# Sync to centralized migrations
cd migrations
./sync-schemas.sh

# Production - Migrations run automatically on container start
# To manually trigger if needed:
docker restart bw-auth-service bw-post-service

# Verify migrations
docker exec bw-postgres psql -U admin -d postgres -c "SELECT migration_name, finished_at FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 5;"
```

### Test Users

```bash
# Test users are created automatically by k6 tests
# No manual seeding required

# Verify test users
docker exec bw-postgres psql -U admin -d postgres -c "SELECT email, role FROM auth_schema.users;"
```

### Database Inspection

```bash
# Check schemas
docker exec bw-postgres psql -U admin -d postgres -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('auth_schema', 'post_schema');"

# Check tables
docker exec bw-postgres psql -U admin -d postgres -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname IN ('auth_schema', 'post_schema') ORDER BY schemaname, tablename;"

# Check table structure
docker exec bw-postgres psql -U admin -d postgres -c "\d auth_schema.users"
docker exec bw-postgres psql -U admin -d postgres -c "\d post_schema.posts"

# Check data
docker exec bw-postgres psql -U admin -d postgres -c "SELECT COUNT(*) FROM auth_schema.users;"
docker exec bw-postgres psql -U admin -d postgres -c "SELECT COUNT(*) FROM post_schema.posts;"
```

---

## 🐳 Docker Operations

### Container Management

```bash
# List running containers
docker ps

# View logs
docker logs bw-auth-service -f
docker logs bw-post-service -f
docker logs bw-traefik -f
docker logs bw-postgres -f

# Execute commands in container
docker exec -it bw-auth-service sh
docker exec -it bw-postgres psql -U admin -d postgres

# Restart services
docker restart bw-auth-service
docker restart bw-post-service
docker restart bw-traefik

# Stop all
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.yml down
```

### Image Management

```bash
# List images
docker images | grep nestjs-microservices

# Remove images
docker rmi nestjs-microservices-auth-service
docker rmi nestjs-microservices-post-service

# Rebuild images
docker-compose -f docker-compose.yml build --no-cache auth
docker-compose -f docker-compose.yml build --no-cache post
```

### Volume Management

```bash
# List volumes
docker volume ls | grep nestjs-microservices

# Remove volumes (WARNING: Data loss!)
docker volume rm nestjs-microservices_postgres_data
docker volume rm nestjs-microservices_redis_data

# Backup volume
docker run --rm -v nestjs-microservices_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz /data

# Restore volume
docker run --rm -v nestjs-microservices_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_backup.tar.gz -C /
```

---

## 🔍 Debugging

### Check Service Health

```bash
# Health endpoints
curl http://localhost:8000/health        # Via Traefik
curl http://localhost:3001/health        # Auth direct (dev only)
curl http://localhost:3002/health        # Post direct (dev only)

# Traefik dashboard (dev only)
open http://localhost:8080
```

### Test Authentication

```bash
# Login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"User123456"}'

# Get profile (with token)
curl http://localhost:8000/v1/user/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Verify token (Traefik ForwardAuth endpoint)
curl http://localhost:8000/auth/verify-token \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Test File Upload

```bash
# Upload file (requires JWT)
curl -X PUT http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: text/plain" \
  -d "Hello World"

# List files
curl http://localhost:8000/files/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Download file
curl http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Delete file
curl -X DELETE http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 🧪 Testing

### Integration Tests

```bash
# Development
./dev.run

# Production
./prod.run

# Expected output
# ✅ ALL 17 TESTS PASSED
```

### Unit Tests

```bash
# All services
./run-all-tests.sh

# Specific service
cd auth && npm test
cd post && npm test
```

---

## 🔧 Prisma Operations

### Generate Client

```bash
# Development
cd auth && yarn prisma:generate:local
cd post && yarn prisma:generate:local

# Production (in container)
docker exec bw-auth-service sh -c "yarn prisma:generate"
docker exec bw-post-service sh -c "yarn prisma:generate"
```

### Prisma Studio

```bash
# Development
cd auth && yarn prisma:studio:local
cd post && yarn prisma:studio:local

# Opens at http://localhost:5555
```

### Reset Database (Development Only)

```bash
# WARNING: This will delete all data!
cd auth && yarn prisma migrate reset
cd post && yarn prisma migrate reset
```

---

## 📊 Monitoring

### Traefik Dashboard (Dev Only)

```bash
# Open dashboard
open http://localhost:8080

# Features:
# - View all routers and routes
# - Monitor service health
# - View middleware configuration
# - Real-time request metrics
```

### Service Logs

```bash
# Follow all logs
docker-compose -f docker-compose.dev.yml logs -f

# Follow specific service
docker logs bw-auth-service -f
docker logs bw-post-service -f
docker logs bw-traefik -f

# Last 100 lines
docker logs bw-auth-service --tail 100

# Since timestamp
docker logs bw-auth-service --since 2025-10-24T00:00:00
```

---

## 🚨 Emergency Procedures

### Complete Reset (Development)

```bash
# Stop everything
docker-compose -f docker-compose.dev.yml down -v

# Remove all containers
docker rm -f $(docker ps -a -q --filter "name=bw-")

# Remove all volumes
docker volume rm $(docker volume ls -q --filter "name=nestjs-microservices")

# Remove all images
docker rmi $(docker images -q --filter "reference=nestjs-microservices*")

# Start fresh
./dev.sh
```

### Database Recovery

```bash
# Backup current state
docker exec bw-postgres pg_dump -U admin -d postgres > backup_emergency.sql

# Restore from backup
docker exec -i bw-postgres psql -U admin -d postgres < backup_emergency.sql
```

### Service Restart

```bash
# Restart specific service
docker restart bw-auth-service
docker restart bw-post-service

# Restart all services
docker-compose -f docker-compose.dev.yml restart
docker-compose -f docker-compose.yml restart
```

---

## 📝 Common Workflows

### Add New Field to User Model

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
git add . && git commit -m "feat: add new field to User"
```

### Deploy to Production

```bash
# 1. Pull latest code
git pull origin main

# 2. Stop current environment
docker-compose -f docker-compose.yml down

# 3. Start new environment (migrations run automatically)
./prod.sh

# 4. Verify
./prod.run
```

---

## 🔗 Useful Links

- **Setup Guide**: [docs/SETUP_GUIDE.md](./SETUP_GUIDE.md)
- **Migration Guide**: [docs/MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
- **Architecture**: [ARCHITECTURE.md](../ARCHITECTURE.md)
- **Database Architecture**: [DATABASE_ARCHITECTURE.md](../DATABASE_ARCHITECTURE.md)

---

## 📞 Support

If you encounter issues:

1. Check logs: `docker logs bw-<service-name> -f`
2. Verify database: `docker exec bw-postgres psql -U admin -d postgres`
3. Check Traefik dashboard: http://localhost:8080 (dev only)
4. Review documentation in `docs/` folder
5. Check GitHub issues

