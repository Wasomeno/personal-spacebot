# Spacebot Custom Dockerfile
# Extends official image with worker dependencies for browser/coding tasks
# Build: docker compose build

ARG SPACEBO_IMAGE=ghcr.io/spacedriveapp/spacebot:latest

FROM ${SPACEBO_IMAGE}

USER root

# -----------------------------------------------------------------------------
# Browser/Playwright dependencies (fixes Chromium crashes in workers)
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libglib2.0-0 \
    libfontconfig1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcursor1 \
    libxext6 \
    libxi6 \
    libxrender1 \
    libxtst6 \
    libxxf86vm1 \
    fonts-liberation \
    fontconfig \
    curl \
    wget \
    git \
    unzip \
    zip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Python + Node for worker tools
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    ffmpeg \
    libsm6 \
    libxext6 \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

# Don't override CMD - base image has the correct entrypoint/cmd
