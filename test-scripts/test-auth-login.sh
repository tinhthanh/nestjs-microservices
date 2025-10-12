#!/bin/bash

# Test Auth Login
echo "========================================="
echo "Testing Auth Login"
echo "========================================="

curl -X POST http://localhost:8000/auth/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User123456"
  }' | jq .

echo ""

