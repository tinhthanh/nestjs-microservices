# Auth Refresh Token Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant Redis as Redis Cache

    Note over K6: Step 1: Login
    K6->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward request
    Auth-->>K6: {accessToken, refreshToken}
    
    Note over K6: Step 2: Refresh Token
    K6->>Kong: GET /auth/v1/auth/refresh
    Note over K6: Authorization: Bearer {refreshToken}
    Kong->>Auth: Forward request
    Auth->>Redis: Verify refresh token
    Redis-->>Auth: Token valid
    Auth->>Auth: Generate new tokens
    Auth->>Redis: Cache new refresh token
    Auth-->>Kong: 200 + {accessToken, refreshToken}
    Kong-->>K6: Return response
    
    Note over K6: Verify status 200
    Note over K6: Verify new tokens exist
```

## Test Steps

1. Login to get refresh token
2. Send GET request to `/auth/v1/auth/refresh` with refresh token in Authorization header
3. Verify response status is 200
4. Verify response contains new `accessToken`
5. Verify response contains new `refreshToken`

## Expected Response

```json
{
  "statusCode": 200,
  "message": "Token refresh successful.",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

