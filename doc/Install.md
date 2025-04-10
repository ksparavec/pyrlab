## Prerequisites

1. **Fast modern hardware.** Most important component is fast NVME or SSD flash for building and storing Docker images. Image building process is demanding wrt. storage hardware, good storage hardware performance in terms of both number of disk ops and throughput is important. For development purposes, a fairly modern laptop with SSD flash will probably do, however, even with NVME flash and modern multicore CPUs, be prepared to wait up to 30 minutes for a build cycle to finish. Make sure that you have enough RAM for your applications. NVIDIA GPUs are recommended, but optional.

2. **Linux or macOS software platform.** Both bare metal and VM based platforms are fine. If using a VM, make sure to use latest virtio storage driver and configure VM virtual disk on flash-based storage. Docker PyrLab containers might run on Windows as well, however, this has not been tested or documented. Therefore Windows as platform is not recommended unless you are well experienced with Docker on Windows and you know how to deal with possible issues. On the other hand, running JupyterLab sessions in browser on MS Windows, served from remote Linux/Mac server system, is supported. See [Remote document](Remote.md) for more information how to configure appropriate proxy on server to enable remote JupyterLab access.

3. **Docker Engine, Make and Git** installed on your host platform OS. You are advised to install Docker distribution from docker.io. Instructions how to do this in a way that you get automatic updates are available on [Docker portal][1]. If you are a developer, then both Make and Git are probably already installed on your system and chances are that you know how to use them. If not, just use your OS package management tool to install them. If you are not familiar with Git and/or Make, find yourself some time to learn how to use them. It will be worthwhile to you. There has also been done some work to support building and running containers with Docker Compose instead of Make, but this work is still just in experimental phase.

4. **Internet connection with low latency, high bandwidth and flat traffic rate.** Be aware that you will be downloading several GBs of data during each build cycle unless you use proxies. Apt proxy and Pip proxy are currently directly supported and configured in default configuration. See [Proxy document](Proxy.md) for more details. Building process within organizations will probably require usage of proxies for regulatory and security reasons.

5. **At least 200 GB of disk space** for Docker containers and proxy cache. In case that you want to build and use more than one version of base image at a time, you will need more. Typical use case would be testing your code with all currently supported Python versions. Image build process is constructed around Python base images that support only one Python version per container.


## Basic install and build steps

Just three simple steps are necessary:

##### 1. Clone the repository from GitHub to your system using `git`:

```
$ git clone https://github.com/ksparavec/pyrlab.git
```

If you are a developer, it is recommended to fork the repository first, and then clone your own forked version. This way you can make modifications and push them back to your own GitHub repository. If you have some interesting contributions you would like to share, do not hesitate to open a pull request.

##### 2. Change your working directory into `pyrlab` directory and edit parameters in `Configuration.mk`:

```
### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###
### Parameters marked as MANDATORY must be set to non-empty value  ###
### Parameters marked as OPTIONAL may be commented out             ###
### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ###

# MANDATORY: Log file (can be absolute or relative path)
BUILD_LOG  := '/tmp/pyrlab_$(shell date +"%F_%T").log'

# MANDATORY: Base Python image tag (see https://hub.docker.com/_/python)
PYTHONBASE := 3.12-bullseye

# MANDATORY: Default PyLab image flavor (select from: mini common torch tf jax)
PYLAB      := torch

# MANDATORY: Directory on host to be mounted as notebooks directory in container
NOTEBOOKS  := ${HOME}/notebooks

# MANDATORY: Directory on host to be mounted as home directory of notebook user in container
DOCKER     := ${HOME}/docker

# OPTIONAL: Install full CUDA support? (select from: yes no)
CUDA_INSTALL := yes

# OPTIONAL: docker runtime arguments (see GPU document)
DOCKER_ARGS  := --runtime=nvidia --gpus all

# OPTIONAL: Apt proxy URL (see Proxy document)
APTPROXY   := http://172.17.0.1:3142

# OPTIONAL: Does Apt proxy support HTTPS/// style URLs (see Proxy document)
APTHTTPS   := yes

# OPTIONAL: Pip proxy URL (see Proxy document)
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
```

General remarks:

* mandatory parameters *must* be set to some sensible non-empty value, otherwise build process will fail
* optional parameters can be commented out or left empty
* parameters are set to reasonable default values and in most cases you want to keep them as they are

You may want to use different Python base image or disable full CUDA support if you don't have NVIDIA hardware available. Also interesting are locations of persistent storage for notebooks and Docker user configuration. In case you don't have or don't want to use proxies, just comment `APTPROXY` and `PIPPROXY` out.

You can also add custom init scripts for pylab or rlab images (see `PYRCS` and `RRCS` parameters and `jupyterlab.sh` script where custom init scripts get called). You can even completely replace default `jupyterlab.sh` startup script with your own version (just redefine `USERLAB` and provide your own startup script). Doing so is recommended only if you are fairly familiar with Docker containers and environments, i.e. you know exactly what you are doing. In most cases, you will want to keep the provided startup script as is.

See [Configuration document](Configuration.md) for more information on each configurable parameter, as well as configuration for Python and R modules.

##### 3. Build Docker images

```
$ make build
```

If you are building multiple images with different parameters, you don't need to modify `Configuration.mk` before each build cycle. For example, if you want to build images with different base version of Python and without CUDA support, you can use provided `Configuration.mk` as is and override relevant parameter values in CLI like this:

```
$ make build PYTHONBASE=3.8-bullseye CUDA_INSTALL=no DOCKER_ARGS=
```

About 15-30 minutes later (depending on how fast/slow your hardware and Internet connection are), and if there were no errors during build process, you will obtain all configured Docker images in your local Docker repository. See [Imaging document](Images.md) for more information on how Docker image configuration is structured, and how to build additional images that are inherited from base images.

You can follow detailed trace of all actions performed during build process in the log file. Its name has to be provided in `Configuration.mk` as `BUILD_LOG` parameter. During build process, just execute `tail` command as suggested before each `docker build` command. For example:

```
$ tail -f '/tmp/pyrlab_2024-03-21_10:16:45.log'
```


## Persistent storage configuration

Before running the container, you must prepare two separate directories on your host. In default configuration, following two parameters are set as:

```
NOTEBOOKS  := ${HOME}/notebooks
DOCKER     := ${HOME}/docker
```

What this means is that you need to execute on your host:

```
$ mkdir ${HOME}/notebooks
$ mkdir ${HOME}/docker
```

You are strongly advised to initialize Git repository immediately in `notebooks` directory or clone the appropriate remote. Always keep your work versioned and backed up. Containers are provided with Git client too, so you can comfortably work with Git in JupyterLab Terminal as well.

N.B. There is JupyterLab Git extension that supports basic Git operations from JupyterLab GUI. If you want to use it, just uncomment the appropriate line in `requirements_mini.txt` and `r_requirements.txt` for Python and R kernels, respectively. Be aware though, that extension tends to hog the browser session in regular short time intervals, therefore after some experimenting, I commented it out in configuration files. However, YMMV. See [Configuration document](Configuration.md) for more details.

`docker` directory should be populated with initial bash configuration files. You can simply copy your own `.bashrc` and `.profile`, and start from there. It is advisable to define all environment variables in separate special configuration file referenced by `ENVVARS` parameter in `Configuration.mk`. If left unchanged, file shall be called `.env` and stored in the home directory of `notebook` user in container. It must have the syntax like in this (rather lengthy) example:

```
GIT_COMPLETION_SHOW_ALL_COMMANDS=1
GIT_COMPLETION_SHOW_ALL=1
GIT_COMPLETION_IGNORE_CASE=1
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto git"
GIT_PS1_SHOWCONFLICTSTATE=yes
GIT_PS1_SHOWCOLORHINTS=1

PRETTY_NAME=`grep ^PRETTY_NAME /etc/os-release | cut -d\" -f2`
OS_VERSION="${PRETTY_NAME} "`uname -r`"; "
PYTHON_VERSION=`python --version`"; "
PIP_VERSION=`pip --version | awk '{print "PIP",$2}'`"; "
R_VERSION=""
[[ -x /usr/bin/R ]] && R_VERSION=`R --version | head -1 | cut -d " " -f1,3`"; "
CUDA_VERSION=""
[[ -r /usr/local/cuda/version.json ]] && CUDA_VERSION=`cat /usr/local/cuda/version.json | jq -j '.cuda.name, " ", .cuda.version'`"; "
GCC_VERSION=`gcc -v 2>&1 | grep ^gcc | cut -d" " -f3 | awk '{print "GCC "$1}'`"; "
#CARGO_VERSION=`cargo -V | cut -d" " -f1,2`
JUPYTERLAB_VERSION=`pip list | grep "^jupyterlab\s" | awk '{print "JupyterLab",$2}'`
TIMEZONE=`date +"%Z"`
VERSIONS_STRING="\e[01m${OS_VERSION}${GCC_VERSION}${CUDA_VERSION}${PYTHON_VERSION}${PIP_VERSION}${R_VERSION}${JUPYTERLAB_VERSION}\e[m"
SHELL_PROMPT="\e[01;33m\d \t ${TIMEZONE}\e[m \e[01;32m[\h:\w]\e[m"
PROMPT_COMMAND='__git_ps1 "${SHELL_PROMPT}" "\n\\\$ "'
```

This file will be sourced by `jupyterlab.sh` startup script automatically if it exists, so that all environment variables defined in there are available in JupyterLab notebooks. Normally, you would put stuff like API keys or passwords in there too, so that they are not hardcoded in notebooks. For this reason, you may not want to use Git in this directory, at least not without taking measures to encrypt or mask passwords before commits taking place.

Now, add the following shell snippet to your `.bashrc`:

```
source <(cat /etc/bash_completion.d/*)
set -a
. "$HOME/.env"
set +a

# print software versions
printf "\n%s$VERSIONS_STRING\n\n"

# print NVIDIA summary
[[ -x /usr/bin/nvidia-smi ]] && nvidia-smi

# stop cursor blinking
printf '\033[?12l'
```

This will source the environment configuration, you will get some cool looking startup message in your JupyterLab Terminal, and even cooler bash prompt including `git-prompt` support. If you use CLI and Git a lot like myself, you will quickly learn to appreciate it ;) The last line makes sure that cursor does not blink - I find blinking cursor terribly annoying :)

One thing to check for in your `.bashrc` file is `PATH` environment variable. If `.profile` and `.bashrc` have been copied from a Debian system, it should be already set properly, however, you may want to make sure that it contains following paths:

```
export PATH=/usr/local/cuda/bin:/notebook/.local/bin:/usr/local/bin:${PATH}
```

See [Architecture document](Architecture.md) for more details on container software structure in general.


## Running the containers

After build process has finished, and your notebooks and home directory for notebook user have been created and initialized, you need to tag your image as either `pylab:latest` or `rlab:latest` to be able to use appropriate targets in `Makefile` to run containers. Let's imagine that using supplied default configuration, you want to tag and run `torch` image flavor of `pylab`, i.e. JupyterLab with Python kernel:

```
$ make tag_pylab PYLAB=torch
...
```

`rlab` image comes in only one flavor in default configuration and gets tagged automatically, so this step is not necessary.

Finally, you can run your container:

```
$ make pylab
```

In case that you have overriden some of the parameters in `Configuration.mk` during build process, you need to use same parameters here. Corresponding to the example above:

```
$ make pylab PYTHONBASE=3.8-bullseye CUDA_INSTALL=no DOCKER_ARGS=
```

Now point your browser to `http://127.0.0.1:8888/lab` (if you changed the listener port in `Configuration.mk`, change it here as well).

See [Imaging document](Images.md) for more detailed information on image flavors.

If you run your container on remote server, some additional setup is needed to be able to access it from remote client machine. See [Remote document](Remote.md) for more details.


[1]: <https://docs.docker.com/engine/install/> (Install Docker Engine)

