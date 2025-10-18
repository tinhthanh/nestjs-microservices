# NestJS Microservices Architecture

[![NestJS](https://img.shields.io/badge/NestJS-10.x-red.svg)](https://nestjs.com/)
[![Docker](https://img.shields.io/badge/Docker-20.x-blue.svg)](https://docker.com/)
[![gRPC](https://img.shields.io/badge/gRPC-latest-brightgreen.svg)](https://grpc.io/)

Kiến trúc microservices sẵn sàng cho production, xây dựng với NestJS, gRPC, PostgreSQL, Redis và Kong API Gateway.

---

### 🎯 Tổng quan

Dự án này là một hệ thống backend được xây dựng theo mô hình microservices, bao gồm:
*   **Auth Service:** Quản lý xác thực, người dùng, phân quyền và tích hợp với Firebase để xác thực từ đối tác.
*   **Post Service:** Quản lý các bài viết (posts).
*   **Kong API Gateway:** Cổng vào duy nhất cho tất cả các request từ client.
*   **Centralized Migrations:** Cơ chế quản lý database schema tập trung, đảm bảo an toàn dữ liệu.

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

# Services sẽ chạy:
# - Auth Service: http://localhost:3001
# - Post Service: http://localhost:3002
# - Kong Gateway: http://localhost:8000
# - PostgreSQL, Redis trong Docker

# Stop development environment
./dev-stop.sh
```

#### Production Mode (All in Docker)

```bash
# Start production environment
./prod.sh

# Chỉ expose port 8000 (Kong Gateway)
# Tất cả services khác chạy internal trong Docker network

# Stop production environment
docker-compose -f docker-compose.yml down
```

#### Kiểm tra hệ thống

```bash
# Run all tests
./run-all-tests.sh

# Test API endpoints
./test-scripts/test-partner-verify.sh
```

---

### 📚 Tài liệu chính

*   **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Sơ đồ kiến trúc hệ thống và luồng giao tiếp chi tiết.
*   **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**: Hướng dẫn đầy đủ các bước để triển khai lên môi trường production.
*   **[migrations/README.md](./migrations/README.md)**: Hướng dẫn chi tiết về cách tạo và quản lý database migrations.

---

### 🧪 Chạy Thử nghiệm API

Các script trong thư mục `test-scripts/` cho phép bạn nhanh chóng kiểm tra các luồng API chính.

```bash
# Test luồng đăng ký và đăng nhập
./test-scripts/test-signup.sh
./test-scripts/test-auth-login.sh

# Test luồng tạo và lấy danh sách bài viết (yêu cầu đăng nhập)
./test-scripts/test-post-create.sh
./test-scripts/test-post-list.sh

# Test luồng xác thực qua partner (Firebase)
./test-scripts/test-partner-verify.sh
```

---
###  주요 API 엔드포인트

| Method | Endpoint                    | Service      | Description                               |
|--------|-----------------------------|--------------|-------------------------------------------|
| POST   | `/v1/auth/signup`           | Auth Service | Đăng ký người dùng mới.                     |
| POST   | `/v1/auth/login`            | Auth Service | Đăng nhập và nhận JWT tokens.             |
| GET    | `/v1/auth/refresh`          | Auth Service | Làm mới access token.                     |
| GET    | `/v1/user/profile`          | Auth Service | Lấy thông tin người dùng hiện tại.        |
| GET    | `/v1/partner/verify`        | Auth Service | Xác thực Firebase token từ đối tác.       |
| GET    | `/v1/post`                  | Post Service | Lấy danh sách bài viết (phân trang).      |
| POST   | `/v1/post`                  | Post Service | Tạo bài viết mới.                         |
