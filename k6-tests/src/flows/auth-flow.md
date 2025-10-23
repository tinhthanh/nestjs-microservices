# Complete Auth Flow Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Traefik as Traefik Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL
    participant Redis as Redis Cache

    Note over K6: Step 1: Signup
    K6->>Traefik: POST /auth/v1/auth/signup
    Traefik->>Auth: Forward request
    Auth->>DB: Create user
    Auth-->>K6: {accessToken, refreshToken}
    
    Note over K6: Step 2: Verify Access Token
    K6->>Traefik: GET /auth/v1/user/profile
    Note over K6: Authorization: Bearer {accessToken}
    Traefik->>Auth: Forward request
    Auth->>Auth: Verify JWT
    Auth->>DB: Get user
    Auth-->>K6: {user profile}
    
    Note over K6: Step 3: Login
    K6->>Traefik: POST /auth/v1/auth/login
    Traefik->>Auth: Forward request
    Auth->>DB: Verify credentials
    Auth->>Redis: Cache refresh token
    Auth-->>K6: {accessToken, refreshToken}
    
    Note over K6: Step 4: Refresh Token
    K6->>Traefik: GET /auth/v1/auth/refresh
    Note over K6: Authorization: Bearer {refreshToken}
    Traefik->>Auth: Forward request
    Auth->>Redis: Verify refresh token
    Auth->>Auth: Generate new tokens
    Auth-->>K6: {newAccessToken, newRefreshToken}
    
    Note over K6: Step 5: Verify New Token
    K6->>Traefik: GET /auth/v1/user/profile
    Note over K6: Authorization: Bearer {newAccessToken}
    Traefik->>Auth: Forward request
    Auth-->>K6: {user profile}
```

## Test Steps

1. **Signup**: Create new user account
2. **Verify Access Token**: Get user profile with access token
3. **Login**: Login with new user credentials
4. **Refresh Token**: Use refresh token to get new access token
5. **Verify New Token**: Verify new access token works

## Success Criteria

- All API calls return expected status codes
- Tokens are generated and validated correctly
- User can complete full authentication cycle

