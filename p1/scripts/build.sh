#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

command -v packer >/dev/null || { echo "packer not found: install it first (see docs/p1.md)" >&2; exit 1; }

packer init confs/packer/debian-13.pkr.hcl
packer build -force confs/packer/debian-13.pkr.hcl

vagrant box remove --force --all debian13 2>/dev/null || true
