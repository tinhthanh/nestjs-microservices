#!/bin/bash

# Test Health Check for all services
echo "========================================="
echo "Testing Health Check Endpoints"
echo "========================================="

echo ""
echo "1. Kong Gateway Health:"
echo "-----------------------------------"
curl -s http://localhost:8000/ | jq . || echo "Kong Gateway is not responding"

echo ""
echo "2. Auth Service Health:"
echo "-----------------------------------"
curl -s http://localhost:9001/health | jq . || echo "Auth Service is not responding"

echo ""
echo "3. Post Service Health:"
echo "-----------------------------------"
curl -s http://localhost:9002/health | jq . || echo "Post Service is not responding"

echo ""
echo "4. Kong Gateway - Auth Route:"
echo "-----------------------------------"
curl -s http://localhost:8000/auth/health | jq . || echo "Kong Auth route is not responding"

echo ""
echo "5. Kong Gateway - Post Route:"
echo "-----------------------------------"
curl -s http://localhost:8000/post/health | jq . || echo "Kong Post route is not responding"

echo ""

