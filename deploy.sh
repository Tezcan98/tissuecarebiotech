#!/usr/bin/env bash
set -euo pipefail

# Bu script sunucuda, repo'nun içinden (/home/tissuecarebiotech) root
# olarak çalıştırılır: ./deploy.sh

SITE_PATH="/home/tissuecarebiotech"
DOMAIN="tissuecarebiotech.com"
WWW_DOMAIN="www.tissuecarebiotech.com"
NGINX_SITE_NAME="tissuecarebiotech.com"

cd "${SITE_PATH}"
git pull

# Nginx: sunucudaki diğer sitelere dokunmadan sadece bu domain'e ait
# config dosyasını ekle/güncelle.
SITE_FILE="/etc/nginx/sites-available/${NGINX_SITE_NAME}"

cat > "${SITE_FILE}" <<NGINX_CONF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    root ${SITE_PATH};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX_CONF

ln -sf "${SITE_FILE}" "/etc/nginx/sites-enabled/${NGINX_SITE_NAME}"

nginx -t
systemctl enable --now nginx
systemctl reload nginx

echo "Deploy tamamlandı: http://${DOMAIN}"
