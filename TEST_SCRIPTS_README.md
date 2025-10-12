# API Test Scripts Documentation

## 📋 Tổng quan

Bộ test scripts này cung cấp các công cụ để test toàn bộ API endpoints của hệ thống NestJS Microservices thông qua curl commands.

## 🔧 Yêu cầu

- `curl` - Command line tool để gửi HTTP requests
- `jq` - Command line JSON processor (để format output đẹp hơn)
- Docker và Docker Compose (để chạy services)

### Cài đặt jq (nếu chưa có)

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

## 🚀 Cách sử dụng

### 1. Khởi động services

Trước khi chạy tests, đảm bảo tất cả services đang chạy:

```bash
docker-compose up -d
```

Kiểm tra services đã sẵn sàng:

```bash
docker-compose ps
```

### 2. Chạy từng test riêng lẻ

Mỗi test script có thể chạy độc lập:

```bash
# Cấp quyền thực thi (chỉ cần làm 1 lần)
chmod +x test-*.sh

# Test health check
./test-health-check.sh

# Test signup
./test-signup.sh

# Test login
./test-auth-login.sh

# Test refresh token
./test-refresh-token.sh

# Test user profile
./test-user-profile.sh

# Test update user
./test-user-update.sh

# Test create post
./test-post-create.sh

# Test list posts
./test-post-list.sh

# Test update post
./test-post-update.sh

# Test delete posts
./test-post-delete.sh
```

### 3. Chạy tất cả tests

Chạy toàn bộ test suite:

```bash
chmod +x test-all.sh
./test-all.sh
```

## 📝 Mô tả các test scripts

### 1. `test-health-check.sh`
- **Mục đích**: Kiểm tra health status của tất cả services
- **Endpoints**: 
  - Kong Gateway: `http://localhost:8000/`
  - Auth Service: `http://localhost:8000/auth/health`
  - Post Service: `http://localhost:8000/post/health`
- **Không cần**: Authentication

### 2. `test-signup.sh`
- **Mục đích**: Đăng ký user mới
- **Endpoint**: `POST /auth/signup`
- **Payload**:
  ```json
  {
    "email": "user@example.com",
    "password": "User123456",
    "name": "Regular User"
  }
  ```
- **Response**: Access token và refresh token

### 3. `test-auth-login.sh`
- **Mục đích**: Đăng nhập user
- **Endpoint**: `POST /auth/login`
- **Payload**:
  ```json
  {
    "email": "user@example.com",
    "password": "User123456"
  }
  ```
- **Response**: Access token và refresh token

### 4. `test-refresh-token.sh`
- **Mục đích**: Làm mới access token
- **Endpoint**: `GET /auth/refresh`
- **Authentication**: Refresh token (Bearer)
- **Flow**:
  1. Login để lấy refresh token
  2. Sử dụng refresh token để lấy access token mới

### 5. `test-user-profile.sh`
- **Mục đích**: Lấy thông tin profile của user
- **Endpoint**: `GET /user/profile`
- **Authentication**: Access token (Bearer)
- **Flow**:
  1. Login để lấy access token
  2. Gọi API để lấy profile

### 6. `test-user-update.sh`
- **Mục đích**: Cập nhật thông tin profile
- **Endpoint**: `PUT /user/profile`
- **Authentication**: Access token (Bearer)
- **Payload**:
  ```json
  {
    "name": "Updated User Name"
  }
  ```

### 7. `test-post-create.sh`
- **Mục đích**: Tạo post mới
- **Endpoint**: `POST /post`
- **Authentication**: Access token (Bearer)
- **Payload**:
  ```json
  {
    "title": "My First Post",
    "content": "This is the content of my first post."
  }
  ```

### 8. `test-post-list.sh`
- **Mục đích**: Lấy danh sách posts (có pagination)
- **Endpoint**: `GET /post?page=1&limit=10`
- **Authentication**: Access token (Bearer)
- **Query params**:
  - `page`: Số trang (default: 1)
  - `limit`: Số items per page (default: 10)

### 9. `test-post-update.sh`
- **Mục đích**: Cập nhật post
- **Endpoint**: `PUT /post/:id`
- **Authentication**: Access token (Bearer)
- **Flow**:
  1. Login để lấy access token
  2. Lấy danh sách posts để tìm post ID
  3. Cập nhật post với ID đó

### 10. `test-post-delete.sh`
- **Mục đích**: Xóa nhiều posts (batch delete)
- **Endpoint**: `DELETE /post/batch`
- **Authentication**: Access token (Bearer)
- **Flow**:
  1. Login để lấy access token
  2. Lấy danh sách posts để tìm post IDs
  3. Xóa các posts đó

## 🧪 Kết quả Unit Tests

### Auth Service Tests
```
Test Suites: 2 failed, 4 passed, 6 total
Tests:       8 failed, 80 passed, 88 total
Coverage:    100% statements, 98.55% branches, 100% functions, 100% lines
```

**Failed Tests:**
- `user.auth.service.spec.ts`: 4 tests về NotFoundException handling
- `database.service.spec.ts`: 4 tests về emoji trong log messages

### Post Service Tests
```
Test Suites: 2 failed, 4 passed, 6 total
Tests:       101 passed, 101 total
Coverage:    72.57% statements, 93.65% branches, 77.14% functions, 71.25% lines
```

**Failed Tests:**
- `grpc.auth.service.spec.ts`: TypeScript compilation errors
- `database.service.spec.ts`: Constructor parameter mismatch

## 🔍 Troubleshooting

### Lỗi: "Failed to get access token"
- Kiểm tra user đã được tạo chưa bằng cách chạy `./test-signup.sh` trước
- Kiểm tra email/password có đúng không
- Kiểm tra auth service có đang chạy không

### Lỗi: "No posts found"
- Chạy `./test-post-create.sh` để tạo posts trước
- Kiểm tra post service có đang chạy không

### Lỗi: "Connection refused"
- Kiểm tra Docker containers có đang chạy không: `docker-compose ps`
- Khởi động lại services: `docker-compose restart`
- Kiểm tra logs: `docker-compose logs -f`

### Lỗi: "jq: command not found"
- Cài đặt jq theo hướng dẫn ở phần Yêu cầu
- Hoặc xóa `| jq .` khỏi các commands (output sẽ không được format)

## 📊 API Endpoints Summary

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/auth/signup` | ❌ | Đăng ký user mới |
| POST | `/auth/login` | ❌ | Đăng nhập |
| GET | `/auth/refresh` | ✅ (Refresh Token) | Làm mới token |
| GET | `/user/profile` | ✅ | Lấy thông tin profile |
| PUT | `/user/profile` | ✅ | Cập nhật profile |
| POST | `/post` | ✅ | Tạo post mới |
| GET | `/post` | ✅ | Lấy danh sách posts |
| PUT | `/post/:id` | ✅ | Cập nhật post |
| DELETE | `/post/batch` | ✅ | Xóa nhiều posts |

## 🎯 Best Practices

1. **Chạy health check trước**: Luôn kiểm tra services đã sẵn sàng
2. **Tạo user trước**: Chạy signup trước khi test các endpoints cần auth
3. **Tạo data trước**: Tạo posts trước khi test update/delete
4. **Kiểm tra logs**: Nếu có lỗi, xem logs của services
5. **Clean up**: Xóa test data sau khi test xong

## 📚 Tài liệu tham khảo

- [NestJS Documentation](https://docs.nestjs.com/)
- [Kong Gateway Documentation](https://docs.konghq.com/)
- [curl Documentation](https://curl.se/docs/)
- [jq Manual](https://stedolan.github.io/jq/manual/)

