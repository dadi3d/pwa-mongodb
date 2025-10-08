#!/bin/bash

echo "🚀 Starting PWA-MongoDB Container..."
echo "📅 Date: $(date)"
echo "🐳 Container: medienausleihe-mongodb"
echo ""
echo "🔧 Environment Variables:"
echo "MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME:-not set}"
echo "MONGO_INITDB_ROOT_PASSWORD: $(if [ -n "$MONGO_INITDB_ROOT_PASSWORD" ]; then echo "***SET***"; else echo "not set"; fi)"
echo "MONGO_INITDB_DATABASE: ${MONGO_INITDB_DATABASE:-not set}"
echo "MONGO_PORT: 27017 (container)"
echo ""
echo "🗄️ MongoDB Configuration:"
echo "Version: $(mongod --version 2>/dev/null | head -1 || echo 'MongoDB 7.0')"
echo "Authentication: Enabled"
echo "Init Scripts: $(ls /docker-entrypoint-initdb.d/ 2>/dev/null | wc -l) files"
echo ""
echo "🌐 Access URLs:"
echo "- Internal: mongodb://mongodb:27017"
echo "- External: mongodb://localhost:27017"
echo "- Compass: mongodb://${MONGO_INITDB_ROOT_USERNAME}:***@localhost:27017/admin"
echo ""
echo "📋 Status: Initializing MongoDB..."
echo "=========================================="

# Call the original MongoDB entrypoint
exec docker-entrypoint.sh "$@"

