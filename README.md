# PWA-MongoDB Setup

MongoDB Container für die Medienausleihe-Anwendung mit automatischer Nutzer-Erstellung.

## Features

- ✅ MongoDB 7.0 mit Custom Configuration
- ✅ Automatische Root- und App-User Erstellung
- ✅ Flexible zusätzliche Nutzer-Erstellung über Build-Argumente
- ✅ Custom Port-Konfiguration (Standard: 27018)
- ✅ Persistent Data Storage
- ✅ Development & Production Ready

## Quick Start

```bash
# Standard Setup (nur Standard-Nutzer)
cd docker
docker-compose up -d

# Mit zusätzlichen Nutzern
ADDITIONAL_USERS='[{"name":"testuser","password":"test123","role":"readWrite"}]' docker-compose up -d --build
```

## Konfiguration

### Standard-Nutzer

Werden automatisch erstellt:
- **Root-User**: `admin:medienausleihe2024` (Full Access)

### App-Nutzer & Zusätzliche Nutzer

Alle Anwendungsnutzer (inklusive App-User) werden über die `ADDITIONAL_USERS` Umgebungsvariable definiert.

**Standard-Konfiguration** (bereits in `.env` enthalten):
```json
[{"name":"medienapp","password":"medienapp2024","role":"readWrite"}]
```

**Zusätzliche Nutzer** können ebenfalls über `ADDITIONAL_USERS` hinzugefügt werden:

#### Format
```json
[
  {
    "name": "username",
    "password": "password", 
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
```bash
export ADDITIONAL_USERS='[{"name":"viewer","password":"view123","role":"read"}]'
```

**Mehrere Nutzer:**
```bash
export ADDITIONAL_USERS='[
  {"name":"viewer","password":"view123","role":"read"},
  {"name":"editor","password":"edit123","role":"readWrite"},
  {"name":"dbadmin","password":"admin123","role":"dbAdmin"}
]'
```

**In .env Datei:**
```env
ADDITIONAL_USERS=[{"name":"testuser","password":"test123","role":"readWrite"}]
```

## Environment Variables

### Basis-Konfiguration (.env)
```env
# MongoDB Port
MONGO_PORT=27018

# Root Credentials
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=medienausleihe2024

# Application Database
MONGO_DATABASE=medienausleihe

# App & Additional Users (JSON Array)
# Standard App-Benutzer ist bereits enthalten
ADDITIONAL_USERS=[{"name":"medienapp","password":"medienapp2024","role":"readWrite"}]
```

## Connection Strings

### Für Anwendungen
```javascript
// Standard App-User
mongodb://medienapp:medienapp2024@localhost:27018/medienausleihe

// Custom User (falls erstellt)
mongodb://username:password@localhost:27018/medienausleihe
```

### Für MongoDB Compass
```
# Admin User
mongodb://admin:medienausleihe2024@localhost:27018/medienausleihe?authSource=admin

# App User  
mongodb://medienapp:medienapp2024@localhost:27018/medienausleihe

# Custom User
mongodb://username:password@localhost:27018/medienausleihe
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
export ADDITIONAL_USERS='[{"name":"produser","password":"secure123","role":"readWrite"}]'
docker-compose -f docker-compose.yml up -d --build
```

### Mit Docker Build
```bash
# Direct Docker Build
docker build \
  --build-arg ADDITIONAL_USERS='[{"name":"builduser","password":"build123"}]' \
  -f docker/Dockerfile \
  -t medienausleihe-mongodb .

docker run -d \
  -p 27018:27018 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=medienausleihe2024 \
  -e ADDITIONAL_USERS='[{"name":"runuser","password":"run123"}]' \
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