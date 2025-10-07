# PWA-MongoDB Docker Setup

## 🗄️ Database Container - MongoDB 7.0

Diese Anleitung beschreibt, wie die MongoDB-Datenbank für die Medienausleihe-Anwendung mit Docker gestartet wird.

## 🚀 Schnellstart

```bash
cd pwa-mongodb/docker
docker-compose up --build
```

Die Datenbank ist dann unter `localhost:27017` erreichbar.

## ⚙️ Konfiguration

### Environment-Variablen (.env)

Die wichtigsten Einstellungen befinden sich in der `.env` Datei:

```bash
# MongoDB Configuration
MONGO_PORT=27017
MONGO_DATABASE=medienausleihe

# MongoDB Authentication (WICHTIG: Für Produktion ändern!)
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=medienausleihe2024

# Application Database User
MONGO_APP_USERNAME=medienapp
MONGO_APP_PASSWORD=medienapp2024
```

### Passwörter für Produktion ändern

**WICHTIG**: Die Standard-Passwörter sollten für Produktionsumgebungen geändert werden:

```bash
# Sichere Passwörter generieren
openssl rand -base64 32

# Oder online Generator verwenden
# https://passwordsgenerator.net/
```

## 🔧 Docker Commands

### Container starten
```bash
docker-compose up
```

### Container im Hintergrund starten
```bash
docker-compose up -d
```

### Container neu builden (löscht alle Daten!)
```bash
docker-compose down -v
docker-compose up --build
```

### Container stoppen
```bash
docker-compose down
```

### Container stoppen und Daten löschen
```bash
docker-compose down -v
```

### Logs anzeigen
```bash
docker-compose logs -f
```

## 🌐 Ports

- **MongoDB**: 27017

## 📦 Volumes

- `mongodb_data:/data/db` - Persistente Datenspeicherung
- `./mongo.conf:/etc/mongod.conf.orig` - MongoDB Konfiguration
- `./init-scripts:/docker-entrypoint-initdb.d` - Initialisierungs-Skripte

## 🔐 Benutzer und Berechtigungen

### Automatisch erstellte Benutzer

1. **Root Administrator**
   - Benutzername: `admin` (aus MONGO_ROOT_USERNAME)
   - Passwort: `medienausleihe2024` (aus MONGO_ROOT_PASSWORD)
   - Rolle: `root`
   - Datenbank: `admin`

2. **Anwendungsbenutzer**
   - Benutzername: `medienapp` (aus MONGO_APP_USERNAME)
   - Passwort: `medienapp2024` (aus MONGO_APP_PASSWORD)
   - Rolle: `readWrite`
   - Datenbank: `medienausleihe`

### Verbindungsstrings

```bash
# Root-Zugriff (für Administration)
mongodb://admin:medienausleihe2024@localhost:27017/admin

# Anwendungs-Zugriff (für pwa-server)
mongodb://medienapp:medienapp2024@localhost:27017/medienausleihe

# Für externe Tools (MongoDB Compass)
mongodb://admin:medienausleihe2024@localhost:27017/medienausleihe?authSource=admin
```

## 🛠️ Externe Tools

### MongoDB Compass

1. **Installation**: Lade [MongoDB Compass](https://www.mongodb.com/products/compass) herunter
2. **Verbindung**: Verwende folgenden Connection String:
   ```
   mongodb://admin:medienausleihe2024@localhost:27017/medienausleihe?authSource=admin
   ```
3. **Klicke "Connect"**

### MongoDB Shell (mongosh)

```bash
# Container betreten
docker exec -it medienausleihe-mongodb mongosh

# Oder direkt verbinden
mongosh "mongodb://admin:medienausleihe2024@localhost:27017/medienausleihe?authSource=admin"
```

### Studio 3T / Robo 3T

Verwende die gleichen Verbindungsparameter wie bei MongoDB Compass.

## 📋 Datenbank-Schema

### Automatisch erstellte Collections

- `users` - Benutzerkonten und Authentifizierung
- `products` - Medienprodukte (Kameras, Mikrofone, etc.)
- `orders` - Ausleihvorgänge und Reservierungen
- `manufacturers` - Herstellerinformationen
- `sets` - Produktsets und Bundles
- `settings` - Anwendungseinstellungen

## 🔄 Backup & Restore

### Backup erstellen

```bash
# Über den Container
docker exec medienausleihe-mongodb mongodump --uri="mongodb://admin:medienausleihe2024@localhost:27017/medienausleihe?authSource=admin" --out=/tmp/backup

# Backup aus Container kopieren
docker cp medienausleihe-mongodb:/tmp/backup ./backup-$(date +%Y%m%d)
```

### Backup wiederherstellen

```bash
# Backup in Container kopieren
docker cp ./backup-folder medienausleihe-mongodb:/tmp/restore

# Restore durchführen
docker exec medienausleihe-mongodb mongorestore --uri="mongodb://admin:medienausleihe2024@localhost:27017/medienausleihe?authSource=admin" --drop /tmp/restore
```

### Über Web-Interface

Die Anwendung bietet auch ein Web-Interface für Backup und Restore unter:
`http://localhost:8080/einstellungen`

## 🐛 Troubleshooting

### Problem: "Authentication failed"
- Überprüfe Benutzername und Passwort in der .env Datei
- Stelle sicher, dass die Container mit den aktuellen .env Werten gestartet wurden
- Bei Passwort-Änderungen: Container stoppen, Volumes löschen, neu starten

### Problem: "Connection refused"
- Prüfe ob der Container läuft: `docker ps`
- Überprüfe die Port-Bindung (27017)
- Stelle sicher, dass keine andere MongoDB-Instanz läuft

### Problem: "Database not found"
- Die Datenbank wird automatisch beim ersten Zugriff erstellt
- Überprüfe den Datenbanknamen in der Connection-URL

### Problem: "Volume permission errors"
- Linux/macOS: Prüfe Docker-Berechtigungen
- Windows: Stelle sicher, dass das Laufwerk für Docker freigegeben ist

### Problem: "Init scripts not running"
- Lösche alle Volumes: `docker-compose down -v`
- Starte neu: `docker-compose up`
- Init-Scripts laufen nur bei leerem MongoDB-Datenverzeichnis

## 📁 Dateistruktur

```
pwa-mongodb/docker/
├── docker-compose.yml      # Docker Service Definition
├── .env                   # Environment Variablen
├── mongo.conf            # MongoDB Konfiguration
├── README.md             # Diese Anleitung
└── init-scripts/         # Initialisierungs-Skripte
    └── 01-init-db.js     # Benutzer- und Collection-Setup
```

## 🔒 Sicherheit

### Produktionsumgebung

- Ändere alle Standard-Passwörter
- Aktiviere TLS/SSL-Verschlüsselung
- Konfiguriere Firewall-Regeln
- Regelmäßige Sicherheitsupdates
- Monitoring und Logging aktivieren

### Netzwerk-Sicherheit

```bash
# Nur für localhost zugänglich (Standard)
ports:
  - "127.0.0.1:27017:27017"

# Für alle Interfaces (VORSICHT in Produktion!)
ports:
  - "27017:27017"
```

## 📊 Monitoring

### Logs überwachen

```bash
# Container-Logs
docker-compose logs -f

# MongoDB-spezifische Logs
docker exec medienausleihe-mongodb tail -f /var/log/mongodb/mongod.log
```

### Ressourcen-Verbrauch

```bash
# Container-Statistiken
docker stats medienausleihe-mongodb

# Datenbank-Größe
docker exec medienausleihe-mongodb mongosh --eval "db.stats()" medienausleihe
``` Setup

Dieser Ordner enthält die Docker-Konfiguration für MongoDB.

## Starten

```bash
cd docker
docker-compose up --build
```

## Stoppen

```bash
docker-compose down
```

## Konfiguration

- `docker-compose.yml`: Docker Compose Konfiguration
- `mongo.conf`: MongoDB Konfigurationsdatei
- Port: 27017 (konfigurierbar über MONGO_PORT in .env)

## Hinweise

- **Keine persistenten Daten**: Container startet immer mit leerer Datenbank
- Init-Scripts können über Volume gemountet werden (siehe Kommentar in docker-compose.yml)
- MongoDB läuft mit Authentifizierung (siehe mongo.conf)