#!/bin/bash

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}=========================================${NC}"
}

print_step() {
    echo ""
    echo -e "${MAGENTA}--- $1 ---${NC}"
}

# Function to check service health
check_service() {
    local service_name=$1
    local url=$2
    
    if curl -s "$url" > /dev/null 2>&1; then
        print_success "$service_name is healthy"
        return 0
    else
        print_error "$service_name is not responding"
        return 1
    fi
}

# Function to login and get access token
get_access_token() {
    local email=${1:-"user@example.com"}
    local password=${2:-"User123456"}
    
    # SỬA LẠI ĐƯỜNG DẪN Ở ĐÂY: Bỏ /v1/auth
    local response=$(curl -s -X POST $KONG_URL/auth/login \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$email\",
            \"password\": \"$password\"
        }")
    
    local token=$(echo "$response" | jq -r '.data.accessToken')
    
    if [ "$token" == "null" ] || [ -z "$token" ]; then
        return 1
    fi
    
    echo "$token"
    return 0
}

# Function to run a test and track results
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${BLUE}Running ${test_name}...${NC}"
    
    if eval "$test_command" > /dev/null 2>&1; then
        print_success "${test_name} passed"
        return 0
    else
        print_error "${test_name} failed"
        return 1
    fi
}

