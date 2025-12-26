#!/bin/bash

# Task 1.1: Generate files of different sizes
# This script creates a folder with files of specified sizes

set -e

FOLDER_NAME="test_files"
LOG_FILE="file_generation.log"

# Create the folder
mkdir -p "$FOLDER_NAME"
echo "Created folder: $FOLDER_NAME" | tee "$LOG_FILE"

# Function to generate files
generate_files() {
    local count=$1
    local size=$2
    local unit=$3
    
    echo "Generating $count files of $size$unit each..." | tee -a "$LOG_FILE"
    
    for ((i=1; i<=count; i++)); do
        filename="${FOLDER_NAME}/file_${size}${unit}_${i}.bin"
        dd if=/dev/zero of="$filename" bs=1 count=0 seek="${size}${unit}" 2>/dev/null
        echo "Created: $filename" | tee -a "$LOG_FILE"
    done
}

# Generate files with specified sizes
# 10X50MB
generate_files 10 50 M

# 20X100MB
generate_files 20 100 M

# 30X500MB
generate_files 30 500 M

# 5X1GB
generate_files 5 1 G

# 3X5GB
generate_files 3 5 G

# 1X10GB
generate_files 1 10 G

echo "File generation completed!" | tee -a "$LOG_FILE"

# Display the total size
echo "Total size of generated files:" | tee -a "$LOG_FILE"
du -sh "$FOLDER_NAME" | tee -a "$LOG_FILE"
