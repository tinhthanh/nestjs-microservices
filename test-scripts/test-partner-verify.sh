#!/bin/bash

# Load configuration
source "$(dirname "$0")/config.sh"

echo "========================================"
echo "Partner Token Verification Test"
echo "========================================"
echo ""

# Step 1: Authenticate with Firebase
echo "Step 1: Authenticate with Firebase"
echo "Email: test@vetgo.ai"
echo ""

FIREBASE_API_KEY="AIzaSyB2TjO3fDU-Fhd9a52f3MdoKu5w1lF8dWQ"
FIREBASE_RESPONSE=$(curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@vetgo.ai","password":"Test123456","returnSecureToken":true}')

FIREBASE_ID_TOKEN=$(echo "$FIREBASE_RESPONSE" | jq -r '.idToken')
FIREBASE_UID=$(echo "$FIREBASE_RESPONSE" | jq -r '.localId')

if [ "$FIREBASE_ID_TOKEN" == "null" ] || [ -z "$FIREBASE_ID_TOKEN" ]; then
    echo "✗ Firebase authentication failed"
    echo "Response: $FIREBASE_RESPONSE"
    exit 1
fi

echo "✓ Firebase authentication successful"
echo "Firebase UID: $FIREBASE_UID"
echo ""

# Step 2: Verify partner token (GET method, no body)
echo "Step 2: Verify partner token"
echo "Endpoint: GET ${BASE_URL}/v1/partner/verify"
echo "Project ID: vetgo-ai-01"
echo ""

VERIFY_RESPONSE=$(curl -s -X GET "${BASE_URL}/v1/partner/verify" \
  -H "x-client-id: vetgo-ai-01" \
  -H "x-client-secret: ${FIREBASE_ID_TOKEN}")

echo "Response:"
echo "$VERIFY_RESPONSE" | jq .
echo ""

# Check if verification was successful
STATUS_CODE=$(echo "$VERIFY_RESPONSE" | jq -r '.statusCode')
if [ "$STATUS_CODE" == "201" ] || [ "$STATUS_CODE" == "200" ]; then
    echo "✓ Token verification successful"
    
    USER_ID=$(echo "$VERIFY_RESPONSE" | jq -r '.data.userId')
    ACCESS_TOKEN=$(echo "$VERIFY_RESPONSE" | jq -r '.data.accessToken')
    REFRESH_TOKEN=$(echo "$VERIFY_RESPONSE" | jq -r '.data.refreshToken')
    
    echo "User ID: $USER_ID"
    echo "Access Token: ${ACCESS_TOKEN:0:50}..."
    echo "Refresh Token: ${REFRESH_TOKEN:0:50}..."
    echo ""
    
    # Step 3: Verify access token by getting user profile
    echo "Step 3: Verify access token by getting user profile"
    echo "Endpoint: ${BASE_URL}/v1/user/profile"
    echo ""
    
    PROFILE_RESPONSE=$(curl -s -X GET "${BASE_URL}/v1/user/profile" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}")
    
    echo "Response:"
    echo "$PROFILE_RESPONSE" | jq .
    echo ""
    
    PROFILE_STATUS=$(echo "$PROFILE_RESPONSE" | jq -r '.statusCode')
    if [ "$PROFILE_STATUS" == "200" ]; then
        echo "✓ Access token is valid"
        
        # Check if user info was saved
        FIRST_NAME=$(echo "$PROFILE_RESPONSE" | jq -r '.data.firstName')
        LAST_NAME=$(echo "$PROFILE_RESPONSE" | jq -r '.data.lastName')
        AVATAR=$(echo "$PROFILE_RESPONSE" | jq -r '.data.avatar')
        
        echo ""
        echo "User Info:"
        echo "  First Name: $FIRST_NAME"
        echo "  Last Name: $LAST_NAME"
        echo "  Avatar: $AVATAR"
        
        echo "✓ All tests passed!"
    else
        echo "✗ Access token is invalid"
        exit 1
    fi
else
    echo "✗ Token verification failed"
    exit 1
fi

echo ""
echo "========================================"
echo "Partner Token Verification Test Complete"
echo "========================================"

