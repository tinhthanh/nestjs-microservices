# Post Delete Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Post as Post Service
    participant Auth as Auth Service (gRPC)
    participant DB as PostgreSQL

    Note over K6: Create post first
    K6->>Kong: POST /post/v1/post
    Kong->>Post: Forward request
    Post-->>K6: {postId}
    
    K6->>Kong: DELETE /post/v1/post/batch
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: {ids: [postId]}
    Kong->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Auth-->>Post: {userId, role}
    Post->>DB: Soft delete posts
    DB-->>Post: Deleted count
    Post-->>Kong: 200 + {count}
    Kong-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Create a post
3. Send DELETE request to `/post/v1/post/batch` with post IDs
4. Verify response status is 200
5. Verify posts were deleted (soft delete)

