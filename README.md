# PWA-MongoDB Setup

> ⚠️ **SICHERHEITSHINWEIS**: Verwenden Sie NIEMALS die Beispiel-Passwörter aus dieser Dokumentation! Kopieren Sie `.env.example` zu `.env` und setzen Sie eigene sichere Passwörter. Siehe [SECURITY.md](SECURITY.md) für Sicherheitsrichtlinien.

MongoDB Container für die Medienausleihe-Anwendung mit automatischer Nutzer-Verwaltung.

## 🆕 Neue Features

- ✅ **Automatische Nutzer-Überprüfung bei jedem Start**
- ✅ **Nutzer werden bei jedem Container-Start geprüft und ergänzt**
- ✅ **Rollenaktualisierung für bestehende Nutzer**
- ✅ **Hilfsskript für Nutzer-Verwaltung**

## Features

- ✅ MongoDB 7.0 mit Custom Configuration
- ✅ Automatische Root- und App-User Erstellung
- ✅ **Kontinuierliche Nutzer-Synchronisation bei jedem Start**
- ✅ Flexible zusätzliche Nutzer-Erstellung über Umgebungsvariablen
- ✅ Custom Port-Konfiguration (Standard: 27018)
- ✅ Persistent Data Storage
- ✅ Development & Production Ready

## Quick Start

> ⚠️ **WICHTIG**: Vor dem ersten Start kopieren Sie `.env.example` zu `.env` und setzen Sie sichere Passwörter!

```bash
# 1. Sichere Konfiguration erstellen
cp docker/.env.example docker/.env
# BEARBEITEN Sie .env und setzen Sie sichere Passwörter!

# 2. Standard Setup starten
cd docker
docker-compose up -d

# Container neu starten (Nutzer werden automatisch überprüft)
docker-compose restart

# Logs anzeigen um Nutzer-Status zu sehen
docker-compose logs mongodb
```

## 👥 Nutzer-Verwaltung

### Automatische Nutzer-Synchronisation

Bei **jedem Container-Start** werden die konfigurierten Nutzer überprüft:
- ✅ Fehlende Nutzer werden automatisch erstellt
- ✅ Bestehende Nutzer werden erkannt und übersprungen  
- ✅ Rollen werden bei Bedarf aktualisiert
- ✅ Detaillierte Logs über alle Aktionen

### Standard-Nutzer

Werden automatisch erstellt:
- **Root-User**: `${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}` (Full Access)

### App-Nutzer & Zusätzliche Nutzer

Alle Anwendungsnutzer werden über die `ADDITIONAL_USERS` Umgebungsvariable in der `.env`-Datei definiert.

**Konfigurationsformat** (siehe `.env.example`):
```json
[
  {"name":"app_user","password":"SICHERES_PASSWORT","role":"readWrite"},
  {"name":"viewer","password":"SICHERES_PASSWORT","role":"read"}
]
```

#### Format
```json
[
  {
    "name": "username",
    "password": "SICHERES_PASSWORT", 
    "role": "readWrite"
  }
]
```

#### Verfügbare Rollen
- `read` - Nur Lesen
- `readWrite` - Lesen und Schreiben (Standard)
- `dbAdmin` - Datenbank-Administration
- `userAdmin` - Nutzer-Administration

#### Beispiele

**Einzelner Nutzer:**
```env
ADDITIONAL_USERS=[{"name":"viewer","password":"SICHERES_PASSWORT","role":"read"}]
```

**Mehrere Nutzer:**
```env
ADDITIONAL_USERS=[{"name":"viewer","password":"SICHERES_PASSWORT","role":"read"},{"name":"editor","password":"SICHERES_PASSWORT","role":"readWrite"},{"name":"dbadmin","password":"SICHERES_PASSWORT","role":"dbAdmin"}]
```

**Produktionsumgebung:**
```env
ADDITIONAL_USERS=[{"name":"medienausleihe_app","password":"SEHR_SICHERES_PASSWORT","role":"readWrite"}]
```

## 🔧 Nutzer-Verwaltungswerkzeuge

### Hilfsskript verwenden

```bash
# Alle verfügbaren Befehle anzeigen
./check-users.sh help

# Alle Nutzer in der Datenbank auflisten
./check-users.sh list

# Verbindung mit konfigurierten Nutzern testen
./check-users.sh test

# Aktuelle Konfiguration anzeigen
./check-users.sh env
```

### Manuelle Nutzer-Überprüfung

```bash
# Container-Logs anzeigen (zeigt Nutzer-Status beim Start)
docker-compose logs mongodb

# In laufenden Container einloggen  
docker-compose exec mongodb mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin

# Nutzer in Datenbank anzeigen
docker-compose exec mongodb mongosh -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} --authenticationDatabase admin --eval "db.getSiblingDB('${MONGO_DATABASE}').runCommand({usersInfo: 1})"
```

## Environment Variables

### Basis-Konfiguration (.env.example)
```env
# MongoDB Host & Port
MONGO_HOST=localhost
MONGO_PORT=27018

# Root Credentials - ÄNDERN SIE DIESE WERTE!
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=SICHERES_ROOT_PASSWORT

# Application Database
MONGO_DATABASE=medienausleihe

# App & Additional Users (JSON Array) - SICHERE PASSWÖRTER VERWENDEN!
ADDITIONAL_USERS=[{"name":"app_user","password":"SICHERES_PASSWORT","role":"readWrite"},{"name":"viewer","password":"SICHERES_PASSWORT","role":"read"}]
```

## Connection Strings

### Für Anwendungen
```javascript
// Beispiel App-User (aus .env ADDITIONAL_USERS)
mongodb://app_user:SICHERES_PASSWORT@localhost:27018/medienausleihe

// Viewer User (aus .env ADDITIONAL_USERS)
mongodb://viewer:SICHERES_PASSWORT@localhost:27018/medienausleihe
```

### Für MongoDB Compass
```
# Admin User (aus .env)
mongodb://admin:SICHERES_ROOT_PASSWORT@localhost:27018/medienausleihe?authSource=admin

# App User (aus .env ADDITIONAL_USERS)
mongodb://app_user:SICHERES_PASSWORT@localhost:27018/medienausleihe

# Viewer User (aus .env ADDITIONAL_USERS)
mongodb://viewer:SICHERES_PASSWORT@localhost:27018/medienausleihe
```

## Deployment

### Development
```bash
cd docker
docker-compose up -d
```

### Production
```bash
# Mit Custom Users
export ADDITIONAL_USERS='[{"name":"produser","password":"SICHERES_PASSWORT","role":"readWrite"}]'
docker-compose -f docker-compose.yml up -d --build
```

### Mit Docker Build
```bash
# Direct Docker Build
docker build \
  --build-arg ADDITIONAL_USERS='[{"name":"builduser","password":"SICHERES_PASSWORT"}]' \
  -f docker/Dockerfile \
  -t medienausleihe-mongodb .

docker run -d \
  -p 27018:27018 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=SICHERES_ROOT_PASSWORT \
  -e MONGO_INITDB_DATABASE=medienausleihe \
  -e ADDITIONAL_USERS='[{"name":"app_user","password":"SICHERES_PASSWORT","role":"readWrite"}]' \
  medienausleihe-mongodb
```

## Troubleshooting

### Container startet nicht
```bash
# Logs prüfen
docker-compose logs mongodb

# Container Status
docker ps -a | grep medienausleihe-mongodb
```

### Nutzer werden nicht erstellt
```bash
# Init-Script Logs prüfen
docker exec medienausleihe-mongodb cat /var/log/mongodb/mongod.log | grep -i "init"

# Umgebungsvariablen prüfen
docker exec medienausleihe-mongodb env | grep ADDITIONAL_USERS
```

### Verbindungsprobleme
```bash
# Port prüfen
netstat -an | grep 27018

# MongoDB Status
docker exec medienausleihe-mongodb mongosh --port 27018 --eval "db.adminCommand('ismaster')"
```

### Nutzer manuell erstellen
```bash
# Script ausführen
./docker/setup-users.sh
```

## Data Persistence

Daten werden in einem Docker Volume gespeichert:
```bash
# Volume Info
docker volume ls | grep mongodb
docker volume inspect pwa-mongodb_mongodb_data
```

## Security Notes

- Verwenden Sie starke Passwörter in Production
- Ändern Sie Standard-Credentials
- Beschränken Sie Nutzer-Rollen auf das Minimum
- Verwenden Sie TLS/SSL in Production
- Firewall-Regeln für Port 27018

## File Structure

```
pwa-mongodb/
├── docker/
│   ├── .env                 # Environment Variables
│   ├── docker-compose.yml   # Docker Compose Config
│   ├── Dockerfile          # MongoDB Container Build
│   ├── mongo.conf          # MongoDB Configuration
│   ├── setup-users.sh      # Manual User Creation
│   └── startup.sh          # Container Startup Script
├── init-scripts/
│   └── 01-init-db.js       # Database Initialization
├── mongodb.sh              # Quick Start Script
└── README.md              # Diese Datei
```