# Partner Verification Flow Test

## Flow Diagram

```mermaid
sequenceDiagram
    participant K6 as k6 Test
    participant Firebase as Firebase Auth
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL

    Note over K6: Step 1: Firebase Authentication
    K6->>Firebase: Authenticate with Firebase
    Firebase-->>K6: {firebaseIdToken}
    
    Note over K6: Step 2: Verify Partner
    K6->>Kong: GET /auth/v1/partner/verify
    Note over K6: Authorization: Bearer {firebaseIdToken}
    Kong->>Auth: Forward request
    Auth->>Auth: Verify Firebase token
    Auth->>DB: Find/Create partner user
    Auth->>Auth: Generate JWT tokens
    Auth-->>Kong: 200 + {accessToken, refreshToken, user}
    Kong-->>K6: Return response
```

## Test Steps

1. **Firebase Authentication**: Authenticate with Firebase to get ID token
2. **Verify Partner**: Send Firebase ID token to partner verify endpoint
3. **Verify Response**: Check that partner was authenticated and JWT tokens were generated

## Note

This test requires Firebase configuration and is currently skipped. To enable:
- Configure Firebase Admin SDK in Auth service
- Provide Firebase test credentials
- Update test to use real Firebase authentication

## Success Criteria

- Firebase token is validated
- Partner user is created/found in database
- JWT tokens are generated for partner

