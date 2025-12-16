#!/bin/bash

# Script to change the first ## heading to # heading in all markdown files

echo "Fixing markdown file headings..."

# Find all .md files and process each one
find pages -name "*.md" | while read -r file; do
    # Get the first line
    first_line=$(head -1 "$file")

    # Check if first line starts with ##
    if [[ "$first_line" == "## "* ]]; then
        # Replace the first occurrence of ## with # at the start of the file
        # Use sed to replace ## with # on the first line only
        sed -i '' '1s/^## /# /' "$file"
        echo "Fixed: $file"
    fi
done

echo "Done!"
