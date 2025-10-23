# 📋 Tổng quan Dự án - NestJS Microservices & File Management

> **Mục đích:** Cung cấp cho AI và Lập trình viên mới một cái nhìn toàn diện về dự án chỉ trong một file duy nhất.

---

### 1. 🎯 Mục tiêu & Bối cảnh

*   **Tên dự án:** Hệ thống Microservices quản lý Người dùng, Bài viết và Files.
*   **Mục tiêu kinh doanh:** Xây dựng một nền tảng backend có khả năng mở rộng, cho phép quản lý xác thực người dùng, nội dung bài viết và lưu trữ file một cách độc lập và an toàn.
*   **Vấn đề giải quyết:** Tách biệt logic nghiệp vụ phức tạp thành các dịch vụ nhỏ, dễ phát triển, bảo trì, triển khai độc lập và cung cấp một giải pháp quản lý file tập trung, bảo mật.

---

### 2. 🏗️ Kiến trúc Tổng thể

*   **Mô hình:** Microservices.
*   **Giao tiếp:**
    *   **Client -> Backend:** RESTful API qua Traefik API Gateway.
    *   **Service <-> Service:** gRPC để tối ưu hiệu năng.
*   **Các thành phần chính:**
    1.  **Traefik API Gateway:** Cổng vào duy nhất, xử lý routing, rate limiting, logging, và xác thực JWT cho các route yêu cầu.
    2.  **Auth Service:** Quản lý mọi thứ liên quan đến người dùng: đăng ký, đăng nhập, JWT, phân quyền (roles), tích hợp Firebase.
    3.  **Post Service:** Quản lý các bài viết (CRUD), tìm kiếm, phân trang.
    4.  **Dufs Service:** Dịch vụ quản lý file chuyên dụng, xử lý upload, download, và lưu trữ file an toàn.
    5.  **PostgreSQL:** Cơ sở dữ liệu quan hệ chính, lưu trữ dữ liệu cho Auth và Post service.
    6.  **Redis:** Dùng cho caching để tăng tốc độ truy vấn và quản lý session.

> *Xem chi tiết sơ đồ và luồng giao tiếp tại [ARCHITECTURE.md](./ARCHITECTURE.md).*

---

### 3. ✨ Tính năng Cốt lõi

#### Module `Auth Service`
*   ✅ Đăng ký, Đăng nhập bằng Email/Password.
*   ✅ Quản lý JWT (Access Token & Refresh Token) với `issuer` là `backend-works-app`.
*   ✅ Tích hợp xác thực với Partner qua Firebase.
*   ✅ Cung cấp gRPC endpoint `ValidateToken` cho các service khác xác thực.

#### Module `Post Service`
*   ✅ Quản lý bài viết (CRUD).
*   ✅ Tích hợp với Auth Service qua gRPC để xác thực người tạo/chỉnh sửa bài viết.

#### Module `Dufs Service` (File Management)
*   ✅ Upload file an toàn qua API Gateway.
*   ✅ Download file.
*   ✅ Xóa file.
*   ✅ Được bảo vệ bởi JWT, yêu cầu Access Token hợp lệ do Auth Service cấp.

---

### 4. 🔄 Luồng Nghiệp vụ Chính

#### Luồng Đăng ký và Tạo bài viết:
1.  **Client** gửi request `POST /auth/signup` đến **Traefik Gateway**.
2.  **Traefik** chuyển tiếp request đến **Auth Service**.
3.  **Auth Service** tạo user trong **PostgreSQL** và trả về `accessToken` & `refreshToken`.
4.  **Client** dùng `accessToken` gửi request `POST /post` đến **Traefik Gateway**.
5.  **Traefik** chuyển tiếp đến **Post Service**.
6.  **Post Service** gọi đến gRPC `ValidateToken` của **Auth Service** để xác thực token.
7.  **Auth Service** xác nhận token hợp lệ, trả về `userId`.
8.  **Post Service** tạo bài viết trong **PostgreSQL** với `createdBy = userId`.

#### Luồng Upload File:
1.  **Client** đăng nhập và nhận `accessToken` từ **Auth Service**.
2.  **Client** gửi request `PUT /files/{tên-file}` đến **Traefik Gateway**, đính kèm `Authorization: Bearer <accessToken>` và nội dung file.
3.  **Traefik** sử dụng plugin **JWT** để xác thực `accessToken`. Token phải hợp lệ và có `key` (issuer) là `backend-works-app`.
4.  Nếu token hợp lệ, **Traefik** chuyển tiếp request đến **Dufs Service**.
5.  **Dufs Service** lưu file vào thư mục `managed_files` trên server.

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
