## NVIDIA GPU hardware support

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
ENV CUDA_KRP_URL=https://developer.download.nvidia.com/compute/cuda/repos
ENV CUDA_URL=http://HTTPS///developer.download.nvidia.com/compute/cuda/repos
```

Note that https URL appears twice: once to install keyring (without local caching) and then to install the packages (with local caching). See [Proxy document](Proxy.md) for more information on https configuration used with `apt-cache-ng` package. If you want or must use different proxy software, you might need to convert the http URLs with special HTTPS/// syntax back to original https scheme. This generally means no caching support, however, some transparent proxies might do caching. This is usually the case in enterprise environments where forward proxies generate fake certificates signed by local authority on the fly.

The second parameter above (`DOCKER_ARGS`) is used when starting container with GPU support. Please note that in order for NVIDIA GPU support to work in container, you need to install NVIDIA kernel module on your host, and then configure `dockerd` using NVIDIA container toolkit afterwards. NVIDIA provides very detailed high quality documentation how to do that on all major Linux distributions:

* https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html (NVIDIA CUDA Installation Guide for Linux)
* https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.14.5/install-guide.html (Installing the NVIDIA Container Toolkit)

Please note that if you are a developer without necessary system administration experience or you don't even have administrative access to host, you will definitely need support from your system administration to get this running.

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

If you obtain any kind of error instead of output similar to the one shown above, you will need to debug where the issue is. You can try following steps in order:

1. Restart your container by executing `docker stop <container name>` followed by `make pylab` or `make rlab`. Watch for eventual errors with `docker logs <container name>`

2. Restart `dockerd` on host by executing `systemctl restart docker.service`. Watch for status and eventual errors with `journalctl _SYSTEMD_UNIT=docker.service`

3. Make sure that you have NVIDIA support on host by executing `nvidia-smi` on host itself

4. Make sure that you have working NVIDIA native kernel module on host by executing `lsmod` on host:

```
$ lsmod | grep ^nvidia
nvidia_uvm           4632576  0
nvidia_drm             94208  2
nvidia_modeset       1347584  2 nvidia_drm
nvidia              54054912  37 nvidia_uvm,nvidia_modeset
```

If you have professional system administration support, you will probably just do step 1, and if it does not help, leave the rest to it.

Another way to test GPU working in container without building it yourself is downloading Docker container from Docker Hub or from NGC built by NVIDIA engineers:

* https://hub.docker.com/r/nvidia/cuda (NVIDIA CUDA on Docker Hub)
* https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda (NVIDIA CUDA on NGC)

Note that some Python modules have CUDA support builtin. This is especially the case for current versions of TensorFlow and Torch. Both modules will automatically detect GPU and use it if present or fail back to CPU otherwise. Some modules still require specific version installed like Jax for example. See [Imaging document](Image.md) for more information on the last module and how to use it within PyrLab framework.

