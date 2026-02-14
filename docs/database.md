# Database Architecture

## Tổng quan

Dự án sử dụng **Database per Service pattern** với **PostgreSQL Schemas** — 1 database instance, mỗi service có schema riêng.

```
PostgreSQL Database: postgres (Port 5435)
├── auth_schema    ← Auth Service
│   ├── users
│   └── Role (enum)
└── post_schema    ← Post Service
    └── posts
```

**Lợi ích:**
- Data isolation giữa services
- Schema evolution độc lập
- 1 instance tiết kiệm resources
- Dễ backup/restore
- Scale ra separate databases khi cần (chỉ đổi `DATABASE_URL`)

## Schema Details

### auth_schema

```sql
CREATE TABLE auth_schema.users (
    id          TEXT PRIMARY KEY,
    email       TEXT UNIQUE NOT NULL,
    password    TEXT,
    first_name  TEXT,
    last_name   TEXT,
    avatar      TEXT,
    is_verified BOOLEAN DEFAULT false,
    phone_number TEXT,
    role        auth_schema.Role NOT NULL,
    created_at  TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP(3) NOT NULL,
    deleted_at  TIMESTAMP(3)
);

CREATE TYPE auth_schema.Role AS ENUM ('ADMIN', 'USER');
```

### post_schema

```sql
CREATE TABLE post_schema.posts (
    id          TEXT PRIMARY KEY,
    title       TEXT NOT NULL,
    content     TEXT NOT NULL,
    images      TEXT[],
    created_by  UUID NOT NULL,
    updated_by  UUID,
    deleted_by  UUID,
    created_at  TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP(3) NOT NULL,
    deleted_at  TIMESTAMP(3),
    is_deleted  BOOLEAN DEFAULT false
);
```

> `created_by`, `updated_by`, `deleted_by` reference `auth_schema.users.id` nhưng **không có foreign key constraint** (microservices best practice).

## Prisma Configuration

### Service-specific schemas

Mỗi service có schema riêng, chỉ truy cập schema của mình:

**Auth** (`auth/prisma/schema.prisma`):
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id          String    @id @default(uuid())
  email       String    @unique
  password    String?
  firstName   String?   @map("first_name")
  lastName    String?   @map("last_name")
  avatar      String?
  isVerified  Boolean   @default(false) @map("is_verified")
  phoneNumber String?   @map("phone_number")
  role        Role
  createdAt   DateTime  @default(now()) @map("created_at")
  updatedAt   DateTime  @updatedAt @map("updated_at")
  deletedAt   DateTime? @map("deleted_at")
  @@map("users")
}
```

**Post** (`post/prisma/schema.prisma`):
```prisma
model Post {
  id        String    @id @default(uuid())
  title     String
  content   String
  images    String[]
  createdBy String    @map("created_by") @db.Uuid
  updatedBy String?   @map("updated_by") @db.Uuid
  deletedBy String?   @map("deleted_by") @db.Uuid
  createdAt DateTime  @default(now()) @map("created_at")
  updatedAt DateTime  @updatedAt @map("updated_at")
  deletedAt DateTime? @map("deleted_at")
  isDeleted Boolean   @default(false) @map("is_deleted")
  @@map("posts")
}
```

## Migration Workflow

### Chạy migrations

```bash
# Auth Service
cd auth && npx prisma migrate deploy && cd ..

# Post Service
cd post && npx prisma migrate deploy && cd ..
```

### Tạo migration mới

```bash
# Sửa schema.prisma của service, ví dụ thêm field:
cd auth
# Edit prisma/schema.prisma
npx prisma migrate dev --name add_phone_verified
npx prisma generate
```

### Regenerate Prisma Client

```bash
cd auth && npx prisma generate
cd post && npx prisma generate
```

### Prisma Studio (GUI)

```bash
cd auth && npx prisma studio    # Port 5555
cd post && npx prisma studio    # Port 5556
```

## Schema Initialization

Docker Compose tự động tạo schemas khi PostgreSQL start lần đầu:

```yaml
# docker-compose.dev.yml
postgres:
  volumes:
    - ./migrations/init-schemas.sql:/docker-entrypoint-initdb.d/01-init-schemas.sql:ro
```

File `migrations/init-schemas.sql`:
```sql
CREATE SCHEMA IF NOT EXISTS auth_schema;
CREATE SCHEMA IF NOT EXISTS post_schema;
```

## Best Practices

### ✅ Nên

- Dùng gRPC/HTTP APIs để giao tiếp giữa services
- Mỗi service chỉ truy cập schema của mình
- Dùng UUIDs cho cross-service references
- Prisma generate sau mỗi schema change

### ❌ Không nên

- Truy cập trực tiếp schema của service khác
- Tạo foreign keys giữa schemas
- Share Prisma Client giữa services

## Troubleshooting

### Check schemas

```bash
docker exec bw-postgres-dev psql -U admin -d postgres -c "\dn"
```

### Check tables

```bash
docker exec bw-postgres-dev psql -U admin -d postgres -c "\dt auth_schema.*"
docker exec bw-postgres-dev psql -U admin -d postgres -c "\dt post_schema.*"
```

### Check data

```bash
docker exec bw-postgres-dev psql -U admin -d postgres -c "SELECT * FROM auth_schema.users LIMIT 5;"
```

### Migration conflict

```bash
cd auth && npx prisma migrate reset   # ⚠️ Xoá tất cả data
```
