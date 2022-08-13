IMAGE := pylab
PORT  := 8888
FILES := ${HOME}/notebooks
PAUSE := 3

.PHONY: all clean build build_base build_rbase build_python build_r bash start start_pylab start_rlab browser pylab rlab stop stop_pylab stop_rlab list pause
build: build_base build_rbase build_python build_r
start: start_pylab
stop: stop_pylab
all: build start
pylab: start_pylab pause browser
rlab: start_rlab pause browser

clean:
	docker image prune --force
	docker image rm pyrlab-base pylab rlab-base rlab

build_base:
	docker build -f Dockerfile.Base -t pyrlab-base:latest .

build_python:
	docker build -f Dockerfile.Python -t pylab:latest .

build_rbase:
	docker build -f Dockerfile.RBase -t rlab-base:latest .

build_r:
	docker build -f Dockerfile.R -t rlab:latest .

bash:
	docker run -it --rm -v ${FILES}:/notebook/files pyrlab bash --login

start_pylab:
	docker run -it --rm -v ${FILES}:/notebook/files -e PORT=${PORT} -p ${PORT}:${PORT} -p 6006:6006 -d ${IMAGE}

start_rlab:
	docker run -it --rm -v ${FILES}:/notebook/files -e PORT=${PORT} -p ${PORT}:${PORT} -d ${IMAGE}

browser:
	python3 -m webbrowser -t $(shell docker logs `docker container ls -l -q` | grep -E "^\s+or http" | awk '{print $$2}')

stop:
	docker stop `docker ps -q --filter "ancestor=${IMAGE}"`

stop_pylab:
	docker stop `docker ps -q --filter "ancestor=pylab"`

stop_rlab:
	docker stop `docker ps -q --filter "ancestor=rlab"`

list:
	docker ps --filter "ancestor=${IMAGE}"

pause:
	sleep ${PAUSE}

