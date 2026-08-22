#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="root"
REMOTE_HOST="31.58.245.116"
REMOTE_PORT="22"
REMOTE_PATH="/home/tissuecarebiotech"
REPO_URL="https://github.com/Tezcan98/tissuecarebiotech.git"
DOMAIN="tissuecarebiotech.com"
WWW_DOMAIN="www.tissuecarebiotech.com"
NGINX_SITE_NAME="tissuecarebiotech.com"

ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
  REMOTE_PATH="${REMOTE_PATH}" REPO_URL="${REPO_URL}" \
  DOMAIN="${DOMAIN}" WWW_DOMAIN="${WWW_DOMAIN}" NGINX_SITE_NAME="${NGINX_SITE_NAME}" \
  bash -s <<'REMOTE_SCRIPT'
set -euo pipefail

# Site içeriği: ilk çalıştırmada klonla, sonrasında pull et.
if [ -d "${REMOTE_PATH}/.git" ]; then
  git -C "${REMOTE_PATH}" pull
else
  mkdir -p "${REMOTE_PATH}"
  git clone "${REPO_URL}" "${REMOTE_PATH}"
fi

# Nginx: sunucudaki diğer sitelere dokunmadan sadece bu domain'e ait
# config dosyasını ekle/güncelle.
SITE_FILE="/etc/nginx/sites-available/${NGINX_SITE_NAME}"

cat > "${SITE_FILE}" <<NGINX_CONF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    root ${REMOTE_PATH};
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
REMOTE_SCRIPT
