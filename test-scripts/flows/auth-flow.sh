#!/bin/bash

# Complete Auth Flow Test: Signup -> Login -> Refresh Token

set -e  # Exit on error

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/config.sh"
source "$SCRIPT_DIR/../common/utils.sh"

print_header "🔐 Complete Auth Flow Test ($MODE mode)"

# Generate unique email for testing
TIMESTAMP=$(date +%s)
TEST_EMAIL="testuser${TIMESTAMP}@example.com"
TEST_PASSWORD="Test123456"

# Step 1: Signup
print_step "Step 1: Signup new user"
SIGNUP_RESPONSE=$(curl -s --max-time 10 -X POST $KONG_URL/auth/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"firstName\": \"Test\",
    \"lastName\": \"User\"
  }")

if [ -z "$SIGNUP_RESPONSE" ]; then
    print_error "Signup failed - no response from server"
    exit 1
fi

echo "$SIGNUP_RESPONSE" | jq . 2>/dev/null || echo "$SIGNUP_RESPONSE"

if echo "$SIGNUP_RESPONSE" | jq -e '.data.user.email' > /dev/null 2>&1; then
    print_success "Signup successful"
else
    print_error "Signup failed"
    exit 1
fi

# Step 2: Login
print_step "Step 2: Login with new credentials"
LOGIN_RESPONSE=$(curl -s --max-time 10 -X POST $KONG_URL/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

if [ -z "$LOGIN_RESPONSE" ]; then
    print_error "Login failed - no response from server"
    exit 1
fi

echo "$LOGIN_RESPONSE" | jq . 2>/dev/null || echo "$LOGIN_RESPONSE"

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken')
REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.refreshToken')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    print_error "Login failed - no access token"
    exit 1
fi

print_success "Login successful"

# Step 3: Verify access token by getting profile
print_step "Step 3: Verify access token (get profile)"
PROFILE_RESPONSE=$(curl -s --max-time 10 -X GET $KONG_URL/auth/v1/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "$PROFILE_RESPONSE" | jq . 2>/dev/null || echo "$PROFILE_RESPONSE"

if echo "$PROFILE_RESPONSE" | jq -e '.data.email' > /dev/null 2>&1; then
    print_success "Access token is valid"
else
    print_error "Access token verification failed"
    exit 1
fi

# Step 4: Refresh token
print_step "Step 4: Refresh access token"
REFRESH_RESPONSE=$(curl -s --max-time 10 -X GET $KONG_URL/auth/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $REFRESH_TOKEN")

echo "$REFRESH_RESPONSE" | jq . 2>/dev/null || echo "$REFRESH_RESPONSE"

NEW_ACCESS_TOKEN=$(echo "$REFRESH_RESPONSE" | jq -r '.data.accessToken')

if [ "$NEW_ACCESS_TOKEN" == "null" ] || [ -z "$NEW_ACCESS_TOKEN" ]; then
    print_error "Token refresh failed"
    exit 1
fi

print_success "Token refresh successful"

# Step 5: Verify new access token
print_step "Step 5: Verify new access token"
VERIFY_RESPONSE=$(curl -s --max-time 10 -X GET $KONG_URL/auth/v1/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $NEW_ACCESS_TOKEN")

echo "$VERIFY_RESPONSE" | jq . 2>/dev/null || echo "$VERIFY_RESPONSE"

if echo "$VERIFY_RESPONSE" | jq -e '.data.email' > /dev/null 2>&1; then
    print_success "New access token is valid"
else
    print_error "New access token verification failed"
    exit 1
fi

echo ""
print_header "✅ Complete Auth Flow Test PASSED"

