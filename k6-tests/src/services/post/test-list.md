# Post List Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Traefik as Traefik Gateway
    participant Post as Post Service
    participant Auth as Auth Service (gRPC)
    participant DB as PostgreSQL

    K6->>Traefik: POST /auth/v1/auth/login
    Traefik->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    K6->>Traefik: GET /post/v1/post?page=1&limit=10
    Note over K6: Authorization: Bearer {accessToken}
    Traefik->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Auth-->>Post: {userId, role}
    Post->>DB: Query posts with pagination
    DB-->>Post: Posts list
    Post-->>Traefik: 200 + {posts, meta}
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Send GET request to `/post/v1/post` with pagination params
3. Verify response status is 200
4. Verify response contains posts array and meta data

