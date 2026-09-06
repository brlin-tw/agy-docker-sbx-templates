# syntax=docker/dockerfile:1
# Docker Sandbox template with Docker-in-Docker for Antigravity CLI
#
# Copyright 2026 林博仁(Buo-ren Lin) <buo.ren.lin@gmail.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

ARG BASE_IMAGE=docker/sandbox-templates:shell-docker
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Antigravity CLI Docker Sandbox Template" \
    org.opencontainers.image.description="Docker Sandbox template image with Docker engine for running Google Antigravity CLI (agy)" \
    org.opencontainers.image.licenses="AGPL-3.0-or-later"

# Switch to root to install system utilities
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch back to the non-root agent user and install Antigravity CLI
USER agent
ENV PATH="/home/agent/.local/bin:${PATH}"

RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# Wrap the real agy binary to default to YOLO mode (--dangerously-skip-permissions --mode=accept-edits)
RUN mv /home/agent/.local/bin/agy /home/agent/.local/bin/agy.real \
    && printf '#!/usr/bin/env bash\nexec /home/agent/.local/bin/agy.real --dangerously-skip-permissions --mode=accept-edits "${@}"\n' \
        > /home/agent/.local/bin/agy \
    && chmod 0755 /home/agent/.local/bin/agy

WORKDIR /workspace
