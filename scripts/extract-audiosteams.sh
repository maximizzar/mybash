#!/usr/bin/env bash
# extract audio from video

# functions
get_audio_format() {
      local codec="$1"
      case "$codec" in
              aac) format="m4a";;
              ac3) format="ac3";;
              alac) format="m4a";;
              flac) format="flac";;
              mp3) format="mp3";;
              opus) format="opus";;
              pcm_s16le) format="wav";;
              pcm_s24le) format="wav";;
              pcm_s32le) format="wav";;
              pcm_u8) format="wav";;
              pcm_f32le) format="wav";;
              vorbis) format="ogg";;
              wma) format="wma";;
              ape) format="ape";;
              dts) format="dts";;
              aiff) format="aiff";;
              tta) format="tta";;
              gsm) format="gsm";;
              adpcm_ima_wav) format="wav";;
              adpcm_ms) format="wav";;
              adpcm_g722) format="g722";;
              adpcm_g726) format="g726";;
              amr_nb) format="amr";;
              amr_wb) format="amr";;
              mpeg_audio) format="mpa";;
              *) format="unknown";;  # Optional: handle unknown formats
      esac
}

# Make sure every Program is installed for the script to run!
if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        exit 1
fi

extract() {
          # List all audio steams using ffmpeg
          ffmpeg_output=$(ffmpeg -i "$1" 2>&1 | grep -E "Stream #[0-9]+:[0-9]+\([a-z]{3}\): Audio:")

          # create array audio_streams from ffmpeg_output
          IFS=$'\n' read -r -d '' -a audio_streams <<< "$ffmpeg_output"

          # Loop over the array and process each audio stream
          for stream in "${audio_streams[@]}"; do
                  id=$(echo "$stream" | grep -oE "[0-9]+:[0-9]+")
                  codec=$(echo "$stream" | grep -oP 'Audio: \K[^,]+' | awk '{print $1}')
                  get_audio_format "$codec"
                  echo "$id", "$codec", "$format"

                  if [ ${#audio_streams[@]} -eq 1 ]; then
                          filename=$(basename "${1%.*}")
                  else
                          filename=$(basename "${1%.*}"."$id")
                  fi
                  ffmpeg -i "$1" -map "$id" -vn -c:a copy "$filename.$format"
          done
}

if [ $# -eq 0 ]; then
        shopt -s dotglob  # This enables the wildcard to match hidden files
        shopt -s nullglob # This prevents the wildcard from returning itself if no matches are found

        for file in *; do
            # Check if the file is not '.' or '..'
            if [[ "$file" != "." && "$file" != ".." ]]; then
                # Use ffmpeg to get information about the file
                output=$(ffmpeg -i "$file" 2>&1)

                # Only process Video files
                if echo "$output" | grep -q "Video:"; then
                        extract "$file"
                fi
            fi
        done
elif [ $# -eq 1 ]; then
        extract "$1"
else
        echo "Too many parameters!"
        exit 1
fi
