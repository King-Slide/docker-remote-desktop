# Docker Remote Desktop

Access a Wayland desktop and remote computers through your browser.
Container based on [Docker Baseimage Selkies by linuxserver](https://github.com/linuxserver/docker-baseimage-selkies), with a labwc Wayland desktop and Waybar panel.

This project is maintained by [King-Slide](https://github.com/King-Slide). It is based on the original [docker-remote-desktop](https://github.com/lanjelin/docker-remote-desktop) project by [lanjelin](https://github.com/lanjelin), whose Docker image structure and desktop configuration provided the foundation for this fork.

The container comes with:

- [Parsec](https://parsec.app)
- [Google Chrome](https://www.google.com/chrome/)

Waybar provides icon-only launchers for foot, Chrome, and Parsec, followed by icon-and-title buttons for running windows. Click a running task to minimize or raise it, or middle-click it to close the window. The desktop uses the light `Breeze_Snow` cursor theme, while the right-click application menu remains text-only.

The Parsec launcher probes available render devices for working VAAPI H.264 decoding. It keeps Parsec's automatic hardware selection on compatible GPUs, disables H.265 when the GPU cannot decode it, and forces software decoding when no working decoder is available. Decoder choices made manually by the user are preserved.

The image is published for `linux/amd64` at `ghcr.io/king-slide/docker-remote-desktop`. The `latest` tag is rebuilt from `main` and every Sunday at 03:00 UTC. Version tags such as `v1.2.0` publish matching `1.2.0`, `1.2`, and `1` image tags. Publishing a new image does not automatically update running containers.

## License

The source code and configuration in this repository are licensed under the [GNU General Public License version 3](LICENSE). Google Chrome, Parsec, the base image, and operating-system packages remain subject to their own licenses and terms. See [NOTICE.md](NOTICE.md) for attribution and third-party notices.

Under no circumstances expose this container to anything but your local machine, unless you really know what you're doing. External access should be protected behind a reverse proxy with authentication, or behind a VPN.

The container runs in privileged mode so Google Chrome can use its internal process sandbox. This gives the container broad access to the host; only run it on a trusted system and network. `START_DOCKER=false` prevents the Selkies base image from starting Docker-in-Docker merely because privileged mode is enabled.

## Application Setup

The application can be accessed at:

* http://yourhost:3000/
* https://yourhost:3001/

## Usage

Some snippets to get you started.

### docker-compose

The included [`docker-compose.yml`](docker-compose.yml) pulls the published image and stores its persistent configuration in a named volume:

```bash
docker compose up -d
```

The host ports, user IDs, timezone, and keyboard layout can be overridden through `HTTP_PORT`, `HTTPS_PORT`, `PUID`, `PGID`, `TZ`, and `KEYBOARD_LAYOUT`. For example: `KEYBOARD_LAYOUT=de docker compose up -d`.

To update an existing deployment:

```bash
docker compose pull
docker compose up -d
```

### Chrome shared memory

Chrome benefits from a larger shared-memory allocation, especially with many tabs, video, or resource-heavy web applications. A 1 GiB `/dev/shm` is treated as sufficient. To provide it in Docker Compose or a Portainer stack, add this to the service:

```yaml
shm_size: "1gb"
```

For `docker run`, add `--shm-size=1g`. The setting is optional: the Chrome launcher checks `/dev/shm` at startup and automatically uses `/tmp` instead when less than 1 GiB is available. Using `/tmp` avoids crashes caused by Docker's default 64 MiB allocation, while a 1 GiB or larger `/dev/shm` generally gives Chrome better performance.

### docker cli

```bash
docker run -d \
  --name=docker-remote-desktop \
  --privileged \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Oslo \
  -e START_DOCKER=false \
  -e KEYBOARD_LAYOUT=us \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/config:/config \
  --restart unless-stopped \
  ghcr.io/king-slide/docker-remote-desktop:latest
```

### Options in all Selkies based GUI containers

This container is based on [Docker Baseimage Selkies](https://github.com/linuxserver/docker-baseimage-selkies) which means there are additional environment variables and run configurations to enable or disable specific functionality.

#### Optional environment variables

| Variable | Description |
| :----: | --- |
| CUSTOM_PORT | Internal port the container listens on for http if it needs to be swapped from the default 3000. |
| CUSTOM_HTTPS_PORT | Internal port the container listens on for https if it needs to be swapped from the default 3001. |
| CUSTOM_USER | HTTP Basic auth username, abc is default. |
| PASSWORD | HTTP Basic auth password, abc is default. If unset there will be no auth |
| SUBFOLDER | Subfolder for the application if running a subfolder reverse proxy, need both slashes IE `/subfolder/` |
| TITLE | The page title displayed in the browser, default `Docker-Remote-Desktop`. |
| KEYBOARD_LAYOUT | XKB keyboard layout used by desktop applications and Parsec. Defaults to `us`; examples include `de`, `fr`, `be`, and `gb`. |
| START_DOCKER | If set to false a container with privilege will not automatically start the DinD Docker setup. |
| DRINODE | Selects a render device for [DRI3 GPU acceleration](https://github.com/linuxserver/docker-baseimage-selkies#dri3-gpu-acceleration), for example `/dev/dri/renderD128`. Privileged mode already exposes available host devices. |
