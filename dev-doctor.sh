#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🏥 Development Environment Doctor${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

ISSUES_FOUND=0

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ Node.js $(node -v)${NC}"
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ npm $(npm -v)${NC}"
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ Docker installed${NC}"
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
fi

echo ""
echo -e "${BLUE}Checking environment files...${NC}"

if [ -f "auth/.env.local" ]; then
    echo -e "${GREEN}✅ auth/.env.local exists${NC}"
else
    echo -e "${RED}❌ auth/.env.local not found${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ -f "post/.env.local" ]; then
    echo -e "${GREEN}✅ post/.env.local exists${NC}"
else
    echo -e "${RED}❌ post/.env.local not found${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
echo -e "${BLUE}Checking dependencies...${NC}"

if [ -d "auth/node_modules" ]; then
    echo -e "${GREEN}✅ Auth dependencies installed${NC}"
else
    echo -e "${RED}❌ Auth dependencies not installed${NC}"
    echo -e "${YELLOW}   Run: cd auth && npm install${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ -d "post/node_modules" ]; then
    echo -e "${GREEN}✅ Post dependencies installed${NC}"
else
    echo -e "${RED}❌ Post dependencies not installed${NC}"
    echo -e "${YELLOW}   Run: cd post && npm install${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
echo -e "${BLUE}Checking Prisma setup...${NC}"

if [ -d "auth/node_modules/.prisma" ]; then
    echo -e "${GREEN}✅ Auth Prisma client generated${NC}"
else
    echo -e "${YELLOW}⚠️  Auth Prisma client not generated${NC}"
    echo -e "${YELLOW}   Run: cd auth && npx prisma generate${NC}"
fi

if [ -d "post/node_modules/.prisma" ]; then
    echo -e "${GREEN}✅ Post Prisma client generated${NC}"
else
    echo -e "${YELLOW}⚠️  Post Prisma client not generated${NC}"
    echo -e "${YELLOW}   Run: cd post && npx prisma generate${NC}"
fi

echo ""
echo -e "${BLUE}Checking Docker containers...${NC}"

if docker ps | grep -q "bw-postgres-dev"; then
    echo -e "${GREEN}✅ PostgreSQL container running${NC}"
    
    # Check if PostgreSQL is ready
    if docker-compose -f docker-compose.dev.yml exec -T postgres pg_isready > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL is ready${NC}"
    else
        echo -e "${YELLOW}⚠️  PostgreSQL is not ready${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  PostgreSQL container not running${NC}"
    echo -e "${YELLOW}   Run: ./dev-start.sh${NC}"
fi

if docker ps | grep -q "bw-redis-dev"; then
    echo -e "${GREEN}✅ Redis container running${NC}"
    
    # Check if Redis is ready
    if docker-compose -f docker-compose.dev.yml exec -T redis redis-cli ping > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Redis is ready${NC}"
    else
        echo -e "${YELLOW}⚠️  Redis is not ready${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  Redis container not running${NC}"
    echo -e "${YELLOW}   Run: ./dev-start.sh${NC}"
fi

if docker ps | grep -q "bw-kong-dev"; then
    echo -e "${GREEN}✅ Kong container running${NC}"
    
    # Check if Kong is ready
    if curl -s http://localhost:8001 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Kong is ready${NC}"
    else
        echo -e "${YELLOW}⚠️  Kong is not ready${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${YELLOW}⚠️  Kong container not running${NC}"
    echo -e "${YELLOW}   Run: ./dev-start.sh${NC}"
fi

echo ""
echo -e "${BLUE}Checking ports...${NC}"

check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Port $port is in use ($service)${NC}"
    else
        echo -e "${YELLOW}⚠️  Port $port is not in use ($service not running)${NC}"
    fi
}

check_port 3001 "Auth Service"
check_port 3002 "Post Service"
check_port 5435 "PostgreSQL"
check_port 6379 "Redis"
check_port 8000 "Kong Gateway"
check_port 8001 "Kong Admin"

echo ""
echo -e "${BLUE}Checking service health...${NC}"

if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Auth Service is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Auth Service is not responding${NC}"
    echo -e "${YELLOW}   Start with: cd auth && npm run start:dev${NC}"
fi

if curl -s http://localhost:3002/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Post Service is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Post Service is not responding${NC}"
    echo -e "${YELLOW}   Start with: cd post && npm run start:dev${NC}"
fi

echo ""
echo -e "${BLUE}Checking Kong routing...${NC}"

if curl -s http://localhost:8000/auth/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Auth Service accessible via Kong${NC}"
else
    echo -e "${YELLOW}⚠️  Auth Service not accessible via Kong${NC}"
fi

if curl -s http://localhost:8000/post/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Post Service accessible via Kong${NC}"
else
    echo -e "${YELLOW}⚠️  Post Service not accessible via Kong${NC}"
fi

echo ""
echo -e "${CYAN}=========================================${NC}"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No critical issues found!${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    echo -e "${GREEN}Your development environment is healthy! 🎉${NC}"
else
    echo -e "${YELLOW}⚠️  Found $ISSUES_FOUND issue(s)${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the issues above and run this script again.${NC}"
fi

echo ""
echo -e "${CYAN}Quick fixes:${NC}"
echo -e "  ${BLUE}./dev-setup.sh${NC}        - Run initial setup"
echo -e "  ${BLUE}./dev-start.sh${NC}        - Start infrastructure"
echo -e "  ${BLUE}./dev-run-services.sh${NC} - Start services"
echo -e "  ${BLUE}make status${NC}           - Check service status"
echo ""

