#!/usr/bin/env bash
set -euo pipefail

# Bu script sunucuda, repo'nun içinden (/home/tissuecarebiotech) root
# olarak çalıştırılır: ./deploy.sh
#
# İletişim formu, contact-handler.js'i 127.0.0.1:8091'de çalıştıran bir
# systemd servisi (contact-handler.service) üzerinden mesajı yerel
# sendmail ile gönderir. Node'un ve /usr/sbin/sendmail'in sunucuda
# kurulu olması gerekir; biri eksikse form gönderimi 502 döner ama
# sitenin geri kalanı etkilenmez.

SITE_PATH="/home/tissuecarebiotech"
DOMAIN="tissuecarebiotech.com"
WWW_DOMAIN="www.tissuecarebiotech.com"
NGINX_SITE_NAME="tissuecarebiotech.com"
CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
CF_IPS_FILE="/etc/nginx/cloudflare-ips-${NGINX_SITE_NAME}.conf"

cd "${SITE_PATH}"
git pull

# Cloudflare'in yayınladığı edge IP aralıkları (cloudflare.com/ips-v4,
# ips-v6). Sadece bu domain'in HTTPS bloğunda kullanılır, sunucu
# genelini etkilemez: orijine Cloudflare dışından doğrudan erişimi
# engeller. Deploy anında ağdan çekmek yerine sabit liste kullanılır —
# deploy sırasında geçici bir ağ hatası nedeniyle boş/bozuk bir
# allowlist yazıp siteyi kilitleme riskini önler.
cat > "${CF_IPS_FILE}" <<'CF_IPS'
allow 173.245.48.0/20;
allow 103.21.244.0/22;
allow 103.22.200.0/22;
allow 103.31.4.0/22;
allow 141.101.64.0/18;
allow 108.162.192.0/18;
allow 190.93.240.0/20;
allow 188.114.96.0/20;
allow 197.234.240.0/22;
allow 198.41.128.0/17;
allow 162.158.0.0/15;
allow 104.16.0.0/13;
allow 104.24.0.0/14;
allow 172.64.0.0/13;
allow 131.0.72.0/22;
allow 2400:cb00::/32;
allow 2606:4700::/32;
allow 2803:f800::/32;
allow 2405:b500::/32;
allow 2405:8100::/32;
allow 2a06:98c0::/29;
allow 2c0f:f248::/32;
deny all;
CF_IPS

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

    # Sadece Cloudflare üzerinden gelen trafiği kabul et; orijine
    # doğrudan IP ile erişimi kapat.
    include ${CF_IPS_FILE};

    root ${SITE_PATH};
    index index.html;

    error_page 404 /404.html;

    location ~ /\. {
        deny all;
        return 404;
    }
    location = /deploy.sh {
        deny all;
        return 404;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /contact-handler {
        proxy_pass http://127.0.0.1:8091/contact-handler;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

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

    error_page 404 /404.html;

    location ~ /\. {
        deny all;
        return 404;
    }
    location = /deploy.sh {
        deny all;
        return 404;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /contact-handler {
        proxy_pass http://127.0.0.1:8091/contact-handler;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
NGINX_CONF
fi

ln -sf "${SITE_FILE}" "/etc/nginx/sites-enabled/${NGINX_SITE_NAME}"

nginx -t
systemctl enable --now nginx
systemctl reload nginx

# İletişim formu servisi: kod her deploy'da değişebileceği için servis
# dosyası her seferinde yazılır ve süreç yeniden başlatılır.
cp "${SITE_PATH}/contact-handler.service" /etc/systemd/system/contact-handler.service
systemctl daemon-reload
systemctl enable --now contact-handler
systemctl restart contact-handler

echo "Deploy tamamlandı: http://${DOMAIN}"
