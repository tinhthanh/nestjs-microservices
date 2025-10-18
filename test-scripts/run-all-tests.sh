#!/bin/bash

# Run all tests for all services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Running All Tests"
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
AUTH_RESULT=0
POST_RESULT=0

# Test Auth Service
echo "========================================="
echo "Testing Auth Service"
echo "========================================="
cd "$ROOT_DIR/auth"
if npm run test 2>&1 | tee /tmp/auth-test.log; then
    echo -e "${GREEN}✓ Auth Service Tests PASSED${NC}"
    AUTH_RESULT=0
else
    echo -e "${RED}✗ Auth Service Tests FAILED${NC}"
    AUTH_RESULT=1
fi
echo ""

# Test Post Service
echo "========================================="
echo "Testing Post Service"
echo "========================================="
cd "$ROOT_DIR/post"
if npm run test 2>&1 | tee /tmp/post-test.log; then
    echo -e "${GREEN}✓ Post Service Tests PASSED${NC}"
    POST_RESULT=0
else
    echo -e "${RED}✗ Post Service Tests FAILED${NC}"
    POST_RESULT=1
fi
echo ""

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
if [ $AUTH_RESULT -eq 0 ]; then
    echo -e "Auth Service: ${GREEN}PASSED${NC}"
else
    echo -e "Auth Service: ${RED}FAILED${NC}"
fi

if [ $POST_RESULT -eq 0 ]; then
    echo -e "Post Service: ${GREEN}PASSED${NC}"
else
    echo -e "Post Service: ${RED}FAILED${NC}"
fi

echo ""

# Exit with error if any test failed
if [ $AUTH_RESULT -ne 0 ] || [ $POST_RESULT -ne 0 ]; then
    echo -e "${RED}========================================="
    echo "✗ SOME TESTS FAILED"
    echo "=========================================${NC}"
    echo ""
    echo "Please check the output above for details."
    exit 1
else
    echo -e "${GREEN}========================================="
    echo "✓ ALL TESTS PASSED"
    echo "=========================================${NC}"
    exit 0
fi

