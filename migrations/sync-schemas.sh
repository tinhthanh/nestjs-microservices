#!/bin/bash

# Sync service schemas from centralized schema

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔄 Syncing service schemas from centralized schema..."
echo ""

# Function to extract models for a service
extract_models() {
    local service=$1
    local schema_file=$2
    local output_file=$3
    
    echo "📝 Extracting models for $service..."
    
    # Start with header
    cat > "$output_file" << 'EOF'
// This file is auto-generated from centralized schema
// DO NOT EDIT MANUALLY - Use migrations/prisma/schema.prisma instead

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

EOF
    
    # Extract models based on service
    if [ "$service" = "auth" ]; then
        # Extract User, Role, ThirdPartyIntegration
        awk '/^\/\/ AUTH SERVICE MODELS/,/^\/\/ POST SERVICE MODELS/ {
            if (!/^\/\/ POST SERVICE MODELS/) print
        }' "$schema_file" >> "$output_file"
    elif [ "$service" = "post" ]; then
        # Extract Post model
        awk '/^\/\/ POST SERVICE MODELS/,0' "$schema_file" >> "$output_file"
    fi
    
    echo "✅ $service schema updated"
}

# Sync auth service schema
AUTH_SCHEMA="$ROOT_DIR/auth/prisma/schema.prisma"
if [ -f "$AUTH_SCHEMA" ]; then
    extract_models "auth" "$SCRIPT_DIR/prisma/schema.prisma" "$AUTH_SCHEMA"
    
    # Regenerate Prisma client for auth
    echo "🔨 Regenerating Prisma client for auth service..."
    cd "$ROOT_DIR/auth"
    npm run prisma:generate:local
    cd "$SCRIPT_DIR"
else
    echo "⚠️  Auth schema not found: $AUTH_SCHEMA"
fi

echo ""

# Sync post service schema
POST_SCHEMA="$ROOT_DIR/post/prisma/schema.prisma"
if [ -f "$POST_SCHEMA" ]; then
    extract_models "post" "$SCRIPT_DIR/prisma/schema.prisma" "$POST_SCHEMA"
    
    # Regenerate Prisma client for post
    echo "🔨 Regenerating Prisma client for post service..."
    cd "$ROOT_DIR/post"
    npm run prisma:generate:local
    cd "$SCRIPT_DIR"
else
    echo "⚠️  Post schema not found: $POST_SCHEMA"
fi

echo ""
echo "✅ All schemas synced successfully!"
echo ""
echo "Services can now use their updated Prisma clients."

