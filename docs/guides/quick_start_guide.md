# 🚀 Hướng dẫn Cài đặt & Khởi chạy Chi tiết

Tài liệu này cung cấp các bước chi tiết để cài đặt môi trường, khởi chạy hệ thống và xác minh hoạt động.

### 1. 📋 Yêu cầu Môi trường

Đảm bảo bạn đã cài đặt các công cụ sau trên máy của mình:

- **🐳 Docker & Docker Compose**: Để chạy các service dưới dạng container.
- **🟢 Node.js >= 18.0.0**: Cho việc phát triển cục bộ (nếu cần).
- **📦 npm >= 9.0.0**: Quản lý package.
- **📝 Git**: Hệ thống quản lý phiên bản.

### 2. ⚡ Cài đặt

#### Bước 2.1: Clone Repository và Submodules

```bash
# Clone repository chính
git clone https://github.com/your-username/nestjs-microservices.git
cd nestjs-microservices

# Khởi tạo và clone code từ các submodules (auth, post)
git submodule update --init --recursive
```

#### Bước 2.2: Cấu hình Môi trường

Dự án đã bao gồm các file môi trường được cấu hình sẵn cho Docker:
- `auth/.env.docker`
- `post/.env.docker`

Bạn không cần thay đổi gì để chạy ở môi trường local. Các biến môi trường này chỉ định cổng, chuỗi kết nối đến database và Redis trong mạng Docker nội bộ.

### 3. 🐳 Khởi chạy Hệ thống với Docker

Đây là cách được khuyến khích để chạy toàn bộ hệ thống.

#### Bước 3.1: Start tất cả Services

```bash
# Lệnh này sẽ build images (nếu cần) và khởi chạy tất cả các container
docker-compose up -d
```

#### Bước 3.2: Theo dõi Logs (Tùy chọn)

Để xem log của tất cả các service trong thời gian thực:
```bash
docker-compose logs -f
```
Để xem log của một service cụ thể (ví dụ: `auth-service`):
```bash
docker-compose logs -f auth-service
```

#### Bước 3.3: Dừng các Services
```bash
# Dừng và xóa các container
docker-compose down
```

### 4. 🗄️ Thiết lập Cơ sở dữ liệu

Sau khi các container đã khởi chạy, bạn cần chạy migration để tạo các bảng trong database.

```bash
# Chạy migration cho Auth Service
docker-compose exec auth-service npm run prisma:migrate

# Chạy migration cho Post Service
docker-compose exec post-service npm run prisma:migrate

# (Tùy chọn) Generate lại Prisma client nếu có thay đổi schema
docker-compose exec auth-service npm run prisma:generate
docker-compose exec post-service npm run prisma:generate
```

### 5. ✅ Xác minh Hoạt động

Sau khi hoàn tất các bước trên, hãy kiểm tra xem hệ thống có hoạt động đúng không.

#### Bước 5.1: Kiểm tra Trạng thái Container
```bash
docker-compose ps
```
Bạn sẽ thấy tất cả các service (kong, auth-service, post-service, postgres, redis) đều có trạng thái `Up` hoặc `running`.

#### Bước 5.2: Kiểm tra các Health Endpoints
```bash
# Kiểm tra health của Auth Service (qua Kong)
curl http://localhost:8000/auth/health

# Kiểm tra health của Post Service (qua Kong)
curl http://localhost:8000/post/health
```
Cả hai lệnh trên đều phải trả về JSON với `status: "ok"`.

#### Bước 5.3: Chạy Script Kiểm tra Nhanh
Dự án cung cấp một script để tự động thực hiện một loạt các kiểm tra cơ bản.
```bash
./scripts/quick-test.sh
```
Script này sẽ kiểm tra health, thử đăng ký, tạo bài viết và lấy danh sách bài viết.

---

Chúc mừng! Hệ thống của bạn đã sẵn sàng để sử dụng và phát triển.
