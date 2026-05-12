# Build stage
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libjpeg-dev \
    libudev-dev \
    libgpiod-dev \
    libevent-dev \
    libssl-dev \
    libdrm-dev \
    libbsd-dev \
    && rm -rf /var/lib/apt/lists/*

# BuildKit clones via the Docker daemon — no git/ca-certs needed inside the container
ADD https://github.com/pikvm/ustreamer.git /build/ustreamer

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
    libevent-pthreads-2.1-7 \
    libssl3 \
    libdrm2 \
    libbsd0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/ustreamer/ustreamer /usr/local/bin/ustreamer

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/ustreamer"]
