## Configuration

There are several places to configure build and run process:

1. `Makefile` configuration block
2. `base/*.txt`, `rbase/*.txt`, `pylab/*.txt`, `rlab/*.txt` simple text configuration files
3. `docker/Dockerfile*` headers


### Makefile configuration block

This is the most important place to configure build and run process. Full list of configurable parameters:

```
# Base Python image tag (see https://hub.docker.com/_/python)
PYTHONBASE := 3.11-bullseye

# Default PyLab image flavor (select from: mini common torch jax)
PYLAB      := torch

# Install CUDA into base image? (optional)
CUDA_INSTALL := yes
DOCKER_ARGS  := --runtime=nvidia --gpus all

### Custom built image names
IMAGE      := pylab
RIMAGE     := rlab

### Default container ports
# pylab
PYPORT     := 8888
# D-Tale
DTPORT     := 40000
# tensorboard
TFPORT     := 6006
# rlab
RPORT      := 9999

### Default user scripts (optional)
# pylab rc
PYRCS      := pylab.sh
# rlab rc
RRCS       := rlab.sh
# jupyter lab start
USERLAB    := userlab.sh

### Notebooks and home directory of notebook user on host
NOTEBOOKS  := ${HOME}/notebooks
DOCKER     := ${HOME}/docker

### Default environment variables definitions in container (optional)
ENVVARS    := /notebook/.env

### Application proxies (optional)
# Apt proxy
APTPROXY   := "http://172.17.0.1:3142"
# Pip proxy
PIPPROXY   := "http://172.17.0.1:3141"
```

Most of parameters have been already commented in `Makefile` itself and/or should be self-explanatory. Unless you already have listeners running on some of the default ports, there is usually no reason to change them. Same goes for image names, optional default user scripts and environment variables file name. Most likely you will want/need to change: See [Install document](Install.md) for details on `ENVVARS` file.

* `PYTHONBASE`: specify base image. Python images from Docker Hub are good start, but you are free to use any other image that is based on Debian distribution. You may even just use standard Debian Docker image as base image, however, Python version there is rather outdated. You can also use your own image. See [Architecture document](Architecture.md) for the list of requirements in case you decide to go that path. Unless you are image developer, you will probably want to stick with default.

* `PYLAB`: this is just selector for `pylab` image flavor. You can currently choose between 'mini', 'common', 'torch' and 'jax'. Most complete is 'torch'. You may want to select 'jax' if you need latest jax version with CUDA support. Alternatively you could decide to start with 'mini' version and then build incrementaly your own package list.

* `CUDA_INSTALL`: Whether or not install CUDA support into base image. See [GPU document](GPU.md) for details.

* `DOCKER_ARGS`: Additional arguments for docker when using CUDA support. See [GPU document](GPU.md) for details.

* `NOTEBOOKS`: Persistent directory on host for Python/R notebooks. See [Install document](Install.md) for details.

* `DOCKER`: Persistent directory on host for home directory of notebook user. See [Install document](Install.md) for details.

* `APTPROXY`: Apt proxy URL. See [Proxy document](Proxy.md) for details.

* `PIPPROXY`: PIP proxy URL. See [Proxy document](Proxy.md) for details.


### Text configuration files

These just list Python or R modules (one per line) that you want to put into your images. You can also specify module versions (output of `pip freeze`), however, contrary to popular belief, this is usually not the best idea. The reason is, you will severely limit pip dependency resolver if you do that and you will probably miss the latest bug fixes. Nevertheless, in enterprise environments, where stability and security are of paramount importance, you may want to restrict module versions. Another use case for this is to document the exact module versions you used when testing image for specific purpose i.e. with specific notebooks and you want these test cases to be perfectly reproducible. As usual, YMMV.

In general, it is advisable to use modules that have been published to PyPI repository. Nevertheless, sometimes you will want to use development version that has not been published yet or you have your own/proprietary modules stored in local Git repository. In this case, make sure they are installable with pip, and then use 'git+https' syntax to include them into Docker images. See `pylab/requirements_repos.txt` for couple of examples.


### Dockerfile headers

Configuration parameters (`ENV` parameters) in Dockerfiles are unlikely to change often, if at all. On the other hand, you may want to add your own if you decide to extend and/or create new Dockerfiles for new image flavors. It is advisable to keep them tight to the image where they are used. Some of the global parameters defined in `Makefile` are propagated into Dockerfiles as well.

See also [Architecture document](Architecture.md) for more information on Dockerfile headers.

