# DUFS Delete Test

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
    
    Note over K6: Upload file first
    K6->>Kong: PUT /files/{filename}
    Kong->>DUFS: Forward request
    DUFS-->>K6: 201 Created
    
    K6->>Kong: DELETE /files/{filename}
    Note over K6: Authorization: Bearer {accessToken}
    Kong->>Kong: Verify JWT (Kong JWT Plugin)
    Kong->>DUFS: Forward request
    DUFS->>DUFS: Delete file from disk
    DUFS-->>Kong: 200 or 204
    Kong-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Upload a test file
3. Send DELETE request to `/files/{filename}`
4. Verify response status is 200 or 204
5. Verify file was deleted

