#!/bin/bash

# Production Environment Setup
# Runs everything in Docker, only expose port 8000

set -e

echo "========================================="
echo "🚀 Starting Production Environment"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command_exists docker; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    exit 1
fi

if ! command_exists docker-compose; then
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"
echo ""

# Build and start all services
echo "🐳 Building and starting all services..."
docker-compose -f docker-compose.yml up -d --build

# Wait for services to be ready
echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check PostgreSQL
echo -n "Checking PostgreSQL... "
if docker exec bw-postgres pg_isready -U admin > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Check Redis
echo -n "Checking Redis... "
if docker exec bw-redis redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Check Kong
echo -n "Checking Kong... "
if curl -s http://localhost:8000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Check Auth Service
echo -n "Checking Auth Service... "
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}✗ Timeout${NC}"
    echo "Check logs: docker-compose -f docker-compose.yml logs auth"
    exit 1
fi

# Check Post Service
echo -n "Checking Post Service... "
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ Warning: Post service may not be ready${NC}"
fi

echo ""
echo "========================================="
echo "✅ Production Environment Ready!"
echo "========================================="
echo ""
echo "📍 Access Point:"
echo "  - API Gateway:   http://localhost:8000"
echo ""
echo "🔒 Internal Services (not exposed):"
echo "  - Auth Service:  http://auth:3001 (internal)"
echo "  - Post Service:  http://post:3002 (internal)"
echo "  - PostgreSQL:    postgres:5432 (internal)"
echo "  - Redis:         redis:6379 (internal)"
echo ""
echo "📝 View Logs:"
echo "  - All:  docker-compose -f docker-compose.yml logs -f"
echo "  - Auth: docker-compose -f docker-compose.yml logs -f auth"
echo "  - Post: docker-compose -f docker-compose.yml logs -f post"
echo "  - Kong: docker-compose -f docker-compose.yml logs -f kong"
echo ""
echo "🛑 To stop: docker-compose -f docker-compose.yml down"
echo ""

