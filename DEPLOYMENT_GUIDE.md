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

---

## 🌐 Traefik Configuration

### Static Configuration

Traefik sử dụng 2 loại configuration:

1. **Static Config** (`traefik/traefik.yml`):
   - Entry points (ports)
   - Providers (file, docker)
   - API/Dashboard settings
   - Logging và metrics
   - **Không thay đổi khi runtime**

2. **Dynamic Config** (`traefik/dynamic-config.yml`):
   - Routers (routing rules)
   - Services (backend services)
   - Middlewares (rate limiting, auth, headers)
   - **Có thể reload khi thay đổi**

### Production Configuration

File `traefik/traefik.yml`:
```yaml
# Entry point
entryPoints:
  web:
    address: ":8000"

# Providers
providers:
  file:
    directory: /etc/traefik/dynamic
    watch: true

# Health check
ping:
  entryPoint: "web"
```

File `traefik/dynamic-config.yml`:
- Định nghĩa routers cho `/auth`, `/post`, `/files`, `/v1/user`, `/v1/partner`
- JWT ForwardAuth middleware cho `/files` routes
- Rate limiting cho từng route
- Security headers

### Monitoring Traefik

**Health Check:**
```bash
curl http://localhost:8000/ping
# Response: OK
```

**Logs:**
```bash
docker logs -f bw-traefik
```

**Metrics (Prometheus):**
Traefik expose Prometheus metrics tại internal endpoint.

---

## 🔒 Security Checklist

### Traefik Security

- [ ] Dashboard disabled trong production (`api.dashboard: false`)
- [ ] HTTPS enabled với TLS certificates (nếu có)
- [ ] Rate limiting configured cho tất cả routes
- [ ] Security headers enabled
- [ ] Access logs enabled để audit

### JWT Security

- [ ] JWT secret keys được lưu trong environment variables
- [ ] Access token expiration: 1 day (có thể giảm xuống)
- [ ] Refresh token expiration: 7 days
- [ ] JWT issuer: `backend-works-app`
- [ ] ForwardAuth endpoint (`/v1/auth/verify-token`) hoạt động đúng

### Database Security

- [ ] PostgreSQL password mạnh
- [ ] Database chỉ accessible từ internal network
- [ ] Regular backups
- [ ] SSL/TLS connection (nếu có)

### File Storage Security

- [ ] `./managed_files` directory có permissions đúng
- [ ] JWT authentication required cho tất cả file operations
- [ ] File size limits configured
- [ ] Malware scanning (optional)

---

## 📊 Monitoring và Logging

### Traefik Logs

Traefik tạo 2 loại logs:

1. **Application Logs**: Thông tin về Traefik itself
   ```bash
   docker logs bw-traefik 2>&1 | grep -i error
   ```

2. **Access Logs**: Tất cả HTTP requests
   ```json
   {
     "ClientAddr": "172.18.0.1:54321",
     "RequestMethod": "GET",
     "RequestPath": "/auth/v1/auth/login",
     "RequestProtocol": "HTTP/1.1",
     "RouterName": "auth-routes",
     "ServiceName": "auth-service",
     "Duration": 123456789
   }
   ```

### Service Logs

```bash
# Auth Service
docker logs -f bw-auth-service

# Post Service
docker logs -f bw-post-service

# DUFS Service
docker logs -f bw-dufs-service

# All services
docker-compose logs -f
```

### Health Monitoring

Traefik tự động health check các backend services:

```bash
# Xem health status
docker-compose ps

# Kiểm tra Traefik health
curl http://localhost:8000/ping

# Kiểm tra Auth Service health
curl http://localhost:8000/auth/health

# Kiểm tra Post Service health
curl http://localhost:8000/post/health
```

---

## 🚨 Troubleshooting

### Traefik Issues

**Problem: Traefik không start**
```bash
# Kiểm tra logs
docker logs bw-traefik

# Kiểm tra config syntax
docker run --rm -v $(pwd)/traefik:/etc/traefik traefik:v3.0 \
  traefik --configFile=/etc/traefik/traefik.yml --validate
```

**Problem: 404 Not Found**
- Kiểm tra routing rules trong `dynamic-config.yml`
- Kiểm tra service có healthy không: `docker-compose ps`
- Xem Traefik logs để debug routing

**Problem: 502 Bad Gateway**
- Backend service không healthy
- Kiểm tra service logs: `docker logs bw-auth-service`
- Kiểm tra network connectivity

**Problem: 401 Unauthorized trên /files**
- JWT token không hợp lệ hoặc expired
- ForwardAuth endpoint không hoạt động
- Kiểm tra Auth Service logs
- Test endpoint: `curl -H "Authorization: Bearer <token>" http://localhost:8000/auth/v1/auth/verify-token`

### Performance Issues

**High latency:**
- Kiểm tra Traefik access logs để xem `Duration`
- Kiểm tra database query performance
- Kiểm tra Redis connection
- Scale services nếu cần

**Rate limiting triggered:**
- Tăng rate limit trong `dynamic-config.yml`
- Reload Traefik config: `docker restart bw-traefik`

---

## 📈 Scaling

### Horizontal Scaling

Traefik hỗ trợ load balancing tự động:

```yaml
# docker-compose.yml
auth-service:
  deploy:
    replicas: 3  # Chạy 3 instances
```

Traefik sẽ tự động distribute requests giữa các instances.

### Vertical Scaling

Tăng resources cho services:

```yaml
auth-service:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
```

---

## 🔄 Migration từ Kong sang Traefik

Nếu bạn đang migrate từ Kong:

### Thay đổi chính:

1. **JWT Authentication:**
   - Kong: Built-in JWT plugin
   - Traefik: ForwardAuth middleware + Auth Service endpoint

2. **Configuration:**
   - Kong: Declarative YAML (`kong/config.yml`)
   - Traefik: Static + Dynamic YAML (`traefik/*.yml`)

3. **Rate Limiting:**
   - Kong: Plugin-based
   - Traefik: Middleware-based

4. **Health Checks:**
   - Kong: `kong health`
   - Traefik: `curl http://localhost:8000/ping`

### Migration Steps:

1. ✅ Tạo Traefik configuration files
2. ✅ Thêm `/v1/auth/verify-token` endpoint trong Auth Service
3. ✅ Cập nhật `docker-compose.yml` để thay Kong bằng Traefik
4. ✅ Cập nhật health check scripts (`dev.sh`, `prod.sh`)
5. ✅ Test tất cả endpoints
6. ✅ Chạy integration tests (`./dev.run`, `./prod.run`)
7. ✅ Remove Kong configuration files (optional)

---

## 📚 Tài liệu Tham khảo

- **Traefik Documentation**: https://doc.traefik.io/traefik/
- **ForwardAuth Middleware**: https://doc.traefik.io/traefik/middlewares/http/forwardauth/
- **Rate Limiting**: https://doc.traefik.io/traefik/middlewares/http/ratelimit/
- **Health Checks**: https://doc.traefik.io/traefik/routing/services/#health-check
- **Docker Provider**: https://doc.traefik.io/traefik/providers/docker/
