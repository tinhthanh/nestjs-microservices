#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Test Auth Signup
echo "========================================="
echo "Testing Auth Signup ($MODE mode)"
echo "========================================="

curl -X POST $KONG_URL/auth/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456",
    "firstName": "Regular",
    "lastName": "User"
  }' | jq .

echo ""