# Pull base image.
FROM jlesage/baseimage-gui:debian-12-v4

ENV USER_ID=0 \
    GROUP_ID=0 \
    TERM=xterm

ARG MEDIATHEK_VERSION=14.5.0
ENV MEDIATHEK_VERSION=${MEDIATHEK_VERSION}

# Locale and runtime dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        locales \
        wget \
        procps \
        vlc \
        ffmpeg \
        ca-certificates \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Maximize only the main/initial window.
COPY src/main-window-selection.xml /etc/openbox/main-window-selection.xml

# Set environment variables.
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

# Define software download URL.
ARG MEDIATHEKVIEW_URL=https://download.mediathekview.de/stabil/MediathekView-${MEDIATHEK_VERSION}-linux.tar.gz

# Download MediathekView.
RUN mkdir -p /opt \
    && wget -q "${MEDIATHEKVIEW_URL}" -O /tmp/MediathekView.tar.gz \
    && tar xf /tmp/MediathekView.tar.gz -C /opt \
    && rm -f /tmp/MediathekView.tar.gz

COPY src/startapp.sh /startapp.sh
