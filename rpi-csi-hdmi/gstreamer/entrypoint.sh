#!/bin/sh
set -e

# The entrypoint script reads the actual framebuffer resolution at runtime via
# fbset so the pipeline adapts to whatever display is connected.

# Read framebuffer geometry at runtime — adapts to any display resolution.
FB=${FBDEV:-/dev/fb0}
read W H <<EOF
$(fbset -fb "$FB" | awk '/geometry/ { print $2, $3 }')
EOF

echo "Display resolution: ${W}x${H}"

# Source aspect ratio from ustreamer (fixed by the EDID we programmed).
# Compute the largest scaled size that fits within WxH while preserving it.
SW=1920
SH=1080

if [ $((W * SH)) -gt $((H * SW)) ]; then
    # Display is wider relative to source — fit to height
    SCALE_H=$H
    SCALE_W=$((H * SW / SH))
else
    # Display is taller relative to source — fit to width
    SCALE_W=$W
    SCALE_H=$((W * SH / SW))
fi

# Padding to centre the scaled image (videobox uses negative = add borders)
PAD_T=$(( (H - SCALE_H) / 2 ))
PAD_B=$(( H - SCALE_H - PAD_T ))
PAD_L=$(( (W - SCALE_W) / 2 ))
PAD_R=$(( W - SCALE_W - PAD_L ))

echo "Scaled: ${SCALE_W}x${SCALE_H}, padding L${PAD_L} R${PAD_R} T${PAD_T} B${PAD_B}"

# Pipeline explanation:
#   souphttpsrc    — HTTP MJPEG source (ustreamer)
#   multipartdemux — splits the multipart/x-mixed-replace stream into JPEG frames
#   jpegdec        — software JPEG decode (avoids bcm2835-codec contention)
#   queue          — single frame, drop old frames to stay real-time
#   videoscale     — scale to computed dimensions (aspect ratio preserved)
#   videobox       — add black borders to reach full display size
#   videoconvert   — convert to RGB16 which fbdevsink expects
#   fbdevsink      — writes directly to /dev/fb0; no DRM plane ownership needed

exec gst-launch-1.0 -e \
    souphttpsrc location=http://ustreamer:8080/stream is-live=true \
    ! multipartdemux \
    ! jpegdec \
    ! queue max-size-buffers=1 leaky=downstream \
    ! videoscale \
    ! "video/x-raw,width=${SCALE_W},height=${SCALE_H}" \
    ! videobox border-alpha=0 \
        top=-${PAD_T} bottom=-${PAD_B} left=-${PAD_L} right=-${PAD_R} \
    ! videoconvert \
    ! fbdevsink device="$FB" sync=false
