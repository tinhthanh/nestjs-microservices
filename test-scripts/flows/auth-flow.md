# Auth Flow Diagram

## Complete Authentication Flow

```mermaid
sequenceDiagram
    participant Test as Test Script
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL
    
    Note over Test,DB: Step 1: Signup
    Test->>Kong: POST /auth/v1/auth/signup
    Kong->>Auth: Forward request
    Auth->>DB: Create user
    DB-->>Auth: User created
    Auth-->>Kong: User data
    Kong-->>Test: 201 Created
    
    Note over Test,DB: Step 2: Login
    Test->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward credentials
    Auth->>DB: Verify user
    DB-->>Auth: User found
    Auth-->>Kong: Access + Refresh tokens
    Kong-->>Test: 200 OK with tokens
    
    Note over Test,DB: Step 3: Verify Access Token
    Test->>Kong: GET /auth/v1/user/profile
    Note right of Test: Authorization: Bearer {accessToken}
    Kong->>Auth: Forward with token
    Auth->>Auth: Validate JWT
    Auth->>DB: Get user profile
    DB-->>Auth: User data
    Auth-->>Kong: Profile data
    Kong-->>Test: 200 OK with profile
    
    Note over Test,DB: Step 4: Refresh Token
    Test->>Kong: POST /auth/v1/auth/refresh
    Note right of Test: Body: {refreshToken}
    Kong->>Auth: Forward refresh token
    Auth->>DB: Verify refresh token
    DB-->>Auth: Token valid
    Auth-->>Kong: New access token
    Kong-->>Test: 200 OK with new token
    
    Note over Test,DB: Step 5: Verify New Token
    Test->>Kong: GET /auth/v1/user/profile
    Note right of Test: Authorization: Bearer {newAccessToken}
    Kong->>Auth: Forward with new token
    Auth->>Auth: Validate JWT
    Auth->>DB: Get user profile
    DB-->>Auth: User data
    Auth-->>Kong: Profile data
    Kong-->>Test: 200 OK with profile
```

## Flow Steps

1. **Signup**: Create a new user account
   - Endpoint: `POST /auth/v1/auth/signup`
   - Input: email, password, firstName, lastName
   - Output: User data

2. **Login**: Authenticate and get tokens
   - Endpoint: `POST /auth/v1/auth/login`
   - Input: email, password
   - Output: accessToken, refreshToken

3. **Verify Access Token**: Use token to access protected resource
   - Endpoint: `GET /auth/v1/user/profile`
   - Header: `Authorization: Bearer {accessToken}`
   - Output: User profile data

4. **Refresh Token**: Get new access token
   - Endpoint: `POST /auth/v1/auth/refresh`
   - Input: refreshToken
   - Output: New accessToken

5. **Verify New Token**: Confirm new token works
   - Endpoint: `GET /auth/v1/user/profile`
   - Header: `Authorization: Bearer {newAccessToken}`
   - Output: User profile data

## Success Criteria

- ✅ User can signup successfully
- ✅ User can login with correct credentials
- ✅ Access token can access protected resources
- ✅ Refresh token can generate new access token
- ✅ New access token works correctly

