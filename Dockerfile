# Pull base image.
FROM jlesage/baseimage-gui:debian-12-v4

ENV USER_ID=0 GROUP_ID=0 TERM=xterm
ENV MEDIATHEK_VERSION=14.5.0

# Locale needed for storing files with umlaut.
RUN \
    add-pkg apt-utils locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Runtime deps.
RUN \
    add-pkg \
        wget \
        ca-certificates \
        procps \
        vlc \
        ffmpeg \
        libxtst6 \
        libxrender1 \
        libxi6 \
        libxext6

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
      org.label-schema.version=$MEDIATHEK_VERSION \
      org.label-schema.vcs-url="https://github.com/conrad784/docker-mediathekview-webinterface" \
      org.label-schema.schema-version="1.0"

# Define software download URLs.
ARG MEDIATHEKVIEW_URL=https://download.mediathekview.de/stabil/MediathekView-$MEDIATHEK_VERSION-linux.tar.gz

# Download MediathekView.
RUN mkdir -p /opt/MediathekView
RUN wget -q "${MEDIATHEKVIEW_URL}" -O /tmp/MediathekView.tar.gz && \
    tar xf /tmp/MediathekView.tar.gz -C /opt && \
    rm -f /tmp/MediathekView.tar.gz

COPY src/startapp.sh /startapp.sh