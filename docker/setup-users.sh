#!/bin/bash

echo "🔧 MongoDB Benutzer manuell erstellen..."

# Port aus Environment verwenden
MONGO_PORT=${MONGO_PORT}

# Warte bis MongoDB bereit ist
echo "⏳ Warte auf MongoDB (Port: $MONGO_PORT)..."
sleep 5

# Erstelle Admin-Benutzer
echo "👤 Erstelle Admin-Benutzer..."
docker exec medienausleihe-mongodb mongosh --port $MONGO_PORT --eval "
db.getSiblingDB('admin').createUser({
  user: 'admin',
  pwd: 'medienausleihe2024', 
  roles: ['root']
});
"

echo "✅ Admin-Benutzer erfolgreich erstellt!"
echo "ℹ️  App-Benutzer werden über ADDITIONAL_USERS Environment Variable erstellt"
echo "🔑 Compass Connection Strings:"
echo "   Admin: mongodb://admin:medienausleihe2024@localhost:$MONGO_PORT/medienausleihe?authSource=admin"
echo "   App:   mongodb://medienapp:medienapp2024@localhost:$MONGO_PORT/medienausleihe (falls über ADDITIONAL_USERS erstellt)"

