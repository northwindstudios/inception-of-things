#!/usr/bin/env bash
set -euo pipefail

cat > /etc/ssh/sshd_config.d/10-iot.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
EOF

passwd -l vagrant

sshd -t
systemctl reload ssh
