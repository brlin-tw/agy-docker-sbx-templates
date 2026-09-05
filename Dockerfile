# syntax=docker/dockerfile:1
# Docker Sandbox template for Antigravity CLI
#
# Copyright 2026 林博仁(Buo-ren Lin) <buo.ren.lin@gmail.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

ARG BASE_IMAGE=docker/sandbox-templates:shell
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Antigravity CLI Docker Sandbox Template" \
    org.opencontainers.image.description="Docker Sandbox template image for running Google Antigravity CLI (agy)" \
    org.opencontainers.image.licenses="AGPL-3.0-or-later"

# Switch to root to install required system utilities
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch back to the non-root agent user
USER agent
WORKDIR /workspace
