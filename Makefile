include Configuration.mk

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
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.Base \
    -t pyrlab-base:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg APTPROXY=${APTPROXY} \
    --build-arg APTHTTPS=${APTHTTPS} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    . >>${BUILD_LOG} 2>&1
	docker image tag pyrlab-base:${PYTHONBASE} pyrlab-base:latest

build_pylab-mini:
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.PyLab-mini \
    -t pylab-mini:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    . >>${BUILD_LOG} 2>&1
	docker image tag pylab-mini:${PYTHONBASE} pylab-mini:latest

build_pylab-common:
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.PyLab-common \
    -t pylab-common:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    . >>${BUILD_LOG} 2>&1
	docker image tag pylab-common:${PYTHONBASE} pylab-common:latest

build_pylab-torch:
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.PyLab-torch \
    -t pylab-torch:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    . >>${BUILD_LOG} 2>&1
	docker image tag pylab-torch:${PYTHONBASE} pylab-torch:latest

build_pylab-jax:
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.PyLab-jax \
    -t pylab-jax:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    --build-arg CUDA_INSTALL=${CUDA_INSTALL} \
    . >>${BUILD_LOG} 2>&1
	docker image tag pylab-jax:${PYTHONBASE} pylab-jax:latest

tag_pylab:
	docker image tag pylab-${PYLAB}:${PYTHONBASE} pylab:${PYTHONBASE}
	docker image tag pylab:${PYTHONBASE} pylab:latest
	docker images | grep ^pylab

build_rbase:
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.RBase \
    -t rlab-base:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    . >>${BUILD_LOG} 2>&1
	docker image tag rlab-base:${PYTHONBASE} rlab-base:latest

build_rlab:
	@printf "\nINFO: execute \"tail -f ${BUILD_LOG}\" in second terminal to follow image building process in detail\n"
	docker build \
    -f docker/Dockerfile.RLab \
    -t rlab:${PYTHONBASE} \
    --build-arg PYTHONBASE=${PYTHONBASE} \
    --build-arg PIPPROXY=${PIPPROXY} \
    . >>${BUILD_LOG} 2>&1
	docker image tag rlab:${PYTHONBASE} rlab:latest

pylab:
	docker stop $@_${PYTHONBASE} || true
	docker run \
    --detach \
    --interactive \
    --tty \
    --rm \
    --hostname "pylab-"`hostname` \
    --cap-add=SYS_ADMIN \
    --name $@_${PYTHONBASE} \
    ${DOCKER_ARGS} \
    -v ${NOTEBOOKS}:/volumes/notebooks \
    -v ${DOCKER}:/notebook \
    -e ENVVARS=${ENVVARS} \
    -e RCS=${PYRCS} \
    -e USERLAB=${USERLAB} \
    -e PORT=${PYPORT} -p ${PYPORT}:${PYPORT} \
    -e TFPORT=${TFPORT} -p ${TFPORT}:${TFPORT} \
    -e DTPORT=${DTPORT} -p ${DTPORT}:${DTPORT} \
    -d $@:${PYTHONBASE}

rlab:
	docker stop $@_${PYTHONBASE} || true
	docker run \
    --detach \
    --interactive \
    --tty \
    --rm \
    --hostname "rlab-"`hostname` \
    --name $@_${PYTHONBASE} \
    ${DOCKER_ARGS} \
    -v ${NOTEBOOKS}:/volumes/notebooks \
    -v ${DOCKER}:/notebook \
    -e ENVVARS=${ENVVARS} \
    -e RCS=${RRCS} \
    -e USERLAB=${USERLAB} \
    -e PORT=${RPORT} -p ${RPORT}:${RPORT} \
    -d $@:${PYTHONBASE}
