# DUFS Upload Test

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
    
    K6->>Kong: PUT /files/{filename}
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: Content-Type: text/plain
    Note over K6: Body: file content
    Kong->>Kong: Verify JWT (Kong JWT Plugin)
    Kong->>DUFS: Forward request
    DUFS->>DUFS: Save file to disk
    DUFS-->>Kong: 201 Created
    Kong-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Generate unique filename
3. Send PUT request to `/files/{filename}` with file content
4. Verify response status is 201 or 200
5. Verify file was uploaded

