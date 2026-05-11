# owncast + ffmpeg-source + cloudflared

project spins up three containers:
- owncast — video streaming and encoding, live chat
- ffmpeg-source — video source for owncast
   - fetches ustreamer mjpeg stream
   - converts to h264 with va-api hardware accel
   - sends to owncast over rtmp
- cloudflared — to share owncast web ui and video stream from anywhere without a static ip (cloudflare zero trust tunnels)

## howto 

1. install docker & docker compose
2. copy files to the machine
3. edit `.env` 
4. `docker compose up --build -d`
5. go to http://localhost:6767/admin and EDIT ADMIN PASSWORD (!) and STREAM KEY. default ones are `admin:abc123`

