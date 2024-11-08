#!/bin/bash

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <video>"
	exit 1
elif [ "$#" -lt 2 ]; then
	echo "Usage: $0 <video> <default-audio-stream-id>"
	exit 1
fi

# Get filename from path
filename=$(basename "$1" | sed 's/\.[^.]*$//')
mkdir -pv output

if [ "$#" -eq 2 ]; then
	# get current default audio stream id
	current_default_a_stream=$(ffmpeg -i "$1" 2>&1 | grep "Audio:" | grep "(default)" | grep -oP ':\d+')

	# set current default audio stream disposition to none and set default disposition to the new one
	ffmpeg -i "$1" -map 0 -metadata title="$filename" -disposition"$current_default_a_stream" none -disposition:a:"$2" default -c copy output/"$1"
	exit 0
fi

if [ "$#" -eq 3 ]; then
	ffmpeg -i "$1" -map 0 -c copy -metadata title="$filename" -metadata:s:s:"$2" title="Forced" -disposition:s:s:"$2" default+forced -metadata:s:s:"$3" title="Full" -disposition:s:s:"$3" none output/"$1"
	exit 1
fi

ffmpeg -i "$1" -map 0 -c copy -metadata title="$filename" "output/$1"
