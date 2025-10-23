# Complete DUFS Flow Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DUFS as DUFS Service
    participant Disk as File System

    Note over K6: Step 1: Login
    K6->>Kong: POST /auth/v1/auth/login
    Kong->>Auth: Forward request
    Auth-->>K6: {accessToken}
    
    Note over K6: Step 2: Upload File
    K6->>Kong: PUT /files/{filename}
    Note over K6: Authorization: Bearer {accessToken}
    Kong->>Kong: Verify JWT (Kong Plugin)
    Kong->>DUFS: Forward request
    DUFS->>Disk: Write file
    DUFS-->>K6: 201 Created
    
    Note over K6: Step 3: List Files
    K6->>Kong: GET /files/
    Kong->>Kong: Verify JWT
    Kong->>DUFS: Forward request
    DUFS->>Disk: List directory
    DUFS-->>K6: File list (HTML)
    
    Note over K6: Step 4: Download File
    K6->>Kong: GET /files/{filename}
    Kong->>Kong: Verify JWT
    Kong->>DUFS: Forward request
    DUFS->>Disk: Read file
    DUFS-->>K6: File content
    
    Note over K6: Step 5: Delete File
    K6->>Kong: DELETE /files/{filename}
    Kong->>Kong: Verify JWT
    Kong->>DUFS: Forward request
    DUFS->>Disk: Delete file
    DUFS-->>K6: 200 or 204
```

## Test Steps

1. **Login**: Get access token
2. **Upload File**: Upload a test file
3. **List Files**: List all files in directory
4. **Download File**: Download the uploaded file
5. **Delete File**: Delete the uploaded file

## Success Criteria

- File upload, download, and delete operations work
- Kong JWT plugin validates tokens correctly
- Files are persisted to disk

