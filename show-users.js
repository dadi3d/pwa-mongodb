// Script zum Anzeigen aller Nutzer und MongoDB Status
// Ausführung: mongosh --host localhost:27018 -u admin -p medienausleihe2024 --authenticationDatabase admin show-users.js

print('='.repeat(60));
print('📊 MongoDB Status:');
print('='.repeat(60));

// Verbindung zur medienausleihe Datenbank
db = db.getSiblingDB('medienausleihe');

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

print('');
print('='.repeat(60));
print('👥 Alle Nutzer in der Datenbank:');
print('='.repeat(60));

try {
  const users = db.runCommand({usersInfo: 1}).users;
  if (users && users.length > 0) {
    users.forEach((user, index) => {
      print('📋 Nutzer #' + (index + 1) + ':');
      print('  • Name: ' + user.user);
      print('  • Datenbank: ' + user.db);
      print('  • Rollen: ' + JSON.stringify(user.roles));
      print('  • Erstellt: ' + (user.userSource ? user.userSource : 'Standard'));
      print('');
    });
  } else {
    print('ℹ️  Keine Nutzer in der aktuellen Datenbank gefunden');
  }
} catch (err) {
  print('❌ Fehler beim Abrufen der Nutzerinformationen: ' + err.message);
}

// Alle Datenbanken anzeigen
print('='.repeat(60));
print('🗄️  Alle Datenbanken:');
print('='.repeat(60));

try {
  const dbs = db.adminCommand('listDatabases');
  dbs.databases.forEach((database, index) => {
    print('📂 Datenbank #' + (index + 1) + ':');
    print('  • Name: ' + database.name);
    print('  • Größe: ' + Math.round(database.sizeOnDisk / 1024) + ' KB');
    print('');
  });
} catch (err) {
  print('❌ Fehler beim Abrufen der Datenbanken: ' + err.message);
}

print('='.repeat(60));
print('✅ Status-Abfrage abgeschlossen');
print('='.repeat(60));