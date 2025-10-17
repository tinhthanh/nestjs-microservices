# NestJS Microservices - Development Guide

## 🚀 Quick Start

### Development Mode (Code chạy local, Infrastructure trong Docker)

```bash
# 1. Start infrastructure (PostgreSQL, Redis, Kong)
./dev-start.sh

# 2. Start services (2 terminals)
# Terminal 1:
cd auth && npm run start:dev

# Terminal 2:
cd post && npm run start:dev

# 3. Test
cd test-scripts && ./test-health-check.sh

# 4. Stop
./dev-stop.sh
```

### Production Mode (Tất cả trong Docker)

```bash
# 1. Start all services
docker-compose up -d

# 2. Test
cd test-scripts && ./test-health-check.sh

# 3. Stop
docker-compose down
```

## 📦 Services

### Development Mode
- **Auth Service**: http://localhost:3001 (Swagger: /docs)
- **Post Service**: http://localhost:3002 (Swagger: /docs)
- **Kong Gateway**: http://localhost:8000
- **PostgreSQL**: localhost:5435
- **Redis**: localhost:6379

### Production Mode
- **Auth Service**: http://localhost:9001 (Swagger: /docs)
- **Post Service**: http://localhost:9002 (Swagger: /docs)
- **Kong Gateway**: http://localhost:8000
- **PostgreSQL**: localhost:5435
- **Redis**: localhost:6379

## 🔧 Scripts

### Development
```bash
./dev-start.sh          # Start infrastructure
./dev-stop.sh           # Stop infrastructure
./dev-run-services.sh   # Start services (tmux)
./dev-logs.sh           # View logs
./dev-doctor.sh         # Health check
```

### Switch Mode
```bash
./switch-to-dev.sh      # Switch to dev mode
./switch-to-prod.sh     # Switch to prod mode
```

### Make Commands
```bash
make dev-start          # Start dev infrastructure
make dev-run            # Start services
make dev-stop           # Stop infrastructure
make doctor             # Health check
make test               # Run tests
```

## 🧪 Testing

All test scripts auto-detect mode (dev/prod) and use correct ports:

```bash
cd test-scripts

# Individual tests
./test-health-check.sh
./test-signup.sh
./test-auth-login.sh
./test-user-profile.sh
./test-post-create.sh
./test-post-list.sh

# Full verification
./verify-all.sh
```

## 🎯 Features

- ✅ Auto-detect dev/prod mode
- ✅ Dynamic port configuration
- ✅ Hot reload in dev mode
- ✅ Easy debugging
- ✅ Consistent infrastructure
- ✅ All tests work in both modes

## 📝 Notes

- Test scripts tự động detect mode và sử dụng đúng ports
- Dev mode: services chạy local (3001/3002)
- Prod mode: services chạy trong Docker (9001/9002)
- Kong Gateway luôn ở port 8000

