# Post Create Test

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
    
    K6->>Traefik: POST /post/v1/post
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: {title, content}
    Traefik->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Auth-->>Post: {userId, role}
    Post->>DB: Create post
    DB-->>Post: Post created
    Post-->>Traefik: 201 + {post}
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Send POST request to `/post/v1/post` with post data
3. Verify response status is 201
4. Verify post was created with ID

