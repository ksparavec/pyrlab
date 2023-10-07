### Start of configuration section

# Base Python image tag (see https://hub.docker.com/_/python)
PYTHONBASE := 3.11-bookworm

### Custom built image names
IMAGE      := pylab
RIMAGE     := rlab

### Default container ports
# pylab
PORT       := 8888
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
build: build_base build_rbase build_python build_r
.PHONY: all clean build build_base build_rbase build_python build_r pylab rlab

clean:
	docker image prune --force
	docker image rm pyrlab-base pylab rlab-base rlab

build_base:
	docker build -f Dockerfile.Base -t pyrlab-base:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg APTPROXY=${APTPROXY} .
	docker image tag pyrlab-base:${PYTHONBASE} pyrlab-base:latest

build_python:
	docker build -f Dockerfile.Python -t pylab:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg PIPPROXY=${PIPPROXY} --build-arg PIPHOST=${PIPHOST} .
	docker image tag pylab:${PYTHONBASE} pylab:latest

build_rbase:
	docker build -f Dockerfile.RBase -t rlab-base:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} .
	docker image tag rlab-base:${PYTHONBASE} rlab-base:latest

build_r:
	docker build -f Dockerfile.R -t rlab:${PYTHONBASE} --build-arg PYTHONBASE=${PYTHONBASE} --build-arg APTPROXY=${APTPROXY} --build-arg PIPPROXY=${PIPPROXY} --build-arg PIPHOST=${PIPHOST} .
	docker image tag rlab:${PYTHONBASE} rlab:latest

pylab:
	docker run -it --rm --name ${IMAGE}_${PYTHONBASE} -v ${FILES}:/notebook/files -v ${DOCKER}:/notebook/docker:ro -e PORT=${PORT} -p ${PORT}:${PORT} -e TFPORT=${TFPORT} -p ${TFPORT}:${TFPORT} -d ${IMAGE}:${PYTHONBASE}

rlab:
	docker run -it --rm --name ${RIMAGE}_${PYTHONBASE} -v ${FILES}:/notebook/files -v ${DOCKER}:/notebook/docker:ro -e PORT=${RPORT} -p ${RPORT}:${RPORT} -d ${RIMAGE}:${PYTHONBASE}
