# rpi csi hdmi ustreamer

includes services specifically tuned for tc358743 hdmi-to-csi adapter
- ustreamer service
- edid setter service (with gopro hero 3 plus compatible edid)
- live hdmi video player for preview

## howto

1. edit `/boot/firmware/config.txt` — append lines from the files in the repository to the original file for your board
2. install docker + docker compose
3. `docker compose up --build -d`
   