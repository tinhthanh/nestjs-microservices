# 🚀 Hướng dẫn Triển khai Production

Tài liệu này mô tả quy trình chuẩn để triển khai hệ thống NestJS Microservices và File Service lên môi trường production.

## 📋 Checklist Trước Khi Deploy

*   [ ] Code đã được merge vào nhánh `main`.
*   [ ] Tất cả unit tests và integration tests đều pass trên CI.
*   [ ] Đã tạo migration mới cho các thay đổi về schema (nếu có).
*   [ ] Đã tạo backup cho database production.
*   **[ ] Đảm bảo thư mục `./managed_files` tồn tại trên server production để lưu trữ file.**
*   [ ] Chuẩn bị kế hoạch rollback.
*   [ ] Đảm bảo các biến môi trường cho production đã được cấu hình đúng.

## 🔄 Quy trình Triển khai

### Giai đoạn 1: Chuẩn bị (10 phút)

1.  **Tạo Backup Database:**
    ```bash
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    pg_dump -h <prod-host> -U <user> -d postgres > backup_prod_${TIMESTAMP}.sql
    ```

2.  **Kiểm tra Trạng thái Hiện tại:**
    ```bash
    # Kiểm tra các services đang chạy
    docker-compose ps
    ```

### Giai đoạn 2: Deploy Migrations (5 phút)

1.  **Áp dụng các migrations mới:**
    ```bash
    cd migrations
    npm run migrate:deploy:prod
    ```

2.  **Xác minh trạng thái migration:**
    ```bash
    npm run migrate:status
    cd ..
    ```

### Giai đoạn 3: Deploy Services (15 phút)

1.  **Pull code mới nhất:**
    ```bash
    git pull origin main
    ```

2.  **Build và khởi chạy lại các services:**
    Lệnh này sẽ build lại image cho `auth-service`, `post-service` và `dufs-service` nếu có thay đổi trong `Dockerfile` hoặc context.
    ```bash
    docker-compose up -d --build
    ```

3.  **Dọn dẹp các images cũ (tùy chọn):**
    ```bash
    docker image prune -f
    ```

### Giai đoạn 4: Xác minh và Giám sát (10 phút)

1.  **Kiểm tra trạng thái các services:**
    ```bash
    docker-compose ps
    # Đảm bảo tất cả services (auth, post, dufs, traefik, postgres, redis) đều "Up" và "healthy"
    ```

2.  **Chạy script kiểm tra toàn diện:**
    Bao gồm cả luồng upload/download file.
    ```bash
    ./test-scripts/test-dufs-flow.sh
    ```

3.  **Theo dõi logs để phát hiện lỗi:**
    ```bash
    docker-compose logs -f --tail=100
    ```

4.  **Giám sát hệ thống** trong 30 phút.

## 🔙 Kế hoạch Rollback

### Trường hợp Service Lỗi
1.  **Nhanh chóng revert lại commit trước đó:** `git revert HEAD`
2.  **Deploy lại phiên bản ổn định:** `docker-compose up -d --build`
3.  Phân tích log để tìm nguyên nhân lỗi.

## 🔐 Thiết lập Firebase cho Production

Để tính năng Partner Verification hoạt động, bạn cần:

1.  **Lấy Service Account Key từ Firebase Console.**
2.  **Cập nhật `private_key` và `client_email`** vào bảng `third_party_integrations` trong database.
    ```sql
    UPDATE third_party_integrations 
    SET 
      private_key = '...',
      client_email = '...'
    WHERE project_id = 'your-project-id';
    ```
