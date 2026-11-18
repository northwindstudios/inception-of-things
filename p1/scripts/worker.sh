#!/usr/bin/env bash
set -euo pipefail

: "${K3S_TOKEN:?K3S_TOKEN is not set}"

dest=/etc/rancher/k3s/join-token

mkdir -p /etc/rancher/k3s

if [ "$(cat "$dest" 2>/dev/null)" != "$K3S_TOKEN" ]; then
  (umask 077; printf '%s\n' "$K3S_TOKEN" > "$dest")
fi
chmod 600 "$dest"

echo "join token stored in $dest (sha256 $(printf '%s' "$K3S_TOKEN" | sha256sum | cut -c1-8))"
echo "worker provisioned on $(hostname)"
