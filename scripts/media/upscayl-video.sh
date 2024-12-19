#!/usr/bin/env bash

INSTALL_DIR="/opt/upscayl"
BATCH_SIZE=100

usage() {
    echo "Usage: $0 <input-video> <model> <output-resolution (1920x1080)>"
}

# Check argument amount
if [[ "$#" -ne 3 ]]; then
    usage;
    exit 1;
fi

# Check input video
if [[ $1 = /* ]]; then
    if ! [[ -f "$1" ]]; then
        echo "Can't find $1!";
        exit 1;
    fi
else
    if [[ -f "$INSTALL_DIR/video/input/$1" ]]; then
        VIDEO="$INSTALL_DIR/video/input/$1";
    elif [[ -f "$(pwd)/$1" ]]; then
        VIDEO="$(pwd)/$1";
    else
        echo "Can't find $1!";
        exit 1;
    fi
fi

# Check upscayl model
if ! [[ -f $INSTALL_DIR/models/"$2.bin" ]]; then
    echo "Can't find model $2 under $INSTALL_DIR/models!";
    exit 1;
fi

# Constances
MODEL="$2"; RESOLUTION="$3"
VIDEO_md5="$(md5sum $VIDEO | cut -d ' ' -f 1)"

VIDEO_RESOLUTION=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $VIDEO)
VIDEO_FRAMECOUNT=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 -i "$VIDEO")
VIDEO_FRAMERATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 -i "$VIDEO")

#
# Functions
#

decode_video() {
    (
        local working_dir="$INSTALL_DIR/frames/input/$VIDEO_md5"
        mkdir -pv "$working_dir";
        cd "$working_dir" || exit 1;

        if [[ $(ls $working_dir | wc -l) -eq $VIDEO_FRAMECOUNT ]]; then
            echo "Skip upscale process, done!"
        else
            # Cut video into it's frames
            ffmpeg -i "$VIDEO" %d.png
        fi
    )
}

encode_video() {
    echo ""
}

upscale_batch() {
    (
        local working_dir="$INSTALL_DIR/frames/output/$VIDEO_md5";
        mkdir -pv "$working_dir";
        cd "$working_dir" | exit 1;


        # Loop through batches in steps of 100
        for ((start=0; ; start+=batch_size)); do
            end=$((start + batch_size - 1))
            
            # Create the pattern to match the files in the current batch
            pattern="${start}-$(($end)).png"
            
            # Use 'find' to match files in the range
            files=$(find . -maxdepth 1 -name "$pattern" -type f | sort)
            echo "$files"
            exit 0;
        done

        # Catch a batch of files with an regex pattern
        local work_batch="$1"
        exit 0;
        upscayl -i "original/$sub_dir" -o "upscale/$MODEL/$sub_dir" -s "$3" -j 2:4:6 -m "$MODEL_PATH" -n "$MODEL" -f png > /dev/null 2>&1
    )
}

#
# Main
#

echo "$VIDEO_md5"
decode_video
