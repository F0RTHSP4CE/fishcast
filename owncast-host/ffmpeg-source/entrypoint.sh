#!/bin/sh
set -eu

: "${SOURCE_MJPEG_URL:?SOURCE_MJPEG_URL is required}"
: "${OWNCAST_RTMP_URL:?OWNCAST_RTMP_URL is required}"
: "${VAAPI_DEVICE:=/dev/dri/renderD128}"
: "${SOURCE_RW_TIMEOUT_US:=10000000}"
: "${RESTART_DELAY_SECONDS:=5}"
: "${VIDEO_BITRATE:=5000k}"
: "${VIDEO_MAXRATE:=5000k}"
: "${VIDEO_BUFSIZE:=10000k}"
: "${GOP_SIZE:=50}"
: "${AUDIO_BITRATE:=128k}"

while true; do
  echo "[ffmpeg-wrapper] starting ffmpeg at $(date -Is)"

  ffmpeg \
    -hide_banner \
    -loglevel info \
    -nostdin \
    -rw_timeout "$SOURCE_RW_TIMEOUT_US" \
    -reconnect 1 \
    -reconnect_at_eof 1 \
    -reconnect_streamed 1 \
    -reconnect_on_network_error 1 \
    -reconnect_on_http_error 4xx,5xx \
    -reconnect_delay_max 5 \
    -thread_queue_size 1024 \
    -f mpjpeg \
    -i "$SOURCE_MJPEG_URL" \
    -f lavfi \
    -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
    -map 0:v:0 \
    -map 1:a:0 \
    -vaapi_device "$VAAPI_DEVICE" \
    -vf "format=nv12,hwupload" \
    -c:v h264_vaapi \
    -profile:v high \
    -b:v "$VIDEO_BITRATE" \
    -maxrate "$VIDEO_MAXRATE" \
    -bufsize "$VIDEO_BUFSIZE" \
    -g "$GOP_SIZE" \
    -c:a aac \
    -b:a "$AUDIO_BITRATE" \
    -ar 48000 \
    -ac 2 \
    -f flv \
    "$OWNCAST_RTMP_URL"

  rc=$?
  echo "[ffmpeg-wrapper] ffmpeg exited with code $rc at $(date -Is); retrying in ${RESTART_DELAY_SECONDS}s"
  sleep "$RESTART_DELAY_SECONDS"
done
