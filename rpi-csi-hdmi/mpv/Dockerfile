FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends mpv \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/mpv"]
