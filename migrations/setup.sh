#!/bin/bash

# Setup centralized migrations

set -e

echo "🔧 Setting up centralized migrations..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Generate Prisma client
echo "🔨 Generating Prisma client..."
npm run generate

# Check migration status
echo "📊 Checking migration status..."
npm run migrate:status || true

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run migrations: npm run migrate:deploy"
echo "2. Sync service schemas: ./sync-schemas.sh"

