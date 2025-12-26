#!/bin/bash

# Task 1.5: CRON script for periodic large file detection and cleanup

# Configuration
LARGE_FILE_THRESHOLD="50M"  # Files larger than 50MB trigger cleanup
CLEAN_FILE_THRESHOLD="50M"  # Files smaller than 50MB are committed
REPO_PATH="."
LOG_FILE="cron_cleanup.log"
LARGE_FILES_DIR="large_files_to_clean"
SMALL_FILES_DIR="test_files"

# Initialize logging
LOG_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$LOG_TIMESTAMP] $1" >> "$LOG_FILE"
}

# Function to find and report large files
detect_large_files() {
    echo "[$LOG_TIMESTAMP] Detecting files larger than $LARGE_FILE_THRESHOLD..." >> "$LOG_FILE"
    
    LARGE_FILES=$(find "$REPO_PATH" -type f -size +${LARGE_FILE_THRESHOLD} ! -path "./.git/*" 2>/dev/null)
    
    if [ -z "$LARGE_FILES" ]; then
        log_message "No large files detected."
        return 0
    else
        log_message "Found large files:"
        echo "$LARGE_FILES" | while read file; do
            SIZE=$(du -h "$file" | awk '{print $1}')
            log_message "  - $file ($SIZE)"
        done
        return 1
    fi
}

# Function to clean up large files
cleanup_large_files() {
    log_message "Cleaning up large files..."
    
    # Create a backup directory
    mkdir -p "$LARGE_FILES_DIR"
    
    find "$REPO_PATH" -type f -size +${LARGE_FILE_THRESHOLD} ! -path "./.git/*" 2>/dev/null | while read file; do
        log_message "Moving large file: $file"
        mv "$file" "$LARGE_FILES_DIR/" 2>&1 >> "$LOG_FILE" || log_message "Failed to move $file"
    done
    
    log_message "Large file cleanup completed."
}

# Function to commit small files
commit_small_files() {
    log_message "Committing files smaller than $CLEAN_FILE_THRESHOLD..."
    
    if [ -z "$(git -C $REPO_PATH status --short)" ]; then
        log_message "No changes to commit."
        return
    fi
    
    # Stage small files
    find "$REPO_PATH" -type f -size -${CLEAN_FILE_THRESHOLD} ! -path "./.git/*" 2>/dev/null | while read file; do
        git -C "$REPO_PATH" add "$file" 2>&1 >> "$LOG_FILE"
    done
    
    # Commit if there are staged changes
    if [ -n "$(git -C $REPO_PATH diff --cached --name-only)" ]; then
        COMMIT_MSG="[CRON] Auto-commit small files at $(date '+%Y-%m-%d %H:%M:%S')"
        git -C "$REPO_PATH" commit -m "$COMMIT_MSG" 2>&1 >> "$LOG_FILE"
        log_message "Files committed: $COMMIT_MSG"
    else
        log_message "No small files to commit."
    fi
}

# Main execution
main() {
    log_message "========================================="
    log_message "Starting CRON cleanup job"
    log_message "========================================="
    
    # Detect large files
    if ! detect_large_files; then
        cleanup_large_files
    fi
    
    # Commit small files
    commit_small_files
    
    log_message "CRON cleanup job completed."
    log_message "========================================="
}

# Execute main function
main "$@"

# CRON Schedule (add to crontab with: crontab -e)
# Run daily at 2 AM
# 0 2 * * * /path/to/this/script/05-cron-cleanup-job.sh
#
# Run every 6 hours
# 0 */6 * * * /path/to/this/script/05-cron-cleanup-job.sh
#
# Run every hour
# 0 * * * * /path/to/this/script/05-cron-cleanup-job.sh
