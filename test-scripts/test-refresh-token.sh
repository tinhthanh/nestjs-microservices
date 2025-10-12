#!/bin/bash

# Test Refresh Token
# First login to get refresh token
echo "========================================="
echo "Step 1: Login to get refresh token"
echo "========================================="

RESPONSE=$(curl -s -X POST http://localhost:8000/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }')

echo "$RESPONSE" | jq .

REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.data.refreshToken')

if [ "$REFRESH_TOKEN" == "null" ] || [ -z "$REFRESH_TOKEN" ]; then
  echo "Failed to get refresh token. Please check login credentials."
  exit 1
fi

echo ""
echo "========================================="
echo "Step 2: Refresh Access Token"
echo "========================================="

curl -X GET http://localhost:8000/auth/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $REFRESH_TOKEN" | jq .

echo ""

