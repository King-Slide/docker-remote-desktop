FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

LABEL maintainer="King-Slide" \
    org.opencontainers.image.source="https://github.com/King-Slide/docker-remote-desktop" \
    org.opencontainers.image.description="Browser-accessible Wayland desktop with Parsec and Google Chrome"

ENV TITLE=Docker-Remote-Desktop \
    KEYBOARD_LAYOUT=us \
    PIXELFLUX_WAYLAND=true

RUN \
  mkdir -p /app && \
  echo "**** setup google chrome repository ****" && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
      | gpg --dearmor \
      | tee /usr/share/keyrings/google-chrome.gpg > /dev/null && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
      > /etc/apt/sources.list.d/google-chrome.list && \
  echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      gstreamer1.0-pipewire \
      i965-va-driver \
      jq \
      vainfo \
      waybar \
      google-chrome-stable && \
  echo "**** install parsec ****" && \
    curl -fsSL https://builds.parsec.app/package/parsec-linux.deb -o /app/parsec-linux.deb && \
    apt-get install -y /app/parsec-linux.deb && \
  echo "**** cleanup ****" && \
    rm -rf \
      /tmp/* \
      /var/lib/apt/lists/* \
      /var/tmp/* \
      /app/parsec-linux.deb

COPY /root /

EXPOSE 3000 3001

VOLUME /config
