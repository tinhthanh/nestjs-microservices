#!/bin/bash

# Test Update Post
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
echo "Step 2: Get Posts List to find a post ID"
echo "========================================="

POSTS_RESPONSE=$(curl -s -X GET "http://localhost:8000/post/v1/post?page=1&limit=1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "$POSTS_RESPONSE" | jq .

POST_ID=$(echo "$POSTS_RESPONSE" | jq -r '.data.items[0].id')

if [ "$POST_ID" == "null" ] || [ -z "$POST_ID" ]; then
  echo "No posts found. Please create a post first using test-post-create.sh"
  exit 1
fi

echo ""
echo "========================================="
echo "Step 3: Update Post with ID: $POST_ID"
echo "========================================="

curl -X PUT "http://localhost:8000/post/v1/post/$POST_ID" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "title": "Updated Post Title",
    "content": "This is the updated content of the post."
  }' | jq .

echo ""

