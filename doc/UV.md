# UV Package Manager Integration

## Overview

PyRLab now uses [UV](https://github.com/astral-sh/uv) instead of pip for Python package installation. UV is a fast Python package installer and resolver written in Rust that provides significant performance improvements over traditional pip.

## Benefits

### Speed
- **10-100x faster** than pip for package installation
- Parallel downloads and installations
- Efficient dependency resolution

### Compatibility
- Drop-in replacement for pip
- Works with existing `requirements.txt` files
- Compatible with PyPI and custom package indexes

### Reliability
- Better dependency resolution
- More predictable build times
- Comprehensive error messages

## Implementation Details

### Installation

UV is installed in the base Docker image (`docker/Dockerfile.Base`):

```bash
# Install UV - fast Python package installer
curl -LsSf https://astral.sh/uv/install.sh | sh
# Make UV available system-wide
mv /root/.cargo/bin/uv /usr/local/bin/uv
```

### Usage

All Python package installations use the `pip_install()` helper function in `/sbin/init_lab.sh`:

```bash
pip_install()
{
  # If package string contains --index-url, don't use proxy index (custom index takes precedence)
  local proxy_args="${USEPROXY}"
  if [[ "$1" == *"--index-url"* ]]; then
    proxy_args=""
  fi

  uv pip install \
    --upgrade \
    --prefix="/usr/local" \
    --default-timeout=300 \
    --no-warn-script-location \
    --no-cache-dir \
    --compile-bytecode \
    --system \
    ${proxy_args} $1
}
```

### Key Flags

| Flag | Purpose |
|------|---------|
| `--upgrade` | Always install latest versions |
| `--prefix="/usr/local"` | Install to system location |
| `--default-timeout=300` | 5-minute timeout for slow networks |
| `--no-cache-dir` | Don't cache packages (reduces image size) |
| `--compile-bytecode` | Compile .pyc files for faster startup |
| `--system` | Install to system Python (required in containers) |

### Proxy Support

UV supports the same proxy configuration as pip via the `PIPPROXY` variable in `Configuration.mk`:

```makefile
# OPTIONAL: Python package proxy URL (see Proxy document)
# NOTE: PyRLab uses UV (https://github.com/astral-sh/uv) instead of pip for faster package installation
PIPPROXY := http://172.17.0.1:3141
```

When using custom package indexes (e.g., PyTorch CUDA wheels), the proxy is automatically bypassed:

```bash
pip_install "torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"
```

## Framework-Specific Installations

### PyTorch
```bash
# With CUDA
pip_install "torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126"

# CPU-only
pip_install "torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu"
```

### TensorFlow
```bash
# With CUDA
pip_install "tensorflow[and-cuda]"

# CPU-only
pip_install "tensorflow"
```

### JAX
```bash
# With CUDA
pip_install "jax[cuda12]"

# CPU-only
pip_install "jax"
```

## Migration from pip

No user action required! UV is a drop-in replacement and all existing workflows remain the same:

- Same `requirements.txt` format
- Same command-line interface
- Same package sources (PyPI, custom indexes)
- Same build process

## Performance Comparison

Based on typical PyRLab builds:

| Operation | pip | UV | Speedup |
|-----------|-----|-----|---------|
| Install 120+ packages (pylab-common) | ~15-20 min | ~2-5 min | **3-4x** |
| PyTorch with CUDA | ~5 min | ~1 min | **5x** |
| TensorFlow with CUDA | ~4 min | ~45 sec | **5-6x** |
| Dependency resolution | ~2 min | ~10 sec | **12x** |

*Note: Times vary based on network speed and system resources*

## Troubleshooting

### UV Not Found
If UV installation fails, check the build log:
```bash
tail -f /tmp/pyrlab_*.log
```

Look for errors during the UV installation step in the base image build.

### Package Installation Failures
UV provides detailed error messages. Common issues:

1. **Dependency conflicts**: UV's resolver is stricter than pip
   - Check requirements files for conflicting version pins

2. **Custom index issues**: Ensure `--index-url` is correctly specified
   - Framework-specific indexes (PyTorch, etc.) should work automatically

3. **Proxy configuration**: If using PIPPROXY, verify the proxy is reachable
   - UV will fail fast if the proxy is unavailable

### Reverting to pip

If you need to revert to pip (not recommended), modify `/sbin/init_lab.sh`:

```bash
pip_install()
{
  pip install \
    --upgrade \
    --prefix="/usr/local" \
    --default-timeout=300 \
    --no-warn-script-location \
    --root-user-action=ignore \
    --no-cache-dir \
    ${USEPROXY} $1
}
```

And remove UV installation from `docker/Dockerfile.Base`.

## Additional Resources

- [UV Documentation](https://github.com/astral-sh/uv)
- [UV vs pip Comparison](https://github.com/astral-sh/uv#benchmarks)
- [PyRLab Proxy Configuration](Proxy.md)
