# syntax=docker/dockerfile:1.7

##
## Stage 1: downloader
## - Uses GitHub API to fetch latest runner release metadata
## - Downloads and extracts runner package
##
FROM --platform=$TARGETPLATFORM docker.io/ubuntu:24.04 AS downloader

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      jq \
      tar \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/runner-download

# Map Docker arch -> runner arch and download latest runner release
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) RUNNER_ARCH="x64" ;; \
      arm64) RUNNER_ARCH="arm64" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH:-unknown}"; exit 1 ;; \
    esac; \
    TAG_NAME="$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name')"; \
    VERSION="${TAG_NAME#v}"; \
    FILE="actions-runner-linux-${RUNNER_ARCH}-${VERSION}.tar.gz"; \
    URL="https://github.com/actions/runner/releases/download/${TAG_NAME}/${FILE}"; \
    curl -fsSL -o runner.tgz "${URL}"; \
    mkdir -p /opt/actions-runner; \
    tar -xzf runner.tgz -C /opt/actions-runner; \
    rm -f runner.tgz; \
    test -x /opt/actions-runner/config.sh

##
## Stage 2: runtime
## - Minimal packages
## - Installs runner runtime dependencies (Ubuntu-specific + common)
## - Non-root execution
##
FROM --platform=$TARGETPLATFORM docker.io/ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV RUNNER_HOME=/opt/actions-runner
ENV PATH="${RUNNER_HOME}:${PATH}"

# Minimal runtime tools + deps commonly required by runner/.NET on Ubuntu 24.04
# (Keeping list explicit for image-size control.)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      iproute2 \
      jq \
      libcurl4 \
      libicu74 \
      libkrb5-3 \
      liblttng-ust1 \
      libssl3 \
      lsb-release \
      tar \
      unzip \
      zlib1g \
 && rm -rf /var/lib/apt/lists/*

# Create runner user
RUN useradd -m -d /home/runner -s /bin/bash -u 1001 runner

# Copy runner bits from downloader stage
COPY --from=downloader /opt/actions-runner ${RUNNER_HOME}

# Add startup scripts
COPY entrypoint.sh /entrypoint.sh
COPY configure.sh /usr/local/bin/configure-runner
RUN chmod +x /entrypoint.sh /usr/local/bin/configure-runner \
 && chown -R runner:runner "${RUNNER_HOME}" /home/runner

WORKDIR ${RUNNER_HOME}
USER runner

# Optional check (non-fatal) to aid debugging if libs change upstream
RUN set -eux; \
    ldd ./bin/libcoreclr.so | grep 'not found' && exit 1 || true; \
    ldd ./bin/libSystem.Security.Cryptography.Native.OpenSsl.so | grep 'not found' && exit 1 || true; \
    ldd ./bin/libSystem.IO.Compression.Native.so | grep 'not found' && exit 1 || true

ENTRYPOINT ["/entrypoint.sh"]