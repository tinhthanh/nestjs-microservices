# Post Update Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Traefik as Traefik Gateway
    participant Post as Post Service
    participant Auth as Auth Service (gRPC)
    participant DB as PostgreSQL

    Note over K6: Create post first
    K6->>Traefik: POST /post/v1/post
    Traefik->>Post: Forward request
    Post-->>K6: {postId}
    
    K6->>Traefik: PATCH /post/v1/post/{postId}
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: {title, content}
    Traefik->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Auth-->>Post: {userId, role}
    Post->>DB: Update post
    DB-->>Post: Updated post
    Post-->>Traefik: 200 + {post}
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Create a post
3. Send PATCH request to `/post/v1/post/{id}` with updated data
4. Verify response status is 200
5. Verify post was updated

