# 🗄️ Database Architecture - Microservices Pattern

## Tổng quan

Dự án sử dụng **Database per Service pattern** với **PostgreSQL Schemas** để đảm bảo data isolation giữa các microservices trong khi vẫn sử dụng chung một PostgreSQL database instance.

---

## 🏗️ Architecture Pattern

### Database per Service với PostgreSQL Schemas

```
PostgreSQL Database: postgres
├── auth_schema (Auth Service)
│   ├── users
│   ├── third_party_integrations
│   └── Role (enum)
└── post_schema (Post Service)
    └── posts
```

### Lợi ích

✅ **Data Isolation**: Mỗi service có schema riêng, không thể truy cập trực tiếp data của service khác

✅ **Independent Schema Evolution**: Mỗi service có thể thay đổi schema độc lập

✅ **Resource Efficiency**: Sử dụng chung một database instance, tiết kiệm resources

✅ **Simplified Operations**: Dễ dàng backup, restore, và monitor hơn nhiều databases riêng biệt

✅ **Transaction Support**: Có thể sử dụng distributed transactions nếu cần (không khuyến khích)

✅ **Cost Effective**: Chỉ cần một database instance thay vì nhiều instances

---

## 📊 Schema Details

### Auth Schema (`auth_schema`)

**Owner**: Auth Service

**Tables**:

#### 1. `users`
```sql
CREATE TABLE auth_schema.users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password TEXT,
    first_name TEXT,
    last_name TEXT,
    avatar TEXT,
    is_verified BOOLEAN DEFAULT false,
    phone_number TEXT,
    role auth_schema.Role NOT NULL,
    created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(3) NOT NULL,
    deleted_at TIMESTAMP(3)
);
```

**Purpose**: Lưu trữ thông tin người dùng và authentication credentials

#### 2. `third_party_integrations`
```sql
CREATE TABLE auth_schema.third_party_integrations (
    id TEXT PRIMARY KEY,
    project_id TEXT UNIQUE NOT NULL,
    firebase_config JSONB,
    private_key TEXT,
    client_email TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(3) NOT NULL,
    deleted_at TIMESTAMP(3)
);
```

**Purpose**: Lưu trữ cấu hình Firebase cho partner authentication

#### 3. `Role` (Enum)
```sql
CREATE TYPE auth_schema.Role AS ENUM ('ADMIN', 'USER');
```

---

### Post Schema (`post_schema`)

**Owner**: Post Service

**Tables**:

#### 1. `posts`
```sql
CREATE TABLE post_schema.posts (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    images TEXT[],
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_by UUID,
    created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(3) NOT NULL,
    deleted_at TIMESTAMP(3),
    is_deleted BOOLEAN DEFAULT false
);
```

**Purpose**: Lưu trữ bài viết (posts) của users

**Note**: `created_by`, `updated_by`, `deleted_by` reference đến `auth_schema.users.id` nhưng không có foreign key constraint (microservices best practice)

---

## 🔧 Prisma Configuration

### Centralized Schema (`migrations/prisma/schema.prisma`)

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["multiSchema"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["auth_schema", "post_schema"]
}

// Auth Service Models
model User {
  // ... fields
  @@map("users")
  @@schema("auth_schema")
}

// Post Service Models
model Post {
  // ... fields
  @@map("posts")
  @@schema("post_schema")
}
```

### Service-Specific Schemas

**Auth Service** (`auth/prisma/schema.prisma`):
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["auth_schema"]
}
```

**Post Service** (`post/prisma/schema.prisma`):
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["post_schema"]
}
```

---

## 🚀 Migration Strategy

### 1. Centralized Migrations

Tất cả migrations được quản lý tập trung trong `migrations/` directory:

```bash
cd migrations
npm run migrate:dev    # Development
npm run migrate:deploy # Production
```

### 2. Schema Sync

Sau khi migrate, sync schemas đến các services:

```bash
cd migrations
npm run sync
```

Script này sẽ:
- Extract models cho từng service từ centralized schema
- Copy vào service-specific schema files
- Regenerate Prisma Client cho mỗi service

### 3. Automatic Initialization

Docker Compose tự động initialize schemas khi start:

```yaml
postgres:
  volumes:
    - ./migrations/init-schemas.sql:/docker-entrypoint-initdb.d/01-init-schemas.sql:ro
```

---

## 🔐 Access Control

### Service Isolation

Mỗi service chỉ có thể truy cập schema của mình thông qua Prisma Client:

**Auth Service**:
```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Chỉ có thể truy cập auth_schema.users
await prisma.user.findMany();
```

**Post Service**:
```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Chỉ có thể truy cập post_schema.posts
await prisma.post.findMany();
```

### Cross-Service Communication

Services giao tiếp với nhau qua **gRPC** hoặc **HTTP APIs**, KHÔNG truy cập trực tiếp database của nhau:

```typescript
// Post Service cần user info
// ❌ WRONG: await prisma.user.findUnique() 
// ✅ CORRECT: Call Auth Service via gRPC
const user = await authGrpcClient.validateToken(token);
```

---

## 📈 Scaling Considerations

### Current Setup (Single Database)

```
┌─────────────────────────────────────┐
│     PostgreSQL Database             │
│  ┌──────────────┬──────────────┐   │
│  │ auth_schema  │ post_schema  │   │
│  └──────────────┴──────────────┘   │
└─────────────────────────────────────┘
         ▲              ▲
         │              │
    ┌────┴────┐    ┌────┴────┐
    │  Auth   │    │  Post   │
    │ Service │    │ Service │
    └─────────┘    └─────────┘
```

### Future: Separate Databases (if needed)

Khi scale lớn, có thể tách thành separate databases:

```
┌──────────────┐      ┌──────────────┐
│ Auth DB      │      │ Post DB      │
│ auth_schema  │      │ post_schema  │
└──────────────┘      └──────────────┘
       ▲                     ▲
       │                     │
  ┌────┴────┐           ┌────┴────┐
  │  Auth   │           │  Post   │
  │ Service │           │ Service │
  └─────────┘           └─────────┘
```

**Migration path**: Chỉ cần thay đổi `DATABASE_URL` cho mỗi service, code không cần thay đổi!

---

## 🛠️ Development Workflow

### 1. Thay đổi Schema

Edit `migrations/prisma/schema.prisma`:

```prisma
model User {
  // Add new field
  phoneVerified Boolean @default(false) @map("phone_verified")
  
  @@schema("auth_schema")
}
```

### 2. Create Migration

```bash
cd migrations
npx prisma migrate dev --name add_phone_verified
```

### 3. Sync to Services

```bash
npm run sync
```

### 4. Services tự động có Prisma Client mới

```typescript
// Auth Service có thể sử dụng field mới ngay
await prisma.user.update({
  where: { id },
  data: { phoneVerified: true }
});
```

---

## 🧪 Testing

### Database State

Check schemas:
```bash
docker exec bw-postgres-dev psql -U admin -d postgres -c "\dn"
```

Check tables:
```bash
docker exec bw-postgres-dev psql -U admin -d postgres -c "\dt auth_schema.*"
docker exec bw-postgres-dev psql -U admin -d postgres -c "\dt post_schema.*"
```

Check data:
```bash
docker exec bw-postgres-dev psql -U admin -d postgres -c "SELECT * FROM auth_schema.users LIMIT 5;"
```

---

## 📚 Best Practices

### ✅ DO

- Sử dụng gRPC/HTTP APIs để giao tiếp giữa services
- Mỗi service chỉ truy cập schema của mình
- Centralized migrations trong `migrations/` directory
- Sync schemas sau mỗi migration
- Use UUIDs cho cross-service references (không dùng foreign keys)

### ❌ DON'T

- Không truy cập trực tiếp schema của service khác
- Không tạo foreign keys giữa schemas
- Không share Prisma Client giữa services
- Không skip schema sync sau migration
- Không edit service-specific schema files trực tiếp

---

## 🔍 Troubleshooting

### Problem: Prisma Client không thấy schema mới

**Solution**:
```bash
cd migrations
npm run sync
```

### Problem: Migration conflict

**Solution**:
```bash
cd migrations
npx prisma migrate reset  # ⚠️ Xóa tất cả data
npx prisma migrate dev
```

### Problem: Service không connect được database

**Solution**: Check `DATABASE_URL` trong `.env.local`:
```
DATABASE_URL="postgresql://admin:master123@localhost:5435/postgres?schema=public"
```

---

## 📖 References

- [Prisma Multi-Schema](https://www.prisma.io/docs/orm/prisma-schema/data-model/multi-schema)
- [Database per Service Pattern](https://microservices.io/patterns/data/database-per-service.html)
- [PostgreSQL Schemas](https://www.postgresql.org/docs/current/ddl-schemas.html)

