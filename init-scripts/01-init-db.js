// MongoDB Initialization Script for Medienausleihe Application
// This script will be executed when the container starts for the first time

print('🚀 Initialisiere Medienausleihe Datenbank...');

// Switch to the medienausleihe database
db = db.getSiblingDB('medienausleihe');

// Create application user with read/write permissions
db.createUser({
  user: 'medienapp',
  pwd: 'medienapp2024',
  roles: [
    {
      role: 'readWrite',
      db: 'medienausleihe'
    }
  ]
});

// Erstelle grundlegende Collections
db.createCollection('users');
db.createCollection('orders');
db.createCollection('products');
db.createCollection('categories');
db.createCollection('settings');

print('✅ Database initialization completed successfully!');
print('📋 Created database: medienausleihe');
print('👤 Created DB user: medienapp');
print('🔑 Verfügbare Zugangsdaten:');
print('   MongoDB: admin:medienausleihe2024 (Root-Zugriff)');
print('   MongoDB: medienapp:medienapp2024 (App-Zugriff)');
print('ℹ️  Admin-Benutzer wird automatisch bei erster Anmeldung erstellt:');
print('   App Login: admin@admin.de:admin123 (Admin-Rolle)');
print('🎯 Database is ready for application use');