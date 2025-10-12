# 🧪 Testing Guide - NestJS Microservices

## 📋 Tổng quan

Hướng dẫn này cung cấp thông tin chi tiết về cách test toàn bộ hệ thống NestJS Microservices, bao gồm:
- Unit Tests (Jest)
- Integration Tests (API Tests với curl)
- Health Checks
- End-to-End Testing

## 🎯 Các loại tests

### 1. Unit Tests (Jest)

Unit tests kiểm tra các service methods riêng lẻ.

#### Chạy Unit Tests

```bash
# Chạy tất cả unit tests cho cả 2 services
./run-all-tests.sh

# Hoặc chạy riêng từng service
cd auth && npm test
cd post && npm test
```

#### Kết quả Unit Tests hiện tại

**Auth Service:**
- ✅ 80/88 tests passed (90.9%)
- ❌ 8 tests failed
- Coverage: ~100% statements, 98.55% branches

**Post Service:**
- ✅ 101/101 tests passed (100%)
- ⚠️ Coverage: 72.57% (cần cải thiện)

### 2. API Integration Tests (curl)

API tests kiểm tra các endpoints thông qua HTTP requests.

#### Chạy API Tests

```bash
# Đảm bảo services đang chạy
docker-compose up -d

# Chờ services khởi động (khoảng 30-60 giây)
sleep 60

# Chạy tất cả API tests
./test-all.sh

# Hoặc chạy từng test riêng lẻ
./test-health-check.sh
./test-signup.sh
./test-auth-login.sh
./test-user-profile.sh
./test-post-create.sh
./test-post-list.sh
```

## 🚀 Quick Start

### Bước 1: Khởi động hệ thống

```bash
# Build và start tất cả services
docker-compose up -d --build

# Kiểm tra status
docker-compose ps

# Xem logs
docker-compose logs -f
```

### Bước 2: Chạy Health Checks

```bash
./test-health-check.sh
```

Expected output:
```json
{
  "status": "ok",
  "info": {
    "database": { "status": "up" },
    "redis": { "status": "up" }
  }
}
```

### Bước 3: Test Authentication Flow

```bash
# 1. Đăng ký user mới
./test-signup.sh

# 2. Đăng nhập
./test-auth-login.sh

# 3. Lấy profile
./test-user-profile.sh

# 4. Refresh token
./test-refresh-token.sh
```

### Bước 4: Test Post Management

```bash
# 1. Tạo post
./test-post-create.sh

# 2. Lấy danh sách posts
./test-post-list.sh

# 3. Cập nhật post
./test-post-update.sh

# 4. Xóa posts
./test-post-delete.sh
```

## 📊 Test Coverage

### Auth Service Coverage

| File | Statements | Branches | Functions | Lines |
|------|-----------|----------|-----------|-------|
| auth.service.ts | 100% | 100% | 100% | 100% |
| user.auth.service.ts | 100% | 100% | 100% | 100% |
| user.admin.service.ts | 100% | 100% | 100% | 100% |
| hash.service.ts | 100% | 100% | 100% | 100% |
| query-builder.service.ts | 100% | 97.61% | 100% | 100% |
| database.service.ts | 100% | 100% | 100% | 100% |

### Post Service Coverage

| File | Statements | Branches | Functions | Lines |
|------|-----------|----------|-----------|-------|
| post.service.ts | 100% | 77.77% | 100% | 100% |
| post-mapping.service.ts | 100% | 100% | 100% | 100% |
| hash.service.ts | 100% | 100% | 100% | 100% |
| query-builder.service.ts | 98.07% | 95.23% | 100% | 97.91% |
| grpc.auth.service.ts | 0% | 100% | 0% | 0% ⚠️ |
| database.service.ts | 23.8% | 100% | 0% | 15.78% ⚠️ |

## 🐛 Known Issues & Fixes Needed

### Auth Service

1. **user.auth.service.spec.ts** - 4 failed tests
   - Issue: NotFoundException không được throw khi user không tồn tại
   - Fix needed: Cập nhật service để throw exception đúng cách

2. **database.service.spec.ts** - 4 failed tests
   - Issue: Log messages không có emoji như expected
   - Fix needed: Cập nhật test expectations hoặc thêm emoji vào log messages

### Post Service

1. **grpc.auth.service.spec.ts** - Compilation errors
   - Issue: `onModuleInit` method không tồn tại
   - Fix needed: Implement `OnModuleInit` interface

2. **database.service.spec.ts** - Constructor mismatch
   - Issue: Constructor parameters không khớp
   - Fix needed: Cập nhật test mock hoặc service constructor

## 🔧 Troubleshooting

### Services không khởi động

```bash
# Xem logs chi tiết
docker-compose logs auth-service
docker-compose logs post-service

# Restart services
docker-compose restart

# Rebuild nếu cần
docker-compose up -d --build
```

### Database connection errors

```bash
# Kiểm tra PostgreSQL
docker-compose exec postgres psql -U admin -d postgres

# Kiểm tra Redis
docker-compose exec redis redis-cli ping
```

### Port conflicts

```bash
# Kiểm tra ports đang sử dụng
lsof -i :8000  # Kong
lsof -i :9001  # Auth Service
lsof -i :9002  # Post Service
lsof -i :5435  # PostgreSQL
lsof -i :6379  # Redis

# Stop conflicting processes hoặc thay đổi ports trong docker-compose.yml
```

### Test failures

```bash
# Clear và reinstall dependencies
cd auth
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps

cd ../post
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

## 📈 Continuous Integration

### GitHub Actions

Dự án đã có CI workflows cho cả 2 services:
- `.github/workflows/ci.yml` (Auth Service)
- `.github/workflows/ci.yml` (Post Service)

Workflows tự động chạy:
- Lint checks
- Unit tests
- Build verification

### Local CI Simulation

```bash
# Chạy tất cả checks như CI
./run-all-tests.sh

# Chạy lint
cd auth && npm run lint
cd post && npm run lint

# Chạy build
cd auth && npm run build
cd post && npm run build
```

## 🎯 Best Practices

### 1. Test Isolation
- Mỗi test phải độc lập
- Không phụ thuộc vào thứ tự chạy
- Clean up data sau mỗi test

### 2. Mock External Dependencies
- Mock database calls
- Mock gRPC services
- Mock Redis cache

### 3. Test Coverage Goals
- Minimum 80% coverage
- 100% coverage cho critical paths
- Test cả success và error cases

### 4. API Testing
- Test với valid data
- Test với invalid data
- Test authentication/authorization
- Test rate limiting
- Test error responses

## 📚 Resources

- [Jest Documentation](https://jestjs.io/)
- [NestJS Testing](https://docs.nestjs.com/fundamentals/testing)
- [Supertest](https://github.com/visionmedia/supertest)
- [curl Documentation](https://curl.se/docs/)

## 🔄 Next Steps

1. **Fix failing tests**
   - Auth Service: 8 failed tests
   - Post Service: 2 failed test suites

2. **Improve coverage**
   - Post Service: Tăng coverage lên 80%+
   - Thêm tests cho grpc.auth.service.ts

3. **Add E2E tests**
   - Test complete user flows
   - Test microservices communication
   - Test Kong gateway routing

4. **Performance testing**
   - Load testing với Apache Bench hoặc k6
   - Stress testing
   - Benchmark API response times

5. **Security testing**
   - Test authentication bypass
   - Test SQL injection
   - Test XSS attacks
   - Test rate limiting

