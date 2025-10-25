# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PyRLab is a Docker-based system for building Python/R JupyterLab containers with pre-installed scientific computing packages. It builds hierarchical Docker images starting from base Python images and extending them with various ML/AI frameworks (TensorFlow, PyTorch, JAX).

## Essential Commands

### Building Images
```bash
# Build all images (base, PyLab variants, RLab)
make build

# Build specific PyLab variants
make build_pylab-mini     # Minimal JupyterLab setup
make build_pylab-common   # Common data science packages
make build_pylab-tf       # TensorFlow variant
make build_pylab-torch    # PyTorch variant  
make build_pylab-jax      # JAX variant

# Tag a specific PyLab variant as default
make tag_pylab PYLAB=torch  # torch, tf, jax, common, mini
```

### Running Containers
```bash
# Start PyLab container (uses tagged variant)
make pylab

# Start/stop specific services
make pylab_start
make pylab_stop
make pylab_restart

# Start RLab container
make rlab
```

### Cleanup
```bash
make clean          # Remove all images and build cache
make image_clean     # Remove built images only
make cache_clean     # Remove Docker build cache only
```

## Configuration

Primary configuration is in `Configuration.mk`:
- `PYTHONBASE`: Base Python image tag (e.g., `3.12-bullseye`)
- `PYLAB`: Default PyLab variant (`mini`, `common`, `torch`, `tf`, `jax`)
- `NOTEBOOKS`: Host directory mounted as `/volumes/notebooks`
- `DOCKER`: Host directory mounted as `/notebook`
- `CUDA_INSTALL`: Enable CUDA support (`yes`/`no`)
- `*PORT`: Port mappings for services (JupyterLab: 8888, TensorBoard: 6006, etc.)

## Architecture

### Image Hierarchy
```
python (base) → pyrlab-base → pylab-mini → pylab-common → [pylab-tf, pylab-torch, pylab-jax]
                            ↘ rlab-base → rlab
```

### Key Components
- **Dockerfiles**: Located in `docker/` directory, each builds one layer
- **Requirements**: Python packages defined in `pylab/requirements_*.txt`
- **Scripts**: Build and runtime scripts in `sbin/`
- **Configuration**: Package lists in `base/`, `pylab/`, `rlab/` directories

### Build Process
1. Images built in strict dependency order
2. Each Dockerfile uses embedded bash scripts with `init_lab.sh`
3. Failed builds cache intermediate layers for faster rebuilds
4. All Python packages installed via `pip_install` function

## Development Workflow

### Adding Python Packages
1. Edit appropriate requirements file in `pylab/`:
   - `requirements_mini.txt`: Minimal JupyterLab packages
   - `requirements_common.txt`: Common data science packages
   - `requirements_tf.txt`: TensorFlow-specific packages
   - `requirements_torch.txt`: PyTorch-specific packages
   - `requirements_jax.txt`: JAX-specific packages

2. Rebuild affected images:
   ```bash
   make build_pylab-common  # if editing requirements_common.txt
   make build_pylab-torch   # if editing requirements_torch.txt
   ```

### Testing Changes
- Access containers via browser at `http://127.0.0.1:8888/lab`
- Check build logs at `/tmp/pyrlab_[timestamp].log`
- Use `docker logs pylab_[version]_[port]` for runtime logs

### Docker Compose Support
Alternative to Make commands using `docker/compose.yml`:
```bash
docker-compose up pylab    # Start PyLab service
docker-compose build       # Build all services
```

## Key Files

- `Makefile`: Main build orchestration
- `Configuration.mk`: Build parameters and settings
- `sbin/jupyterlab.sh`: Container startup script
- `docker/Dockerfile.*`: Image build definitions
- `pylab/requirements_*.txt`: Python package specifications
- `doc/Architecture.md`: Detailed architecture documentation

## Security Notes

- Build phase runs as `root`, runtime as `notebook` user
- `notebook` user has sudo privileges (remove for production in `Dockerfile.Base`)
- For remote access, remove `--LabApp.token=''` from `sbin/jupyterlab.sh`
- Environment variables can be sourced from `ENVVARS` file path

## Monitoring Build Progress

```bash
# Follow build logs in real-time
tail -f /tmp/pyrlab_$(date +"%F_%T").log

# Check Docker images
docker images | grep pylab
```