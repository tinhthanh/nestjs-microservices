# DUFS Delete Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Traefik as Traefik Gateway
    participant Auth as Auth Service
    participant DUFS as DUFS Service

    K6->>Traefik: POST /auth/v1/auth/login
    Traefik->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    Note over K6: Upload file first
    K6->>Traefik: PUT /files/{filename}
    Traefik->>DUFS: Forward request
    DUFS-->>K6: 201 Created
    
    K6->>Traefik: DELETE /files/{filename}
    Note over K6: Authorization: Bearer {accessToken}
    Traefik->>Traefik: Verify JWT (Traefik JWT Plugin)
    Traefik->>DUFS: Forward request
    DUFS->>DUFS: Delete file from disk
    DUFS-->>Traefik: 200 or 204
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Upload a test file
3. Send DELETE request to `/files/{filename}`
4. Verify response status is 200 or 204
5. Verify file was deleted

