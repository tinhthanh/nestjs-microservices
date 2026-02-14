# API Reference

Tất cả API requests đi qua **Traefik Gateway**: `http://localhost:8000`

## Auth Service

### Authentication

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/auth/v1/auth/signup` | Đăng ký | Public |
| POST | `/auth/v1/auth/login` | Đăng nhập | Public |
| GET | `/auth/v1/auth/refresh` | Refresh access token | Public |
| GET | `/auth/v1/auth/verify-token` | Verify JWT (ForwardAuth) | Bearer |

### User Management

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/v1/user/profile` | Lấy profile | Bearer |
| PUT | `/v1/user/profile` | Cập nhật profile | Bearer |

### Admin

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/auth/admin/user` | Danh sách users (paginated) | Admin |
| DELETE | `/auth/admin/user/:id` | Xoá user | Admin |

### Partner (Firebase)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/v1/partner/verify` | Verify Firebase token | x-client-id + x-client-secret |

### Health

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/auth/health` | Health check (qua gateway) |
| GET | `localhost:9001/health` | Health check (direct) |

---

## Post Service

### Posts

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/post/v1/post` | Danh sách posts | Bearer |
| POST | `/post/v1/post` | Tạo post | Bearer |
| PUT | `/post/v1/post/:id` | Cập nhật post | Bearer |
| DELETE | `/post/v1/post/batch` | Bulk delete | Bearer |

**Query params cho GET /post/v1/post:**
- `page` (number) — default: 1
- `limit` (number) — default: 10, max: 100
- `search` (string) — tìm trong title và content
- `sortBy` (string) — default: createdAt
- `sortOrder` — `asc` hoặc `desc`
- `authorId` (string) — filter theo author

### Health

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/post/health` | Health check (qua gateway) |
| GET | `localhost:9002/health` | Health check (direct) |

---

## File Service (DUFS)

> Tất cả file endpoints yêu cầu **JWT token** — Traefik xác thực qua ForwardAuth trước khi forward đến DUFS.

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| PUT | `/files/{path}` | Upload file | Bearer |
| GET | `/files/{path}` | Download file | Bearer |
| DELETE | `/files/{path}` | Xoá file | Bearer |

---

## JWT Authentication Flow

### 1. Login

```bash
curl -X POST http://localhost:8000/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

Response:
```json
{
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

### 2. Sử dụng token

```bash
# Gọi API cần auth
curl http://localhost:8000/post/v1/post \
  -H "Authorization: Bearer <accessToken>"

# Upload file
curl -X PUT http://localhost:8000/files/document.pdf \
  -H "Authorization: Bearer <accessToken>" \
  -H "Content-Type: application/pdf" \
  --data-binary @document.pdf
```

### 3. Refresh token

```bash
curl http://localhost:8000/auth/v1/auth/refresh \
  -H "Authorization: Bearer <refreshToken>"
```

---

## gRPC Services

### Auth Service (Port 50051)

| Method | Mô tả |
|--------|-------|
| `ValidateToken(token)` | Validate JWT, trả về userId + role |

### Post Service (Port 50052)

| Method | Mô tả |
|--------|-------|
| `CreatePost` | Tạo post |
| `GetPost` | Lấy post theo ID |
| `GetPosts` | Danh sách posts |
| `UpdatePost` | Cập nhật post |
| `DeletePost` | Xoá post |

---

## Rate Limits

| Route | Limit | Burst |
|-------|-------|-------|
| Global | 300/min | 50 |
| `/auth/*` | 100/min | 20 |
| `/post/*` | 200/min | 40 |
| `/v1/partner/*` | 50/min | 10 |

---

## Swagger Documentation

Khi chạy dev mode, Swagger UI available tại:

- **Auth**: http://localhost:9001/docs
- **Post**: http://localhost:9002/docs
