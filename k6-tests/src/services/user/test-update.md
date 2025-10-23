# User Update Profile Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Traefik as Traefik Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL

    K6->>Traefik: POST /auth/v1/auth/login
    Traefik->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    K6->>Traefik: PATCH /auth/v1/user/profile
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: {firstName, lastName}
    Traefik->>Auth: Forward request
    Auth->>Auth: Verify JWT token
    Auth->>DB: Update user
    DB-->>Auth: Updated user
    Auth-->>Traefik: 200 + {user}
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Send PATCH request to `/auth/v1/user/profile` with updated data
3. Verify response status is 200
4. Verify profile was updated

