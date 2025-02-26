#!/bin/bash

# Check if directory is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Directory to traverse
DIR=$1

# Output file
OUTPUT_FILE="julia_functions.txt"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Find all Julia files in the directory and its subdirectories
find "$DIR" -type f -name "*.jl" | while read -r file; do
    # Get relative path from current directory
    rel_path=$(realpath --relative-to="$(pwd)" "$file")
    
    # Check if the file contains function definitions
    if grep -q "function" "$file"; then
        # Add to output file in the required format
        echo "include(\"$rel_path\")" >> "$OUTPUT_FILE"
    fi
done

echo "Julia functions have been identified and written to $OUTPUT_FILE"
