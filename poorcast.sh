#!/bin/bash

# Ultra-low-bandwidth YouTube streaming tool.
# Usage: ./poorcast.sh <stream_dir> <rtmp_url> <cpu_core>

DIR="$1"
RTMP="$2"
CORE="$3"

### SETTINGS: ############################################

BITRATE="128k"
PRESET="ultrafast"
FONT_PATH="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
STATIC_COVER="$DIR/background.jpg"
LOGFILE="$DIR/$(basename "$DIR").log"

##########################################################

if [[ -z "$DIR" || -z "$RTMP" || -z "$CORE" ]]; then
  echo "Usage: $0 <stream_dir> <rtmp_url> <cpu_core>"
  exit 1
fi

if [[ ! -f "$STATIC_COVER" ]]; then
  echo "ERROR: $STATIC_COVER image not found!"
  exit 1
fi

shopt -s nullglob

while true; do
  echo "Scan tracks..."
  readarray -t TRACKS < <(find "$DIR" -type f -iname "*.mp3" | shuf)
  # if no recursion needed:
  # readarray -t TRACKS < <(shuf -e "$DIR"/*.mp3)

  for AUDIO_FILE in "${TRACKS[@]}"; do
    REL_PATH="${AUDIO_FILE#$DIR/}"
    TIMESTAMP="$(date '+%y%m%d %H%M%S')"
    echo "[$TIMESTAMP] $REL_PATH" >> "$LOGFILE"
    echo "Streaming: $REL_PATH"

    TITLE=$(ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")
    # ALBUM=$(ffprobe -v error -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")

    [[ -z "$TITLE" ]] && TITLE=$(basename "$AUDIO_FILE")

    escape_for_drawtext() {
        local text="$1"
        printf '%s' "$text" | sed "s/['\\:]/\\\\&/g"
    }

    TITLE=$(escape_for_drawtext "$TITLE")

    taskset -c "$CORE" ffmpeg -loglevel warning -re \
      -loop 1 -framerate 1 -i "$STATIC_COVER" \
      -i "$AUDIO_FILE" \
      -filter_complex "[0:v]scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,format=yuv420p,drawtext=fontfile=$FONT_PATH:text='Track\: $TITLE':fontcolor=white:fontsize=18:box=1:boxcolor=black@0:boxborderw=10:x=(w-text_w)/2:y=h-100[v]" \
      -map "[v]" -map 1:a \
      -shortest \
      -c:v libx264 -preset "$PRESET" -tune stillimage \
      -pix_fmt yuv420p \
      -x264opts "keyint=1:no-scenecut" \
      -c:a aac -b:a "$BITRATE" \
      -f flv -flvflags no_duration_filesize "$RTMP"

  done
done
