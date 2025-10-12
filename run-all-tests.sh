#!/bin/bash

# Script to run all unit tests for both services
echo "========================================="
echo "Running All Unit Tests"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
OVERALL_STATUS=0

# Function to print section header
print_header() {
    echo ""
    echo "========================================="
    echo "$1"
    echo "========================================="
    echo ""
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2 PASSED${NC}"
    else
        echo -e "${RED}✗ $2 FAILED${NC}"
        OVERALL_STATUS=1
    fi
}

# 1. Check if dependencies are installed
print_header "Step 1: Checking Dependencies"

# Check Auth Service
if [ ! -d "auth/node_modules" ]; then
    echo -e "${YELLOW}Installing Auth Service dependencies...${NC}"
    cd auth && npm install --legacy-peer-deps
    cd ..
else
    echo -e "${GREEN}✓ Auth Service dependencies already installed${NC}"
fi

# Check Post Service
if [ ! -d "post/node_modules" ]; then
    echo -e "${YELLOW}Installing Post Service dependencies...${NC}"
    cd post && npm install --legacy-peer-deps
    cd ..
else
    echo -e "${GREEN}✓ Post Service dependencies already installed${NC}"
fi

# 2. Run Auth Service Tests
print_header "Step 2: Running Auth Service Tests"
cd auth
npm test
AUTH_STATUS=$?
cd ..
print_status $AUTH_STATUS "Auth Service Tests"

# 3. Run Post Service Tests
print_header "Step 3: Running Post Service Tests"
cd post
npm test
POST_STATUS=$?
cd ..
print_status $POST_STATUS "Post Service Tests"

# 4. Summary
print_header "Test Summary"

echo "Auth Service Tests: $([ $AUTH_STATUS -eq 0 ] && echo -e "${GREEN}PASSED${NC}" || echo -e "${RED}FAILED${NC}")"
echo "Post Service Tests: $([ $POST_STATUS -eq 0 ] && echo -e "${GREEN}PASSED${NC}" || echo -e "${RED}FAILED${NC}")"

echo ""
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}========================================="
    echo "✓ ALL TESTS PASSED"
    echo "=========================================${NC}"
else
    echo -e "${RED}========================================="
    echo "✗ SOME TESTS FAILED"
    echo "=========================================${NC}"
    echo ""
    echo "Please check the output above for details."
fi

exit $OVERALL_STATUS

