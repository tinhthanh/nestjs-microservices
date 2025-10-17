#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🔧 Development Environment Setup${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo -e "${YELLOW}Please install Node.js 18+ from https://nodejs.org/${NC}"
    exit 1
fi
NODE_VERSION=$(node -v)
echo -e "${GREEN}✅ Node.js ${NODE_VERSION}${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed${NC}"
    exit 1
fi
NPM_VERSION=$(npm -v)
echo -e "${GREEN}✅ npm ${NPM_VERSION}${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo -e "${YELLOW}Please install Docker from https://www.docker.com/${NC}"
    exit 1
fi
DOCKER_VERSION=$(docker --version)
echo -e "${GREEN}✅ ${DOCKER_VERSION}${NC}"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo -e "${YELLOW}Please install Docker Compose${NC}"
    exit 1
fi
COMPOSE_VERSION=$(docker-compose --version)
echo -e "${GREEN}✅ ${COMPOSE_VERSION}${NC}"

# Check tmux (optional)
if command -v tmux &> /dev/null; then
    TMUX_VERSION=$(tmux -V)
    echo -e "${GREEN}✅ ${TMUX_VERSION}${NC}"
else
    echo -e "${YELLOW}⚠️  tmux is not installed (optional but recommended)${NC}"
    echo -e "${YELLOW}   Install with: brew install tmux${NC}"
fi

echo ""
echo -e "${BLUE}Step 1: Making scripts executable...${NC}"
chmod +x dev-start.sh
chmod +x dev-stop.sh
chmod +x dev-run-services.sh
chmod +x dev-logs.sh
chmod +x test-scripts/*.sh
echo -e "${GREEN}✅ Scripts are now executable${NC}"

echo ""
echo -e "${BLUE}Step 2: Installing Auth service dependencies...${NC}"
cd auth
if [ ! -d "node_modules" ]; then
    npm install
    echo -e "${GREEN}✅ Auth dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠️  node_modules already exists, skipping...${NC}"
    echo -e "${YELLOW}   Run 'cd auth && npm install' to update${NC}"
fi
cd ..

echo ""
echo -e "${BLUE}Step 3: Installing Post service dependencies...${NC}"
cd post
if [ ! -d "node_modules" ]; then
    npm install
    echo -e "${GREEN}✅ Post dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠️  node_modules already exists, skipping...${NC}"
    echo -e "${YELLOW}   Run 'cd post && npm install' to update${NC}"
fi
cd ..

echo ""
echo -e "${BLUE}Step 4: Checking environment files...${NC}"

# Check .env.local files
if [ -f "auth/.env.local" ]; then
    echo -e "${GREEN}✅ auth/.env.local exists${NC}"
else
    echo -e "${RED}❌ auth/.env.local not found${NC}"
    exit 1
fi

if [ -f "post/.env.local" ]; then
    echo -e "${GREEN}✅ post/.env.local exists${NC}"
else
    echo -e "${RED}❌ post/.env.local not found${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 5: Creating logs directory...${NC}"
mkdir -p logs
echo -e "${GREEN}✅ Logs directory created${NC}"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Start infrastructure: ${BLUE}./dev-start.sh${NC}"
echo -e "  2. Start services: ${BLUE}./dev-run-services.sh${NC}"
echo -e "  3. Run tests: ${BLUE}./test-scripts/verify-all.sh${NC}"
echo ""
echo -e "${CYAN}Or use Make commands:${NC}"
echo -e "  ${BLUE}make dev-start${NC}     - Start infrastructure"
echo -e "  ${BLUE}make dev-run${NC}       - Start services"
echo -e "  ${BLUE}make dev-stop${NC}      - Stop everything"
echo -e "  ${BLUE}make dev-logs${NC}      - View logs"
echo -e "  ${BLUE}make test${NC}          - Run all tests"
echo ""
echo -e "${CYAN}Documentation:${NC}"
echo -e "  ${BLUE}cat DEV_ENVIRONMENT.md${NC}"
echo ""

