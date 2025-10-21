### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
### Parameters marked as MANDATORY must be set to non-empty value  ###
### Parameters marked as OPTIONAL may be commented out             ###
### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###

# MANDATORY: Log file (can be absolute or relative path)
BUILD_LOG  := '/tmp/pyrlab_$(shell date +"%F_%T").log'

# MANDATORY: Base Python image tag (see https://hub.docker.com/_/python)
PYTHONBASE := 3.12-bullseye

# MANDATORY: Default PyLab image flavor (select from: mini common torch jax)
PYLAB      := torch

# MANDATORY: Directory on host to be mounted as notebooks directory in container
NOTEBOOKS  := ${HOME}/notebooks

# MANDATORY: Directory on host to be mounted as home directory of notebook user in container
DOCKER     := ${HOME}/docker

# OPTIONAL: Install full CUDA support? (select from: yes no)
CUDA_INSTALL := yes

# OPTIONAL: docker runtime arguments (see GPU document)
DOCKER_ARGS  := --runtime=nvidia --gpus all

# OPTIONAL: Container runtime (select from: docker podman)
CONTAINER_RUNTIME := docker

# OPTIONAL: Apt proxy URL (see Proxy document)
APTPROXY   := http://172.17.0.1:3142

# OPTIONAL: Does Apt proxy support HTTPS/// style URLs (see Proxy document)
APTHTTPS   := yes

# OPTIONAL: Python package proxy URL (see Proxy document)
# NOTE: PyRLab uses UV (https://github.com/astral-sh/uv) instead of pip for faster package installation
PIPPROXY   := http://172.17.0.1:3141

# MANDATORY: pylab container port
PYPORT     := 8888

# MANDATORY: dtale port
DTPORT     := 40000

# MANDATORY: tensorboard port
TFPORT     := 6006

# MANDATORY: rlab container port
RPORT      := 9999

# OPTIONAL: script to execute in PyLab container before JupyterLab
PYRCS      := pylab.sh

# OPTIONAL: script to execute in RLab container before JupyterLab
RRCS       := rlab.sh

# OPTIONAL: script to execute instead of jupyterlab.sh
USERLAB    := userlab.sh

# OPTIONAL: Environment variables definitions to be used in container
ENVVARS    := /notebook/.env

# MANDATORY: UID and GID of notebook user in container
UID        := 1000
GID        := 1000
