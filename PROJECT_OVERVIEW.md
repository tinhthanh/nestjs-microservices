# 📋 Tổng quan Dự án - NestJS Microservices

> **Mục đích:** Cung cấp cho AI và Lập trình viên mới một cái nhìn toàn diện về dự án chỉ trong một file duy nhất.

---

### 1. 🎯 Mục tiêu & Bối cảnh

*   **Tên dự án:** Hệ thống Microservices quản lý Người dùng và Bài viết.
*   **Mục tiêu kinh doanh:** Xây dựng một nền tảng backend có khả năng mở rộng, cho phép quản lý xác thực người dùng (authentication) và nội dung bài viết (blog posts) một cách độc lập.
*   **Vấn đề giải quyết:** Tách biệt logic nghiệp vụ phức tạp thành các dịch vụ nhỏ, dễ phát triển, bảo trì và triển khai độc lập.

---

### 2. 🏗️ Kiến trúc Tổng thể

*   **Mô hình:** Microservices.
*   **Giao tiếp:**
    *   **Client -> Backend:** RESTful API qua Kong API Gateway.
    *   **Service <-> Service:** gRPC để tối ưu hiệu năng.
*   **Các thành phần chính:**
    1.  **Kong API Gateway:** Cổng vào duy nhất, xử lý routing, rate limiting, logging.
    2.  **Auth Service:** Quản lý mọi thứ liên quan đến người dùng: đăng ký, đăng nhập, JWT, phân quyền (roles).
    3.  **Post Service:** Quản lý các bài viết (CRUD), tìm kiếm, phân trang.
    4.  **PostgreSQL:** Cơ sở dữ liệu quan hệ chính, lưu trữ dữ liệu cho cả hai service.
    5.  **Redis:** Dùng cho caching để tăng tốc độ truy vấn và quản lý session.

> *Xem chi tiết sơ đồ và luồng giao tiếp tại [ARCHITECTURE.md](./ARCHITECTURE.md).*

---

### 3. ✨ Tính năng Cốt lõi

#### Module `Auth Service`
*   ✅ Đăng ký, Đăng nhập bằng Email/Password.
*   ✅ Quản lý JWT (Access Token & Refresh Token).
*   ✅ Phân quyền dựa trên vai trò (Role-Based Access Control: `ADMIN`, `USER`).
*   ✅ Quản lý thông tin cá nhân (User Profile).
*   ✅ Cung cấp gRPC endpoint `ValidateToken` cho các service khác xác thực.

#### Module `Post Service`
*   ✅ Quản lý bài viết (CRUD: Create, Read, Update, Delete).
*   ✅ Xóa mềm (Soft Delete) để bảo toàn dữ liệu.
*   ✅ Phân trang và tìm kiếm bài viết.
*   ✅ Tích hợp với Auth Service qua gRPC để xác thực người tạo/chỉnh sửa bài viết.
*   ✅ Xóa hàng loạt (Batch Delete).

---

### 4. 🔄 Luồng Nghiệp vụ Chính

#### Luồng Đăng ký và Tạo bài viết:
1.  **Client** gửi request `POST /auth/signup` đến **Kong Gateway**.
2.  **Kong** chuyển tiếp request đến **Auth Service**.
3.  **Auth Service** tạo user trong **PostgreSQL** và trả về `accessToken` & `refreshToken`.
4.  **Client** dùng `accessToken` gửi request `POST /post` đến **Kong Gateway**.
5.  **Kong** chuyển tiếp đến **Post Service**.
6.  **Post Service** gọi đến gRPC `ValidateToken` của **Auth Service** để xác thực token.
7.  **Auth Service** xác nhận token hợp lệ, trả về `userId` và `role`.
8.  **Post Service** tạo bài viết trong **PostgreSQL** với `createdBy = userId`.

---

### 5. 🛠️ Công nghệ Sử dụng

*   **Backend:** NestJS, TypeScript
*   **Giao tiếp:** RESTful API, gRPC
*   **Database:** PostgreSQL (với Prisma ORM)
*   **Cache:** Redis
*   **API Gateway:** Kong
*   **Containerization:** Docker, Docker Compose

---

### 6. 📚 Tài liệu Tham khảo Nhanh

*   **API Specs:** [docs/api/](./docs/api/) (OpenAPI/Swagger YAML files)
*   **Database Schema:** [docs/architecture/database_schema.md](./docs/architecture/database_schema.md)
*   **Hướng dẫn Test:** [docs/guides/testing_guide.md](./docs/guides/testing_guide.md)
*   **Chi tiết Auth Service:** [docs/services/auth_service.md](./docs/services/auth_service.md)
