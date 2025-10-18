# 🚀 Hướng dẫn Triển khai Production

Tài liệu này mô tả quy trình chuẩn để triển khai hệ thống NestJS Microservices lên môi trường production.

## 📋 Checklist Trước Khi Deploy

*   [ ] Code đã được merge vào nhánh `main`.
*   [ ] Tất cả unit tests và integration tests đều pass trên CI.
*   [ ] Đã tạo migration mới cho các thay đổi về schema (nếu có) và đã test trên môi trường staging.
*   [ ] Đã tạo backup cho database production.
*   [ ] Chuẩn bị kế hoạch rollback trong trường hợp xảy ra lỗi.
*   [ ] Đảm bảo các biến môi trường cho production đã được cấu hình đúng, đặc biệt là `NODE_ENV=production`.

## 🔄 Quy trình Triển khai

### Giai đoạn 1: Chuẩn bị (10 phút)

1.  **Tạo Backup Database:**
    ```bash
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    pg_dump -h <prod-host> -U <user> -d postgres > backup_prod_${TIMESTAMP}.sql
    ```

2.  **Kiểm tra Trạng thái Hiện tại:**
    ```bash
    # Đảm bảo không có migration nào đang chờ
    cd migrations
    npm run migrate:status
    cd ..
    
    # Kiểm tra các services đang chạy
    docker-compose ps
    ```

### Giai đoạn 2: Deploy Migrations (5 phút)

1.  **Áp dụng các migrations mới:**
    Lệnh này sử dụng file `.env.docker` để kết nối đến database production.
    ```bash
    cd migrations
    npm run migrate:deploy:prod
    ```

2.  **Xác minh trạng thái migration:**
    ```bash
    npm run migrate:status
    # Output mong muốn: "Database schema is up to date!"
    cd ..
    ```

### Giai đoạn 3: Deploy Services (15 phút)

1.  **Pull code mới nhất:**
    ```bash
    git pull origin main
    ```

2.  **Build và khởi chạy lại các services:**
    Sử dụng `--build` để tạo lại các Docker images với code mới nhất. Docker Compose sẽ thực hiện rolling update để giảm thiểu downtime.
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
    # Đảm bảo tất cả các services đều đang ở trạng thái "Up" và "healthy"
    ```

2.  **Chạy script kiểm tra toàn diện:**
    ```bash
    ./test-scripts/verify-all.sh
    ```

3.  **Theo dõi logs để phát hiện lỗi:**
    ```bash
    docker-compose logs -f --tail=100
    ```

4.  **Giám sát hệ thống** trong 30 phút để đảm bảo hiệu suất và không có lỗi phát sinh.

## 🔙 Kế hoạch Rollback

### Trường hợp Migration Lỗi

1.  **Restore database từ backup:**
    ```bash
    psql -h <prod-host> -U <user> -d postgres < backup_prod_${TIMESTAMP}.sql
    ```
2.  **Revert lại commit chứa migration lỗi:**
    ```bash
    git revert <commit_hash>
    ```
3.  Deploy lại phiên bản code cũ.

### Trường hợp Service Lỗi

1.  **Nhanh chóng revert lại commit trước đó:**
    ```bash
    git revert HEAD
    ```
2.  **Deploy lại phiên bản ổn định:**
    ```bash
    docker-compose up -d --build
    ```
3.  Phân tích log để tìm nguyên nhân lỗi.

## 🔐 Thiết lập Firebase cho Production

Để tính năng Partner Verification hoạt động trong môi trường production, bạn cần:

1.  **Lấy Service Account Key từ Firebase Console:**
    *   Vào Project Settings > Service Accounts.
    *   Tạo và tải về file JSON chứa key.

2.  **Cập nhật Database:**
    Trích xuất `private_key` và `client_email` từ file JSON và cập nhật vào bảng `third_party_integrations` cho `project_id` tương ứng.
    ```sql
    UPDATE third_party_integrations 
    SET 
      private_key = '-----BEGIN PRIVATE KEY-----\n...your_key...\n-----END PRIVATE KEY-----\n',
      client_email = 'your-service-account@...iam.gserviceaccount.com'
    WHERE project_id = 'your-project-id';
    ```
    *Lưu ý: Script `auth/prisma/seed-firebase.ts` đã bao gồm key cho môi trường development.*
