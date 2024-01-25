### Start of configuration section

# Base Python image tag (see https://hub.docker.com/_/python)
PYTHONBASE := 3.11-bullseye

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

### Notebooks and configuration directory locations on host
NOTEBOOKS  := ${HOME}/notebooks
DOCKER     := ${HOME}/docker

### Default environment variables definitions in container (optional)
ENVVARS    := /volumes/docker/.env

### Application proxies (optional)
# Apt proxy
APTPROXY   := "http://172.17.0.1:3142"
# Pip proxy
PIPPROXY   := "http://172.17.0.1:3141"
PIPHOST    := "172.17.0.1"

### End of configuration section

all: build pylab rlab
build: build_base build_rbase build_pylab build_rlab
.PHONY: all image_clean cache_clean clean build build_base build_rbase build_pylab build_rlab pylab rlab

image_clean:
	docker image rm pyrlab-base:${PYTHONBASE} pylab:${PYTHONBASE} rlab-base:${PYTHONBASE} rlab:${PYTHONBASE} pyrlab-base pylab rlab-base rlab

cache_clean:
	docker buildx prune -af

clean: image_clean cache_clean

build_base:
	docker build -f Dockerfile.Base -t pyrlab-base:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg APTPROXY=${APTPROXY} --build-arg CUDA_INSTALL=${CUDA_INSTALL} .
	docker image tag pyrlab-base:${PYTHONBASE} pyrlab-base:latest

build_pylab:
	docker build -f Dockerfile.PyLab -t pylab:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg PIPPROXY=${PIPPROXY} --build-arg PIPHOST=${PIPHOST} .
	docker image tag pylab:${PYTHONBASE} pylab:latest

build_rbase:
	docker build -f Dockerfile.RBase -t rlab-base:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} .
	docker image tag rlab-base:${PYTHONBASE} rlab-base:latest

build_rlab:
	docker build -f Dockerfile.RLab -t rlab:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg APTPROXY=${APTPROXY} --build-arg PIPPROXY=${PIPPROXY} --build-arg PIPHOST=${PIPHOST} .
	docker image tag rlab:${PYTHONBASE} rlab:latest

pylab:
	docker run -h `hostname` -it --rm ${DOCKER_ARGS} --name ${IMAGE}_${PYTHONBASE} -v ${NOTEBOOKS}:/volumes/notebooks -v ${DOCKER}:/volumes/docker -e PORT=${PYPORT} -e ENVVARS=${ENVVARS} -e RCS=${PYRCS} -e USERLAB=${USERLAB} -p ${PYPORT}:${PYPORT} -e TFPORT=${TFPORT} -p ${TFPORT}:${TFPORT} -e DTPORT=${DTPORT} -p ${DTPORT}:${DTPORT} -d ${IMAGE}:${PYTHONBASE}

rlab:
	docker run -h `hostname` -it --rm ${DOCKER_ARGS} --name ${RIMAGE}_${PYTHONBASE} -v ${NOTEBOOKS}:/volumes/notebooks -v ${DOCKER}:/volumes/docker -e PORT=${RPORT} -e ENVVARS=${ENVVARS}-e RCS=${RRCS} -e USERLAB=${USERLAB} -p ${RPORT}:${RPORT} -d ${RIMAGE}:${PYTHONBASE}

