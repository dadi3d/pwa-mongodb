#!/bin/bash

echo "🔧 MongoDB Benutzer manuell erstellen..."

# Lade .env Variablen
source .env

# Warte bis MongoDB bereit ist
echo "⏳ Warte auf MongoDB (Port: $MONGO_PORT)..."
sleep 5

# Erstelle Admin-Benutzer
echo "👤 Erstelle Admin-Benutzer..."
docker exec medienausleihe-mongodb mongosh --port $MONGO_PORT --eval "
db.getSiblingDB('admin').createUser({
  user: '$MONGO_INITDB_ROOT_USERNAME',
  pwd: '$MONGO_INITDB_ROOT_PASSWORD', 
  roles: ['root']
});
"

echo "✅ Admin-Benutzer erfolgreich erstellt!"
echo "ℹ️  App-Benutzer werden über ADDITIONAL_USERS Environment Variable erstellt"
echo "🔑 Compass Connection Strings:"
echo "   Admin: mongodb://${MONGO_INITDB_ROOT_USERNAME}:***@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}?authSource=admin"
echo "   Apps werden über ADDITIONAL_USERS definiert"

