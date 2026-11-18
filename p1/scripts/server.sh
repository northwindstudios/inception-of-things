#!/usr/bin/env bash
set -euo pipefail

: "${NODE_IP:?NODE_IP is not set}"
: "${K3S_VERSION:?K3S_VERSION is not set}"
: "${K3S_TOKEN:?K3S_TOKEN is not set}"

IFACE=$(ip -o -4 addr show | awk -v ip="$NODE_IP" '$4 ~ "^"ip"/" {print $2}')
[ -n "$IFACE" ] || { echo "no interface has $NODE_IP" >&2; exit 1; }

mkdir -p /etc/rancher/k3s
CONFIG=$(cat <<YAML
node-ip: $NODE_IP
advertise-address: $NODE_IP
flannel-iface: $IFACE
write-kubeconfig-mode: "0644"
token: $K3S_TOKEN
YAML
)

changed=0
if [ "$(cat /etc/rancher/k3s/config.yaml 2>/dev/null)" != "$CONFIG" ]; then
  (umask 077; echo "$CONFIG" > /etc/rancher/k3s/config.yaml)
  changed=1
fi
chmod 600 /etc/rancher/k3s/config.yaml

if ! command -v k3s >/dev/null || ! k3s --version | grep -qF "$K3S_VERSION"; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" INSTALL_K3S_EXEC="server" sh -
elif [ "$changed" = 1 ]; then
  systemctl restart k3s
fi

NODE_NAME=$(hostname | tr '[:upper:]' '[:lower:]')

for _ in $(seq 1 90); do
  if [ -s /var/lib/rancher/k3s/server/node-token ] \
     && k3s kubectl get node "$NODE_NAME" 2>/dev/null | grep -qw Ready; then
    k3s kubectl get nodes -o wide
    exit 0
  fi
  sleep 2
done

echo "k3s server not ready after 180s" >&2
systemctl status k3s --no-pager >&2 || true
exit 1
