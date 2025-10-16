// MongoDB Initialization Script for Medienausleihe Application
// This script will be executed when the container starts for the first time

print('🚀 Initialisiere Medienausleihe Datenbank...');

// Switch to the medienausleihe database
db = db.getSiblingDB('medienausleihe');

// Create additional users from build arguments
const additionalUsersEnv = process.env.ADDITIONAL_USERS || '[]';
print('📝 ADDITIONAL_USERS environment variable: ' + additionalUsersEnv);

let createdUsers = [];

try {
  const additionalUsers = JSON.parse(additionalUsersEnv);
  
  if (Array.isArray(additionalUsers) && additionalUsers.length > 0) {
    print('👥 Erstelle zusätzliche Nutzer...');
    
    additionalUsers.forEach((user, index) => {
      if (user.name && user.password) {
        try {
          db.createUser({
            user: user.name,
            pwd: user.password,
            roles: [
              {
                role: user.role || 'readWrite',
                db: 'medienausleihe'
              }
            ]
          });
          createdUsers.push({
            name: user.name,
            role: user.role || 'readWrite'
          });
          print('✅ Nutzer erstellt: ' + user.name + ' (Rolle: ' + (user.role || 'readWrite') + ')');
        } catch (err) {
          print('❌ Fehler beim Erstellen von Nutzer ' + user.name + ': ' + err.message);
        }
      } else {
        print('⚠️  Nutzer #' + (index + 1) + ' übersprungen - fehlende name oder password Eigenschaften');
      }
    });
  } else {
    print('ℹ️  Keine zusätzlichen Nutzer definiert');
  }
} catch (err) {
  print('❌ Fehler beim Parsen der ADDITIONAL_USERS: ' + err.message);
  print('💡 Format: [{"name":"username","password":"password","role":"readWrite"}]');
}

// Erstelle grundlegende Collections
db.createCollection('users');
db.createCollection('orders');
db.createCollection('products');
db.createCollection('categories');
db.createCollection('settings');

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

// Alle Nutzer anzeigen
print('');
print('='.repeat(60));
print('👥 Alle erstellten Nutzer:');
print('='.repeat(60));
try {
  const users = db.runCommand({usersInfo: 1}).users;
  if (users && users.length > 0) {
    users.forEach((user, index) => {
      print('📋 Nutzer #' + (index + 1) + ':');
      print('  • Name: ' + user.user);
      print('  • Datenbank: ' + user.db);
      print('  • Rollen: ' + JSON.stringify(user.roles));
      
      // Passwort aus createdUsers Array anzeigen (falls verfügbar)
      const matchingUser = createdUsers.find(u => u.name === user.user);
      if (matchingUser) {
        print('  • Status: Während dieser Sitzung erstellt');
      } else {
        print('  • Status: Bereits vorhanden oder anderweitig erstellt');
      }
      print('');
    });
  } else {
    print('ℹ️  Keine Nutzer in der aktuellen Datenbank gefunden');
  }
  
  // Zusätzlich die erstellten Nutzer mit Passwörtern anzeigen
  if (createdUsers.length > 0) {
    print('='.repeat(60));
    print('🔐 Nutzer mit Passwörtern (nur in dieser Sitzung erstellt):');
    print('='.repeat(60));
    const additionalUsers = JSON.parse(process.env.ADDITIONAL_USERS || '[]');
    additionalUsers.forEach((user, index) => {
      if (user.name && user.password) {
        print('👤 Nutzer #' + (index + 1) + ':');
        print('  • Name: ' + user.name);
        print('  • Passwort: ' + user.password);
        print('  • Rolle: ' + (user.role || 'readWrite'));
        print('');
      }
    });
  }
} catch (err) {
  print('❌ Fehler beim Abrufen der Nutzerinformationen: ' + err.message);
}

print('='.repeat(60));
print('🎉 INITIALISIERUNG ABGESCHLOSSEN');
print('='.repeat(60));