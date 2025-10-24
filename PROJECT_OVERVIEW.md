# 📋 Tổng quan Dự án - NestJS Microservices & File Management

> **Mục đích:** Cung cấp cho AI và Lập trình viên mới một cái nhìn toàn diện về dự án chỉ trong một file duy nhất.

---

### 1. 🎯 Mục tiêu & Bối cảnh

*   **Tên dự án:** Hệ thống Microservices quản lý Người dùng, Bài viết và Files.
*   **Mục tiêu kinh doanh:** Xây dựng một nền tảng backend có khả năng mở rộng, cho phép quản lý xác thực người dùng, nội dung bài viết và lưu trữ file một cách độc lập và an toàn.
*   **Vấn đề giải quyết:** Tách biệt logic nghiệp vụ phức tạp thành các dịch vụ nhỏ, dễ phát triển, bảo trì, triển khai độc lập và cung cấp một giải pháp quản lý file tập trung, bảo mật.

---

### 2. 🏗️ Kiến trúc Tổng thể

*   **Mô hình:** Microservices với API Gateway pattern.
*   **Giao tiếp:**
    *   **Client -> Backend:** RESTful API qua **Traefik v3.0** API Gateway.
    *   **Service <-> Service:** gRPC để tối ưu hiệu năng.
*   **Các thành phần chính:**
    1.  **Traefik v3.0 API Gateway (Port 8000):**
        - Cổng vào duy nhất cho tất cả requests
        - Xử lý routing dựa trên path prefix
        - Rate limiting với các mức khác nhau cho từng route
        - JWT authentication qua ForwardAuth middleware
        - Security headers và logging
        - Dashboard cho monitoring (development mode)

    2.  **Auth Service (Port 9001 HTTP / 50051 gRPC):**
        - Quản lý người dùng: đăng ký, đăng nhập, profile
        - JWT token generation và validation
        - Phân quyền (ADMIN/USER roles)
        - Tích hợp Firebase authentication cho partners
        - **Endpoint `/v1/auth/verify-token` cho Traefik ForwardAuth**
        - gRPC service cho inter-service authentication

    3.  **Post Service (Port 9002 HTTP / 50052 gRPC):**
        - Quản lý bài viết (CRUD operations)
        - Tìm kiếm và phân trang
        - Xác thực qua gRPC với Auth Service

    4.  **DUFS Service (Port 5000):**
        - File server hiệu năng cao (Rust-based)
        - Upload, download, delete files
        - **Được bảo vệ bởi JWT tại Traefik Gateway**
        - Không cần tự xác thực - Traefik xử lý authentication
        - Lưu trữ files trong `./managed_files`

    5.  **PostgreSQL (Port 5435):**
        - Cơ sở dữ liệu quan hệ chính
        - Schema `users` (Auth Service)
        - Schema `posts` (Post Service)
        - Centralized migrations

    6.  **Redis (Port 6379):**
        - Caching để tăng tốc độ truy vấn
        - Session management
        - Refresh token storage

> *Xem chi tiết sơ đồ và luồng giao tiếp tại [ARCHITECTURE.md](./ARCHITECTURE.md).*

---

### 3. ✨ Tính năng Cốt lõi

#### Module `Auth Service`
*   ✅ Đăng ký, Đăng nhập bằng Email/Password
*   ✅ Quản lý JWT (Access Token & Refresh Token) với `issuer` là `backend-works-app`
*   ✅ Tích hợp xác thực với Partner qua Firebase
*   ✅ Cung cấp gRPC endpoint `ValidateToken` cho các service khác
*   ✅ **Endpoint `/v1/auth/verify-token` cho Traefik ForwardAuth middleware**

#### Module `Post Service`
*   ✅ Quản lý bài viết (CRUD)
*   ✅ Tích hợp với Auth Service qua gRPC để xác thực người tạo/chỉnh sửa bài viết

#### Module `DUFS Service` (File Management)
*   ✅ Upload file an toàn qua API Gateway
*   ✅ Download file
*   ✅ Xóa file
*   ✅ **Được bảo vệ bởi JWT authentication tại Traefik Gateway**
*   ✅ **Traefik sử dụng ForwardAuth để xác thực token với Auth Service**
*   ✅ DUFS không cần tự xác thực - authentication được xử lý tại Gateway

#### Module `Traefik API Gateway`
*   ✅ Routing dựa trên path prefix (`/auth`, `/post`, `/files`, `/v1/user`, `/v1/partner`)
*   ✅ Rate limiting với các mức khác nhau:
    - Global: 300 req/min
    - Auth routes: 100 req/min
    - Post routes: 200 req/min
    - Partner routes: 50 req/min
*   ✅ **JWT authentication qua ForwardAuth middleware cho `/files` routes**
*   ✅ Path stripping để forward request đúng format đến backend
*   ✅ Security headers (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)
*   ✅ Health checks cho tất cả backend services
*   ✅ Dashboard cho monitoring (development mode)

---

### 4. 🔄 Luồng Nghiệp vụ Chính

#### Luồng Đăng ký và Tạo bài viết:
1.  **Client** gửi request `POST /auth/signup` đến **Traefik Gateway** (port 8000)
2.  **Traefik** áp dụng middlewares:
    - Auth rate limiting (100 req/min)
    - Strip `/auth` prefix
    - Security headers
3.  **Traefik** forward request đến **Auth Service**: `POST http://auth-service:9001/v1/auth/signup`
4.  **Auth Service** tạo user trong **PostgreSQL** và trả về `accessToken` & `refreshToken`
5.  **Client** dùng `accessToken` gửi request `POST /post` đến **Traefik Gateway**
6.  **Traefik** forward đến **Post Service**: `POST http://post-service:9002/v1/post`
7.  **Post Service** gọi gRPC `ValidateToken` của **Auth Service** để xác thực token
8.  **Auth Service** xác nhận token hợp lệ, trả về `userId`
9.  **Post Service** tạo bài viết trong **PostgreSQL** với `createdBy = userId`

#### Luồng Upload File với JWT Authentication:
1.  **Client** đăng nhập và nhận `accessToken` từ **Auth Service**
2.  **Client** gửi request `PUT /files/document.pdf` đến **Traefik Gateway**:
    ```
    PUT /files/document.pdf
    Authorization: Bearer eyJhbGc...
    Content-Type: application/pdf
    [File content]
    ```
3.  **Traefik** áp dụng **ForwardAuth middleware**:
    - Forward authentication request đến `http://auth-service:9001/v1/auth/verify-token`
    - Gửi header `Authorization: Bearer eyJhbGc...`
4.  **Auth Service** xác thực token:
    - Kiểm tra signature với secret key
    - Kiểm tra expiration time
    - Kiểm tra issuer (`backend-works-app`)
    - Trích xuất user information
5.  Nếu token **hợp lệ**:
    - Auth Service trả về `200 OK` với headers `X-User-Id`, `X-User-Role`
    - Traefik thêm headers này vào request gốc
    - Traefik strip `/files` prefix
    - Traefik forward request đến **DUFS Service**: `PUT http://dufs-service:5000/document.pdf`
    - DUFS lưu file vào `./managed_files/document.pdf`
6.  Nếu token **không hợp lệ**:
    - Auth Service trả về `401 Unauthorized`
    - Traefik dừng request và trả lỗi về client
    - DUFS không nhận được request

**Lợi ích:**
- ✅ Authentication được xử lý tại Gateway (centralized)
- ✅ DUFS Service không cần implement JWT validation
- ✅ Dễ dàng thay đổi authentication logic
- ✅ Giảm tải cho backend services

---

### 5. 🛠️ Công nghệ Sử dụng

*   **Backend:** NestJS, TypeScript, **Rust (Dufs)**
*   **Giao tiếp:** RESTful API, gRPC
*   **Database:** PostgreSQL (với Prisma ORM)
*   **Cache:** Redis
*   **API Gateway:** Traefik
*   **File Server:** Dufs
*   **Containerization:** Docker, Docker Compose

---

### 6. 📚 Tài liệu Tham khảo Nhanh

*   **Kiến trúc hệ thống:** [ARCHITECTURE.md](./ARCHITECTURE.md)
*   **Hướng dẫn triển khai:** [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
*   **Hướng dẫn khởi động nhanh:** [QUICK_START.md](./QUICK_START.md)
