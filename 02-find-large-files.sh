#!/bin/bash

# Task 1.2: Get all files larger than 50MB and sort in decreasing order

FOLDER_NAME="${1:-.}/test_files"
OUTPUT_FILE="large_files_report.txt"

echo "Finding files larger than 50MB in: $FOLDER_NAME" | tee "$OUTPUT_FILE"
echo "================================================" | tee -a "$OUTPUT_FILE"

# Find files larger than 50MB, sort by size in decreasing order
echo "Files larger than 50MB (sorted by size, descending):" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

find "$FOLDER_NAME" -type f -size +50M -exec ls -lh {} \; | \
    awk '{print $5, $9}' | \
    sort -h -k1 -r | \
    tee -a "$OUTPUT_FILE"

echo "" | tee -a "$OUTPUT_FILE"
echo "Summary:" | tee -a "$OUTPUT_FILE"
echo "Total files larger than 50MB: $(find "$FOLDER_NAME" -type f -size +50M | wc -l)" | tee -a "$OUTPUT_FILE"
echo "Total size of large files: $(du -sh $(find "$FOLDER_NAME" -type f -size +50M) 2>/dev/null | tail -1 | awk '{print $1}')" | tee -a "$OUTPUT_FILE"

echo "Report saved to: $OUTPUT_FILE"
