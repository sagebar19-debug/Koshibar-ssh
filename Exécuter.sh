#!/bin/bash

set -e

BASE="/Koshibar/100%"

echo "======================================"
echo "       KOSHIBAR-SSH"
echo "======================================"
echo "[INFO] Initialisation..."

mkdir -p /run/sshd
mkdir -p "$BASE/data/home"

# Création de l'utilisateur SSH
if ! id "${SSH_USER}" >/dev/null 2>&1; then
    echo "[INFO] Création de l'utilisateur ${SSH_USER}"

    useradd \
        -m \
        -d "/home/${SSH_USER}" \
        -s /bin/bash \
        "${SSH_USER}"
fi

# Définition du mot de passe
echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd

# Préparation du dossier personnel
mkdir -p "/home/${SSH_USER}"
chown -R "${SSH_USER}:${SSH_USER}" "/home/${SSH_USER}"

echo "[INFO] Démarrage SSH..."
/usr/sbin/sshd

echo "[INFO] Démarrage Stunnel..."
stunnel "$BASE/Stunnel.conf"

echo "[INFO] Démarrage Proxy3..."
exec node "$BASE/Proxy3.js"
