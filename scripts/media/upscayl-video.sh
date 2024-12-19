#!/usr/bin/env bash

INSTALL_DIR="/opt/upscayl"

usage() {
    echo "Usage: $0 <input-video> <model> <output-resolution (1920x1080)>"
}

# Check argument amount
if [[ "$#" -ne 3 ]]; then
    usage;
    exit 1;
fi

# Check input video
if ! [[ -f "$1" ]]; then
    echo "Can't find $1!";
    exit 1;
fi

# Check upscayl model
if ! [[ -f $INSTALL_DIR/models/"$2.bin" ]]; then
    echo "Can't find model $2 under $INSTALL_DIR/models!";
    exit 1;
fi

# Constances
VIDEO="$1"; MODEL="$2"; RESOLUTION="$3"
VIDEO_md5="$(md5sum $VIDEO)"

VIDEO_RESOLUTION=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $VIDEO)

#
# Functions
#

decode_video() {
    (
        local working_dir="$INSTALL_DIR/frames/input/$VIDEO_md5"
        mkdir -pv "$working_dir";
        cd "$working_dir" || exit 1;

        # Cut video into it's frames
        ffmpeg -i "$VIDEO" %d.png
    )
}

encode_video() {
    echo "WIP"
}

upscale_batch() {
    upscayl -i "original/$sub_dir" -o "upscale/$MODEL/$sub_dir" -s "$3" -j 2:4:6 -m "$MODEL_PATH" -n "$MODEL" -f png > /dev/null 2>&1
}

#
# Main
#

echo "$VIDEO_md5"
decode_video
