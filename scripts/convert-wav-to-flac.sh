#!/usr/bin/env bash
# Convert any audio_stream inside a wav Container to a flac Container/audio_stream

# Check dependencies
if ! command -v ffmpeg &> /dev/null; then
        echo "Install ffmpeg"
        exit 1;
fi

convert() {
        local filename="${1%.*}"
        if ffprobe -v error -show_format "$1" 2>/dev/null | grep -q format_name=wav; then
             ffmpeg -i "$1" -c:a flac -compression_level 12 "$filename.flac"
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
