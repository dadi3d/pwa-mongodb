#!/bin/bash

# Hilfsskript zum Überprüfen und Verwalten von MongoDB-Nutzern
# Nutzung: ./check-users.sh [list|create|delete]

# Lade Environment-Variablen aus docker/.env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/docker/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "❌ .env Datei nicht gefunden: $ENV_FILE"
    exit 1
fi

MONGO_URI="mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@localhost:${MONGO_PORT}/admin"

function show_help() {
    echo "🔧 MongoDB Nutzer-Verwaltung"
    echo "=============================="
    echo "Nutzung: $0 [COMMAND]"
    echo ""
    echo "COMMANDS:"
    echo "  list     - Alle Nutzer in der Datenbank anzeigen"
    echo "  test     - Verbindung mit konfigurierten Nutzern testen"
    echo "  env      - Aktuelle ADDITIONAL_USERS Konfiguration anzeigen"
    echo "  help     - Diese Hilfe anzeigen"
    echo ""
    echo "Beispiele:"
    echo "  $0 list              # Alle Nutzer anzeigen"
    echo "  $0 test              # Nutzer-Verbindungen testen"
    echo "  $0 env               # Konfiguration anzeigen"
    echo ""
}

function list_users() {
    echo "👥 MongoDB Nutzer auflisten..."
    echo "=============================="
    
    mongosh "$MONGO_URI" --quiet --eval "
        print('📋 Nutzer in Admin-Datenbank:');
        print('============================');
        db.runCommand({usersInfo: 1}).users.forEach((user, index) => {
            print('Nutzer #' + (index + 1) + ':');
            print('  • Name: ' + user.user);
            print('  • Rollen: ' + JSON.stringify(user.roles));
            print('');
        });
        
        print('📋 Nutzer in Medienausleihe-Datenbank:');
        print('====================================');
        db = db.getSiblingDB('${MONGO_DATABASE}');
        const appUsers = db.runCommand({usersInfo: 1}).users;
        if (appUsers && appUsers.length > 0) {
            appUsers.forEach((user, index) => {
                print('Nutzer #' + (index + 1) + ':');
                print('  • Name: ' + user.user);
                print('  • Rollen: ' + JSON.stringify(user.roles));
                print('');
            });
        } else {
            print('ℹ️  Keine Nutzer in der Medienausleihe-Datenbank gefunden');
        }
    "
}

function test_users() {
    echo "🧪 Nutzer-Verbindungen testen..."
    echo "==============================="
    
    # Lese ADDITIONAL_USERS direkt aus der .env Datei mit korrekten Anführungszeichen
    ADDITIONAL_USERS_RAW=$(grep "^ADDITIONAL_USERS=" docker/.env | cut -d'=' -f2-)
    
    if [ -z "$ADDITIONAL_USERS_RAW" ] || [ "$ADDITIONAL_USERS_RAW" = "[]" ]; then
        echo "⚠️  Keine ADDITIONAL_USERS konfiguriert"
        return 1
    fi
    
    echo "Konfigurierte Nutzer aus ADDITIONAL_USERS:"
    echo "$ADDITIONAL_USERS_RAW" | jq -r '.[] | "- \(.name) (Rolle: \(.role // "readWrite"))"' 2>/dev/null || echo "❌ Fehler beim Parsen der JSON-Konfiguration"
    
    # Parse users and test connections
    echo "$ADDITIONAL_USERS_RAW" | jq -r '.[] | @base64' 2>/dev/null | while read -r user_b64; do
        if [ -n "$user_b64" ]; then
            user_json=$(echo "$user_b64" | base64 -d 2>/dev/null)
            username=$(echo "$user_json" | jq -r '.name' 2>/dev/null)
            password=$(echo "$user_json" | jq -r '.password' 2>/dev/null)
            
            if [ -n "$username" ] && [ "$username" != "null" ] && [ -n "$password" ] && [ "$password" != "null" ]; then
                echo "🔍 Teste Verbindung für Nutzer: $username"
                
                test_uri="mongodb://${username}:${password}@localhost:${MONGO_PORT}/${MONGO_DATABASE}"
                if mongosh "$test_uri" --quiet --eval "db.runCommand({ping: 1})" >/dev/null 2>&1; then
                    echo "✅ Verbindung erfolgreich für: $username"
                else
                    echo "❌ Verbindung fehlgeschlagen für: $username"
                fi
            fi
        fi
    done
}

function show_env() {
    echo "⚙️  Aktuelle Konfiguration"
    echo "========================="
    echo "MONGO_HOST: $MONGO_HOST"
    echo "MONGO_PORT: $MONGO_PORT"
    echo "MONGO_DATABASE: $MONGO_DATABASE"
    echo "MONGO_INITDB_ROOT_USERNAME: $MONGO_INITDB_ROOT_USERNAME"
    echo ""
    echo "ADDITIONAL_USERS:"
    # Lese ADDITIONAL_USERS direkt aus der .env Datei mit korrekten Anführungszeichen
    ADDITIONAL_USERS_RAW=$(grep "^ADDITIONAL_USERS=" docker/.env | cut -d'=' -f2-)
    if [ -z "$ADDITIONAL_USERS_RAW" ] || [ "$ADDITIONAL_USERS_RAW" = "[]" ]; then
        echo "  ℹ️  Keine zusätzlichen Nutzer konfiguriert"
    else
        echo "$ADDITIONAL_USERS_RAW" | jq '.' 2>/dev/null || echo "  ❌ Ungültiges JSON-Format"
    fi
}

# Check if MongoDB is running
if ! nc -z localhost "$MONGO_PORT" 2>/dev/null; then
    echo "❌ MongoDB ist nicht erreichbar auf localhost:$MONGO_PORT"
    echo "💡 Starten Sie zunächst den MongoDB-Container:"
    echo "   cd docker && docker-compose up -d"
    exit 1
fi

# Parse command
case "${1:-help}" in
    "list")
        list_users
        ;;
    "test")
        test_users
        ;;
    "env")
        show_env
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo "❌ Unbekannter Befehl: $1"
        echo ""
        show_help
        exit 1
        ;;
esac