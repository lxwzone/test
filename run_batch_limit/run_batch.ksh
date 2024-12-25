#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_TO_RUN="$SCRIPT_DIR/run_batch_core.ksh"
LOG_FILE_BASE="/opt/batch/logs"

# List of commands to monitor
COMMANDS_TO_MONITOR=("run_batch_core.ksh")

# Maximum number of allowed concurrent executions
MAX_CONCURRENT=30dashboard

# Lock file location
LOCK_FILE="/opt/batch/tmp/run_batch_execution.lock"

# Function to count running instances of the monitored commands
count_running_instances() {
    local total_count=0
    for cmd in "${COMMANDS_TO_MONITOR[@]}"; do
        count=$(ps -ef | grep "$cmd" | grep -v grep | wc -l)
        total_count=$((total_count + count))
    done
    echo "$total_count"
}

# Acquire lock
acquire_lock() {
    exec 200>"$LOCK_FILE"
    flock -n 200 || { echo "Another instance is managing the lock. Waiting..."; flock 200; }
}

# Release lock
release_lock() {
    flock -u 200
    rm -f "$LOCK_FILE"
}

# Main logic
acquire_lock
while true; do
    running=$(count_running_instances)
    if [ "$running" -lt "$MAX_CONCURRENT" ]; then
        break
    fi
    echo "Too many concurrent executions ($running). Waiting..."
    sleep 1
done

# Run the underlying script as a separate process and capture its PID
LOG_FILE="$LOG_FILE_BASE/run_batch_$(date +'%Y%m%d_%H%M%S_%N').log"
nohup "$SCRIPT_TO_RUN" "$@"  > "$LOG_FILE" 2>&1 &
UNDERLYING_PID=$!

# Use trap to capture termination signals (e.g., SIGINT, SIGTERM) and kill the background process
trap "kill $UNDERLYING_PID; exit" SIGINT SIGTERM

sleep 0.5
release_lock


# Wait for the underlying script to complete
wait "$UNDERLYING_PID"
cat $LOG_FILE

echo "Underlying script completed with PID: $UNDERLYING_PID"

rm -rf $LOG_FILE
