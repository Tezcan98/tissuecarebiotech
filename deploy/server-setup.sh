#!/usr/bin/env bash
# Sunucuda BİR KEZ çalıştırılır (root olarak). Bu script'in bulunduğu
# deploy/ klasörünü sunucuya kopyalayıp içinden çalıştırın:
#   scp -r deploy root@31.58.245.116:/root/tissuecarebiotech-deploy
#   ssh root@31.58.245.116
#   cd /root/tissuecarebiotech-deploy && ./server-setup.sh
set -euo pipefail

APP_DIR=/home/tissuecarebiotech
DOMAIN=tissuecarebiotech.com
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$APP_DIR"

if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
fi

if ! command -v serve >/dev/null 2>&1; then
  npm install -g serve
fi

cp "$SCRIPT_DIR/tissuecarebiotech.service" /etc/systemd/system/tissuecarebiotech.service
systemctl daemon-reload
systemctl enable --now tissuecarebiotech

cp "$SCRIPT_DIR/tissuecarebiotech.nginx.conf" "/etc/nginx/sites-available/$DOMAIN"
ln -sf "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/$DOMAIN"
nginx -t && systemctl reload nginx

certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN"

echo "Kurulum tamamlandı: https://$DOMAIN"
