# Build stage
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    libjpeg-dev \
    libudev-dev \
    libgpiod-dev \
    libevent-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/pikvm/ustreamer /build/ustreamer

WORKDIR /build/ustreamer

# WITH_V4P=1 enables the V4L2 M2M hardware encoder pipeline (m2m-image) on RPi
RUN make WITH_V4P=1 -j$(nproc)

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libjpeg62-turbo \
    libudev1 \
    libgpiod2 \
    libevent-2.1-7 \
    libssl3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/ustreamer/ustreamer /usr/local/bin/ustreamer

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/ustreamer"]
