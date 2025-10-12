#!/bin/bash

# Test Auth Signup
echo "========================================="
echo "Testing Auth Signup"
echo "========================================="

curl -X POST http://localhost:8000/auth/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456",
    "firstName": "Regular",
    "lastName": "User"
  }' | jq .

echo ""