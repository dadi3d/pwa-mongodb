// Additional Users Creation Script
print('🚀 Starte Additional Users Setup...');

const additionalUsersEnv = process.env.ADDITIONAL_USERS || '[]';
print('📝 ADDITIONAL_USERS: ' + additionalUsersEnv);

try {
    const additionalUsers = JSON.parse(additionalUsersEnv);
    
    if (Array.isArray(additionalUsers) && additionalUsers.length > 0) {
        // Switch to the application database
        db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE);
        
        additionalUsers.forEach((user, index) => {
            if (user.name && user.password) {
                try {
                    // Check if user already exists
                    const existingUsers = db.runCommand({usersInfo: 1});
                    const userExists = existingUsers.users && existingUsers.users.some(u => u.user === user.name);
                    
                    if (userExists) {
                        print('ℹ️  Nutzer "' + user.name + '" existiert bereits');
                    } else {
                        // Create new user
                        db.createUser({
                            user: user.name,
                            pwd: user.password,
                            roles: [
                                {
                                    role: user.role || 'readWrite',
                                    db: process.env.MONGO_INITDB_DATABASE
                                }
                            ]
                        });
                        print('✅ Neuer Nutzer erstellt: ' + user.name + ' (Rolle: ' + (user.role || 'readWrite') + ')');
                    }
                } catch (err) {
                    print('❌ Fehler bei Nutzer ' + user.name + ': ' + err.message);
                }
            } else {
                print('⚠️  Nutzer #' + (index + 1) + ' übersprungen - fehlende name oder password Eigenschaften');
            }
        });
    } else {
        print('ℹ️  Keine zusätzlichen Nutzer in ADDITIONAL_USERS definiert');
    }
} catch (err) {
    print('❌ Fehler beim Parsen der ADDITIONAL_USERS: ' + err.message);
    print('💡 Erwartetes Format: [{"name":"username","password":"password","role":"readWrite"}]');
}

print('🎉 Additional Users Setup abgeschlossen');
