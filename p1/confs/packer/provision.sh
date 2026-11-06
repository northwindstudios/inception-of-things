#!/usr/bin/env bash
set -euo pipefail

install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
  -o /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

echo 'UseDNS no' > /etc/ssh/sshd_config.d/99-vagrant.conf

apt-get -y autoremove --purge
apt-get -y clean
rm -rf /var/lib/apt/lists/*
truncate -s 0 /etc/machine-id

dd if=/dev/zero of=/EMPTY bs=1M status=none || true
rm -f /EMPTY
sync
