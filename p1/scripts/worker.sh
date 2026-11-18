#!/usr/bin/env bash
set -euo pipefail

: "${NODE_IP:?NODE_IP is not set}"
: "${SERVER_IP:?SERVER_IP is not set}"
: "${K3S_VERSION:?K3S_VERSION is not set}"
: "${K3S_TOKEN:?K3S_TOKEN is not set}"

dest=/etc/rancher/k3s/join-token

mkdir -p /etc/rancher/k3s

if [ "$(cat "$dest" 2>/dev/null)" != "$K3S_TOKEN" ]; then
  (umask 077; printf '%s\n' "$K3S_TOKEN" > "$dest")
fi
chmod 600 "$dest"

echo "join token stored in $dest (sha256 $(printf '%s' "$K3S_TOKEN" | sha256sum | cut -c1-8))"

IFACE=$(ip -o -4 addr show | awk -v ip="$NODE_IP" '$4 ~ "^"ip"/" {print $2}')
[ -n "$IFACE" ] || { echo "no interface has $NODE_IP" >&2; exit 1; }

CONFIG=$(cat <<YAML
server: https://$SERVER_IP:6443
token-file: $dest
node-ip: $NODE_IP
flannel-iface: $IFACE
YAML
)

changed=0
if [ "$(cat /etc/rancher/k3s/config.yaml 2>/dev/null)" != "$CONFIG" ]; then
  (umask 077; echo "$CONFIG" > /etc/rancher/k3s/config.yaml)
  changed=1
fi
chmod 600 /etc/rancher/k3s/config.yaml

deadline=$((SECONDS + 180))
until curl -ksf --max-time 5 "https://$SERVER_IP:6443/cacerts" >/dev/null; do
  if [ "$SECONDS" -ge "$deadline" ]; then
    echo "k3s server API not answering at $SERVER_IP:6443 after 180s" >&2
    exit 1
  fi
  sleep 2
done

if ! command -v k3s >/dev/null || ! k3s --version | grep -qF "$K3S_VERSION"; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" INSTALL_K3S_EXEC="agent" INSTALL_K3S_SKIP_START=true sh -
  systemctl start --no-block k3s-agent
elif [ "$changed" = 1 ]; then
  systemctl restart --no-block k3s-agent
fi

for _ in $(seq 1 90); do
  if systemctl is-active --quiet k3s-agent; then
    echo "k3s agent running on $(hostname), joined $SERVER_IP"
    exit 0
  fi
  sleep 2
done

echo "k3s agent not ready after 180s" >&2
systemctl status k3s-agent --no-pager >&2 || true
exit 1
