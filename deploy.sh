#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="root"
REMOTE_HOST="31.58.245.116"
REMOTE_PORT="22"
REMOTE_PATH="/home/tissuecarebiotech"

ssh -p "${REMOTE_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" \
  "cd ${REMOTE_PATH} && git pull"

echo "Deploy tamamlandı: https://tissuecarebiotech.com"
