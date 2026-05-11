# rpi csi hdmi ustreamer

includes services specifically tuned for tc358743 hdmi-to-csi adapter
- ustreamer service
- edid setter service (with gopro hero 3 plus compatible edid)
- live hdmi video player for preview

## howto

1. edit `/boot/firmware/config.txt` — append lines from the files in the repository to the original file for your board
2. copy files from the repo to the rpi 
3. `git clone https://github.com/pikvm/ustreamer /opt/tc358743/ustreamer` 
   and follow https://github.com/pikvm/ustreamer#building

