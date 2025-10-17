#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}🚀 Starting Local Services${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Check if infrastructure is running
if ! docker ps | grep -q "bw-postgres-dev"; then
    echo -e "${RED}❌ Infrastructure is not running${NC}"
    echo -e "${YELLOW}Please run: ./dev-start.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Infrastructure is running${NC}"
echo ""

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}⚠️  tmux is not installed. Services will run in background.${NC}"
    echo ""
    
    # Run services in background
    echo -e "${BLUE}Starting Auth service...${NC}"
    cd auth
    npm run start:dev > ../logs/auth.log 2>&1 &
    AUTH_PID=$!
    echo -e "${GREEN}✅ Auth service started (PID: $AUTH_PID)${NC}"
    cd ..
    
    echo -e "${BLUE}Starting Post service...${NC}"
    cd post
    npm run start:dev > ../logs/post.log 2>&1 &
    POST_PID=$!
    echo -e "${GREEN}✅ Post service started (PID: $POST_PID)${NC}"
    cd ..
    
    echo ""
    echo -e "${CYAN}Services are running in background${NC}"
    echo -e "  - Auth PID: ${BLUE}$AUTH_PID${NC}"
    echo -e "  - Post PID: ${BLUE}$POST_PID${NC}"
    echo ""
    echo -e "${CYAN}View logs:${NC}"
    echo -e "  - Auth: ${BLUE}tail -f logs/auth.log${NC}"
    echo -e "  - Post: ${BLUE}tail -f logs/post.log${NC}"
    echo ""
    echo -e "${CYAN}Stop services:${NC}"
    echo -e "  ${BLUE}kill $AUTH_PID $POST_PID${NC}"
    echo ""
else
    # Use tmux for better experience
    echo -e "${BLUE}Starting services in tmux session...${NC}"
    
    # Create new tmux session
    tmux new-session -d -s nestjs-dev
    
    # Split window
    tmux split-window -h -t nestjs-dev
    
    # Run Auth service in left pane
    tmux send-keys -t nestjs-dev:0.0 "cd auth && npm run start:dev" C-m
    
    # Run Post service in right pane
    tmux send-keys -t nestjs-dev:0.1 "cd post && npm run start:dev" C-m
    
    echo -e "${GREEN}✅ Services started in tmux session 'nestjs-dev'${NC}"
    echo ""
    echo -e "${CYAN}Attach to tmux session:${NC}"
    echo -e "  ${BLUE}tmux attach -t nestjs-dev${NC}"
    echo ""
    echo -e "${CYAN}Detach from tmux: ${BLUE}Ctrl+B then D${NC}"
    echo -e "${CYAN}Kill tmux session: ${BLUE}tmux kill-session -t nestjs-dev${NC}"
    echo ""
    
    # Wait a bit and attach
    sleep 2
    tmux attach -t nestjs-dev
fi

