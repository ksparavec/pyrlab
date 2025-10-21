# Podman Support

## Overview

PyRLab now supports both Docker and Podman as container runtimes. You can choose your preferred runtime by setting the `CONTAINER_RUNTIME` variable in `Configuration.mk`.

## What is Podman?

[Podman](https://podman.io/) is a daemonless container engine for developing, managing, and running OCI containers on Linux. It's designed as a drop-in replacement for Docker with enhanced security features.

## Key Differences from Docker

| Feature | Docker | Podman |
|---------|--------|--------|
| **Daemon** | Requires dockerd daemon | Daemonless (fork-exec model) |
| **Root privileges** | Daemon runs as root | Rootless mode by default |
| **Security** | Single point of failure (daemon) | Better isolation |
| **Pods** | No native support | Native pod support (Kubernetes-compatible) |
| **CLI** | docker command | podman command (compatible syntax) |
| **systemd** | Limited integration | Native systemd integration |
| **License** | Apache 2.0 | Apache 2.0 |

## Configuration

### Selecting Container Runtime

Edit `Configuration.mk`:

```makefile
# OPTIONAL: Container runtime (select from: docker podman)
CONTAINER_RUNTIME := podman
```

Default is `docker`. Change to `podman` to use Podman instead.

### Installation

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y podman
```

#### Fedora/RHEL/CentOS
```bash
sudo dnf install -y podman
```

#### Verify Installation
```bash
podman --version
```

## GPU Support with Podman

### NVIDIA GPU Passthrough

Podman uses a different mechanism than Docker for GPU access. Two options:

#### Option 1: CDI (Container Device Interface) - Recommended

Install nvidia-container-toolkit:
```bash
# Ubuntu/Debian
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Generate CDI spec
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

Update `Configuration.mk`:
```makefile
# For Podman with CDI
DOCKER_ARGS := --device nvidia.com/gpu=all
```

#### Option 2: Direct Device Mounting

Update `Configuration.mk`:
```makefile
# For Podman with direct device mounting
DOCKER_ARGS := --device /dev/nvidia0 --device /dev/nvidia-modeset --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl
```

Or mount all NVIDIA devices:
```makefile
DOCKER_ARGS := $(shell ls /dev/nvidia* | sed 's/^/--device /')
```

### Verify GPU Access

```bash
# Build and run PyRLab with Podman
make CONTAINER_RUNTIME=podman build_base
make CONTAINER_RUNTIME=podman build_pylab-mini
make CONTAINER_RUNTIME=podman tag_pylab PYLAB=mini
make CONTAINER_RUNTIME=podman pylab

# In another terminal, exec into container
podman exec -it pylab_3.12-bullseye_8888 bash

# Inside container, verify GPU
nvidia-smi
```

## Rootless vs Rootful Mode

### Rootless Mode (Default)

Podman runs without root privileges by default. This is more secure but has some limitations:

**Advantages:**
- No root daemon
- Better security isolation
- Each user has their own containers

**Limitations:**
- UID/GID mapping can be complex
- Port binding <1024 requires special setup
- Some volume mount permissions may differ

**Setup for PyRLab:**

Check your UID/GID mappings:
```bash
cat /etc/subuid
cat /etc/subgid
```

Ensure your user has sufficient mappings (at least 65536 UIDs/GIDs).

### Rootful Mode

If you need Docker-compatible behavior, run Podman as root:

```bash
sudo podman build ...
sudo podman run ...
```

Or use the Makefile with sudo:
```bash
sudo make CONTAINER_RUNTIME=podman build
```

## Volume Mounting

Podman volume syntax is identical to Docker:

```bash
-v ${NOTEBOOKS}:/volumes/notebooks
-v ${DOCKER}:/notebook
```

### SELinux Considerations

On systems with SELinux (RHEL, Fedora, CentOS), you may need to add `:z` or `:Z` flags:

```bash
-v ${NOTEBOOKS}:/volumes/notebooks:z    # Shared volume
-v ${DOCKER}:/notebook:Z                # Private volume
```

Update `Makefile` if needed:
```makefile
pylab_start:
	${CONTAINER_RUNTIME} run \
    ... \
    -v ${NOTEBOOKS}:/volumes/notebooks:z \
    -v ${DOCKER}:/notebook:z \
    ...
```

## Port Mapping

Port mapping syntax is identical to Docker:

```bash
-p 8888:8888    # JupyterLab
-p 6006:6006    # TensorBoard
-p 40000:40000  # D-Tale
```

### Binding Privileged Ports (<1024) in Rootless Mode

If you need to bind ports <1024 without root:

```bash
sudo sysctl net.ipv4.ip_unprivileged_port_start=80
```

Or make it permanent:
```bash
echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-unprivileged-ports.conf
sudo sysctl --system
```

## Build Performance

### Build Cache

Podman uses different cache locations than Docker:

```bash
# Rootless
~/.local/share/containers/storage

# Rootful
/var/lib/containers/storage
```

### Clear Podman Cache

```bash
# Using Makefile
make CONTAINER_RUNTIME=podman cache_clean

# Or directly
podman system prune -af
```

## Pod Support (Advanced)

Podman supports native pods (similar to Kubernetes). You could run JupyterLab + TensorBoard in one pod:

```bash
# Create a pod
podman pod create --name pylab-pod -p 8888:8888 -p 6006:6006

# Run containers in the pod
podman run -d --pod pylab-pod --name jupyter pylab:latest
podman run -d --pod pylab-pod --name tensorboard tensorflow/tensorflow tensorboard --logdir=/logs
```

*Note: Current PyRLab Makefile doesn't use pods, but you can extend it*

## Compatibility Matrix

| Feature | Docker | Podman | Notes |
|---------|--------|--------|-------|
| Build | ✅ | ✅ | Identical syntax |
| Run | ✅ | ✅ | Identical syntax |
| GPU (NVIDIA) | ✅ | ✅ | Different setup (CDI) |
| Volume mounts | ✅ | ✅ | May need SELinux flags |
| Port mapping | ✅ | ✅ | Rootless <1024 requires config |
| buildx | ✅ | ⚠️ | Use `podman build` instead |
| Compose | ✅ | ✅ | Via podman-compose |

## Switching Between Docker and Podman

### Quick Switch

Build with Docker:
```bash
make CONTAINER_RUNTIME=docker build
```

Build with Podman:
```bash
make CONTAINER_RUNTIME=podman build
```

### Permanent Switch

Edit `Configuration.mk`:
```makefile
CONTAINER_RUNTIME := podman
```

Then use normal make commands:
```bash
make build
make pylab
```

## Troubleshooting

### "command not found: podman"
Install Podman:
```bash
sudo apt-get install podman  # Ubuntu/Debian
sudo dnf install podman       # Fedora/RHEL
```

### GPU not detected
Verify CDI setup:
```bash
nvidia-ctk cdi list
podman run --rm --device nvidia.com/gpu=all ubuntu nvidia-smi
```

### Permission denied on volumes
Add SELinux flags:
```bash
-v /path:/mount:z
```

Or disable SELinux (not recommended):
```bash
sudo setenforce 0
```

### Port already in use
Check for existing containers:
```bash
podman ps -a
podman stop <container-id>
```

## Migration Checklist

- [ ] Install Podman
- [ ] Install nvidia-container-toolkit (if using GPU)
- [ ] Generate CDI spec for NVIDIA GPUs
- [ ] Update `CONTAINER_RUNTIME` in Configuration.mk
- [ ] Update `DOCKER_ARGS` for GPU access
- [ ] Test build: `make build_base`
- [ ] Test run: `make pylab`
- [ ] Verify GPU: `podman exec <container> nvidia-smi`
- [ ] Update CI/CD if applicable

## Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Podman vs Docker](https://docs.podman.io/en/latest/markdown/podman.1.html#podman-vs-docker)
- [NVIDIA Container Toolkit for Podman](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html)
- [Rootless Containers](https://rootlesscontaine.rs/)
