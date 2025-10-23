# Complete Post Flow Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Post as Post Service
    participant Auth as Auth Service (gRPC)
    participant DB as PostgreSQL

    Note over K6: Step 1: Login
    K6->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    Note over K6: Step 2: Create Post
    K6->>Kong: POST /post/v1/post
    Note over K6: Authorization: Bearer {accessToken}
    Kong->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Auth-->>Post: {userId}
    Post->>DB: Create post
    Post-->>K6: {post with ID}
    
    Note over K6: Step 3: List Posts
    K6->>Kong: GET /post/v1/post?page=1&limit=10
    Kong->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Post->>DB: Query posts
    Post-->>K6: {posts, meta}
    
    Note over K6: Step 4: Update Post
    K6->>Kong: PATCH /post/v1/post/{id}
    Kong->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Post->>DB: Update post
    Post-->>K6: {updated post}
    
    Note over K6: Step 5: Delete Post
    K6->>Kong: DELETE /post/v1/post/batch
    Kong->>Post: Forward request
    Post->>Auth: ValidateToken (gRPC)
    Post->>DB: Soft delete
    Post-->>K6: {count: 1}
```

## Test Steps

1. **Login**: Get access token
2. **Create Post**: Create a new post
3. **List Posts**: Retrieve posts with pagination
4. **Update Post**: Update the created post
5. **Delete Post**: Soft delete the post

## Success Criteria

- All CRUD operations complete successfully
- gRPC token validation works
- Post data is persisted and retrieved correctly

