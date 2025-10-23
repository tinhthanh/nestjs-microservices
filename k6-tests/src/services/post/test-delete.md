# Post Delete Test

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
    
    K6->>Traefik: DELETE /post/v1/post/batch
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: {ids: [postId]}
    Traefik->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Auth-->>Post: {userId, role}
    Post->>DB: Soft delete posts
    DB-->>Post: Deleted count
    Post-->>Traefik: 200 + {count}
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Create a post
3. Send DELETE request to `/post/v1/post/batch` with post IDs
4. Verify response status is 200
5. Verify posts were deleted (soft delete)

