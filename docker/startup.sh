#!/bin/bash

echo "🚀 Starting PWA-MongoDB Container..."
echo "📅 Date: $(date)"
echo "🐳 Container: medienausleihe-mongodb"
echo ""
echo "🔧 Environment Variables:"
echo "MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME}"
echo "MONGO_INITDB_ROOT_PASSWORD: $(if [ -n "$MONGO_INITDB_ROOT_PASSWORD" ]; then echo "***SET***"; else echo "not set"; fi)"
echo "MONGO_INITDB_DATABASE: ${MONGO_INITDB_DATABASE}"
echo "MONGO_PORT: ${MONGO_PORT}"
echo "ADDITIONAL_USERS: $(if [ -n "$ADDITIONAL_USERS" ]; then echo "***CONFIGURED***"; else echo "not set"; fi)"
echo ""
echo "🗄️ MongoDB Configuration:"
echo "Version: $(mongod --version 2>/dev/null | head -1 || echo 'MongoDB 7.0')"
echo "Authentication: Enabled"
echo "Init Scripts: $(ls /docker-entrypoint-initdb.d/ 2>/dev/null | wc -l) files"
echo ""

# Parse additional users for display
if [ -n "$ADDITIONAL_USERS" ] && [ "$ADDITIONAL_USERS" != "[]" ]; then
    echo "👥 Additional Users Configuration:"
    echo "$ADDITIONAL_USERS" | jq -r '.[] | "   - \(.name) (Role: \(.role // "readWrite"))"' 2>/dev/null || echo "   - Custom users configured (JSON parse error)"
    echo ""
fi

echo "🌐 Access URLs:"
echo "- Internal: mongodb://mongodb:${MONGO_PORT}"
echo "- External: mongodb://localhost:${MONGO_PORT}"
echo "- Compass: mongodb://${MONGO_INITDB_ROOT_USERNAME}:***@localhost:${MONGO_PORT}/admin"
echo ""
echo "📋 Status: Initializing MongoDB..."
echo "=========================================="

# Call the original MongoDB entrypoint
exec docker-entrypoint.sh "$@"

