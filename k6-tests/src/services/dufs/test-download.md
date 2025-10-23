# DUFS Download Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DUFS as DUFS Service

    K6->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    K6->>Kong: GET /files/
    Note over K6: Authorization: Bearer {accessToken}
    Kong->>Kong: Verify JWT (Kong JWT Plugin)
    Kong->>DUFS: Forward request
    DUFS->>DUFS: List files
    DUFS-->>Kong: 200 + file list (HTML)
    Kong-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Send GET request to `/files/` to list files
3. Verify response status is 200
4. Verify file list is returned

