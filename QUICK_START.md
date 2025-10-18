# Quick Start Guide

## 🚀 Hai Lệnh Chính

### 1. Development Mode (Local Services + Docker Infrastructure)

```bash
./dev.sh
```

**Chạy gì:**
- ✅ PostgreSQL trong Docker (port 5435)
- ✅ Redis trong Docker (port 6379)
- ✅ Kong Gateway trong Docker (port 8000, 8001)
- ✅ Auth Service chạy local (port 3001)
- ✅ Post Service chạy local (port 3002)

**Dừng:**
```bash
./dev-stop.sh
```

**Khi nào dùng:**
- Development và debugging
- Cần hot-reload khi code thay đổi
- Cần xem logs trực tiếp
- Cần debug với breakpoints

---

### 2. Production Mode (All in Docker)

```bash
./prod.sh
```

**Chạy gì:**
- ✅ Tất cả services trong Docker
- ✅ Chỉ expose port 8000 (Kong Gateway)
- ✅ Tất cả services khác chạy internal

**Dừng:**
```bash
docker-compose -f docker-compose.yml down
```

**Khi nào dùng:**
- Testing production environment
- Deploy lên server
- CI/CD pipelines
- Load testing

---

## 📍 Endpoints

### Development Mode

| Service | URL | Description |
|---------|-----|-------------|
| Kong Gateway | http://localhost:8000 | API Gateway (public) |
| Kong Admin | http://localhost:8001 | Kong Admin API |
| Auth Service | http://localhost:3001 | Auth Service (direct) |
| Post Service | http://localhost:3002 | Post Service (direct) |
| Auth Swagger | http://localhost:3001/docs | API Documentation |
| Post Swagger | http://localhost:3002/docs | API Documentation |
| PostgreSQL | localhost:5435 | Database |
| Redis | localhost:6379 | Cache |

### Production Mode

| Service | URL | Description |
|---------|-----|-------------|
| Kong Gateway | http://localhost:8000 | **ONLY PUBLIC ENDPOINT** |

Tất cả services khác chạy internal trong Docker network.

---

## 🧪 Testing

### Run All Tests

```bash
./run-all-tests.sh
```

### Test API Endpoints

```bash
# Test partner verification (Firebase)
./test-scripts/test-partner-verify.sh

# Test signup
./test-scripts/test-signup.sh

# Test login
./test-scripts/test-auth-login.sh

# Test post creation
./test-scripts/test-post-create.sh
```

---

## 📝 Logs

### Development Mode

```bash
# Auth service logs
tail -f logs/auth.log

# Post service logs
tail -f logs/post.log

# Kong logs
docker logs -f bw-kong-dev
```

### Production Mode

```bash
# All logs
docker-compose -f docker-compose.yml logs -f

# Specific service
docker-compose -f docker-compose.yml logs -f auth
docker-compose -f docker-compose.yml logs -f post
docker-compose -f docker-compose.yml logs -f kong
```

---

## 🔧 Troubleshooting

### Development Mode Issues

**Services không start:**
```bash
# Stop everything
./dev-stop.sh

# Clean up
docker-compose -f docker-compose.dev.yml down -v

# Start again
./dev.sh
```

**Port conflicts:**
```bash
# Check what's using ports
lsof -ti:3001  # Auth
lsof -ti:3002  # Post
lsof -ti:8000  # Kong
lsof -ti:5435  # PostgreSQL

# Kill process
kill -9 <PID>
```

### Production Mode Issues

**Services không start:**
```bash
# Stop everything
docker-compose -f docker-compose.yml down -v

# Rebuild and start
./prod.sh
```

**Check service health:**
```bash
# Check all containers
docker-compose -f docker-compose.yml ps

# Check specific service logs
docker-compose -f docker-compose.yml logs auth
```

---

## 📚 More Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Deployment guide
- [migrations/README.md](./migrations/README.md) - Database migrations

---

## 🎯 Common Workflows

### Development Workflow

```bash
# 1. Start development environment
./dev.sh

# 2. Make code changes
# Files will auto-reload

# 3. Test changes
./test-scripts/test-partner-verify.sh

# 4. Run tests
./run-all-tests.sh

# 5. Stop when done
./dev-stop.sh
```

### Production Testing Workflow

```bash
# 1. Start production environment
./prod.sh

# 2. Run integration tests
./test-scripts/test-partner-verify.sh

# 3. Check logs
docker-compose -f docker-compose.yml logs -f

# 4. Stop when done
docker-compose -f docker-compose.yml down
```

---

## ✅ Quick Health Check

```bash
# Development
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:8000/health

# Production
curl http://localhost:8000/health
```

---

**🎉 That's it! Chỉ cần 2 lệnh: `./dev.sh` và `./prod.sh`**

