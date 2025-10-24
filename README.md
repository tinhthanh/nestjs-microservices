# NestJS Microservices Architecture with File Management

Kiến trúc microservices sẵn sàng cho production, xây dựng với NestJS, gRPC, PostgreSQL, Redis, **Traefik v3.0 API Gateway** và Dufs File Server.

---

### 🎯 Tổng quan

Dự án này là một hệ thống backend được xây dựng theo mô hình microservices, bao gồm:

*   **Traefik v3.0 API Gateway:**
    - Cổng vào duy nhất cho tất cả requests (port 8000)
    - Routing thông minh dựa trên path prefix
    - **JWT authentication qua ForwardAuth middleware**
    - Rate limiting với các mức khác nhau cho từng route
    - Security headers và access logging
    - Dashboard cho monitoring (development mode - port 8080)

*   **Auth Service (Port 9001 HTTP / 50051 gRPC):**
    - Quản lý xác thực, người dùng, JWT tokens
    - Tích hợp Firebase authentication cho partners
    - **Endpoint `/v1/auth/verify-token` cho Traefik ForwardAuth**
    - gRPC service cho inter-service communication

*   **Post Service (Port 9002 HTTP / 50052 gRPC):**
    - Quản lý các bài viết (CRUD operations)
    - Xác thực qua gRPC với Auth Service

*   **DUFS Service (Port 5000):**
    - File server hiệu năng cao (Rust-based)
    - Upload, download, delete files
    - **Được bảo vệ bởi JWT tại Traefik Gateway**
    - Không cần tự xác thực - Traefik xử lý authentication

*   **PostgreSQL & Redis:**
    - Database và cache layer
    - Centralized migrations

> **Để hiểu rõ hơn về kiến trúc, hãy đọc [ARCHITECTURE.md](./ARCHITECTURE.md).**

---

### ✨ Tính năng Nổi bật

- ✅ **Modern API Gateway**: Traefik v3.0 với ForwardAuth middleware
- ✅ **Centralized JWT Authentication**: Authentication tại Gateway layer
- ✅ **Microservices Architecture**: Loosely coupled services
- ✅ **gRPC Communication**: High-performance inter-service communication
- ✅ **Rate Limiting**: Configurable per-route rate limits
- ✅ **Health Checks**: Automatic service health monitoring
- ✅ **Firebase Integration**: Partner authentication support
- ✅ **File Management**: High-performance Rust-based file server
- ✅ **Docker Support**: Full containerization with Docker Compose
- ✅ **Development Dashboard**: Traefik dashboard for monitoring

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
*   **Traefik Gateway**: http://localhost:8000 (API Gateway)
*   **Traefik Dashboard**: http://localhost:8080 (Monitoring UI)
*   `Auth Service`: http://localhost:3001 (với hot-reload)
*   `Post Service`: http://localhost:3002 (với hot-reload)
*   `PostgreSQL`, `Redis`, `DUFS Service` trong Docker

**Truy cập API qua Traefik:**
- Auth: http://localhost:8000/auth/*
- User: http://localhost:8000/v1/user/*
- Partner: http://localhost:8000/v1/partner/*
- Post: http://localhost:8000/post/*
- Files: http://localhost:8000/files/* (requires JWT)

#### Production Mode (All in Docker)

```bash
# Start production environment (migrations run automatically)
./prod.sh

# Run tests (test users created automatically)
./prod.run
```

**Production setup:**
*   Chỉ expose port `8000` (Traefik Gateway)
*   Tất cả services khác chạy internal trong Docker network
*   Traefik Dashboard **disabled** cho security
*   All requests phải đi qua Traefik Gateway
*   Migrations run automatically via Docker entrypoint scripts
*   Test users created automatically by k6 tests

#### Kiểm tra hệ thống

```bash
# Health check
curl http://localhost:8000/ping  # Traefik health

# Chạy integration tests
./dev.run   # Development environment tests
./prod.run  # Production environment tests

# Chạy tất cả unit tests
./run-all-tests.sh
```

---

### 📚 Tài liệu chính

*   **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Sơ đồ kiến trúc hệ thống.
*   **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**: Hướng dẫn triển khai production.
*   **[QUICK_START.md](./QUICK_START.md)**: Hướng dẫn nhanh các lệnh và endpoints.

---

### 🌐 API Endpoints chính

**Tất cả requests phải đi qua Traefik Gateway: `http://localhost:8000`**

#### Auth Service Endpoints

| Method | Endpoint | Description | Auth | Rate Limit |
|--------|----------|-------------|------|------------|
| POST | `/auth/signup` | Đăng ký người dùng mới | Public | 100/min |
| POST | `/auth/login` | Đăng nhập và nhận JWT tokens | Public | 100/min |
| GET | `/auth/refresh` | Làm mới access token | Public | 100/min |
| GET | `/v1/user/profile` | Lấy thông tin user | **JWT** | - |
| PUT | `/v1/user/profile` | Cập nhật thông tin user | **JWT** | - |
| GET | `/v1/partner/verify` | Xác thực Firebase token | Public | 50/min |

#### Post Service Endpoints

| Method | Endpoint | Description | Auth | Rate Limit |
|--------|----------|-------------|------|------------|
| GET | `/post` | Lấy danh sách bài viết | **JWT** | 200/min |
| POST | `/post` | Tạo bài viết mới | **JWT** | 200/min |
| GET | `/post/:id` | Lấy chi tiết bài viết | **JWT** | 200/min |
| PUT | `/post/:id` | Cập nhật bài viết | **JWT** | 200/min |
| DELETE | `/post/:id` | Xóa bài viết | **JWT** | 200/min |

#### File Service Endpoints (JWT Required)

| Method | Endpoint | Description | Auth | Rate Limit |
|--------|----------|-------------|------|------------|
| **PUT** | **/files/{filename}** | **Upload file** | **JWT** | Global |
| **GET** | **/files/{filename}** | **Download file** | **JWT** | Global |
| **DELETE** | **/files/{filename}** | **Xóa file** | **JWT** | Global |

**Note:**
- File endpoints được bảo vệ bởi **Traefik ForwardAuth middleware**
- Traefik tự động xác thực JWT token với Auth Service trước khi forward request đến DUFS
- DUFS Service không cần tự xác thực

---

### 🔐 JWT Authentication Flow

```bash
# 1. Login để lấy access token
curl -X POST http://localhost:8000/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Response:
# {
#   "data": {
#     "accessToken": "eyJhbGc...",
#     "refreshToken": "eyJhbGc..."
#   }
# }

# 2. Sử dụng access token để upload file
curl -X PUT http://localhost:8000/files/document.pdf \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/pdf" \
  --data-binary @document.pdf

# 3. Traefik sẽ:
#    - Forward auth request đến Auth Service (/v1/auth/verify-token)
#    - Nếu token hợp lệ, forward request đến DUFS Service
#    - Nếu token không hợp lệ, trả về 401 Unauthorized
```

---

### 🧪 Testing

#### Integration Tests

```bash
# Development environment tests (17 test cases)
./dev.sh    # Start development environment
./dev.run   # Run all integration tests

# Production environment tests (17 test cases)
./prod.sh   # Start production environment
./prod.run  # Run all integration tests
```

#### Unit Tests

```bash
# Run all unit tests
./run-all-tests.sh

# Run tests for specific service
cd auth && npm test
cd post && npm test
```

---

### 📊 Traefik Dashboard (Development Only)

Khi chạy development mode, Traefik Dashboard sẽ available tại:

**URL:** http://localhost:8080

**Features:**
- 📊 Real-time monitoring của tất cả requests
- 🔀 View routers và routing rules
- 🎯 View services và health status
- 🔧 View middlewares (rate limiting, JWT auth, headers)
- 📈 Request metrics và statistics

**Useful for:**
- Debug routing issues
- Monitor service health
- View JWT authentication flow
- Analyze request patterns và performance

---

## 📚 Documentation

### Getting Started

- **[Quick Start Guide](./QUICK_START.md)** - Get started in 5 minutes
- **[Setup Guide](./docs/SETUP_GUIDE.md)** - Complete setup for Dev & Prod environments
- **[Migration Guide](./docs/MIGRATION_GUIDE.md)** - Database migration workflows

### Architecture & Design

- **[Project Overview](./PROJECT_OVERVIEW.md)** - High-level architecture and technology stack
- **[Architecture](./ARCHITECTURE.md)** - Detailed system architecture with diagrams
- **[Database Architecture](./DATABASE_ARCHITECTURE.md)** - Multi-schema database design

### Deployment & Operations

- **[Deployment Guide](./DEPLOYMENT_GUIDE.md)** - Production deployment instructions
- **[Traefik Migration](./TRAEFIK_MIGRATION.md)** - Kong to Traefik migration guide

### Service Documentation

- **[Auth Service](./docs/services/auth_service.md)** - Authentication and user management
- **[Post Service](./docs/services/post_service.md)** - Post management service
- **[Database Schema](./docs/architecture/database_schema.md)** - Database design and relationships

---

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## 📄 License

This project is licensed under the MIT License.
