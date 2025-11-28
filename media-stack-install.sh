#!/bin/bash
set -e

echo "=== Creating directory structure ==="

BASE="/home/webserver-docker"

mkdir -p $BASE/{jellyfin,jellyseerr,sonarr,radarr,jackett,flaresolverr,prowlarr,qbittorrent}
mkdir -p $BASE/qbittorrent/{config,downloads}

echo "=== Writing docker-compose.yml ==="

cat << 'EOF' > $BASE/docker-compose.yml
version: "3.9"

services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Brussels
      - WEBUI_PORT=8080
    volumes:
      - /home/webserver-docker/qbittorrent/config:/config
      - /home/webserver-docker/qbittorrent/downloads:/downloads
    ports:
      - 8080:8080
      - 8999:8999
      - 8999:8999/udp
    restart: unless-stopped

  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    ports:
      - 8096:8096
    volumes:
      - /home/webserver-docker/jellyfin/config:/config
      - /home/webserver-docker/jellyfin/cache:/cache
      - /mnt/external-1/Nextcloud/Movies:/movies
      - /mnt/external-1/Nextcloud/Music:/music
      - /mnt/external-1/Nextcloud/Books:/books
      - /mnt/external-1/Nextcloud/iptv:/iptv
      - /etc/localtime:/etc/localtime:ro
    restart: unless-stopped

  jellyseerr:
    image: fallenbagel/jellyseerr
    container_name: jellyseerr
    ports:
      - 5055:5055
    environment:
      - LOG_LEVEL=info
      - PORT=5055
    volumes:
      - /home/webserver-docker/jellyseerr:/app/config
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr
    container_name: sonarr
    ports:
      - 8989:8989
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Brussels
    volumes:
      - /home/webserver-docker/sonarr:/config
      - /home/webserver-docker/qbittorrent/downloads:/downloads
      - /mnt/external-1/Nextcloud/Movies:/movies
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr
    container_name: radarr
    ports:
      - 7878:7878
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Brussels
    volumes:
      - /home/webserver-docker/radarr:/config
      - /home/webserver-docker/qbittorrent/downloads:/downloads
      - /mnt/external-1/Nextcloud/Movies:/movies
    restart: unless-stopped

  jackett:
    image: lscr.io/linuxserver/jackett
    container_name: jackett
    ports:
      - 9117:9117
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Brussels
    volumes:
      - /home/webserver-docker/jackett:/config
    restart: unless-stopped

  prowlarr:
    image: lscr.io/linuxserver/prowlarr
    container_name: prowlarr
    ports:
      - 9696:9696
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Brussels
    volumes:
      - /home/webserver-docker/prowlarr:/config
    restart: unless-stopped

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=info
    ports:
      - 8191:8191
    restart: unless-stopped
EOF

echo "=== Pulling containers and starting stack ==="

cd $BASE
sudo docker-compose pull
sudo docker-compose up -d

echo ""
echo "=============================================================="
echo " Your full media automation stack is now running!"
echo ""
echo " Jellyfin:       http://SERVER_IP:8096"
echo " Jellyseerr:     http://SERVER_IP:5055"
echo " Sonarr:         http://SERVER_IP:8989"
echo " Radarr:         http://SERVER_IP:7878"
echo " Jackett:        http://SERVER_IP:9117"
echo " Prowlarr:       http://SERVER_IP:9696"
echo " FlareSolverr:   http://SERVER_IP:8191"
echo " qBittorrent:    http://SERVER_IP:8080"
echo ""
echo " Later, you can easily add Gluetun (VPN) without redoing anything."
echo "=============================================================="
