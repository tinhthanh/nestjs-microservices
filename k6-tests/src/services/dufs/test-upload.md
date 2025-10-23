# DUFS Upload Test

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
    
    K6->>Traefik: PUT /files/{filename}
    Note over K6: Authorization: Bearer {accessToken}
    Note over K6: Content-Type: text/plain
    Note over K6: Body: file content
    Traefik->>Traefik: Verify JWT (Traefik JWT Plugin)
    Traefik->>DUFS: Forward request
    DUFS->>DUFS: Save file to disk
    DUFS-->>Traefik: 201 Created
    Traefik-->>K6: Return response
```

## Test Steps

1. Login to get access token
2. Generate unique filename
3. Send PUT request to `/files/{filename}` with file content
4. Verify response status is 201 or 200
5. Verify file was uploaded

