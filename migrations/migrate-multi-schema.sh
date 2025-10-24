#!/bin/bash

# Migration script for multi-schema PostgreSQL setup
# This script initializes schemas and runs migrations

set -e

echo "🔧 Multi-Schema Migration Script"
echo "=================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}❌ ERROR: DATABASE_URL environment variable is not set${NC}"
    exit 1
fi

echo -e "${YELLOW}📊 Database URL: ${DATABASE_URL}${NC}"

# Step 1: Initialize PostgreSQL Schemas
echo ""
echo "Step 1: Initializing PostgreSQL Schemas..."
echo "-------------------------------------------"

# Extract connection details from DATABASE_URL
# Format: postgresql://user:password@host:port/database
DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\(.*\):.*/\1/p')
DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DATABASE_URL | sed -n 's/.*\/\(.*\)$/\1/p')
DB_USER=$(echo $DATABASE_URL | sed -n 's/.*:\/\/\(.*\):.*/\1/p')
DB_PASS=$(echo $DATABASE_URL | sed -n 's/.*:\/\/.*:\(.*\)@.*/\1/p')

# Use psql to create schemas
export PGPASSWORD=$DB_PASS
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f init-schemas.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Schemas initialized successfully${NC}"
else
    echo -e "${RED}❌ Failed to initialize schemas${NC}"
    exit 1
fi

# Step 2: Generate Prisma Client
echo ""
echo "Step 2: Generating Prisma Client..."
echo "------------------------------------"
npx prisma generate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Prisma Client generated${NC}"
else
    echo -e "${RED}❌ Failed to generate Prisma Client${NC}"
    exit 1
fi

# Step 3: Run Migrations
echo ""
echo "Step 3: Running Database Migrations..."
echo "---------------------------------------"
npx prisma migrate deploy

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Migrations applied successfully${NC}"
else
    echo -e "${RED}❌ Failed to apply migrations${NC}"
    exit 1
fi

# Step 4: Sync schemas to services
echo ""
echo "Step 4: Syncing schemas to services..."
echo "---------------------------------------"
./sync-schemas.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Schemas synced to services${NC}"
else
    echo -e "${RED}❌ Failed to sync schemas${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Multi-Schema Migration Completed Successfully!${NC}"
echo ""
echo "Database Structure:"
echo "  📦 auth_schema (Auth Service)"
echo "     ├── users"
echo "     └── third_party_integrations"
echo "  📦 post_schema (Post Service)"
echo "     └── posts"
echo ""

