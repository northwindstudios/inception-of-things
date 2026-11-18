#!/usr/bin/env bash
set -euo pipefail

command -v kubectl >/dev/null || { echo "kubectl not found: the K3s installer should have created it" >&2; exit 1; }

cat > /usr/local/bin/k <<'EOF'
#!/bin/sh
export KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
exec kubectl "$@"
EOF
chmod 755 /usr/local/bin/k

cat > /etc/profile.d/k3s-kubectl.sh <<'EOF'
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

case $- in
  *i*)
    if [ -n "${BASH_VERSION:-}" ] && declare -F __start_kubectl >/dev/null; then
      complete -o default -F __start_kubectl k
    fi
    ;;
esac
EOF

if [ -f /usr/share/bash-completion/bash_completion ]; then
  kubectl completion bash > /etc/bash_completion.d/kubectl
fi
