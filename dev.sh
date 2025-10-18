#!/bin/bash

# Development Environment Setup
# Starts infrastructure in Docker + local services

set -e

echo "========================================="
echo "🚀 Starting Development Environment"
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

if ! command_exists node; then
    echo -e "${RED}✗ Node.js is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"
echo ""

# Start infrastructure (PostgreSQL, Redis, Kong)
echo "🐳 Starting infrastructure (PostgreSQL, Redis, Kong)..."
docker-compose -f docker-compose.dev.yml up -d

# Wait for services to be ready
echo ""
echo "⏳ Waiting for infrastructure to be ready..."
sleep 5

# Check PostgreSQL
echo -n "Checking PostgreSQL... "
if docker exec bw-postgres-dev pg_isready -U admin > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Check Redis
echo -n "Checking Redis... "
if docker exec bw-redis-dev redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Check Kong
echo -n "Checking Kong... "
if curl -s http://localhost:8001/status > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

echo ""
echo "✅ Infrastructure is ready!"
echo ""

# Install dependencies if needed
echo "📦 Installing dependencies..."

if [ ! -d "auth/node_modules" ]; then
    echo "Installing auth service dependencies..."
    cd auth && npm install && cd ..
fi

if [ ! -d "post/node_modules" ]; then
    echo "Installing post service dependencies..."
    cd post && npm install && cd ..
fi

if [ ! -d "migrations/node_modules" ]; then
    echo "Installing migrations dependencies..."
    cd migrations && npm install && cd ..
fi

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Run migrations
echo "🔄 Running database migrations..."
cd migrations
npm run migrate:dev
cd ..
echo -e "${GREEN}✓ Migrations completed${NC}"
echo ""

# Sync schemas
echo "🔄 Syncing schemas to services..."
cd migrations
npm run sync
cd ..
echo -e "${GREEN}✓ Schemas synced${NC}"
echo ""

# Start services in background
echo "🚀 Starting services..."
echo ""

# Start Auth Service
echo "Starting Auth Service on port 3001..."
cd auth
npm run start:dev > ../logs/auth.log 2>&1 &
AUTH_PID=$!
cd ..
echo -e "${GREEN}✓ Auth Service started (PID: $AUTH_PID)${NC}"

# Wait a bit for auth service to start
sleep 3

# Start Post Service
echo "Starting Post Service on port 3002..."
cd post
npm run start:dev > ../logs/post.log 2>&1 &
POST_PID=$!
cd ..
echo -e "${GREEN}✓ Post Service started (PID: $POST_PID)${NC}"

# Save PIDs
echo "$AUTH_PID" > .dev-auth.pid
echo "$POST_PID" > .dev-post.pid

echo ""
echo "========================================="
echo "✅ Development Environment Ready!"
echo "========================================="
echo ""
echo "📍 Services:"
echo "  - Auth Service:  http://localhost:3001"
echo "  - Post Service:  http://localhost:3002"
echo "  - Kong Gateway:  http://localhost:8000"
echo "  - Kong Admin:    http://localhost:8001"
echo "  - PostgreSQL:    localhost:5435"
echo "  - Redis:         localhost:6379"
echo ""
echo "📖 API Documentation:"
echo "  - Auth Swagger:  http://localhost:3001/docs"
echo "  - Post Swagger:  http://localhost:3002/docs"
echo ""
echo "📝 Logs:"
echo "  - Auth: tail -f logs/auth.log"
echo "  - Post: tail -f logs/post.log"
echo ""
echo "🛑 To stop: ./dev-stop.sh"
echo ""

