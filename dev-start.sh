#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🚀 Starting Development Environment${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Check if .env.local files exist
if [ ! -f "auth/.env.local" ]; then
    echo -e "${RED}❌ auth/.env.local not found${NC}"
    exit 1
fi

if [ ! -f "post/.env.local" ]; then
    echo -e "${RED}❌ post/.env.local not found${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1: Starting infrastructure (PostgreSQL, Redis, Kong)...${NC}"
docker-compose -f docker-compose.dev.yml up -d

echo ""
echo -e "${BLUE}Step 2: Waiting for infrastructure to be ready...${NC}"
sleep 5

# Check PostgreSQL
echo -e "${YELLOW}Checking PostgreSQL...${NC}"
until docker-compose -f docker-compose.dev.yml exec -T postgres pg_isready > /dev/null 2>&1; do
    echo -e "${YELLOW}Waiting for PostgreSQL...${NC}"
    sleep 2
done
echo -e "${GREEN}✅ PostgreSQL is ready${NC}"

# Check Redis
echo -e "${YELLOW}Checking Redis...${NC}"
until docker-compose -f docker-compose.dev.yml exec -T redis redis-cli ping > /dev/null 2>&1; do
    echo -e "${YELLOW}Waiting for Redis...${NC}"
    sleep 2
done
echo -e "${GREEN}✅ Redis is ready${NC}"

# Check Kong
echo -e "${YELLOW}Checking Kong...${NC}"
until curl -s http://localhost:8001 > /dev/null 2>&1; do
    echo -e "${YELLOW}Waiting for Kong...${NC}"
    sleep 2
done
echo -e "${GREEN}✅ Kong is ready${NC}"

echo ""
echo -e "${BLUE}Step 3: Running database migrations...${NC}"

# Run Auth service migrations
echo -e "${YELLOW}Running Auth service migrations...${NC}"
cd auth
npm run prisma:migrate:deploy
npm run prisma:generate:local
cd ..
echo -e "${GREEN}✅ Auth migrations completed${NC}"

# Run Post service migrations
echo -e "${YELLOW}Running Post service migrations...${NC}"
cd post
npm run prisma:migrate:deploy
npm run prisma:generate:local
cd ..
echo -e "${GREEN}✅ Post migrations completed${NC}"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Infrastructure is ready!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Start Auth service: ${BLUE}cd auth && npm run start:dev${NC}"
echo -e "  2. Start Post service: ${BLUE}cd post && npm run start:dev${NC}"
echo ""
echo -e "${CYAN}Or use the helper script:${NC}"
echo -e "  ${BLUE}./dev-run-services.sh${NC}"
echo ""
echo -e "${CYAN}Infrastructure URLs:${NC}"
echo -e "  - PostgreSQL: ${BLUE}localhost:5435${NC}"
echo -e "  - Redis: ${BLUE}localhost:6379${NC}"
echo -e "  - Kong Gateway: ${BLUE}http://localhost:8000${NC}"
echo -e "  - Kong Admin: ${BLUE}http://localhost:8001${NC}"
echo ""
echo -e "${CYAN}Service URLs (when running):${NC}"
echo -e "  - Auth Service: ${BLUE}http://localhost:3001${NC}"
echo -e "  - Post Service: ${BLUE}http://localhost:3002${NC}"
echo -e "  - Auth via Kong: ${BLUE}http://localhost:8000/auth${NC}"
echo -e "  - Post via Kong: ${BLUE}http://localhost:8000/post${NC}"
echo ""

