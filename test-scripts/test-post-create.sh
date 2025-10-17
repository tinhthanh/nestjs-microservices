#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Test Create Post
# First login to get access token
echo "========================================="
echo "Step 1: Login to get access token ($MODE mode)"
echo "========================================="

RESPONSE=$(curl -s -X POST $KONG_URL/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }')

echo "$RESPONSE" | jq .

ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.data.accessToken')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "Failed to get access token. Please check login credentials."
  exit 1
fi

echo ""
echo "========================================="
echo "Step 2: Create New Post"
echo "========================================="

curl -X POST $KONG_URL/post/v1/post \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "title": "My First Post",
    "content": "This is the content of my first post. It contains some interesting information."
  }' | jq .

echo ""

