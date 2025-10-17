#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}📋 Development Environment Logs${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Show menu
echo -e "${BLUE}Select logs to view:${NC}"
echo -e "  1. PostgreSQL"
echo -e "  2. Redis"
echo -e "  3. Kong"
echo -e "  4. All infrastructure"
echo -e "  5. Exit"
echo ""

read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        echo -e "${CYAN}Showing PostgreSQL logs (Ctrl+C to exit)...${NC}"
        docker-compose -f docker-compose.dev.yml logs -f postgres
        ;;
    2)
        echo -e "${CYAN}Showing Redis logs (Ctrl+C to exit)...${NC}"
        docker-compose -f docker-compose.dev.yml logs -f redis
        ;;
    3)
        echo -e "${CYAN}Showing Kong logs (Ctrl+C to exit)...${NC}"
        docker-compose -f docker-compose.dev.yml logs -f kong
        ;;
    4)
        echo -e "${CYAN}Showing all infrastructure logs (Ctrl+C to exit)...${NC}"
        docker-compose -f docker-compose.dev.yml logs -f
        ;;
    5)
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

