#!/usr/bin/env bash

source_dir="$(pwd)/scripts/media"
target_dir="/usr/local/bin"

# Loop through each file in the source directory
for file in "$source_dir"/*; do
    if [[ -f "$file" ]]; then  # Check if it's a file (not a directory)
        # Remove the extension from the filename using parameter expansion
        script_filename=$(basename "$file" .${file##*.})

        # Check if the symlink already exists in the target directory
        if [[ ! -e "$target_dir/$script_filename" ]]; then
            sudo ln -s "$file" "$target_dir/$script_filename"
        fi
    fi
done
