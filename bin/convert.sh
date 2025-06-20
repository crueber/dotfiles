#!/bin/bash

ACTIVATION_BYTES="345e7104"

# Define source and destination directories
SOURCE_DIR="/Users/crueber/temp"
DEST_DIR="/Users/crueber/Sync/Audiobooks"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Loop through all AAX files in source directory
for file in "$SOURCE_DIR"/*.aax; do
    if [ -f "$file" ]; then
        # Get filename without extension and path
        filename=$(basename "${file%.*}")
        
        echo "Converting: $filename"
        
        # Convert AAX to M4B
        ffmpeg -activation_bytes $ACTIVATION_BYTES -i "$file" -c copy "$DEST_DIR/${filename}.m4b"
        
        echo "Finished: $filename"
    fi
done

echo "All conversions complete!"
