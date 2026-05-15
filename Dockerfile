# Pull base image.
FROM jlesage/baseimage-gui:debian-12-v4

# General environment.
ENV USER_ID=0 \
    GROUP_ID=0 \
    TERM=xterm \
    DEBIAN_FRONTEND=noninteractive

# MediathekView version.
ARG MEDIATHEK_VERSION=14.5.0
ENV MEDIATHEK_VERSION=${MEDIATHEK_VERSION}

# Install runtime dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        locales \
        wget \
        procps \
        ffmpeg \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# Locale settings.
ENV LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Maximize only the main/initial window.
COPY src/main-window-selection.xml /etc/openbox/main-window-selection.xml

# Application settings.
ENV APP_NAME="Mediathekview" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/output"]

# Metadata.
LABEL \
    org.label-schema.name="mediathekview" \
    org.label-schema.description="Docker container for Mediathekview" \
    org.label-schema.version="${MEDIATHEK_VERSION}" \
    org.label-schema.vcs-url="https://github.com/conrad784/docker-mediathekview-webinterface" \
    org.label-schema.schema-version="1.0"

# Download URL.
ARG MEDIATHEKVIEW_URL=https://download.mediathekview.de/stabil/MediathekView-${MEDIATHEK_VERSION}-linux.tar.gz

# Download and extract MediathekView.
RUN mkdir -p /opt \
    && wget -q "${MEDIATHEKVIEW_URL}" -O /tmp/MediathekView.tar.gz \
    && tar xf /tmp/MediathekView.tar.gz -C /opt \
    && rm -f /tmp/MediathekView.tar.gz

# Startup script.
COPY src/startapp.sh /startapp.sh
