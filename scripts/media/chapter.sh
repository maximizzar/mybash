#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <video>"
	exit 1
fi

# Function to get chapter information by title
get_chapter_by_title() {
	local chapter_title="$1"
	local metadata="$2"

	# Use a while loop to read through the metadata
	while IFS= read -r line; do
		# If the line contains the chapter title
		if [[ "$line" == title=* && "${line#title=}" == "$chapter_title" ]]; then
			# Print the chapter details
			echo "$line"
			# Print the START and END lines for the chapter
			echo "$previous_line"
			echo "$line" # This is the title line
			echo "$next_line"
			return
		fi
		# Keep track of the previous and next lines
		previous_line="$line"
		next_line="$line"
	done <<<"$metadata"
}

chapter_metadata=$(ffmpeg -i "$1" -f ffmetadata - 2>&1 | grep -E '^\[CHAPTER\]|^TIMEBASE=|^START=|^END=|^title=')

declare -a chapters=()

# Parse the chapter_metadata variable
while IFS= read -r line; do
	if [[ $line == "[CHAPTER]" ]]; then
		# We have encountered a new chapter
		in_chapter=true
	elif [[ $line == START=* && $in_chapter == true ]]; then
		start="${line#START=}"
	elif [[ $line == END=* && $in_chapter == true ]]; then
		end="${line#END=}"
	elif [[ $line == title=* && $in_chapter == true ]]; then
		title="${line#title=}"
		# Add the chapter to the array
		chapters+=("$title, $start, $end")
		# Reset variables for the next chapter
		title=""
		start=""
		end=""
		in_chapter=false
	fi
done <<<"$chapter_metadata"

# Loop through the array and print each chapter
#for chapter in "${chapters[@]}"; do
#  echo "$chapter"
#done

# Access the element at row 0, column 1
row=0
col=1
num_cols=3
element="${chapters[$((row * num_cols + col))]}"

echo "$element"

#echo "scale=10; chapters[@]$start / $timebase" | bc)
