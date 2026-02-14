# Triển khai Production

## Checklist trước deploy

- [ ] Code merged vào `main`
- [ ] Unit tests + integration tests pass
- [ ] DB migration mới (nếu có schema changes)
- [ ] Backup database production
- [ ] Thư mục `./managed_files` tồn tại trên server
- [ ] Biến môi trường production đã cấu hình
- [ ] Kế hoạch rollback sẵn sàng

## Quy trình Deploy

### 1. Chuẩn bị

```bash
# Backup database
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
pg_dump -h <prod-host> -U <user> -d postgres > backup_prod_${TIMESTAMP}.sql

# Kiểm tra trạng thái hiện tại
docker compose ps
```

### 2. Deploy Migrations

```bash
cd migrations
npm run migrate:deploy:prod
npm run migrate:status
cd ..
```

### 3. Deploy Services

```bash
git pull origin main
docker compose up -d --build
docker image prune -f     # Dọn images cũ (optional)
```

### 4. Xác minh

```bash
# Kiểm tra containers
docker compose ps

# Health checks
curl http://localhost:8000/ping
curl http://localhost:8000/auth/health
curl http://localhost:8000/post/health

# Theo dõi logs
docker compose logs -f --tail=100
```

## Production Docker Compose

File `docker-compose.yml` chạy tất cả trong Docker:

- **Traefik**: Port 8000 (dashboard disabled)
- **Auth Service**: Internal (port 9001)
- **Post Service**: Internal (port 9002)
- **PostgreSQL**: Port 5435 (có thể restrict)
- **Redis**: Internal only
- **DUFS**: Internal only

Tất cả requests phải đi qua Traefik Gateway.

## Traefik Configuration

### Static Config (`traefik/traefik.yml`)

Không thay đổi khi runtime: entry points, providers, logging.

### Dynamic Config (`traefik/dynamic-config.yml`)

Có thể reload: routers, services, middlewares. Traefik watch thay đổi tự động.

## Security Checklist

### Traefik
- [ ] Dashboard disabled (`api.dashboard: false`)
- [ ] Rate limiting cho tất cả routes
- [ ] Security headers enabled
- [ ] Access logs enabled

### JWT
- [ ] Secret keys trong environment variables (không hardcode)
- [ ] Access token: 1 day, Refresh token: 7 days
- [ ] ForwardAuth endpoint hoạt động

### Database
- [ ] Password mạnh
- [ ] Chỉ accessible từ internal network
- [ ] Regular backups

### Files
- [ ] `./managed_files` permissions đúng
- [ ] JWT required cho tất cả file operations

## Monitoring

### Logs

```bash
# Tất cả services
docker compose logs -f

# Service cụ thể
docker compose logs -f auth-service
docker compose logs -f post-service
docker compose logs -f traefik

# Traefik errors
docker logs bw-traefik 2>&1 | grep -i error
```

### Health Checks

Traefik tự động check backend health:

| Service | Path | Interval |
|---------|------|----------|
| Auth | `/health` | 30s |
| Post | `/health` | 30s |
| DUFS | `/__dufs__/health` | 30s |

### Prometheus Metrics

Traefik expose metrics tại internal endpoint (cấu hình trong `traefik.yml`).

## Scaling

### Horizontal

```yaml
# docker-compose.yml
auth-service:
  deploy:
    replicas: 3
```

Traefik tự động load balance giữa các instances.

### Vertical

```yaml
auth-service:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
```

## Rollback

### Service lỗi

```bash
git revert HEAD
docker compose up -d --build
```

### Migration lỗi

```bash
# Restore từ backup
psql -h <host> -U <user> -d postgres < backup_prod_YYYYMMDD.sql
```

## Troubleshooting

| Lỗi | Nguyên nhân | Giải pháp |
|------|-------------|-----------|
| 404 Not Found | Routing rule sai | Check `dynamic-config.yml` |
| 502 Bad Gateway | Service không healthy | Check `docker compose ps`, service logs |
| 401 on `/files` | JWT invalid/expired | Check Auth Service logs, test verify-token |
| High latency | DB slow / Redis down | Check DB queries, Redis connection |
| Rate limit hit | Quá nhiều requests | Tăng limit trong `dynamic-config.yml`, restart Traefik |
