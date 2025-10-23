#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../common/config.sh"

echo "========================================="
echo "Testing File Download ($MODE mode)"
echo "========================================="

# Step 1: Login to get access token
echo ""
echo "Step 1: Login to get access token"
LOGIN_RESPONSE=$(curl -s -X POST $KONG_URL/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }')

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ Failed to get access token"
  exit 1
fi

echo "✅ Access token obtained"

# Step 2: List files
echo ""
echo "Step 2: List available files"
curl -s -X GET "$KONG_URL/files/" \
  -H "Authorization: Bearer $ACCESS_TOKEN"

echo ""
echo "✅ File list retrieved"
echo ""

