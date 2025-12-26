#!/bin/bash

# Task 1.3: Commit a large file (>2GB) to the GitHub repo

set -e

LOG_FILE="git_commit.log"

echo "Creating a large file (>2GB) for testing..." | tee "$LOG_FILE"

# Create a 2.5GB file for testing
LARGE_FILE="large_test_file.bin"
SIZE_GB=2.5

dd if=/dev/zero of="$LARGE_FILE" bs=1G count=2 2>&1 | tee -a "$LOG_FILE"
dd if=/dev/zero of="$LARGE_FILE" bs=1M count=512 oflag=append conv=notrunc 2>&1 | tee -a "$LOG_FILE"

echo "Large file created: $LARGE_FILE ($(du -h $LARGE_FILE | awk '{print $1}'))" | tee -a "$LOG_FILE"

# Initialize git if not already initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..." | tee -a "$LOG_FILE"
    git init
    git config user.email "pavankumar938146@gmail.com"
    git config user.name "pavan kumar"
fi

# Configure git to allow large files (disable warning)
git config core.compression 0
git config pack.threads 1
git config pack.deltaCompressionLevel 0

# Add the large file
echo "Adding large file to git..." | tee -a "$LOG_FILE"
git add "$LARGE_FILE"

# Commit the large file
echo "Committing large file..." | tee -a "$LOG_FILE"
git commit -m "Add large test file ($(du -h $LARGE_FILE | awk '{print $1}')) for BFG testing" 2>&1 | tee -a "$LOG_FILE"

echo "Large file committed successfully!" | tee -a "$LOG_FILE"
echo "To push to remote: git push -u origin main" | tee -a "$LOG_FILE"
