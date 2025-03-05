#!/bin/bash

# Input file
INPUT_FILE="ACSST1Y2023.S1501-Data.csv"
OUTPUT_FILE="educational_attainment.csv"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file $INPUT_FILE not found."
    exit 1
fi

# Get header line
HEADER=$(head -n 1 "$INPUT_FILE")

# Create an array of column indices to keep (those not ending with M)
IFS=',' read -ra COLUMNS <<< "$HEADER"
KEEP_INDICES=()
KEEP_HEADERS=()

for i in "${!COLUMNS[@]}"; do
    if [[ ! "${COLUMNS[$i]}" =~ M\"?$ ]]; then
        KEEP_INDICES+=($i)
        KEEP_HEADERS+=("${COLUMNS[$i]}")
    fi
done

# Print summary of operation
echo "Total columns: ${#COLUMNS[@]}"
echo "Keeping columns: ${#KEEP_INDICES[@]}"
echo "Removing columns: $((${#COLUMNS[@]} - ${#KEEP_INDICES[@]}))"

# Create a new CSV with only the columns we want to keep
{
    # Print the new header line
    (IFS=','; echo "${KEEP_HEADERS[*]}")
    
    # Process the data lines (skip header)
    tail -n +2 "$INPUT_FILE" | while IFS= read -r line; do
        NEW_LINE=()
        IFS=',' read -ra LINE_COLUMNS <<< "$line"
        
        for idx in "${KEEP_INDICES[@]}"; do
            NEW_LINE+=("${LINE_COLUMNS[$idx]}")
        done
        
        (IFS=','; echo "${NEW_LINE[*]}")
    done
} > "$OUTPUT_FILE"

echo "Processing complete. Output written to $OUTPUT_FILE"

