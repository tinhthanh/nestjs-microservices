#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🔄 Switching to Development Mode${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

echo -e "${YELLOW}This will:${NC}"
echo -e "  1. Stop production Docker stack (all services)"
echo -e "  2. Start development infrastructure (PostgreSQL, Redis, Kong only)"
echo -e "  3. You'll need to start Auth & Post services manually"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Stopping production Docker stack...${NC}"
docker-compose down
echo -e "${GREEN}✅ Production stack stopped${NC}"

echo ""
echo -e "${BLUE}Step 2: Starting development infrastructure...${NC}"
./dev-start.sh

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Switched to Development Mode!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Start services: ${BLUE}./dev-run-services.sh${NC}"
echo -e "  2. Or manually:"
echo -e "     Terminal 1: ${BLUE}cd auth && npm run start:dev${NC}"
echo -e "     Terminal 2: ${BLUE}cd post && npm run start:dev${NC}"
echo ""

