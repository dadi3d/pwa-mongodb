// MongoDB Initialization Script for Medienausleihe Application
// This script will be executed when the container starts for the first time

print('🚀 Initialisiere Medienausleihe Datenbank...');

// Switch to the medienausleihe database
db = db.getSiblingDB('medienausleihe');

print('📦 Erstelle grundlegende Collections...');

// Erstelle grundlegende Collections
db.createCollection('users');
db.createCollection('orders');
db.createCollection('products');
db.createCollection('categories');
db.createCollection('settings');

print('✅ Collections erstellt');

// Note: User creation is now handled by the startup script on every container start
// This ensures users are checked and created/updated on each restart
print('ℹ️  Hinweis: Nutzer-Erstellung wird durch das Startup-Script bei jedem Container-Start verwaltet');

print('✅ Datenbank erfolgreich initialisiert!');

// MongoDB Status anzeigen
print('');
print('='.repeat(60));
print('📊 MongoDB Status:');
print('='.repeat(60));
print('- Version: ' + version());
print('- Aktuelle Datenbank: ' + db.getName());
print('- Datenbank-Statistiken:');
try {
  const stats = db.stats();
  print('  • Collections: ' + stats.collections);
  print('  • Dokumente: ' + stats.objects);
  print('  • Datengröße: ' + Math.round(stats.dataSize / 1024) + ' KB');
  print('  • Indexgröße: ' + Math.round(stats.indexSize / 1024) + ' KB');
} catch (err) {
  print('  ❌ Fehler beim Abrufen der Statistiken: ' + err.message);
}

print('='.repeat(60));
print('🎉 DATENBANK-INITIALISIERUNG ABGESCHLOSSEN');
print('� Nutzer werden beim Container-Start durch startup.sh verwaltet');
print('='.repeat(60));