# NestJS Microservices Architecture with File Management

Kiến trúc microservices sẵn sàng cho production, xây dựng với NestJS, gRPC, PostgreSQL, Redis, Kong API Gateway và Dufs File Server.

---

### 🎯 Tổng quan

Dự án này là một hệ thống backend được xây dựng theo mô hình microservices, bao gồm:
*   **Auth Service:** Quản lý xác thực, người dùng, và tích hợp Firebase.
*   **Post Service:** Quản lý các bài viết (posts).
*   **Dufs Service:** Dịch vụ quản lý file hiệu năng cao, xử lý upload/download.
*   **Kong API Gateway:** Cổng vào duy nhất, xử lý routing và xác thực JWT cho file service.
*   **Centralized Migrations:** Cơ chế quản lý database schema tập trung.

> **Để hiểu rõ hơn về kiến trúc, hãy đọc [ARCHITECTURE.md](./ARCHITECTURE.md).**

---

### 🚀 Bắt đầu Nhanh

#### Yêu cầu:
*   Docker & Docker Compose
*   Node.js >= 18.0 (chỉ cho development)

#### Development Mode (Local Services + Docker Infrastructure)

```bash
# Start development environment
./dev.sh
```
**Services sẽ chạy:**
*   `Auth Service`: http://localhost:3001
*   `Post Service`: http://localhost:3002
*   `Kong Gateway`: http://localhost:8000
*   `PostgreSQL`, `Redis`, `Dufs Service` trong Docker.

#### Production Mode (All in Docker)

```bash
# Start production environment
./prod.sh

# Lần đầu chạy, cần áp dụng migration:
# cd migrations && npm run migrate:deploy:prod && cd ..
```
*   Chỉ expose port `8000` (Kong Gateway).
*   Tất cả services khác (auth, post, dufs) chạy internal trong Docker network.

#### Kiểm tra hệ thống

```bash
# Chạy tất cả unit tests
./run-all-tests.sh

# Chạy kịch bản kiểm thử luồng quản lý file
./test-scripts/test-dufs-flow.sh
```

---

### 📚 Tài liệu chính

*   **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Sơ đồ kiến trúc hệ thống.
*   **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**: Hướng dẫn triển khai production.
*   **[QUICK_START.md](./QUICK_START.md)**: Hướng dẫn nhanh các lệnh và endpoints.

---

###  API Endpoints chính

| Method | Endpoint | Service | Description | Auth |
|---|---|---|---|---|
| POST | `/auth/signup` | Auth | Đăng ký người dùng mới. | Public |
| POST | `/auth/login` | Auth | Đăng nhập và nhận JWT tokens. | Public |
| GET | `/v1/partner/verify`| Auth | Xác thực Firebase token từ đối tác. | Public |
| GET | `/post` | Post | Lấy danh sách bài viết. | **JWT** |
| POST | `/post` | Post | Tạo bài viết mới. | **JWT** |
| **PUT** | **/files/{filename}** | **Dufs** | **Upload một file.** | **JWT** |
| **GET** | **/files/{filename}** | **Dufs** | **Tải một file.** | **JWT** |
| **DELETE**| **/files/{filename}** | **Dufs** | **Xóa một file.** | **JWT** |

---
### 🧪 Chạy Thử nghiệm API

Các script trong `test-scripts/` cho phép bạn nhanh chóng kiểm tra các luồng API chính.

```bash
# Test luồng xác thực qua partner (Firebase)
./test-scripts/test-partner-verify.sh

# Test luồng đăng ký và đăng nhập
./test-scripts/test-signup.sh
./test-scripts/test-auth-login.sh

# Test luồng quản lý bài viết (yêu cầu đăng nhập)
./test-scripts/test-post-create.sh
./test-scripts/test-post-list.sh

# Test luồng quản lý file end-to-end (yêu cầu đăng nhập)
./test-scripts/test-dufs-flow.sh
```
