#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🔄 Switching to Production Mode${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

echo -e "${YELLOW}This will:${NC}"
echo -e "  1. Stop development infrastructure"
echo -e "  2. Stop local services (if running)"
echo -e "  3. Start full production Docker stack"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Stopping development infrastructure...${NC}"
docker-compose -f docker-compose.dev.yml down
echo -e "${GREEN}✅ Development infrastructure stopped${NC}"

echo ""
echo -e "${YELLOW}Note: Please stop local services manually (Ctrl+C in their terminals)${NC}"
echo -e "${YELLOW}Or kill tmux session: tmux kill-session -t nestjs-dev${NC}"
sleep 2

echo ""
echo -e "${BLUE}Step 2: Starting production Docker stack...${NC}"
docker-compose up -d

echo ""
echo -e "${BLUE}Step 3: Waiting for services to be ready...${NC}"
sleep 10

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Switched to Production Mode!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Service URLs:${NC}"
echo -e "  - Auth: ${BLUE}http://localhost:9001${NC}"
echo -e "  - Post: ${BLUE}http://localhost:9002${NC}"
echo -e "  - Kong: ${BLUE}http://localhost:8000${NC}"
echo ""
echo -e "${CYAN}Check status:${NC}"
echo -e "  ${BLUE}docker-compose ps${NC}"
echo -e "  ${BLUE}docker-compose logs -f${NC}"
echo ""

