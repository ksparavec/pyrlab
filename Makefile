IMAGE := pylab
RIMAGE := rlab
PORT  := 8888
TFPORT := 6006
RPORT := 9999
FILES := ${HOME}/notebooks
PAUSE := 3

APTPROXY := "http://172.17.0.1:3142"
PIPPROXY := "http://172.17.0.1:3141"
PIPHOST  := "172.17.0.1"

.PHONY: all clean build build_base build_rbase build_python build_r bash start start_pylab start_rlab browser pylab rlab stop stop_pylab stop_rlab list pause
build: build_base build_rbase build_python build_r
start: start_pylab start_rlab
stop: stop_pylab stop_rlab
all: build start

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

start_pylab:
	docker run -it --rm -v ${FILES}:/notebook/files -e PORT=${PORT} -p ${PORT}:${PORT} -e TFPORT=${TFPORT} -p ${TFPORT}:${TFPORT} -d ${IMAGE}:${PYTHONBASE}

start_rlab:
	docker run -it --rm -v ${FILES}:/notebook/files -e PORT=${RPORT} -p ${RPORT}:${RPORT} -d ${RIMAGE}:${PYTHONBASE}

stop_pylab:
	docker stop `docker ps -q --filter "ancestor=pylab"`

stop_rlab:
	docker stop `docker ps -q --filter "ancestor=rlab"`

list:
	docker ps --filter "ancestor=${IMAGE}"

