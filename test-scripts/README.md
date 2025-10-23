# Test Scripts Structure

Cấu trúc thư mục test được tổ chức theo 3 cấp độ: **Common**, **Services**, và **Flows**.

## 📁 Cấu trúc thư mục

```
test-scripts/
├── common/              # Scripts dùng chung
│   ├── config.sh       # Configuration và environment detection
│   └── utils.sh        # Utility functions cho testing
│
├── services/           # Tests cho từng service riêng lẻ
│   ├── auth/          # Auth service tests
│   │   ├── test-login.sh
│   │   ├── test-signup.sh
│   │   ├── test-refresh-token.sh
│   │   └── test-partner-create.sh
│   ├── user/          # User service tests
│   │   ├── test-profile-get.sh
│   │   └── test-profile-update.sh
│   ├── post/          # Post service tests
│   │   ├── test-create.sh
│   │   ├── test-list.sh
│   │   ├── test-update.sh
│   │   └── test-delete.sh
│   └── dufs/          # File service tests
│       ├── test-upload.sh
│       ├── test-download.sh
│       └── test-delete.sh
│
├── flows/             # Integration flows giữa các services
│   ├── auth-flow.sh           # Complete auth flow
│   ├── post-flow.sh           # Complete post flow
│   ├── dufs-flow.sh           # Complete file management flow
│   ├── partner-verify-flow.sh # Partner verification flow
│
└── run-all.sh         # Master script để chạy tất cả tests
```

## 🚀 Cách sử dụng

### Bước 1: Khởi động services

**Development mode:**
```bash
./dev.sh
# Sau đó start services manually:
cd auth && npm run start:dev
cd post && npm run start:dev
```

**Production mode:**
```bash
./prod.sh
```

### Bước 2: Chạy tests

#### Test từng service riêng lẻ

```bash
# Test auth service
./test-scripts/services/auth/test-login.sh
./test-scripts/services/auth/test-signup.sh
./test-scripts/services/auth/test-refresh-token.sh
./test-scripts/services/auth/test-partner-create.sh

# Test user service
./test-scripts/services/user/test-profile-get.sh
./test-scripts/services/user/test-profile-update.sh

# Test post service
./test-scripts/services/post/test-create.sh
./test-scripts/services/post/test-list.sh
./test-scripts/services/post/test-update.sh
./test-scripts/services/post/test-delete.sh

# Test dufs service
./test-scripts/services/dufs/test-upload.sh
./test-scripts/services/dufs/test-download.sh
./test-scripts/services/dufs/test-delete.sh
```

#### Test integration flows

```bash
# Test complete auth flow (signup -> login -> refresh -> verify)
./test-scripts/flows/auth-flow.sh

# Test complete post flow (login -> create -> list -> update -> delete)
./test-scripts/flows/post-flow.sh

# Test complete file management flow (login -> upload -> download -> delete)
./test-scripts/flows/dufs-flow.sh

# Test partner verification flow (Firebase auth -> partner verify -> use token)
./test-scripts/flows/partner-verify-flow.sh

```

#### Chạy tất cả tests

```bash
cd test-scripts
./run-all.sh
```

Hoặc từ root directory:
```bash
./test-scripts/run-all.sh
```

## 📝 Quy tắc đặt tên

### Service Tests
- `test-{action}.sh` - Test một action cụ thể
- Ví dụ: `test-login.sh`, `test-create.sh`, `test-profile-get.sh`

### Integration Flows
- `{feature}-flow.sh` - Test toàn bộ flow của một feature
- Ví dụ: `auth-flow.sh`, `post-flow.sh`, `dufs-flow.sh`

## ⚙️ Configuration

### Auto-detect Environment

File `common/config.sh` tự động detect environment:
- **Dev mode**: Services chạy local (ports 3001, 3002) + Kong (8000)
- **Prod mode**: Services chạy qua Kong Gateway (port 8000)

### Environment Variables

Các biến được set tự động:
- `MODE`: "dev" hoặc "prod"
- `KONG_URL`: http://localhost:8000
- `AUTH_URL`: URL của Auth service
- `POST_URL`: URL của Post service
- `BASE_URL`: Base URL cho API calls

## 🧪 Test Coverage

### Auth Service
- ✅ Signup - Đăng ký user mới
- ✅ Login - Đăng nhập và lấy tokens
- ✅ Refresh Token - Làm mới access token
- ✅ Partner Create - Tạo partner integration (Firebase)

### User Service
- ✅ Get Profile - Lấy thông tin profile
- ✅ Update Profile - Cập nhật thông tin profile

### Post Service
- ✅ Create Post - Tạo bài viết mới
- ✅ List Posts - Lấy danh sách bài viết (pagination)
- ✅ Update Post - Cập nhật bài viết
- ✅ Delete Posts - Xóa bài viết (batch delete)

### File Service (Dufs)
- ✅ Upload File - Upload file lên server
- ✅ Download File - Download file từ server
- ✅ Delete File - Xóa file khỏi server

### Integration Flows
- ✅ Complete Auth Flow - Toàn bộ luồng xác thực
- ✅ Complete Post Flow - Toàn bộ luồng quản lý bài viết
- ✅ Complete File Management Flow - Toàn bộ luồng quản lý file
- ✅ Partner Verification Flow - Luồng xác thực qua partner (Firebase)
- ✅ Health Check - Kiểm tra sức khỏe tất cả services

## 🔍 Test Phases

Script `run-all.sh` chạy tests theo 3 phases:

### Phase 1: Health Checks
Kiểm tra tất cả services và infrastructure đang hoạt động:
- Docker containers
- PostgreSQL
- Redis
- Kong Gateway
- Auth Service
- Post Service
- gRPC connectivity

### Phase 2: Service Tests
Test từng service riêng lẻ:
- Auth Service (4 tests)
- User Service (2 tests)
- Post Service (4 tests)
- Dufs Service (3 tests)

### Phase 3: Integration Flow Tests
Test các luồng tích hợp end-to-end:
- Complete Auth Flow
- Complete Post Flow
- Complete DUFS Flow
- Partner Verification Flow

## 📊 Test Output

Mỗi test sẽ hiển thị:
- ✅ PASSED - Test thành công
- ❌ FAILED - Test thất bại

Cuối cùng sẽ có summary:
```
📊 Test Summary
Total Tests: 18
Passed: 18
Failed: 0

✅ ALL TESTS PASSED
```

## 🛠️ Troubleshooting

### Services không chạy
```bash
# Check services status
curl http://localhost:8000/auth/health
curl http://localhost:8000/post/health

# Check Docker containers
docker-compose ps
# hoặc
docker-compose -f docker-compose.dev.yml ps
```

### Test thất bại
```bash
# Chạy test riêng lẻ để xem chi tiết lỗi
./test-scripts/services/auth/test-login.sh

# Check logs
tail -f logs/auth.log
tail -f logs/post.log

# Hoặc với Docker
docker-compose logs -f auth
docker-compose logs -f post
```

### Reset database
```bash
cd migrations
npm run migrate:dev
```

## 📚 Thêm test mới

### Thêm service test mới

1. Tạo file trong thư mục service tương ứng:
```bash
touch test-scripts/services/auth/test-new-feature.sh
chmod +x test-scripts/services/auth/test-new-feature.sh
```

2. Sử dụng template:
```bash
#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../common/config.sh"

# Your test code here
echo "Testing new feature..."
```

3. Thêm vào `run-all.sh` nếu muốn chạy trong test suite

### Thêm integration flow mới

1. Tạo file trong thư mục flows:
```bash
touch test-scripts/flows/new-flow.sh
chmod +x test-scripts/flows/new-flow.sh
```

2. Sử dụng template với utils:
```bash
#!/bin/bash

set -e  # Exit on error

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/config.sh"
source "$SCRIPT_DIR/../common/utils.sh"

print_header "🚀 New Flow Test ($MODE mode)"

# Your flow steps here
print_step "Step 1: ..."
# ...

print_header "✅ New Flow Test PASSED"
```

## 🎯 Best Practices

1. **Luôn load config**: Mọi test script phải load `common/config.sh`
2. **Sử dụng utils**: Dùng các hàm trong `common/utils.sh` để có output đẹp
3. **Exit codes**: Return 0 nếu pass, 1 nếu fail
4. **Cleanup**: Xóa test data sau khi test xong
5. **Idempotent**: Test có thể chạy nhiều lần mà không ảnh hưởng lẫn nhau

---

**Happy Testing! 🎉**

