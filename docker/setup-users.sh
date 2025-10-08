#!/bin/bash

echo "🔧 MongoDB Benutzer manuell erstellen..."

# Warte bis MongoDB bereit ist
echo "⏳ Warte auf MongoDB..."
sleep 5

# Erstelle Admin-Benutzer
echo "👤 Erstelle Admin-Benutzer..."
docker exec medienausleihe-mongodb mongosh --eval "
db.getSiblingDB('admin').createUser({
  user: 'admin',
  pwd: 'medienausleihe2024', 
  roles: ['root']
});
"

# Erstelle App-Benutzer
echo "📱 Erstelle App-Benutzer..."
docker exec medienausleihe-mongodb mongosh -u admin -p medienausleihe2024 --authenticationDatabase admin --eval "
db.getSiblingDB('medienausleihe').createUser({
  user: 'medienapp',
  pwd: 'medienapp2024',
  roles: [{role: 'readWrite', db: 'medienausleihe'}]
});
"

echo "✅ Benutzer erfolgreich erstellt!"
echo "🔑 Compass Connection Strings:"
echo "   Admin: mongodb://admin:medienausleihe2024@localhost:27017/medienausleihe?authSource=admin"
echo "   App:   mongodb://medienapp:medienapp2024@localhost:27017/medienausleihe"

