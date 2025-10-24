# Auth Service

A microservice for handling user authentication and authorization in the NestJS microservices architecture.

## 🚀 Features

- **User Authentication**: JWT-based authentication with access and refresh tokens
- **User Management**: CRUD operations for user accounts
- **Role-based Authorization**: Support for ADMIN and USER roles
- **gRPC Microservice**: Inter-service communication via gRPC
- **REST API**: HTTP endpoints for authentication operations
- **Database Integration**: PostgreSQL with Prisma ORM
- **Caching**: Redis-based caching for performance
- **Internationalization**: Multi-language support with nestjs-i18n
- **API Documentation**: Swagger/OpenAPI documentation
- **Health Checks**: Built-in health monitoring
- **Security**: Helmet security headers, CORS configuration

## 🏗️ Architecture

### Technology Stack

- **Framework**: NestJS 10.x
- **Language**: TypeScript 5.x
- **Database**: PostgreSQL with Prisma ORM
- **Cache**: Redis with cache-manager
- **Authentication**: JWT with Passport.js
- **API Documentation**: Swagger/OpenAPI
- **Microservice**: gRPC communication
- **Validation**: class-validator and class-transformer
- **Testing**: Jest

### Service Structure

```
src/
├── app/                    # Application bootstrap
├── common/                 # Shared modules and utilities
│   ├── config/            # Configuration management
│   ├── constants/         # Application constants
│   ├── decorators/        # Custom decorators
│   ├── dtos/             # Data Transfer Objects
│   ├── filters/          # Exception filters
│   ├── guards/           # Authentication guards
│   ├── interceptors/     # Response interceptors
│   ├── interfaces/       # TypeScript interfaces
│   ├── middlewares/      # Request middlewares
│   ├── providers/        # JWT strategies
│   └── services/         # Shared services
├── generated/            # gRPC generated code
├── languages/            # i18n translation files
├── modules/             # Feature modules
│   ├── auth/            # Authentication module
│   └── user/            # User management module
└── protos/              # gRPC protocol buffers
```

## 📋 Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0
- PostgreSQL
- Redis

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd auth
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Configuration**
   The service includes a pre-configured `.env.docker` file with the following variables:
   ```env
   # App Configuration
   NODE_ENV="local"
   APP_NAME="@backendworks/auth"
   APP_CORS_ORIGINS="*"
   APP_DEBUG=true

   # HTTP Configuration
   HTTP_ENABLE=true
   HTTP_HOST="0.0.0.0"
   HTTP_PORT=9001
   HTTP_VERSIONING_ENABLE=true
   HTTP_VERSION=1

   # Database Configuration
   DATABASE_URL="postgresql://admin:master123@localhost:5435/postgres?schema=public"

   # JWT Configuration
   ACCESS_TOKEN_SECRET_KEY="EAJYjNJUnRGJ6uq1YfGw4NG1pd1z102J"
   ACCESS_TOKEN_EXPIRED="1d"
   REFRESH_TOKEN_SECRET_KEY="LcnlpiuHIJ6eS51u1mcOdk0P49r2Crwu"
   REFRESH_TOKEN_EXPIRED="7d"

   # Redis Configuration
   REDIS_URL="redis://localhost:6379"
   REDIS_KEY_PREFIX="auth:"
   REDIS_TTL=3600

   # gRPC Configuration
   GRPC_URL="0.0.0.0:50051"
   GRPC_PACKAGE="auth"
   ```

4. **Database Setup**
   ```bash
   # Generate Prisma client
   npm run prisma:generate

   # Run migrations
   npm run prisma:migrate

   # (Optional) Open Prisma Studio
   npm run prisma:studio
   ```

5. **Generate gRPC code**
   ```bash
   npm run proto:generate
   ```

## 🚀 Running the Service

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm run build
npm start
```

### Docker (if available)
```bash
docker build -t auth-service .
docker run -p 9001:9001 auth-service
```

## 📡 API Endpoints

### Authentication Endpoints

#### Public Endpoints
- `POST /v1/auth/login` - User login
- `POST /v1/auth/signup` - User registration
- `GET /v1/auth/refresh` - Refresh access token
- `GET /v1/auth/verify-token` - **Verify JWT token (Traefik ForwardAuth)**

#### Protected Endpoints
- `GET /v1/user/profile` - Get user profile
- `PUT /v1/user/profile` - Update user profile

#### Partner Endpoints
- `GET /v1/partner/verify` - Verify Firebase ID token and issue system tokens

### User Management Endpoints

#### Admin Only
- `GET /admin/user` - List all users (paginated)
- `DELETE /admin/user/:id` - Delete user

### Health Check
- `GET /health` - Service health status
- `GET /` - Service information

## 🔌 gRPC Services

### AuthService
- `ValidateToken` - Validate JWT tokens and return user information (used by Post Service)

---

## 🔐 Traefik ForwardAuth Integration

### Overview

Auth Service cung cấp endpoint `/v1/auth/verify-token` để tích hợp với **Traefik ForwardAuth middleware**. Endpoint này được sử dụng để xác thực JWT tokens cho các protected routes (đặc biệt là `/files` routes của DUFS Service).

### How It Works

1. **Client** gửi request đến Traefik với JWT token:
   ```
   PUT /files/document.pdf
   Authorization: Bearer eyJhbGc...
   ```

2. **Traefik** áp dụng ForwardAuth middleware:
   - Forward authentication request đến Auth Service
   - Endpoint: `http://auth-service:9001/v1/auth/verify-token`
   - Headers: `Authorization: Bearer eyJhbGc...`

3. **Auth Service** xác thực token:
   - Kiểm tra JWT signature với secret key
   - Kiểm tra expiration time
   - Kiểm tra issuer (`backend-works-app`)
   - Trích xuất user information

4. **Response:**
   - **Success (200 OK):**
     ```json
     {
       "valid": true,
       "userId": "user-uuid",
       "role": "USER"
     }
     ```
     Response headers:
     - `X-User-Id: user-uuid`
     - `X-User-Role: USER`

   - **Failure (401 Unauthorized):**
     ```json
     {
       "statusCode": 401,
       "message": "Invalid or expired token"
     }
     ```

5. **Traefik** xử lý response:
   - Nếu 200 OK: Thêm `X-User-Id` và `X-User-Role` headers vào request gốc và forward đến backend service
   - Nếu 401: Dừng request và trả lỗi về client

### Endpoint Details

**Endpoint:** `GET /v1/auth/verify-token`

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Success Response (200 OK):**
```json
{
  "valid": true,
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "role": "USER"
}
```

**Response Headers:**
```
X-User-Id: 550e8400-e29b-41d4-a716-446655440000
X-User-Role: USER
```

**Error Response (401 Unauthorized):**
```json
{
  "statusCode": 401,
  "message": "Invalid or expired token",
  "error": "Unauthorized"
}
```

### Implementation

<augment_code_snippet path="auth/src/modules/auth/controllers/auth.public.controller.ts" mode="EXCERPT">
````typescript
@PublicRoute()
@Get('verify-token')
@ApiOperation({
    summary: 'Verify JWT token',
    description: 'Validates JWT token for Traefik ForwardAuth...',
})
async verifyToken(@Headers('authorization') authHeader: string) {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        throw new UnauthorizedException('Missing or invalid authorization header');
    }
    const token = authHeader.substring(7);
    const payload = await this.authService.verifyToken(token);
    return {
        valid: true,
        userId: payload.id,
        role: payload.role,
    };
}
````
</augment_code_snippet>

### Traefik Configuration

**Dynamic Config (`traefik/dynamic-config.yml`):**
```yaml
middlewares:
  jwt-auth:
    forwardAuth:
      address: "http://auth-service:9001/v1/auth/verify-token"
      authResponseHeaders:
        - "X-User-Id"
        - "X-User-Role"

routers:
  dufs-routes:
    rule: "PathPrefix(`/files`)"
    service: dufs-service
    middlewares:
      - jwt-auth
      - strip-files-prefix
      - security-headers
```

### Benefits

- ✅ **Centralized Authentication**: JWT validation tại API Gateway
- ✅ **Reduced Backend Load**: DUFS Service không cần implement JWT validation
- ✅ **Consistent Security**: Tất cả file operations đều được bảo vệ
- ✅ **Easy to Maintain**: Thay đổi authentication logic chỉ cần update Auth Service
- ✅ **User Context**: Backend services nhận `X-User-Id` và `X-User-Role` headers

### Testing

```bash
# 1. Login để lấy token
TOKEN=$(curl -s -X POST http://localhost:8000/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  | jq -r '.data.accessToken')

# 2. Test verify-token endpoint trực tiếp
curl -X GET http://localhost:8000/auth/v1/auth/verify-token \
  -H "Authorization: Bearer $TOKEN"

# 3. Test qua Traefik ForwardAuth (upload file)
curl -X PUT http://localhost:8000/files/test.txt \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: text/plain" \
  -d "Hello World"
```

## 🔧 Configuration

The service uses a modular configuration system with environment-specific settings:

### App Configuration
- **Name**: Service name and display information
- **Environment**: Development, staging, production
- **Debug**: Debug mode settings
- **CORS**: Cross-origin resource sharing settings

### HTTP Configuration
- **Port**: HTTP server port (default: 9001)
- **Host**: HTTP server host
- **Versioning**: API versioning settings

### JWT Configuration
- **Access Token**: Secret key and expiration time
- **Refresh Token**: Secret key and expiration time

### Database Configuration
- **URL**: PostgreSQL connection string
- **Migrations**: Database migration settings

### Redis Configuration
- **URL**: Redis connection string
- **Key Prefix**: Cache key prefix
- **TTL**: Cache time-to-live

### gRPC Configuration
- **URL**: gRPC server address
- **Package**: Protocol buffer package name

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:cov
```

## 📚 API Documentation

When running in development mode, Swagger documentation is available at:
```
http://localhost:9001/docs
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt password hashing
- **Role-based Access Control**: ADMIN and USER roles
- **Helmet Security**: Security headers
- **CORS Protection**: Cross-origin request protection
- **Input Validation**: Request validation with class-validator
- **Rate Limiting**: Built-in rate limiting (configurable)

## 📊 Monitoring

- **Health Checks**: Built-in health monitoring endpoints
- **Sentry Integration**: Error tracking and monitoring
- **Logging**: Structured logging with Winston
- **Metrics**: Performance metrics collection

## 🚀 Deployment

### Environment Variables
Ensure all required environment variables are set in your deployment environment.

### Database Migrations
Run database migrations before starting the service:
```bash
npm run prisma:migrate:prod
```

### Health Checks
The service provides health check endpoints for load balancers and monitoring systems.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions, please contact the development team or create an issue in the repository.
