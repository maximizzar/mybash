#!/usr/bin/env bash
# Encode the Videostream from an existing Video-container with the av1 codec

# Check dependencies
if ! command -v ffmpeg &> /dev/null; then
        echo "Install ffmpeg"
        exit 1;
fi

convert() {
    local filename="${1%.}";
    local extension="${1##*.}";
    # Check input file
    if ffprobe -v error -show_format "$1" 2>/dev/null | grep -Eq "format_name=(mov|mp4|matroska)"; then
        ffmpeg -i "$1" -map 0 -map -0:d -c copy -c:v:0 libsvtav1 -crf 23 -b:v 0 "${1%.*}.av1.${1##*.}"
    fi
}

# Use $1 if provided, otherwise use "*"
input="${1:-*}" 
for file in "$input"; do
        # Check if it's a regular file
        if [ -f "$file" ]; then
                convert "$file"
        else
                echo "Skipping: $file (not a regular file)"
        fi
done
