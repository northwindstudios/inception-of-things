# Inception-of-Things

Introduction to Kubernetes with K3s, K3d, Vagrant and Argo CD (subject in `docs/subjects/`).

## Layout

Each part has a `scripts/` folder (install/setup scripts) and a `confs/` folder (configuration files).

| Folder | Part | What it does | Requirements |
|--------|------|--------------|--------------|
| `p1/` | K3s and Vagrant | 2 VMs (Server + ServerWorker), K3s controller and agent | Vagrant, VirtualBox |
| `p2/` | K3s and three apps | 1 VM, K3s server, 3 apps behind an Ingress (by `HOST`) | Vagrant, VirtualBox |
| `p3/` | K3d and Argo CD | K3d cluster, Argo CD, app in namespace `dev` deployed from GitHub (no Vagrantfile) | Docker, K3d, kubectl |
| `bonus/` | GitLab (optional) | Local GitLab in namespace `gitlab`, feeding the Part 3 flow | Helm, everything from p3 |

## Order to run

Do the parts in order: `p1` → `p2` → `p3` → `bonus`.

1. **p1**: `cd p1 && vagrant up` (TBD)
2. **p2**: `cd p2 && vagrant up` (TBD)
3. **p3**: `cd p3 && ./scripts/<install>.sh` (TBD)
4. **bonus**: `cd bonus && ./scripts/<install>.sh` (TBD, only after the mandatory part is flawless)

Detailed instructions for each part will be added as they are implemented.
