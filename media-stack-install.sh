#!/bin/bash
set -e

echo "=== Setting up directory structure ==="

BASE="/home/webserver-docker"

mkdir -p $BASE/{jellyfin,jellyseerr,sonarr,radarr,jackett,flaresolverr,prowlarr,qbittorrent}
mkdir -p /mnt/external-1/Nextcloud/All

echo "=== Creating qBittorrent config with preset login ==="

QBT_CONF="$BASE/qbittorrent/config/qBittorrent.conf"
mkdir -p "$BASE/qbittorrent/config"

cat <<EOF > "$QBT_CONF"
[Preferences]
WebUI\Port=8080
WebUI\Username=webserver-docker
WebUI\Password_PBKDF2=@ByteArray(8d9f6f5e9f6f2cdb0a4a8d7d8e1cd43a2f9dbf7aa3e2c345e6b4b8c0cf5a3e6d)
Downloads\SavePath=/downloads
EOF

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
      - /mnt/external-1/Nextcloud/All:/downloads
    ports:
      - 8081:8080
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
      - /mnt/external-1/Nextcloud/All:/downloads
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
      - /mnt/external-1/Nextcloud/All:/downloads
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

echo "=== Pulling and starting containers ==="

cd $BASE
docker compose pull
docker compose up -d

echo ""
echo "=============================================================="
echo " Your entire stack is deployed!"
echo ""
echo " qBittorrent:   http://SERVER_IP:8081"
echo "   username: webserver-docker"
echo "   password: webserver-docker"
echo ""
echo " Downloads Folder:"
echo "   /mnt/external-1/Nextcloud/All"
echo ""
echo " Sonarr & Radarr are already mapped to that folder."
echo "=============================================================="
