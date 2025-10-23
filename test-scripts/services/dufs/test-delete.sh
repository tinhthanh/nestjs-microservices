#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../common/config.sh"

echo "========================================="
echo "Testing File Delete ($MODE mode)"
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

# Step 2: Create and upload a test file
echo ""
echo "Step 2: Create and upload test file"
TEST_FILE="/tmp/test-delete-$(date +%s).txt"
echo "This file will be deleted" > "$TEST_FILE"
FILENAME=$(basename "$TEST_FILE")

curl -s -X PUT "$KONG_URL/files/$FILENAME" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  --data-binary "@$TEST_FILE" > /dev/null

echo "✅ Test file uploaded: $FILENAME"

# Step 3: Delete the file
echo ""
echo "Step 3: Delete the file"
DELETE_RESPONSE=$(curl -s -X DELETE "$KONG_URL/files/$FILENAME" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "Delete response: $DELETE_RESPONSE"
echo "✅ File deleted successfully"

# Clean up
rm -f "$TEST_FILE"
echo ""

