# Inception-of-Things

Introduction to Kubernetes with K3s, K3d, Vagrant and Argo CD (subject in `docs/subjects/`).

## Host, hypervisor and Vagrant provider

The subject lets us pick the tools for the host machine and the Vagrant provider. Our choice:

| Item | Choice |
|------|--------|
| Host | Homelab, Ubuntu 24.04, x86_64 with VT-x, 3.5 GiB of RAM (bare metal, reached over SSH) |
| Hypervisor | VirtualBox 7.0.x on the host |
| Vagrant provider | `virtualbox` (Vagrant 2.4.x) |

Why:

- **VirtualBox over libvirt/KVM.** It is the provider used in the subject's example, and the evaluation usually runs VirtualBox. One provider means one path to test. The Debian project only publishes a libvirt box, so we build our own VirtualBox box (see `docs/p1.md`).
- **No nested virtualization.** The VMs run directly on the homelab, so nothing depends on a hypervisor inside another VM.
- **Fits the memory.** P1 is 2 VMs of 1 GB each. The worker can drop to 512 MB if the host gets tight once K3s is installed.
- **x86_64 only.** VirtualBox does not run x86 guests on Apple Silicon. The Debian box is amd64, so there is no ARM path.

Exception: a laptop with Apple Silicon (arm64) cannot run `vagrant up` for this project. Work from that machine goes through SSH to the homelab (`docs/p1.md`, "Rodando num host remoto"). Any other team member needs an x86_64 machine with VT-x and VirtualBox to reproduce it.

## Layout

Each part has a `scripts/` folder (install/setup scripts) and a `confs/` folder (configuration files).

| Folder | Part | What it does | Requirements |
|--------|------|--------------|--------------|
| `p1/` | K3s and Vagrant | 2 Debian 13 VMs (Server + ServerWorker), K3s controller and agent | Vagrant, VirtualBox (Packer only to rebuild the box) |
| `p2/` | K3s and three apps | 1 VM, K3s server, 3 apps behind an Ingress (by `HOST`) | Vagrant, VirtualBox |
| `p3/` | K3d and Argo CD | K3d cluster, Argo CD, app in namespace `dev` deployed from GitHub (no Vagrantfile) | Docker, K3d, kubectl |
| `bonus/` | GitLab (optional) | Local GitLab in namespace `gitlab`, feeding the Part 3 flow | Helm, everything from p3 |

## Order to run

Do the parts in order: `p1` → `p2` → `p3` → `bonus`.

1. **p1**: `cd p1 && vagrant up` (downloads the prebuilt Debian box from a GitHub Release; `./scripts/build.sh` rebuilds it, see `docs/p1.md`)
2. **p2**: `cd p2 && vagrant up` (TBD)
3. **p3**: `cd p3 && ./scripts/<install>.sh` (TBD)
4. **bonus**: `cd bonus && ./scripts/<install>.sh` (TBD, only after the mandatory part is flawless)

Detailed instructions for each part will be added as they are implemented.
