#!/bin/bash

# Complete Post Flow Test: Login -> Create -> List -> Update -> Delete

set -e  # Exit on error

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/config.sh"
source "$SCRIPT_DIR/../common/utils.sh"

print_header "📝 Complete Post Flow Test ($MODE mode)"

# Step 1: Login
print_step "Step 1: Login to get access token"
LOGIN_RESPONSE=$(curl -s --max-time 10 -X POST $KONG_URL/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }')

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken' 2>/dev/null)

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    print_error "Login failed"
    exit 1
fi

print_success "Login successful"

# Step 2: Create Post
print_step "Step 2: Create new post"
CREATE_RESPONSE=$(curl -s --max-time 10 -X POST $KONG_URL/post/v1/post \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "title": "Test Post from Flow",
    "content": "This is a test post created during the complete flow test."
  }')

echo "$CREATE_RESPONSE" | jq . 2>/dev/null || echo "$CREATE_RESPONSE"

POST_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data.id' 2>/dev/null)

if [ "$POST_ID" == "null" ] || [ -z "$POST_ID" ]; then
    print_error "Post creation failed"
    exit 1
fi

print_success "Post created with ID: $POST_ID"

# Step 3: List Posts
print_step "Step 3: List posts"
LIST_RESPONSE=$(curl -s --max-time 10 -X GET "$KONG_URL/post/v1/post?page=1&limit=10" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "$LIST_RESPONSE" | jq . 2>/dev/null || echo "$LIST_RESPONSE"

TOTAL_ITEMS=$(echo "$LIST_RESPONSE" | jq -r '.data.meta.total' 2>/dev/null)

if [ "$TOTAL_ITEMS" == "null" ] || [ -z "$TOTAL_ITEMS" ]; then
    print_error "Failed to list posts"
    exit 1
fi

print_success "Found $TOTAL_ITEMS posts"

# Step 4: Update Post
print_step "Step 4: Update post"
UPDATE_RESPONSE=$(curl -s --max-time 10 -X PUT "$KONG_URL/post/v1/post/$POST_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "title": "Updated Test Post",
    "content": "This post has been updated during the flow test."
  }')

echo "$UPDATE_RESPONSE" | jq . 2>/dev/null || echo "$UPDATE_RESPONSE"

if echo "$UPDATE_RESPONSE" | jq -e '.data.id' > /dev/null 2>&1; then
    print_success "Post updated successfully"
else
    print_error "Post update failed"
    exit 1
fi

# Step 5: Delete Post
print_step "Step 5: Delete post"
DELETE_RESPONSE=$(curl -s --max-time 10 -X DELETE "$KONG_URL/post/v1/post/batch" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{
    \"ids\": [\"$POST_ID\"]
  }")

echo "$DELETE_RESPONSE" | jq . 2>/dev/null || echo "$DELETE_RESPONSE"

if echo "$DELETE_RESPONSE" | jq -e '.data.count' > /dev/null 2>&1; then
    print_success "Post deleted successfully"
else
    print_error "Post deletion failed"
    exit 1
fi

echo ""
print_header "✅ Complete Post Flow Test PASSED"

