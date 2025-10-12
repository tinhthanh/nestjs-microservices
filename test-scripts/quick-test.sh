#!/bin/bash

# Quick test script to verify services are running
echo "========================================="
echo "Quick Service Health Check"
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" == "$expected_status" ] || [ "$response" == "200" ] || [ "$response" == "201" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC} (HTTP $response)"
        return 1
    fi
}

# Test services
echo "1. Testing Kong Gateway..."
test_endpoint "Kong Gateway" "http://localhost:8000/"

echo ""
echo "2. Testing Auth Service..."
test_endpoint "Auth Health (via Kong)" "http://localhost:8000/auth/health"
test_endpoint "Auth Health (direct)" "http://localhost:9001/health"

echo ""
echo "3. Testing Post Service..."
test_endpoint "Post Health (via Kong)" "http://localhost:8000/post/health"
test_endpoint "Post Health (direct)" "http://localhost:9002/health"

echo ""
echo "========================================="
echo "Quick API Test"
echo "========================================="
echo ""

# Test signup
echo "4. Testing Signup..."
SIGNUP_RESPONSE=$(curl -s -X POST http://localhost:8000/auth/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"test$(date +%s)@example.com\",
    \"password\": \"Test123456\",
    \"firstName\": \"Test\",
    \"lastName\": \"User\"
  }")

if echo "$SIGNUP_RESPONSE" | grep -q "accessToken"; then
    echo -e "${GREEN}✓ Signup successful${NC}"
    ACCESS_TOKEN=$(echo "$SIGNUP_RESPONSE" | jq -r '.data.accessToken')
    
    echo ""
    echo "5. Testing Create Post..."
    POST_RESPONSE=$(curl -s -X POST http://localhost:8000/post/v1/post \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -d '{
        "title": "Test Post",
        "content": "This is a test post content."
      }')
    
    if echo "$POST_RESPONSE" | grep -q "title"; then
        echo -e "${GREEN}✓ Create post successful${NC}"
    else
        echo -e "${RED}✗ Create post failed${NC}"
    fi
    
    echo ""
    echo "6. Testing Get Posts..."
    LIST_RESPONSE=$(curl -s -X GET "http://localhost:8000/post/v1/post?page=1&limit=5" \
      -H "Authorization: Bearer $ACCESS_TOKEN")
    
    if echo "$LIST_RESPONSE" | grep -q "items"; then
        echo -e "${GREEN}✓ Get posts successful${NC}"
    else
        echo -e "${RED}✗ Get posts failed${NC}"
    fi
else
    echo -e "${RED}✗ Signup failed${NC}"
    echo "Response: $SIGNUP_RESPONSE"
fi

echo ""
echo "========================================="
echo "Quick Test Complete!"
echo "========================================="
echo ""
echo "For detailed testing, run:"
echo "  ./test-all.sh          - Run all API tests"
echo "  ./run-all-tests.sh     - Run all unit tests"
echo ""

