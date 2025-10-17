#!/bin/bash

# Load config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Test Health Check for all services
echo "========================================="
echo "Testing Health Check Endpoints ($MODE mode)"
echo "========================================="

echo ""
echo "1. Kong Gateway Health:"
echo "-----------------------------------"
curl -s $KONG_URL/ | jq . || echo "Kong Gateway is not responding"

echo ""
echo "2. Auth Service Health (Direct):"
echo "-----------------------------------"
curl -s $AUTH_URL/health | jq . || echo "Auth Service is not responding"

echo ""
echo "3. Post Service Health (Direct):"
echo "-----------------------------------"
curl -s $POST_URL/health | jq . || echo "Post Service is not responding"

echo ""
echo "4. Kong Gateway - Auth Route:"
echo "-----------------------------------"
curl -s $KONG_URL/auth/health | jq . || echo "Kong Auth route is not responding"

echo ""
echo "5. Kong Gateway - Post Route:"
echo "-----------------------------------"
curl -s $KONG_URL/post/health | jq . || echo "Kong Post route is not responding"

echo ""

