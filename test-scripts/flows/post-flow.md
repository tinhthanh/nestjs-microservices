# Post Flow Diagram

## Complete Post Management Flow

```mermaid
sequenceDiagram
    participant Test as Test Script
    participant Kong as Kong Gateway
    participant Post as Post Service
    participant Auth as Auth Service (gRPC)
    participant DB as PostgreSQL
    
    Note over Test,DB: Step 1: Login
    Test->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward credentials
    Auth->>DB: Verify user
    DB-->>Auth: User found
    Auth-->>Kong: Access token
    Kong-->>Test: 200 OK with token
    
    Note over Test,DB: Step 2: Create Post
    Test->>Kong: POST /post/v1/post
    Note right of Test: Authorization: Bearer {token}
    Kong->>Post: Forward request
    Post->>Auth: gRPC ValidateToken
    Auth-->>Post: User ID
    Post->>DB: Create post
    DB-->>Post: Post created
    Post-->>Kong: Post data
    Kong-->>Test: 201 Created
    
    Note over Test,DB: Step 3: List Posts
    Test->>Kong: GET /post/v1/post?page=1&limit=10
    Note right of Test: Authorization: Bearer {token}
    Kong->>Post: Forward request
    Post->>Auth: gRPC ValidateToken
    Auth-->>Post: User ID
    Post->>DB: Get posts with pagination
    DB-->>Post: Posts list
    Post-->>Kong: Paginated data
    Kong-->>Test: 200 OK with posts
    
    Note over Test,DB: Step 4: Update Post
    Test->>Kong: PUT /post/v1/post/{id}
    Note right of Test: Authorization: Bearer {token}
    Kong->>Post: Forward request
    Post->>Auth: gRPC ValidateToken
    Auth-->>Post: User ID
    Post->>DB: Update post
    DB-->>Post: Post updated
    Post-->>Kong: Updated post
    Kong-->>Test: 200 OK
    
    Note over Test,DB: Step 5: Delete Post
    Test->>Kong: DELETE /post/v1/post/batch
    Note right of Test: Body: {ids: [postId]}
    Kong->>Post: Forward request
    Post->>Auth: gRPC ValidateToken
    Auth-->>Post: User ID
    Post->>DB: Delete posts
    DB-->>Post: Posts deleted
    Post-->>Kong: Delete result
    Kong-->>Test: 200 OK
```

## Flow Steps

1. **Login**: Get access token
   - Endpoint: `POST /auth/v1/auth/login`
   - Input: email, password
   - Output: accessToken

2. **Create Post**: Create a new post
   - Endpoint: `POST /post/v1/post`
   - Header: `Authorization: Bearer {token}`
   - Input: title, content
   - Output: Post data with ID

3. **List Posts**: Get paginated posts
   - Endpoint: `GET /post/v1/post?page=1&limit=10`
   - Header: `Authorization: Bearer {token}`
   - Output: Posts array with pagination metadata

4. **Update Post**: Update existing post
   - Endpoint: `PUT /post/v1/post/{id}`
   - Header: `Authorization: Bearer {token}`
   - Input: title, content
   - Output: Updated post data

5. **Delete Post**: Batch delete posts
   - Endpoint: `DELETE /post/v1/post/batch`
   - Header: `Authorization: Bearer {token}`
   - Input: Array of post IDs
   - Output: Delete count

## Success Criteria

- ✅ User can login successfully
- ✅ User can create post with valid token
- ✅ User can list posts with pagination
- ✅ User can update own post
- ✅ User can delete own posts
- ✅ gRPC token validation works correctly

## Key Features Tested

- **Authentication**: Token-based auth via Kong
- **Authorization**: gRPC validation between services
- **CRUD Operations**: Complete post lifecycle
- **Pagination**: List with page/limit parameters
- **Batch Operations**: Delete multiple posts at once

