#!/bin/bash

# Auto-detect environment and set ports
# Checks if services are running on dev ports (3001/3002) or prod mode via Kong (8000)

# Kong is always on 8000
export KONG_URL="http://localhost:8000"
export BASE_URL="http://localhost:8000"

# Default to unknown mode
export MODE="unknown"

# Check if prod mode (Kong gateway on 8000)
if curl -s http://localhost:8000/auth/health > /dev/null 2>&1; then
    export MODE="prod"
    export AUTH_PORT=8000
    export POST_PORT=8000
    export AUTH_URL="http://localhost:8000/auth"
    export POST_URL="http://localhost:8000/post"
fi

# Check if dev mode (local services on 3001/3002)
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    export MODE="dev"
    export AUTH_PORT=3001
    export AUTH_URL="http://localhost:3001"
fi

if curl -s http://localhost:3002/health > /dev/null 2>&1; then
    export MODE="dev"
    export POST_PORT=3002
    export POST_URL="http://localhost:3002"
fi

# If still unknown and not in SKIP_CHECK mode, show error
if [ "$MODE" = "unknown" ] && [ "$SKIP_SERVICE_CHECK" != "true" ]; then
    echo "❌ No services detected. Please start services first."
    echo ""
    echo "For dev mode: ./dev.sh"
    echo "For prod mode: ./prod.sh"
    exit 1
fi

# Display detected mode
if [ "$SHOW_MODE" = "true" ]; then
    echo "🔍 Detected mode: $MODE"
    echo "   Auth: $AUTH_URL"
    echo "   Post: $POST_URL"
    echo "   Kong: $KONG_URL"
    echo ""
fi

