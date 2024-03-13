### Start of configuration section

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
PIPHOST    := "172.17.0.1"

### End of configuration section

all: build pylab rlab
build: build_base build_rbase build_pylab build_rlab
build_pylab: build_pylab-mini build_pylab-common build_pylab-torch build_pylab-jax
.PHONY: all image_clean cache_clean clean build build_base build_rbase build_pylab build_pylab-mini build_pylab-common build_pylab-torch build_pylab-jax build_rlab tag_pylab pylab rlab

image_clean:
	docker image rm \
    pyrlab-base:${PYTHONBASE} \
    pyrlab-base:latest \
    pylab:${PYTHONBASE} \
    pylab:latest \
    rlab-base:${PYTHONBASE} \
    rlab-base:latest \
    rlab:${PYTHONBASE} \
    rlab:latest \
    pylab-mini:${PYTHONBASE} \
    pylab-mini:latest \
    pylab-common:${PYTHONBASE} \
    pylab-common:latest \
    pylab-torch:${PYTHONBASE} \
    pylab-torch:latest \
    pylab-jax:${PYTHONBASE} \
    pylab-jax:latest

cache_clean:
	docker buildx prune -af

clean: image_clean cache_clean

build_base:
	docker build \
    -f docker/Dockerfile.Base \
    -t pyrlab-base:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg APTPROXY=${APTPROXY} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    .
	docker image tag pyrlab-base:${PYTHONBASE} pyrlab-base:latest

build_pylab-mini:
	docker build \
    -f docker/Dockerfile.PyLab-mini \
    -t pylab-mini:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg PIPHOST=${PIPHOST} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    .
	docker image tag pylab-mini:${PYTHONBASE} pylab-mini:latest

build_pylab-common:
	docker build \
    -f docker/Dockerfile.PyLab-common \
    -t pylab-common:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg PIPHOST=${PIPHOST} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    .
	docker image tag pylab-common:${PYTHONBASE} pylab-common:latest

build_pylab-torch:
	docker build \
    -f docker/Dockerfile.PyLab-torch \
    -t pylab-torch:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg PIPHOST=${PIPHOST} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    .
	docker image tag pylab-torch:${PYTHONBASE} pylab-torch:latest

build_pylab-jax:
	docker build \
    -f docker/Dockerfile.PyLab-jax \
    -t pylab-jax:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg PIPHOST=${PIPHOST} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    .
	docker image tag pylab-jax:${PYTHONBASE} pylab-jax:latest

tag_pylab:
	docker image tag pylab-${PYLAB}:${PYTHONBASE} pylab:${PYTHONBASE}
	docker image tag pylab:${PYTHONBASE} pylab:latest
	docker images | grep ^pylab

build_rbase:
	docker build \
    -f docker/Dockerfile.RBase \
    -t rlab-base:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    .
	docker image tag rlab-base:${PYTHONBASE} rlab-base:latest

build_rlab:
	docker build \
    -f docker/Dockerfile.RLab \
    -t rlab:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg PIPHOST=${PIPHOST} \
    .
	docker image tag rlab:${PYTHONBASE} rlab:latest

pylab:
	docker run \
    --detach \
    --interactive \
    --tty \
    --rm \
    --hostname "pylab-"`hostname` \
    --cap-add=SYS_ADMIN \
    --name ${IMAGE}_${PYTHONBASE} \
    ${DOCKER_ARGS} \
    -v ${NOTEBOOKS}:/volumes/notebooks \
    -v ${DOCKER}:/notebook \
    -e ENVVARS=${ENVVARS} \
    -e RCS=${PYRCS} \
    -e USERLAB=${USERLAB} \
    -e PORT=${PYPORT} -p ${PYPORT}:${PYPORT} \
    -e TFPORT=${TFPORT} -p ${TFPORT}:${TFPORT} \
    -e DTPORT=${DTPORT} -p ${DTPORT}:${DTPORT} \
    -d ${IMAGE}:${PYTHONBASE}

rlab:
	docker run \
    --detach \
    --interactive \
    --tty \
    --rm \
    --hostname "rlab-"`hostname` \
    --name ${RIMAGE}_${PYTHONBASE} \
    ${DOCKER_ARGS} \
    -v ${NOTEBOOKS}:/volumes/notebooks \
    -v ${DOCKER}:/notebook \
    -e ENVVARS=${ENVVARS} \
    -e RCS=${RRCS} \
    -e USERLAB=${USERLAB} \
    -e PORT=${RPORT} -p ${RPORT}:${RPORT} \
    -d ${RIMAGE}:${PYTHONBASE}
