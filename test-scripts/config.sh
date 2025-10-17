#!/bin/bash

# Auto-detect environment and set ports
# Checks if services are running on dev ports (3001/3002) or prod ports (9001/9002)

# Check if dev mode (local services on 3001/3002)
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    export MODE="dev"
    export AUTH_PORT=3001
    export POST_PORT=3002
    export AUTH_URL="http://localhost:3001"
    export POST_URL="http://localhost:3002"
# Check if prod mode (docker services on 9001/9002)
elif curl -s http://localhost:9001/health > /dev/null 2>&1; then
    export MODE="prod"
    export AUTH_PORT=9001
    export POST_PORT=9002
    export AUTH_URL="http://localhost:9001"
    export POST_URL="http://localhost:9002"
else
    echo "❌ No services detected. Please start services first."
    echo ""
    echo "For dev mode: ./dev-start.sh && cd auth && npm run start:dev"
    echo "For prod mode: docker-compose up -d"
    exit 1
fi

# Kong is always on 8000
export KONG_URL="http://localhost:8000"

# Display detected mode
if [ "$SHOW_MODE" = "true" ]; then
    echo "🔍 Detected mode: $MODE"
    echo "   Auth: $AUTH_URL"
    echo "   Post: $POST_URL"
    echo "   Kong: $KONG_URL"
    echo ""
fi

