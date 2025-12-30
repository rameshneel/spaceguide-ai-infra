#!/bin/bash

# Configuration
PROJECT_ROOT="/opt/spaceguide-ai/spaceguide-ai-infra"
BACKUP_DIR="$PROJECT_ROOT/backups/mongodb"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="spaceguide_db_$TIMESTAMP.gz"
RETENTION_DAYS=7

# Load environment variables from .env
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' $PROJECT_ROOT/.env | xargs)
fi

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "Starting backup for database: $MONGO_DATABASE..."

# Run mongodump inside the container and stream it to a file on the host
docker exec spaceguide-ai-mongodb mongodump \
    --username="$MONGO_ROOT_USER" \
    --password="$MONGO_ROOT_PASSWORD" \
    --authenticationDatabase="admin" \
    --db="$MONGO_DATABASE" \
    --archive \
    --gzip > "$BACKUP_DIR/$BACKUP_NAME"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "✅ Backup successful: $BACKUP_DIR/$BACKUP_NAME"
else
    echo "❌ Backup failed!"
    exit 1
fi

# Remove backups older than RETENTION_DAYS
echo "Cleaning up old backups (older than $RETENTION_DAYS days)..."
find $BACKUP_DIR -type f -name "spaceguide_db_*.gz" -mtime +$RETENTION_DAYS -delete

echo "Done!"
