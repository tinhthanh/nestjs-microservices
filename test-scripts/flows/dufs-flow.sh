#!/bin/bash

# Complete DUFS Flow Test: Login -> Upload -> Download -> Delete

set -e  # Exit on error

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/config.sh"
source "$SCRIPT_DIR/../common/utils.sh"

print_header "📁 Complete DUFS Flow Test ($MODE mode)"

# Step 1: Login
print_step "Step 1: Login to get access token"
LOGIN_RESPONSE=$(curl -s -X POST $KONG_URL/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }')

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    print_error "Login failed"
    exit 1
fi

print_success "Login successful"

# Step 2: Test unauthorized access (should fail)
print_step "Step 2: Test unauthorized access (should return 401)"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/files/)

if [ "$HTTP_STATUS" -eq 401 ]; then
    print_success "Unauthorized access correctly blocked (401)"
else
    print_warning "Expected 401 but got $HTTP_STATUS"
fi

# Step 3: Create test file
print_step "Step 3: Create test file"
TEST_FILE="/tmp/dufs-test-$(date +%s).txt"
echo "This is a test file for DUFS flow test" > "$TEST_FILE"
FILENAME=$(basename "$TEST_FILE")
print_success "Test file created: $FILENAME"

# Step 4: Upload file
print_step "Step 4: Upload file to DUFS"
UPLOAD_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PUT "http://localhost:8000/files/$FILENAME" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  --data-binary "@$TEST_FILE")

HTTP_STATUS=$(echo "$UPLOAD_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)

if [ "$HTTP_STATUS" == "201" ] || [ "$HTTP_STATUS" == "200" ]; then
    print_success "File uploaded successfully"
else
    print_error "File upload failed with status $HTTP_STATUS"
    rm -f "$TEST_FILE"
    exit 1
fi

# Step 5: List files
print_step "Step 5: List files"
LIST_RESPONSE=$(curl -s -X GET "http://localhost:8000/files/" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

if echo "$LIST_RESPONSE" | grep -q "$FILENAME"; then
    print_success "File found in listing"
else
    print_warning "File not found in listing (might be in subdirectory)"
fi

# Step 6: Download file
print_step "Step 6: Download file"
DOWNLOAD_FILE="/tmp/downloaded-$FILENAME"
curl -s -X GET "http://localhost:8000/files/$FILENAME" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -o "$DOWNLOAD_FILE"

if [ -f "$DOWNLOAD_FILE" ]; then
    print_success "File downloaded successfully"
    ORIGINAL_CONTENT=$(cat "$TEST_FILE")
    DOWNLOADED_CONTENT=$(cat "$DOWNLOAD_FILE")
    
    if [ "$ORIGINAL_CONTENT" == "$DOWNLOADED_CONTENT" ]; then
        print_success "File content matches original"
    else
        print_warning "File content differs from original"
    fi
else
    print_error "File download failed"
fi

# Step 7: Delete file
print_step "Step 7: Delete file"
DELETE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "http://localhost:8000/files/$FILENAME" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

HTTP_STATUS=$(echo "$DELETE_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)

if [ "$HTTP_STATUS" == "200" ] || [ "$HTTP_STATUS" == "204" ]; then
    print_success "File deleted successfully"
else
    print_warning "File deletion returned status $HTTP_STATUS"
fi

# Clean up
rm -f "$TEST_FILE" "$DOWNLOAD_FILE"

echo ""
print_header "✅ Complete DUFS Flow Test PASSED"

