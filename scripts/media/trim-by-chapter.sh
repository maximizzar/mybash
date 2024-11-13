#!/usr/bin/env bash

usage() {
	echo "Usage: $0 <video> <ss chapter> <to chapter> <output>"
	echo "       $0 <video> <ss chapter> <output>"
}

check_dependencies() {
	if ! command -v ffmpeg &> /dev/null; then
		echo "Install ffmpeg"
		exit 1;
	fi
}

convert_nanoseconds_to_hh_mm_ss() {
    local nanoseconds=$1

    # Convert to seconds
    local seconds=$((nanoseconds / 1000000000))

    # Calculate hours, minutes, and seconds
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local remaining_seconds=$((seconds % 60))

    # Return the formatted output
    printf "%02d:%02d:%02d" $hours $minutes $remaining_seconds
}

# Script start! (check dependencies and cmd args)
check_dependencies
if [ "$#" -lt 3  ] || [ "$#" -gt 4 ]; then
	usage
	exit 1
fi

# metadata from the input video
chapter_metadata=$(ffmpeg -i "$1" -f ffmetadata - 2>&1 | grep -E '^\[CHAPTER\]|^TIMEBASE=|^START=|^END=|^title=')

# array with chapter start times
declare -a chapters=()

# Parse the chapter_metadata variable
while IFS= read -r line; do
	if [[ $line == START=* ]]; then
		# We have encountered a new chapter
		chapters+=("${line#START=}")
	fi
done <<<"$chapter_metadata"

start_time=$(convert_nanoseconds_to_hh_mm_ss "${chapters[$2-1]}")
if [ "$#" -eq 4 ]; then
	# If start and end chapter present
	end_time=$(convert_nanoseconds_to_hh_mm_ss "${chapters[$3-1]}")
	ffmpeg -i "$1" -map 0 -ss "$start_time" -to "$end_time" -c copy "$4"
	exit 0
fi

# If only an start chapter is provided
ffmpeg -i "$1" -map 0 -ss "$start_time" -c copy "$3"
exit 0
