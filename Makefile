IMAGE := pyrlab-latex
PORT  := 8888
FILES := ${HOME}/notebooks
PAUSE := 3

.PHONY: all clean build bash start browser lab stop list pause
all: build start pause browser
lab: start pause browser

clean:
	docker image prune --force
	docker image rm ${IMAGE} pyrlab-slim pyrlab-build

build:
	docker build --target pyrlab-build -t pyrlab-build:latest .
	docker build --target pyrlab-slim  -t pyrlab-slim:latest .
	docker build --target pyrlab-latex -t pyrlab-latex:latest .

bash:
	docker run -it --rm -v ${FILES}:/notebook/files pyrlab-build bash --login

start:
	docker run -it --rm -v ${FILES}:/notebook/files -e PORT=${PORT} -p ${PORT}:${PORT} -d ${IMAGE}

browser:
	python3 -m webbrowser -t $(shell docker logs `docker container ls -l -q` | grep -E "^\s+or http" | awk '{print $$2}')

stop:
	docker stop `docker ps -q --filter "ancestor=${IMAGE}"`

list:
	docker ps --filter "ancestor=${IMAGE}"

pause:
	sleep ${PAUSE}

