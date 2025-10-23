# DUFS Flow Diagram

## Complete File Management Flow

```mermaid
sequenceDiagram
    participant Test as Test Script
    participant Kong as Kong Gateway
    participant Plugin as Kong JWT Plugin
    participant Dufs as Dufs File Server
    participant FS as File System
    
    Note over Test,FS: Step 1: Login
    Test->>Kong: POST /auth/v1/auth/login
    Kong->>Kong: Route to Auth Service
    Kong-->>Test: 200 OK with token
    
    Note over Test,FS: Step 2: Test Unauthorized Access
    Test->>Kong: GET /files/
    Note right of Test: No Authorization header
    Kong->>Plugin: Check JWT
    Plugin-->>Kong: 401 Unauthorized
    Kong-->>Test: 401 Unauthorized
    
    Note over Test,FS: Step 3: Create Test File
    Test->>Test: Create local file
    Note right of Test: /tmp/dufs-test-{timestamp}.txt
    
    Note over Test,FS: Step 4: Upload File
    Test->>Kong: PUT /files/{filename}
    Note right of Test: Authorization: Bearer {token}
    Kong->>Plugin: Validate JWT
    Plugin-->>Kong: Token valid
    Kong->>Dufs: Forward file upload
    Dufs->>FS: Write file
    FS-->>Dufs: File written
    Dufs-->>Kong: 201 Created
    Kong-->>Test: 201 Created
    
    Note over Test,FS: Step 5: List Files
    Test->>Kong: GET /files/
    Note right of Test: Authorization: Bearer {token}
    Kong->>Plugin: Validate JWT
    Plugin-->>Kong: Token valid
    Kong->>Dufs: Forward request
    Dufs->>FS: List directory
    FS-->>Dufs: File list
    Dufs-->>Kong: HTML/JSON response
    Kong-->>Test: 200 OK with file list
    
    Note over Test,FS: Step 6: Download File
    Test->>Kong: GET /files/{filename}
    Note right of Test: Authorization: Bearer {token}
    Kong->>Plugin: Validate JWT
    Plugin-->>Kong: Token valid
    Kong->>Dufs: Forward request
    Dufs->>FS: Read file
    FS-->>Dufs: File content
    Dufs-->>Kong: File data
    Kong-->>Test: 200 OK with file
    Test->>Test: Verify content matches
    
    Note over Test,FS: Step 7: Delete File
    Test->>Kong: DELETE /files/{filename}
    Note right of Test: Authorization: Bearer {token}
    Kong->>Plugin: Validate JWT
    Plugin-->>Kong: Token valid
    Kong->>Dufs: Forward request
    Dufs->>FS: Delete file
    FS-->>Dufs: File deleted
    Dufs-->>Kong: 200 OK
    Kong-->>Test: 200 OK
    
    Note over Test,FS: Step 8: Cleanup
    Test->>Test: Remove local test files
```

## Flow Steps

1. **Login**: Get access token
   - Endpoint: `POST /auth/v1/auth/login`
   - Output: accessToken

2. **Test Unauthorized Access**: Verify JWT protection
   - Endpoint: `GET /files/`
   - Expected: 401 Unauthorized

3. **Create Test File**: Generate local test file
   - Location: `/tmp/dufs-test-{timestamp}.txt`
   - Content: Test string

4. **Upload File**: Upload to DUFS
   - Endpoint: `PUT /files/{filename}`
   - Header: `Authorization: Bearer {token}`
   - Method: Binary upload
   - Expected: 201 Created

5. **List Files**: Get file listing
   - Endpoint: `GET /files/`
   - Header: `Authorization: Bearer {token}`
   - Expected: File appears in list

6. **Download File**: Download and verify
   - Endpoint: `GET /files/{filename}`
   - Header: `Authorization: Bearer {token}`
   - Verify: Content matches original

7. **Delete File**: Remove from server
   - Endpoint: `DELETE /files/{filename}`
   - Header: `Authorization: Bearer {token}`
   - Expected: 200 OK

8. **Cleanup**: Remove local test files

## Success Criteria

- ✅ Unauthorized access is blocked (401)
- ✅ File upload works with valid token
- ✅ Uploaded file appears in listing
- ✅ Downloaded file content matches original
- ✅ File deletion works correctly
- ✅ Kong JWT plugin protects all endpoints

## Key Features Tested

- **JWT Authentication**: Kong plugin validates tokens
- **File Upload**: Binary file upload via PUT
- **File Download**: Binary file download via GET
- **File Listing**: Directory listing
- **File Deletion**: Remove files from server
- **Content Verification**: Ensure data integrity

