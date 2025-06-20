#!/bin/bash

# convert-xlsx.sh
INPUT_FILE="$1"
SHEET="$2"
OUTPUT_FILE="$3"

# Check if input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input.xlsx> <sheetid> [output.csv]"
    exit 1
fi

# Set output file name if not provided
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${INPUT_FILE%.xlsx}.csv"
fi

# Use Nushell to convert
nu -c "open '$INPUT_FILE' | get '$SHEET' | headers | to csv | save '$OUTPUT_FILE'"

echo "Converted $INPUT_FILE to $OUTPUT_FILE"
