#!/usr/bin/env bash
set -euo pipefail

# Bu script sunucuda, repo'nun içinden (/home/tissuecarebiotech) root
# olarak çalıştırılır: ./deploy.sh

SITE_PATH="/home/tissuecarebiotech"
DOMAIN="tissuecarebiotech.com"
WWW_DOMAIN="www.tissuecarebiotech.com"
NGINX_SITE_NAME="tissuecarebiotech.com"
CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"

cd "${SITE_PATH}"
git pull

# Nginx: sunucudaki diğer sitelere dokunmadan sadece bu domain'e ait
# config dosyasını ekle/güncelle. Certbot ile bu domain için daha önce
# sertifika alınmışsa HTTPS + HTTP->HTTPS redirect bloğunu, yoksa düz
# HTTP config'i yazar.
SITE_FILE="/etc/nginx/sites-available/${NGINX_SITE_NAME}"

if [ -f "${CERT_DIR}/fullchain.pem" ]; then
  cat > "${SITE_FILE}" <<NGINX_CONF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    if (\$host = ${WWW_DOMAIN}) {
        return 301 https://\$host\$request_uri;
    }
    if (\$host = ${DOMAIN}) {
        return 301 https://\$host\$request_uri;
    }

    return 404;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    root ${SITE_PATH};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    ssl_certificate ${CERT_DIR}/fullchain.pem;
    ssl_certificate_key ${CERT_DIR}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
NGINX_CONF
else
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
fi

ln -sf "${SITE_FILE}" "/etc/nginx/sites-enabled/${NGINX_SITE_NAME}"

nginx -t
systemctl enable --now nginx
systemctl reload nginx

echo "Deploy tamamlandı: http://${DOMAIN}"
