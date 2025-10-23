#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../common/config.sh"

echo "========================================="
echo "Testing File Upload ($MODE mode)"
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

# Step 2: Create a test file
echo ""
echo "Step 2: Create test file"
TEST_FILE="/tmp/test-upload-$(date +%s).txt"
echo "This is a test file for upload" > "$TEST_FILE"
echo "✅ Test file created: $TEST_FILE"

# Step 3: Upload file
echo ""
echo "Step 3: Upload file to dufs"
UPLOAD_RESPONSE=$(curl -s -X PUT "$KONG_URL/files/$(basename $TEST_FILE)" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  --data-binary "@$TEST_FILE")

echo "Upload response: $UPLOAD_RESPONSE"
echo "✅ File uploaded successfully"

# Clean up
rm -f "$TEST_FILE"
echo ""

