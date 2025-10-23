#!/bin/bash

# Partner Verification Flow Test: Firebase Auth -> Partner Verify

set -e  # Exit on error

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/config.sh"
source "$SCRIPT_DIR/../common/utils.sh"

print_header "🔑 Partner Verification Flow Test ($MODE mode)"

# Step 1: Authenticate with Firebase
print_step "Step 1: Authenticate with Firebase"
FIREBASE_API_KEY="AIzaSyB2TjO3fDU-Fhd9a52f3MdoKu5w1lF8dWQ"
FIREBASE_RESPONSE=$(curl -s --max-time 10 -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@vetgo.ai","password":"Test123456","returnSecureToken":true}')

FIREBASE_ID_TOKEN=$(echo "$FIREBASE_RESPONSE" | jq -r '.idToken' 2>/dev/null)
FIREBASE_UID=$(echo "$FIREBASE_RESPONSE" | jq -r '.localId' 2>/dev/null)

if [ "$FIREBASE_ID_TOKEN" == "null" ] || [ -z "$FIREBASE_ID_TOKEN" ]; then
    print_error "Firebase authentication failed"
    echo "$FIREBASE_RESPONSE" | jq . 2>/dev/null || echo "$FIREBASE_RESPONSE"
    exit 1
fi

print_success "Firebase authentication successful"
print_info "Firebase UID: $FIREBASE_UID"

# Step 2: Verify partner token
print_step "Step 2: Verify partner token with our service"
VERIFY_RESPONSE=$(curl -s --max-time 10 -X GET "${BASE_URL}/auth/v1/partner/verify" \
  -H "x-client-id: vetgo-ai-01" \
  -H "x-client-secret: ${FIREBASE_ID_TOKEN}")

echo "$VERIFY_RESPONSE" | jq . 2>/dev/null || echo "$VERIFY_RESPONSE"

if echo "$VERIFY_RESPONSE" | jq -e '.data.accessToken' > /dev/null 2>&1; then
    print_success "Partner verification successful"
    ACCESS_TOKEN=$(echo "$VERIFY_RESPONSE" | jq -r '.data.accessToken')
else
    print_error "Partner verification failed"
    exit 1
fi

# Step 3: Use access token to get profile
print_step "Step 3: Verify access token by getting profile"
PROFILE_RESPONSE=$(curl -s --max-time 10 -X GET $KONG_URL/auth/v1/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "$PROFILE_RESPONSE" | jq . 2>/dev/null || echo "$PROFILE_RESPONSE"

if echo "$PROFILE_RESPONSE" | jq -e '.data.email' > /dev/null 2>&1; then
    print_success "Access token is valid and working"
else
    print_error "Access token verification failed"
    exit 1
fi

echo ""
print_header "✅ Partner Verification Flow Test PASSED"

