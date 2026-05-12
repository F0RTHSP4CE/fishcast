FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends v4l-utils \
    && rm -rf /var/lib/apt/lists/*
