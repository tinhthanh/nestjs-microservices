# Auth Signup Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Traefik as Traefik Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL

    K6->>Traefik: POST /auth/v1/auth/signup
    Note over K6: {email, password, firstName, lastName}
    Traefik->>Auth: Forward request
    Auth->>DB: Create user
    DB-->>Auth: User created
    Auth->>Auth: Generate JWT tokens
    Auth-->>Traefik: 201 + {accessToken, refreshToken, user}
    Traefik-->>K6: Return response
    
    Note over K6: Verify status 201
    Note over K6: Verify accessToken exists
```

## Test Steps

1. Generate unique test email
2. Send POST request to `/auth/v1/auth/signup`
3. Verify response status is 201
4. Verify response contains `accessToken`
5. Verify response contains user data

## Expected Response

```json
{
  "statusCode": 201,
  "message": "User registration successful.",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "user": {
      "id": "uuid",
      "email": "test@example.com",
      "firstName": "Test",
      "lastName": "User",
      "role": "USER"
    }
  }
}
```

