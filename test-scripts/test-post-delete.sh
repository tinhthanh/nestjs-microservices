#!/bin/bash

# Test Delete Posts (Batch)
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
echo "Step 2: Get Posts List to find post IDs"
echo "========================================="

POSTS_RESPONSE=$(curl -s -X GET "http://localhost:8000/post/v1/post?page=1&limit=5" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "$POSTS_RESPONSE" | jq .

# Extract post IDs (get first 2 posts)
POST_IDS=$(echo "$POSTS_RESPONSE" | jq -r '.data.items[0:2] | map(.id) | @json')

if [ "$POST_IDS" == "null" ] || [ "$POST_IDS" == "[]" ]; then
  echo "No posts found. Please create posts first using test-post-create.sh"
  exit 1
fi

echo ""
echo "========================================="
echo "Step 3: Batch Delete Posts"
echo "========================================="

curl -X DELETE "http://localhost:8000/post/v1/post/batch" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{
    \"ids\": $POST_IDS
  }" | jq .

echo ""

