#!/bin/bash

# Create migration and sync to services

set -e

if [ -z "$1" ]; then
    echo "Usage: ./migrate-and-sync.sh <migration_name>"
    echo "Example: ./migrate-and-sync.sh add_user_preferences"
    exit 1
fi

MIGRATION_NAME=$1

echo "🚀 Creating migration: $MIGRATION_NAME"
echo ""

# Create migration
echo "📝 Creating migration..."
npm run migrate:dev -- --name "$MIGRATION_NAME"

echo ""
echo "✅ Migration created successfully!"
echo ""

# Sync schemas
echo "🔄 Syncing service schemas..."
./sync-schemas.sh

echo ""
echo "🎉 Done!"
echo ""
echo "Migration '$MIGRATION_NAME' has been created and service schemas are synced."

