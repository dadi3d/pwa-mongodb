#!/bin/bash

# MongoDB Management Script for Medienausleihe
# Usage: ./mongodb.sh [start|stop|restart|logs|status|backup|restore]

set -e

PROJECT_NAME="medienausleihe"
CONTAINER_NAME="medienausleihe-mongodb"

function show_help() {
    echo "MongoDB Management Script für Medienausleihe"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     - Start MongoDB containers"
    echo "  stop      - Stop MongoDB containers"
    echo "  restart   - Restart MongoDB containers"
    echo "  logs      - Show MongoDB logs"
    echo "  status    - Show container status"
    echo "  backup    - Create database backup"
    echo "  restore   - Restore database from backup"
    echo "  shell     - Connect to MongoDB shell"
    echo "  help      - Show this help message"
}

function check_env() {
    if [ ! -f .env ]; then
        echo "Error: .env file not found!"
        echo "Please copy .env.template to .env and configure it."
        exit 1
    fi
}

function start_mongodb() {
    echo "Starting MongoDB container..."
    check_env
    docker-compose up -d
    echo "MongoDB container started successfully!"
    echo "MongoDB: localhost:27017"
}

function stop_mongodb() {
    echo "Stopping MongoDB container..."
    docker-compose down
    echo "MongoDB container stopped successfully!"
}

function restart_mongodb() {
    echo "Restarting MongoDB container..."
    docker-compose restart
    echo "MongoDB container restarted successfully!"
}

function show_logs() {
    echo "Showing MongoDB logs..."
    docker-compose logs -f mongodb
}

function show_status() {
    echo "Container Status:"
    docker-compose ps
    echo ""
    echo "MongoDB Connection Test:"
    if docker exec $CONTAINER_NAME mongosh --eval "print('MongoDB is running')" >/dev/null 2>&1; then
        echo "✅ MongoDB is running and accessible"
    else
        echo "❌ MongoDB is not accessible"
    fi
}

function create_backup() {
    echo "Creating database backup..."
    BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
    
    docker exec $CONTAINER_NAME mongodump --db medienausleihe --out /tmp/backup
    docker cp $CONTAINER_NAME:/tmp/backup ./\"$BACKUP_DIR\"
    docker exec $CONTAINER_NAME rm -rf /tmp/backup
    
    echo "Backup created successfully in: $BACKUP_DIR"
}

function restore_backup() {
    if [ -z "$2" ]; then
        echo "Usage: $0 restore [backup-directory]"
        echo "Available backups:"
        ls -la | grep "backup-"
        exit 1
    fi
    
    BACKUP_DIR="$2"
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Error: Backup directory '$BACKUP_DIR' not found!"
        exit 1
    fi
    
    echo "Restoring database from: $BACKUP_DIR"
    docker cp "$BACKUP_DIR" $CONTAINER_NAME:/tmp/restore
    docker exec $CONTAINER_NAME mongorestore --db medienausleihe --drop /tmp/restore/medienausleihe
    docker exec $CONTAINER_NAME rm -rf /tmp/restore
    
    echo "Database restored successfully!"
}

function connect_shell() {
    echo "Connecting to MongoDB shell..."
    echo "Use: db.help() for help"
    echo "Note: Using medienapp credentials (must be created via ADDITIONAL_USERS)"
    docker exec -it $CONTAINER_NAME mongosh mongodb://medienapp:medienapp2024@localhost:27018/medienausleihe
}

# Main script logic
case "${1:-help}" in
    start)
        start_mongodb
        ;;
    stop)
        stop_mongodb
        ;;
    restart)
        restart_mongodb
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    backup)
        create_backup
        ;;
    restore)
        restore_backup "$@"
        ;;
    shell)
        connect_shell
        ;;
    help|*)
        show_help
        ;;
esac