#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="root"
REMOTE_HOST="31.58.245.116"
REMOTE_PORT="22"
REMOTE_PATH="/home/tissuecarebiotech"

cd "$(dirname "$0")"

rsync -avz --delete \
  --chmod=D755,F644 \
  --exclude ".git" \
  --exclude ".gitignore" \
  --exclude "deploy.sh" \
  --exclude "deploy/" \
  -e "ssh -p ${REMOTE_PORT}" \
  ./ "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo "Deploy tamamlandı: https://tissuecarebiotech.com"
