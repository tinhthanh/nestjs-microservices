# Auth Partner Create Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL

    Note over K6: Requires Admin User
    K6->>Kong: POST /auth/v1/auth/login (admin)
    Kong->>Auth: Forward request
    Auth-->>K6: {accessToken (admin)}
    
    K6->>Kong: POST /auth/v1/partner/create
    Note over K6: Authorization: Bearer {adminToken}
    Note over K6: {firebaseUid, email, ...}
    Kong->>Auth: Forward request
    Auth->>Auth: Verify admin role
    Auth->>DB: Create partner user
    DB-->>Auth: Partner created
    Auth-->>Kong: 201 + {partner}
    Kong-->>K6: Return response
```

## Test Steps

1. Login as admin user (if available)
2. Send POST request to `/auth/v1/partner/create` with Firebase UID
3. Verify response status is 201
4. Verify partner was created

## Note

This test is skipped if no admin user is available. It requires:
- Admin user credentials
- Firebase UID for partner creation

## Expected Response

```json
{
  "statusCode": 201,
  "message": "Partner created successfully.",
  "data": {
    "id": "uuid",
    "firebaseUid": "firebase-uid",
    "email": "partner@example.com",
    "role": "PARTNER"
  }
}
```

