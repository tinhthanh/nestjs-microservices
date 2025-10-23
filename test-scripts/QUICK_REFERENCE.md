# Test Scripts Quick Reference

## 🚀 Quick Start

```bash
# 1. Start services
./dev.sh    # or ./prod.sh

# 2. Run all tests
cd test-scripts && ./run-all.sh
```

## 📁 Structure Overview

```
test-scripts/
├── common/         # Level 1: Shared utilities
├── services/       # Level 2: Individual service tests
├── flows/          # Level 3: Integration flows
└── run-all.sh      # Master test runner
```

## 🎯 Common Commands

### Run All Tests
```bash
cd test-scripts
./run-all.sh
```

### Run Service Tests
```bash
# Auth
./services/auth/test-login.sh
./services/auth/test-signup.sh
./services/auth/test-refresh-token.sh
./services/auth/test-partner-create.sh

# User
./services/user/test-profile-get.sh
./services/user/test-profile-update.sh

# Post
./services/post/test-create.sh
./services/post/test-list.sh
./services/post/test-update.sh
./services/post/test-delete.sh

# Dufs
./services/dufs/test-upload.sh
./services/dufs/test-download.sh
./services/dufs/test-delete.sh
```

### Run Integration Flows
```bash
./flows/auth-flow.sh              # Complete auth flow
./flows/post-flow.sh              # Complete post flow
./flows/dufs-flow.sh              # Complete file flow
./flows/partner-verify-flow.sh    # Partner verification
```

## 🔧 Troubleshooting

### Check Services
```bash
curl http://localhost:8000/auth/health
curl http://localhost:8000/post/health
```

### Check Docker
```bash
docker-compose ps
# or
docker-compose -f docker-compose.dev.yml ps
```

### View Logs
```bash
# Dev mode
tail -f logs/auth.log
tail -f logs/post.log

# Prod mode
docker-compose logs -f auth
docker-compose logs -f post
```

## 📊 Test Coverage

| Category | Tests | Description |
|----------|-------|-------------|
| Auth Service | 4 | Login, Signup, Refresh, Partner |
| User Service | 2 | Get Profile, Update Profile |
| Post Service | 4 | Create, List, Update, Delete |
| Dufs Service | 3 | Upload, Download, Delete |
| Integration | 4 | Complete flows |
| Health Check | 1 | All services |
| **TOTAL** | **18** | **Complete test suite** |

## 🎨 Color Codes

- 🔵 Blue: Common utilities (Level 1)
- 🟠 Orange: Service tests (Level 2)
- 🟣 Purple: Integration flows (Level 3)
- 🟢 Green: Master script

## 📖 Full Documentation

See [README.md](./README.md) for complete documentation.

