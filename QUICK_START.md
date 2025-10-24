# Quick Start Guide

## 🚀 Hai Lệnh Chính

### 1. Development Mode (Local Services + Docker Infrastructure)

```bash
./dev.sh
```

**Chạy gì:**
- ✅ PostgreSQL trong Docker (port 5435)
- ✅ Redis trong Docker (port 6379)
- ✅ **Traefik v3.0 Gateway** trong Docker (port 8000)
- ✅ **Traefik Dashboard** (port 8080) - Monitoring UI
- ✅ Auth Service chạy local (port 3001) - Hot reload enabled
- ✅ Post Service chạy local (port 3002) - Hot reload enabled
- ✅ DUFS Service trong Docker (port 5000)

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
- ✅ Chỉ expose port 8000 (Traefik Gateway)
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
| **Traefik Gateway** | http://localhost:8000 | **API Gateway (public endpoint)** |
| **Traefik Dashboard** | http://localhost:8080 | **Monitoring UI - Routers, Services, Middlewares** |
| Auth Service (Direct) | http://localhost:3001 | Auth Service HTTP API |
| Post Service (Direct) | http://localhost:3002 | Post Service HTTP API |
| Auth Swagger | http://localhost:3001/docs | Auth API Documentation |
| Post Swagger | http://localhost:3002/docs | Post API Documentation |
| PostgreSQL | localhost:5435 | Database |
| Redis | localhost:6379 | Cache |

**Recommended: Truy cập qua Traefik Gateway**
- Auth API: http://localhost:8000/auth/*
- User API: http://localhost:8000/v1/user/*
- Partner API: http://localhost:8000/v1/partner/*
- Post API: http://localhost:8000/post/*
- File API: http://localhost:8000/files/* (requires JWT)

### Production Mode

| Service | URL | Description |
|---------|-----|-------------|
| **Traefik Gateway** | http://localhost:8000 | **ONLY PUBLIC ENDPOINT** |

**All routes:**
- Auth: http://localhost:8000/auth/*
- User: http://localhost:8000/v1/user/*
- Partner: http://localhost:8000/v1/partner/*
- Post: http://localhost:8000/post/*
- Files: http://localhost:8000/files/* (requires JWT)

Tất cả services khác chạy internal trong Docker network.
Traefik Dashboard **disabled** trong production mode.

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

# Traefik logs
docker logs -f bw-traefik-dev
```

### Production Mode

```bash
# All logs
docker-compose -f docker-compose.yml logs -f

# Specific service
docker-compose -f docker-compose.yml logs -f auth
docker-compose -f docker-compose.yml logs -f post
docker-compose -f docker-compose.yml logs -f traefik
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
lsof -ti:8000  # Traefik
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
# Traefik Gateway
curl http://localhost:8000/ping
# Response: OK

# Development - Direct access
curl http://localhost:3001/health  # Auth Service
curl http://localhost:3002/health  # Post Service

# Development - Via Traefik Gateway
curl http://localhost:8000/auth/health
curl http://localhost:8000/post/health

# Production - Only via Traefik Gateway
curl http://localhost:8000/auth/health
curl http://localhost:8000/post/health
```

---

## 🎯 Traefik Dashboard (Development Only)

Khi chạy `./dev.sh`, Traefik Dashboard sẽ available tại:

**URL:** http://localhost:8080

**Features:**
- 📊 Real-time monitoring
- 🔀 View all routers và routing rules
- 🎯 View all services và health status
- 🔧 View all middlewares (rate limiting, auth, headers)
- 📈 Request metrics và statistics

**Useful for:**
- Debug routing issues
- Monitor service health
- View middleware configuration
- Analyze request patterns

---

## 🔐 Testing JWT Authentication

```bash
# 1. Login để lấy access token
TOKEN=$(curl -s -X POST http://localhost:8000/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  | jq -r '.data.accessToken')

# 2. Upload file với JWT token
curl -X PUT http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: text/plain" \
  -d "Hello World"

# 3. Download file
curl http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer $TOKEN"

# 4. Delete file
curl -X DELETE http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer $TOKEN"
```

**Note:** Traefik sẽ tự động xác thực JWT token qua ForwardAuth middleware trước khi forward request đến DUFS Service.

---

## 📊 Traefik Logs

```bash
# Development
docker logs -f bw-traefik-dev

# Production
docker logs -f bw-traefik

# Filter errors only
docker logs bw-traefik 2>&1 | grep -i error

# View access logs (JSON format)
docker logs bw-traefik 2>&1 | grep -i "requestpath"
```

---

**🎉 That's it! Chỉ cần 2 lệnh: `./dev.sh` và `./prod.sh`**

**🚀 Traefik Dashboard:** http://localhost:8080 (development mode)

