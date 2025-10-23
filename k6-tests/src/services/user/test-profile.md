# User Get Profile Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL

    K6->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    K6->>Kong: GET /auth/v1/user/profile
    Note over K6: Authorization: Bearer {accessToken}
    Kong->>Auth: Forward request
    Auth->>Auth: Verify JWT token
    Auth->>DB: Get user by ID
    DB-->>Auth: User data
    Auth-->>Kong: 200 + {user}
    Kong-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Send GET request to `/auth/v1/user/profile` with access token
3. Verify response status is 200
4. Verify response contains user profile data

