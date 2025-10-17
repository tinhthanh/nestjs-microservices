# NestJS Microservices Architecture (Tối ưu cho AI)

[![NestJS](https://img.shields.io/badge/NestJS-10.x-red.svg)](https://nestjs.com/)
[![Docker](https://img.shields.io/badge/Docker-20.x-blue.svg)](https://docker.com/)
[![gRPC](https://img.shields.io/badge/gRPC-latest-brightgreen.svg)](https://grpc.io/)

Kiến trúc microservices sẵn sàng cho production, xây dựng với NestJS, gRPC, PostgreSQL, Redis và Kong API Gateway.

---

### 🚀 Bắt đầu Nhanh (5 phút)

1.  **Clone và cài đặt submodules:**
    ```bash
    git clone [your-repo-url] && cd [your-repo]
    git submodule update --init --recursive
    ```

2.  **Khởi chạy các services:**
    ```bash
    docker-compose up -d
    ```

3.  **Chạy database migrations:**
    ```bash
    docker-compose exec auth-service npm run prisma:migrate
    docker-compose exec post-service npm run prisma:migrate
    ```

4.  **Kiểm tra nhanh:**
    ```bash
    ./test-scripts/quick-test.sh
    ```

---

### 📚 **Tài liệu & Kiến trúc**

> **Để hiểu rõ dự án, hãy bắt đầu với các file sau:**

*   **⭐ [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md)**: **(Đọc file này đầu tiên)** Cung cấp cái nhìn tổng quan toàn diện về mục tiêu, tính năng và các thành phần chính của dự án.
*   **🏗️ [ARCHITECTURE.md](./ARCHITECTURE.md)**: Sơ đồ kiến trúc hệ thống và luồng giao tiếp chi tiết.
*   **📖 [docs/](./docs/)**: Thư mục chứa tất cả các tài liệu chi tiết khác (API, Hướng dẫn, ...).
