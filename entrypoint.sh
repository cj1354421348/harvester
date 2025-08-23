#!/bin/sh

# Harvester Docker Entrypoint Script
# Handles configuration initialization and parameter mapping

set -e

# Clean up queue state files for robustness
QUEUE_STATE_DIR="data/queue_state"
if [ -d "$QUEUE_STATE_DIR" ]; then
    echo "Cleaning up old queue state files in $QUEUE_STATE_DIR..."
    rm -f "$QUEUE_STATE_DIR"/*
    echo "Old queue state files removed."
else
    echo "Queue state directory $QUEUE_STATE_DIR not found, skipping cleanup."
fi

# Create config if not exists and not running special commands
if [ ! -f "$CONFIG_FILE" ] && [ "$1" != "--validate" ] && [ "$1" != "--create-config" ]; then
    echo "Config file '$CONFIG_FILE' not found, creating default configuration..."
    python main.py --create-config --config "$CONFIG_FILE"
    echo "Default configuration created at '$CONFIG_FILE'"
fi

# Build command line arguments from environment variables
ARGS=""

# Add config file if specified
if [ -n "$CONFIG_FILE" ]; then
    ARGS="$ARGS --config $CONFIG_FILE"
fi

# Add log level if specified
if [ -n "$LOG_LEVEL" ]; then
    ARGS="$ARGS --log-level $LOG_LEVEL"
fi

# Add stats interval if specified
if [ -n "$STATS_INTERVAL" ]; then
    ARGS="$ARGS --stats-interval $STATS_INTERVAL"
fi

# If no arguments provided, run with environment-based arguments
if [ $# -eq 0 ]; then
    echo "Starting Harvester with arguments:$ARGS"
    exec python -u main.py $ARGS
else
    # Execute the provided command
    exec "$@"
fi
