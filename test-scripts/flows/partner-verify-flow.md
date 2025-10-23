# Partner Verification Flow Diagram

## Firebase Partner Integration Flow

```mermaid
sequenceDiagram
    participant Test as Test Script
    participant Firebase as Firebase Auth
    participant Kong as Kong Gateway
    participant Auth as Auth Service
    participant DB as PostgreSQL
    
    Note over Test,DB: Step 1: Authenticate with Firebase
    Test->>Firebase: POST /accounts:signInWithPassword
    Note right of Test: email: test@vetgo.ai<br/>password: Test123456
    Firebase->>Firebase: Verify credentials
    Firebase-->>Test: idToken + localId (UID)
    
    Note over Test,DB: Step 2: Verify Partner Token
    Test->>Kong: GET /auth/v1/partner/verify
    Note right of Test: x-client-id: vetgo-ai-01<br/>x-client-secret: {firebaseIdToken}
    Kong->>Auth: Forward request
    Auth->>DB: Get partner config by projectId
    DB-->>Auth: Partner config (apiKey, etc.)
    Auth->>Firebase: Verify idToken with Firebase Admin SDK
    Firebase-->>Auth: Token valid + user data
    Auth->>DB: Find or create user
    Note right of Auth: Map Firebase UID to local user
    DB-->>Auth: User record
    Auth->>Auth: Generate JWT tokens
    Auth-->>Kong: accessToken + refreshToken
    Kong-->>Test: 200 OK with tokens
    
    Note over Test,DB: Step 3: Verify Access Token
    Test->>Kong: GET /auth/v1/user/profile
    Note right of Test: Authorization: Bearer {accessToken}
    Kong->>Auth: Forward request
    Auth->>Auth: Validate JWT
    Auth->>DB: Get user profile
    DB-->>Auth: User data
    Auth-->>Kong: Profile data
    Kong-->>Test: 200 OK with profile
    
    Note over Test,DB: Step 4: Use Token with Other Services
    Test->>Kong: POST /post/v1/post
    Note right of Test: Authorization: Bearer {accessToken}
    Kong->>Kong: Route to Post Service
    Note over Kong: Post Service validates<br/>token via gRPC to Auth
    Kong-->>Test: 201 Created
```

## Flow Steps

1. **Authenticate with Firebase**
   - Endpoint: `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword`
   - Input: email, password, Firebase API key
   - Output: Firebase idToken and UID

2. **Verify Partner Token**
   - Endpoint: `GET /auth/v1/partner/verify`
   - Headers:
     - `x-client-id`: Partner project ID (e.g., "vetgo-ai-01")
     - `x-client-secret`: Firebase idToken
   - Process:
     - Auth service looks up partner config
     - Verifies token with Firebase Admin SDK
     - Maps Firebase UID to local user (create if not exists)
     - Generates our JWT tokens
   - Output: accessToken, refreshToken

3. **Verify Access Token**
   - Endpoint: `GET /auth/v1/user/profile`
   - Header: `Authorization: Bearer {accessToken}`
   - Output: User profile data

4. **Use Token with Other Services**
   - Example: Create post
   - Token works across all services
   - gRPC validation ensures consistency

## Partner Configuration

Partner must be registered in database with:
- `projectId`: Unique identifier (e.g., "vetgo-ai-01")
- `apiKey`: Firebase API key
- `authDomain`: Firebase auth domain
- `clientEmail`: Service account email
- `privateKey`: Service account private key
- `isActive`: true

## Success Criteria

- ✅ Firebase authentication succeeds
- ✅ Partner token verification succeeds
- ✅ User is created/found in local database
- ✅ JWT tokens are generated
- ✅ Tokens work with all services
- ✅ User profile is accessible

## Key Features Tested

- **Firebase Integration**: External auth provider
- **Partner Management**: Multi-tenant support
- **Token Exchange**: Firebase token → JWT token
- **User Mapping**: Firebase UID → Local user
- **Cross-Service Auth**: Token works everywhere
- **Admin SDK**: Server-side token verification

## Error Cases

- ❌ Invalid Firebase credentials → 401
- ❌ Invalid partner projectId → 404
- ❌ Inactive partner → 403
- ❌ Invalid Firebase token → 401
- ❌ Expired Firebase token → 401

