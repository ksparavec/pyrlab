### Start of configuration section

# Base Python image tag (see https://hub.docker.com/_/python)
PYTHONBASE := 3.11-bullseye

### Custom built image names
IMAGE      := pylab
RIMAGE     := rlab

### Default container ports
# pylab
PORT       := 8888
# D-Tale
DTPORT     := 40000
# tensorboard
TFPORT     := 6006
# rlab
RPORT      := 9999

### Notebooks and configuration directory locations
FILES      := ${HOME}/notebooks
DOCKER     := ${HOME}/docker

### Application proxies
# Apt proxy
APTPROXY   := "http://172.17.0.1:3142"
# Pip proxy
PIPPROXY   := "http://172.17.0.1:3141"
PIPHOST    := "172.17.0.1"

### End of configuration section

all: pylab rlab
build: build_base build_rbase build_pylab build_rlab
.PHONY: all image_clean cache_clean clean build build_base build_rbase build_pylab build_rlab pylab rlab

image_clean:
	docker image rm pyrlab-base:${PYTHONBASE} pylab:${PYTHONBASE} rlab-base:${PYTHONBASE} rlab:${PYTHONBASE}

cache_clean:
	docker builder prune -f

clean: image_clean cache_clean

build_base:
	docker build -f Dockerfile.Base -t pyrlab-base:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg APTPROXY=${APTPROXY} .
	docker image tag pyrlab-base:${PYTHONBASE} pyrlab-base:latest

build_pylab:
	docker build -f Dockerfile.Python -t pylab:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg PIPPROXY=${PIPPROXY} --build-arg PIPHOST=${PIPHOST} .
	docker image tag pylab:${PYTHONBASE} pylab:latest

build_rbase:
	docker build -f Dockerfile.RBase -t rlab-base:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} .
	docker image tag rlab-base:${PYTHONBASE} rlab-base:latest

build_rlab:
	docker build -f Dockerfile.R -t rlab:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg APTPROXY=${APTPROXY} --build-arg PIPPROXY=${PIPPROXY} --build-arg PIPHOST=${PIPHOST} .
	docker image tag rlab:${PYTHONBASE} rlab:latest

pylab:
	docker run -h `hostname` -it --rm --runtime=nvidia --gpus all --name ${IMAGE}_${PYTHONBASE} -v ${FILES}:/notebook/files -v ${DOCKER}:/notebook/docker -e PORT=${PORT} -p ${PORT}:${PORT} -e TFPORT=${TFPORT} -p ${TFPORT}:${TFPORT} -e DTPORT=${DTPORT} -p ${DTPORT}:${DTPORT} -d ${IMAGE}:${PYTHONBASE}

rlab:
	docker run -h `hostname` -it --rm --runtime=nvidia --gpus all --name ${RIMAGE}_${PYTHONBASE} -v ${FILES}:/notebook/files -v ${DOCKER}:/notebook/docker -e PORT=${RPORT} -p ${RPORT}:${RPORT} -d ${RIMAGE}:${PYTHONBASE}

