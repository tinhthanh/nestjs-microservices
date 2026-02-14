# Hướng dẫn Phát triển (Development)

## Yêu cầu

- **Node.js** >= 18.0
- **Docker** & Docker Compose
- **npm** >= 9.0

## Khởi động nhanh

### 1. Cài dependencies

```bash
cd auth && npm install --legacy-peer-deps && cd ..
cd post && npm install --legacy-peer-deps && cd ..
```

### 2. Start Docker infra

```bash
docker compose -f docker-compose.dev.yml up -d
```

Kiểm tra infra:
```bash
docker exec bw-postgres-dev pg_isready -U admin   # accepting connections
docker exec bw-redis-dev redis-cli ping            # PONG
curl http://localhost:8000/ping                     # OK
```

### 3. Database migrations

```bash
cd auth && npx prisma generate && npx prisma migrate deploy && cd ..
cd post && npx prisma generate && npx prisma migrate deploy && cd ..
```

### 4. Start services

```bash
# Terminal 1 - Auth Service
cd auth && npm run dev

# Terminal 2 - Post Service
cd post && npm run dev
```

Hoặc chạy background:
```bash
cd auth && npm run dev > ../logs/auth.log 2>&1 &
cd post && npm run dev > ../logs/post.log 2>&1 &
```

### 5. Dừng

```bash
# Dừng infra
docker compose -f docker-compose.dev.yml down

# Dừng services (nếu chạy background)
kill $(cat .dev-auth.pid) $(cat .dev-post.pid) 2>/dev/null
```

## Services & Endpoints

| Service | URL | Mô tả |
|---------|-----|-------|
| **Traefik Gateway** | http://localhost:8000 | API Gateway |
| **Traefik Dashboard** | http://localhost:8080 | Monitoring UI |
| Auth Service | http://localhost:9001 | HTTP API |
| Auth Swagger | http://localhost:9001/docs | API Documentation |
| Post Service | http://localhost:9002 | HTTP API |
| Post Swagger | http://localhost:9002/docs | API Documentation |
| PostgreSQL | localhost:5435 | Database |
| Redis | localhost:6379 | Cache |

**Truy cập qua Gateway:**
- `http://localhost:8000/auth/*` → Auth Service
- `http://localhost:8000/v1/user/*` → Auth Service
- `http://localhost:8000/v1/partner/*` → Auth Service
- `http://localhost:8000/post/*` → Post Service
- `http://localhost:8000/files/*` → DUFS (JWT required)

## Environment Variables

Mỗi service có file `.env` cho local dev (đã tạo sẵn):

| File | Mô tả |
|------|-------|
| `auth/.env` | Auth config: DB `localhost:5435/auth_schema`, Redis, JWT secrets |
| `post/.env` | Post config: DB `localhost:5435/post_schema`, Redis, gRPC auth |
| `migrations/.env.local` | Migration: DB `localhost:5435` |

> **Note**: `.env.docker` là config cho Docker containers (dùng internal ports). `.env` là config cho chạy local.

## Logs

```bash
# Xem logs services (nếu chạy background)
tail -f logs/auth.log
tail -f logs/post.log

# Xem logs Traefik
docker logs -f bw-traefik-dev

# Xem logs PostgreSQL
docker logs -f bw-postgres-dev
```

## Makefile Commands

```bash
make help           # Xem tất cả commands
make dev-start      # Start Docker infra
make dev-stop       # Stop Docker infra
make dev-clean      # Stop + xoá volumes
make dev-ps         # Xem Docker containers
make install        # Install dependencies
make migrate        # Run migrations
make test           # Run all tests
make lint           # Run linter
make format         # Format code
make status         # Xem status tất cả services
```

## Troubleshooting

### Port conflict

```bash
lsof -ti:9001    # Auth
lsof -ti:9002    # Post
lsof -ti:8000    # Traefik
lsof -ti:5435    # PostgreSQL
kill -9 <PID>
```

### DB connection failed

Kiểm tra PostgreSQL đang chạy:
```bash
docker compose -f docker-compose.dev.yml ps
```

Kiểm tra DATABASE_URL trong `.env`:
```
postgresql://admin:master123@localhost:5435/postgres?schema=auth_schema
```

### Prisma Client lỗi

```bash
cd auth && npx prisma generate
cd post && npx prisma generate
```

### Clean restart

```bash
docker compose -f docker-compose.dev.yml down -v   # Xoá data
docker compose -f docker-compose.dev.yml up -d      # Start lại
cd auth && npx prisma migrate deploy && cd ..
cd post && npx prisma migrate deploy && cd ..
```
