#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🛑 Stopping Development Environment${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

echo -e "${BLUE}Stopping infrastructure containers...${NC}"
docker-compose -f docker-compose.dev.yml down

echo ""
echo -e "${GREEN}✅ Development environment stopped${NC}"
echo ""
echo -e "${YELLOW}Note: Your local services (auth, post) need to be stopped manually${NC}"
echo -e "${YELLOW}Press Ctrl+C in their terminal windows${NC}"
echo ""

