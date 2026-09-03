#!/bin/bash

set -e

BASE="/Koshibar/100%"

echo "======================================"
echo "       KOSHIBAR-SSH"
echo "======================================"
echo "[INFO] Initialisation..."

mkdir -p /run/sshd
mkdir -p "$BASE/data/home"

SSH_USER="${SSH_USER:-koshibar}"
SSH_PASSWORD="${SSH_PASSWORD:-CHANGE-ME}"

PORT="${PORT:-8080}"
DHOST="${DHOST:-127.0.0.1}"
DPORT="${DPORT:-22}"

echo "[INFO] SSH_USER=$SSH_USER"
echo "[INFO] SSH backend=$DHOST:$DPORT"
echo "[INFO] HTTP/WebSocket PORT=$PORT"

if ! id "$SSH_USER" >/dev/null 2>&1; then
    echo "[INFO] Création de l'utilisateur $SSH_USER"

    useradd \
        -m \
        -d "/home/$SSH_USER" \
        -s /bin/bash \
        "$SSH_USER"
fi

echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

mkdir -p "/home/$SSH_USER"
chown -R "$SSH_USER:$SSH_USER" "/home/$SSH_USER"

echo "[INFO] Vérification de la configuration SSH..."

/usr/sbin/sshd -t

echo "[INFO] Démarrage SSH..."

/usr/sbin/sshd

echo "[INFO] Vérification du port SSH..."

if ! (echo >/dev/tcp/127.0.0.1/22) 2>/dev/null; then
    echo "[ERROR] SSH n'écoute pas sur le port 22"
    exit 1
fi

echo "[INFO] Démarrage Proxy3..."

export PORT
export DHOST
export DPORT

exec node "$BASE/Proxy3.js"
