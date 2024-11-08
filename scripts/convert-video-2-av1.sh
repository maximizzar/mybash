#!/usr/bin/env bash
# Convert all video_streams in a Video Container to the av1 codec

# Check dependencies
if ! command -v ffmpeg &> /dev/null; then
        echo "Install ffmpeg"
        exit 1;
fi

# functions
convert() {
              local file="$1"
              # Check if the file is not '.' or '..'
              if [[ "$file" != "." && "$file" != ".." ]]; then
                      # Use ffmpeg to get information about the file
                      output=$(ffmpeg -i "$file" 2>&1)

                      # Only process Video files
                      if echo "$output" | grep -q "Video:"; then
                              # Run ffmpeg to get stream information and filter
                              stream_ids=($(ffmpeg -i "$file" 2>&1 | grep 'Stream #[0-9]+:[0-9]+\([a-z]{3}\)' | grep -v 'mjpeg' | awk -F: '{print $1}' | awk '{print $2}'))

                              # Print the array (optional)
                              #echo "Video Stream IDs: ${stream_ids[@]}"
                      fi
              fi
}

if [ $# -eq 0 ]; then
        for file in *; do
                convert "$file"
        done
elif [ $# -eq 1 ]; then
        convert "$1"
else
        echo "Too many parameters!"
fi
