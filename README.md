# NestJS Microservices

Hệ thống backend microservices với NestJS, Traefik API Gateway, gRPC, PostgreSQL, Redis và DUFS File Server.

## Kiến trúc

```
Client → Traefik Gateway (:8000) → Auth Service (:9001) / Post Service (:9002) / DUFS (:5000)
                                         ↕ gRPC
                                   PostgreSQL (:5435) + Redis (:6379)
```

- **Traefik v3.0** — API Gateway, routing, rate limiting, JWT ForwardAuth
- **Auth Service** — Đăng ký, đăng nhập, JWT, user management, gRPC
- **Post Service** — CRUD posts, gRPC auth integration
- **DUFS** — File server (Rust), bảo vệ bởi JWT tại gateway
- **PostgreSQL** — 2 schemas: `auth_schema`, `post_schema`
- **Redis** — Cache, sessions

## Quick Start

```bash
# 1. Start Docker infra
docker compose -f docker-compose.dev.yml up -d

# 2. Install & migrate
cd auth && npm install --legacy-peer-deps && npx prisma generate && npx prisma migrate deploy && cd ..
cd post && npm install --legacy-peer-deps && npx prisma generate && npx prisma migrate deploy && cd ..

# 3. Start services (2 terminals)
cd auth && npm run dev
cd post && npm run dev
```

| Service | URL |
|---------|-----|
| Traefik Gateway | http://localhost:8000 |
| Traefik Dashboard | http://localhost:8080 |
| Auth Service | http://localhost:9001 |
| Auth Swagger | http://localhost:9001/docs |
| Post Service | http://localhost:9002 |
| Post Swagger | http://localhost:9002/docs |

## Tài liệu

| Tài liệu | Mô tả |
|-----------|-------|
| [Architecture](docs/architecture.md) | Kiến trúc hệ thống, diagrams, components |
| [Development](docs/development.md) | Hướng dẫn setup và phát triển local |
| [Deployment](docs/deployment.md) | Triển khai production |
| [API Reference](docs/api-reference.md) | Tất cả API endpoints và auth flow |
| [Database](docs/database.md) | Schema design, Prisma, migrations |

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | NestJS, TypeScript |
| API Gateway | Traefik v3.0 |
| Inter-service | gRPC + Protocol Buffers |
| Database | PostgreSQL 15 + Prisma ORM |
| Cache | Redis 7 |
| File Server | DUFS (Rust) |
| Container | Docker Compose |

## License

MIT
