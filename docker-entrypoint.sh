#!/bin/sh
set -e

# Configuration
APP_SCRIPT="/app/dist/index.js"
LOG_FILE="/var/log/actual-flow.log"
DATA_DIR="/data"

# Change to /data directory where config will be stored
cd "$DATA_DIR"

# Function to run the sync
run_sync() {
    echo "$(date): Running sync..." >> "$LOG_FILE"
    if node "$APP_SCRIPT" import >> "$LOG_FILE" 2>&1; then
        echo "$(date): Sync completed successfully" >> "$LOG_FILE"
    else
        echo "$(date): Sync failed with exit code $?" >> "$LOG_FILE"
        return 1
    fi
}

# Graceful shutdown handler
cleanup() {
    echo "$(date): Shutting down..." >> "$LOG_FILE"
    kill -TERM "$TAIL_PID" 2>/dev/null || true
    kill -TERM "$CROND_PID" 2>/dev/null || true
    exit 0
}

trap cleanup TERM INT

# Handle different commands
case "$1" in
    cron)
        # Use CRON_SCHEDULE environment variable, default to daily at 2 AM if not set
        CRON_SCHEDULE=${CRON_SCHEDULE:-"0 2 * * *"}
        echo "Starting actual-flow with cron (schedule: $CRON_SCHEDULE)..."
        
        # Create log file
        touch "$LOG_FILE"
        
        # Create cron job with the configured schedule
        echo "$CRON_SCHEDULE cd $DATA_DIR && node $APP_SCRIPT import >> $LOG_FILE 2>&1" > /etc/crontabs/root
        
        # Start crond in foreground
        echo "Cron job configured with schedule: $CRON_SCHEDULE"
        echo "To view logs: docker logs <container-name>"
        echo "To run manual sync: docker exec <container-name> /usr/local/bin/docker-entrypoint.sh sync"
        
        # Start crond in background and tail log file
        crond -f -l 2 &
        CROND_PID=$!
        
        tail -f "$LOG_FILE" &
        TAIL_PID=$!
        
        # Wait for processes
        wait
        ;;
        
    sync)
        echo "Running manual sync..."
        if run_sync; then
            echo "✓ Sync completed successfully"
            exit 0
        else
            echo "✗ Sync failed"
            exit 1
        fi
        ;;
        
    interactive|config)
        echo "Starting interactive configuration mode..."
        cd "$DATA_DIR"
        exec node "$APP_SCRIPT"
        ;;
        
    import)
        echo "Running direct import..."
        cd "$DATA_DIR"
        exec node "$APP_SCRIPT" import
        ;;
        
    *)
        # Pass through any other command
        cd "$DATA_DIR"
        exec "$@"
        ;;
esac
