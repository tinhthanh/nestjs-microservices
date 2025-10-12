#!/bin/bash

# Test Get User Profile
# First login to get access token
echo "========================================="
echo "Step 1: Login to get access token"
echo "========================================="

RESPONSE=$(curl -s -X POST http://localhost:8000/auth/v1/auth/login \
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
echo "Step 2: Get User Profile"
echo "========================================="

curl -X GET http://localhost:8000/auth/v1/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq .

echo ""

