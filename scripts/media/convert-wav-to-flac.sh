#!/usr/bin/env bash
#Convert any audio_stream inside a wav Container to a flac Container/audio_stream

#Check dependencies
if ! command -v ffmpeg &> /dev/null; then
        echo "Install ffmpeg"
        exit 1;
fi

convert() {
    local filename="${1%.}"
            if ffprobe -v error -show_format "$1" 2>/dev/null | grep -q format_name=wav; then
        # Check if the bit depth is 32 bits
                if ffprobe -v error -show_streams "$1" 2>/dev/null | grep -q "pcm_f32"; then
                        ffmpeg -i "$1" -c:a flac -sample_fmt s32 -dither_method triangular_hp -compression_level 12 "$filename.flac"
                else
                        ffmpeg -i "$1" -c:a flac -compression_level 12 "$filename.flac"
                fi
        fi
}

input="${1:-*}"  # Use $1 if provided, otherwise use "*"
for file in "$input"; do
    if [ -f "$file" ]; then  # Check if it's a regular file
        convert "$file"
    else
        echo "Skipping: $file (not a regular file)"
    fi
done
