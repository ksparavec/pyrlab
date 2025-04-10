## NVIDIA GPU hardware support

## Host considerations

Before you can use GPU support in containers, you need to ensure your host system is properly configured. Here are the key requirements:

1. **Hardware Requirements**:
   - NVIDIA GPU with CUDA support
   - Sufficient system memory (RAM)
   - Adequate power supply for the GPU

2. **Software Requirements**:
   - Linux operating system (Ubuntu, Debian, CentOS, etc.)
   - NVIDIA drivers installed
   - Docker engine
   - NVIDIA Container Toolkit

3. **System Configuration**:
   - The host must have the NVIDIA kernel module loaded
   - Docker daemon must be configured to use NVIDIA runtime
   - Proper permissions must be set for GPU access

4. **Performance Considerations**:
   - Ensure the host has enough CPU resources to feed the GPU
   - Monitor system temperature and cooling
   - Consider using a dedicated GPU for container workloads

5. **Security Considerations**:
   - Only trusted containers should be given GPU access
   - Monitor GPU usage to prevent resource exhaustion
   - Consider using GPU isolation features if available

For detailed instructions on setting up your host system, please refer to the NVIDIA documentation:
* https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
* https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.14.5/install-guide.html

Please note that if you are a developer without necessary system administration experience or you don't even have administrative access to host, you will definitely need support from your system administration to get this running.

NVIDIA GPU hardware is explicitly supported in both PyLab and RLab images. Whether support is built into the image is controlled via parameters in `Configuration.mk`:

```
CUDA_INSTALL := yes
DOCKER_ARGS  := --runtime=nvidia --gpus all
```

`CUDA_INSTALL` parameter is referenced in Dockerfiles where necessary. If set to "yes", NVIDIA Apt repository will be configured and `cuda` meta-package installed. This will pull in diverse packages from NVIDIA Apt repository. Be aware that CUDA packages will increase base image size by about 8GB. Specific CUDA parameters necessary to install the software are defined on top of `Dockerfile.Base`:

```
ENV CUDA_ARCH=x86_64
ENV CUDA_DEB=debian11
ENV CUDA_KRP=cuda-keyring_1.1-1_all.deb
ENV CUDA_URL=https://developer.download.nvidia.com/compute/cuda/repos
```

Note that https URL appears twice: once to install keyring (without local caching) and then to install the packages (with local caching). See [Proxy document](Proxy.md) for more information on https configuration used with `apt-cache-ng` package. If you want or must use different proxy software, you might need to convert the http URLs with special HTTPS/// syntax back to original https scheme. This generally means no caching support, however, some transparent proxies might do caching. This is usually the case in enterprise environments where forward proxies generate fake certificates signed by local authority on the fly.

The second parameter above (`DOCKER_ARGS`) is used when starting container with GPU support. Please note that in order for NVIDIA GPU support to work in container, you need to install NVIDIA kernel module on your host, and then configure `dockerd` using NVIDIA container toolkit afterwards. NVIDIA provides very detailed high quality documentation how to do that on all major Linux distributions:

* https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html (NVIDIA CUDA Installation Guide for Linux)
* https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.14.5/install-guide.html (Installing the NVIDIA Container Toolkit)

Once containers have been built and started, you can check whether you have usable GPU support within container by executing `nvidia-smi` CLI tool:

```
$ nvidia-smi 
Thu Mar 14 14:18:07 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.54.14              Driver Version: 550.54.14      CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce GTX 1650        On  |   00000000:01:00.0 Off |                  N/A |
| N/A   52C    P8              1W /   50W |       4MiB /   4096MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
+-----------------------------------------------------------------------------------------+
```

If you see similar output, then your GPU is properly configured and ready to use. You can now use GPU-accelerated libraries like TensorFlow, PyTorch, or JAX in your notebooks. Each of these frameworks has its own way of detecting and using GPUs:

* TensorFlow: `tf.config.list_physical_devices('GPU')`
* PyTorch: `torch.cuda.is_available()`
* JAX: `jax.devices('gpu')`

Note that some frameworks may require additional configuration or environment variables to work properly with GPUs. For example, TensorFlow may need `TF_FORCE_GPU_ALLOW_GROWTH=true` to prevent memory allocation issues.

Also note that different image flavors (torch, tf, jax) may have different CUDA and cuDNN versions installed, as they are optimized for their respective frameworks. If you need to use multiple frameworks, you may need to use different containers or carefully manage the versions to ensure compatibility.

