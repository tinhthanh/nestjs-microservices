# 🧪 Testing Documentation

## 📋 Tổng quan

Dự án này bao gồm một bộ test scripts hoàn chỉnh để kiểm tra toàn bộ hệ thống NestJS Microservices.

## 🎯 Các loại tests có sẵn

### 1. Unit Tests (Jest)
- **Auth Service**: 88 tests (80 passed, 8 failed)
- **Post Service**: 101 tests (101 passed)
- **Coverage**: ~90% average

### 2. API Integration Tests (curl)
- 11 test scripts để test các API endpoints
- Tự động login và lấy tokens
- Test đầy đủ CRUD operations

### 3. Health Checks
- Test tất cả services
- Test Kong Gateway
- Test database connections

## 🚀 Quick Start

### Bước 1: Khởi động services

```bash
# Start tất cả services
docker-compose up -d

# Đợi services khởi động (30-60 giây)
docker-compose logs -f
```

### Bước 2: Chạy quick test

```bash
# Test nhanh để kiểm tra services
./quick-test.sh
```

Expected output:
```
✓ Kong Gateway OK
✓ Auth Service OK
✓ Post Service OK
✓ Signup successful
✓ Create post successful
✓ Get posts successful
```

### Bước 3: Chạy full test suite

```bash
# Chạy tất cả API tests
./test-all.sh

# Hoặc chạy unit tests
./run-all-tests.sh
```

## 📁 Test Scripts

### Core Test Scripts

| Script | Mô tả | Yêu cầu Auth |
|--------|-------|--------------|
| `quick-test.sh` | Test nhanh tất cả services | ❌ |
| `test-all.sh` | Chạy tất cả API tests | ❌ |
| `run-all-tests.sh` | Chạy tất cả unit tests | ❌ |

### API Test Scripts

| Script | Endpoint | Method | Mô tả |
|--------|----------|--------|-------|
| `test-health-check.sh` | `/health` | GET | Kiểm tra health của services |
| `test-signup.sh` | `/auth/signup` | POST | Đăng ký user mới |
| `test-auth-login.sh` | `/auth/login` | POST | Đăng nhập |
| `test-refresh-token.sh` | `/auth/refresh` | GET | Làm mới token |
| `test-user-profile.sh` | `/user/profile` | GET | Lấy thông tin user |
| `test-user-update.sh` | `/user/profile` | PUT | Cập nhật profile |
| `test-post-create.sh` | `/post` | POST | Tạo post mới |
| `test-post-list.sh` | `/post` | GET | Lấy danh sách posts |
| `test-post-update.sh` | `/post/:id` | PUT | Cập nhật post |
| `test-post-delete.sh` | `/post/batch` | DELETE | Xóa nhiều posts |

## 📊 Test Results Summary

### Unit Tests

#### Auth Service
```
Test Suites: 6 total (4 passed, 2 failed)
Tests: 88 total (80 passed, 8 failed)
Coverage:
  - Statements: 100%
  - Branches: 98.55%
  - Functions: 100%
  - Lines: 100%
```

**Failed Tests:**
- `user.auth.service.spec.ts`: 4 tests (NotFoundException handling)
- `database.service.spec.ts`: 4 tests (log message format)

#### Post Service
```
Test Suites: 6 total (4 passed, 2 failed)
Tests: 101 total (101 passed)
Coverage:
  - Statements: 72.57%
  - Branches: 93.65%
  - Functions: 77.14%
  - Lines: 71.25%
```

**Failed Tests:**
- `grpc.auth.service.spec.ts`: TypeScript compilation errors
- `database.service.spec.ts`: Constructor parameter mismatch

## 🔧 Cài đặt

### Yêu cầu

```bash
# macOS
brew install curl jq

# Ubuntu/Debian
sudo apt-get install curl jq

# CentOS/RHEL
sudo yum install curl jq
```

### Cấp quyền thực thi

```bash
chmod +x *.sh
```

## 📖 Hướng dẫn sử dụng chi tiết

### Test từng endpoint riêng lẻ

```bash
# 1. Test health check
./test-health-check.sh

# 2. Đăng ký user
./test-signup.sh

# 3. Đăng nhập
./test-auth-login.sh

# 4. Lấy profile
./test-user-profile.sh

# 5. Tạo post
./test-post-create.sh

# 6. Xem danh sách posts
./test-post-list.sh
```

### Test flow hoàn chỉnh

```bash
# Chạy tất cả tests theo thứ tự
./test-all.sh
```

Output sẽ hiển thị:
1. Health checks
2. Signup
3. Login
4. Refresh token
5. User profile operations
6. Post CRUD operations

### Chạy unit tests

```bash
# Chạy tất cả unit tests
./run-all-tests.sh

# Hoặc chạy riêng từng service
cd auth && npm test
cd post && npm test
```

## 🐛 Troubleshooting

### Services không chạy

```bash
# Kiểm tra status
docker-compose ps

# Xem logs
docker-compose logs -f auth-service
docker-compose logs -f post-service

# Restart
docker-compose restart
```

### Test failed: "Failed to get access token"

```bash
# Chạy signup trước
./test-signup.sh

# Hoặc thay đổi email trong script
```

### Test failed: "No posts found"

```bash
# Tạo posts trước
./test-post-create.sh
```

### jq: command not found

```bash
# Cài đặt jq
brew install jq  # macOS
sudo apt-get install jq  # Ubuntu
```

### Port conflicts

```bash
# Kiểm tra ports
lsof -i :8000  # Kong
lsof -i :9001  # Auth
lsof -i :9002  # Post

# Stop conflicting processes
kill -9 <PID>
```

## 📚 Tài liệu chi tiết

- **[TEST_SCRIPTS_README.md](./TEST_SCRIPTS_README.md)** - Chi tiết về các test scripts
- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** - Hướng dẫn testing đầy đủ
- **[README.md](./README.md)** - Tài liệu chính của dự án

## 🎯 Best Practices

1. **Luôn chạy health check trước**
   ```bash
   ./test-health-check.sh
   ```

2. **Tạo test data trước khi test**
   ```bash
   ./test-signup.sh
   ./test-post-create.sh
   ```

3. **Kiểm tra logs khi có lỗi**
   ```bash
   docker-compose logs -f
   ```

4. **Clean up sau khi test**
   ```bash
   docker-compose down -v
   ```

## 🔄 CI/CD Integration

### GitHub Actions

Tests tự động chạy khi:
- Push to main branch
- Create pull request
- Manual trigger

### Local CI Simulation

```bash
# Chạy như CI
./run-all-tests.sh
```

## 📈 Next Steps

### Cải thiện tests

1. **Fix failing unit tests**
   - Auth Service: 8 failed tests
   - Post Service: 2 failed test suites

2. **Tăng coverage**
   - Post Service: Target 80%+
   - Thêm tests cho grpc.auth.service.ts

3. **Thêm E2E tests**
   - Test complete user flows
   - Test microservices communication

4. **Performance testing**
   - Load testing
   - Stress testing
   - Benchmark API response times

### Thêm test cases

1. **Error handling**
   - Invalid input
   - Unauthorized access
   - Rate limiting

2. **Edge cases**
   - Empty data
   - Large payloads
   - Concurrent requests

3. **Security testing**
   - SQL injection
   - XSS attacks
   - Authentication bypass

## 💡 Tips

- Sử dụng `jq` để format JSON output đẹp hơn
- Thêm `-v` flag vào curl để debug
- Kiểm tra response status codes
- Lưu tokens vào biến môi trường để reuse

## 🤝 Contributing

Khi thêm features mới:
1. Viết unit tests
2. Viết API test scripts
3. Update documentation
4. Chạy tất cả tests trước khi commit

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `docker-compose logs -f`
2. Xem troubleshooting guide
3. Tạo issue trên GitHub

