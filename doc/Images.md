## Docker image structure

Docker images are created in hierarchical fashion starting from base image. As base image, [current Python image from Docker Hub][1] is used. Current full image inheritance model is shown in figure below (example uses `3.11-bullseye` version).

![Docker image inheritance model!](model.svg)

Corresponding Dockerfiles are stored in `docker` subdirectory, whereas configuration files are stored in respective subdirectories, depending on whether they are base or application images and their flavor. Each image is generated from its own Dockerfile. Not all images are usable to run as container instances. Following table summarizes images, Dockerfiles and configuration file names as well as what is present in each image and whether it is meant to be run as container instance:


| Image name   | Dockerfile name         | Configuration file                                                                              | Image contents                                                                                                                                                                  | Container instance<br>to be created |
|--------------|-------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------:|
| python       | N/A                     | N/A                                                                                             | Debian base image with current basic Python modules                                                                                                                             |                  no                 |
| pyrlab-base  | Dockerfile.Base         | base/base_debs.txt                                                                              | python extended with additional Debian packages,<br>nodejs, google-chrome, and optional CUDA packages                                                                           |                  no                 |
| rlab-base    | Dockerfile.RBase        | rbase/r_debs.txt                                                                                | pyrlab-base extended with R Debian packages                                                                                                                                     |                  no                 |
| pylab-mini   | Dockerfile.PyLab-mini   | pylab/requirements_mini.txt                                                                     | pyrlab-base extended with minimal list of Python modules<br>so that JupyterLab can be started                                                                                   |                 yes                 |
| pylab-common | Dockerfile.PyLab-common | pylab/requirements_common.txt, <br>pylab/requirements_3.x.txt, <br>pylab/requirements_repos.txt | pylab-mini extended with common list of Python modules,<br>Python modules that are specific to Python major version,<br>and Python modules installed from external repositories |                 yes                 |
| pylab-tf     | Dockerfile.PyLab-tf     | pylab/requirements_tf.txt                                                                       | pylab-common extended with Tensorflow modules                                                                                                                                   |                 yes                 |
| pylab-torch  | Dockerfile.PyLab-torch  | pylab/requirements_torch.txt                                                                    | pylab-common extended with Torch and Peft modules                                                                                                                               |                 yes                 |
| pylab-jax    | Dockerfile.PyLab-jax    | pylab/requirements_jax.txt                                                                      | pylab-common extended with Jax modules                                                                                                                                          |                 yes                 |
| rlab         | Dockerfile.RLab         | rlab/r_requirements.txt,<br>rlab/r_packages.txt                                                 | rlab-base extended with JupyterLab and R modules                                                                                                                                |                 yes                 |


It should be clear from inheritance model and summary table that images are created in strictly ordered fashion: as soon as one of the images in structure is recreated, all images that follow, i.e. are inherited from it must be recreated as well. Inside each Dockerfile, RUN blocks are organized so that each block repsents one closed logical entity. Each RUN block is actually here-bash script that follows strict conventions:

```
#!/usr/bin/env bash
. /usr/local/sbin/init_lab.sh
# do something
```

After shebang line, first `/usr/local/sbin/init_lab.sh` gets sourced. It contains code to initialize `pip_install` shell wrapper function. All Python modules are installed with same pip command afterwards. This ensures consistency. With the exception of Jax module, all other Python modules are specified in their respective configuration files listed in table above. For Jax module, distinction must be made between CUDA and non-CUDA versions, therefore this logic is built into Dockerfile itself.

Apart from Dockerfiles and configuration files, there is a third place relevant to image build process: `Configuration.mk`. See [Configuration document](Configuration.md) for more information on parameters and [Architecture document](Architecture.md) for more information on container build and execution logic.

Careful reader should now be able to conclude that creating new PyLab Docker images involves three steps:

1. Create new Dockerfile by using any of current Dockerfile.Pylab versions as template
2. Create new configuration file(s) for Python modules as needed
3. Insert appropriate lines into Makefile for `docker build`

In case of RLab Docker images, Dockerfile.RLab needs to be copied and modified accordingly.

[1]: <https://hub.docker.com/_/python> (Docker Official Images for Python)
