# Python/R Jupyter Lab Docker Container Image Project

## What is the goal of this project

This project builds easy to use custom Docker containers with custom Python modules and custom R modules built-in based on current stable Python and R distributions. Please see links below for more information on Docker, Python and R.


## Why another Python/R build and deployment system?

Because I became annoyed with managing Python environments manually. I never know for sure what packages I have installed without performing inspection. I also don't want to upgrade my Python distribution manually either from time to time or build it entirely from scratch by copy-pasting commands from online manuals. Python distribution that comes with your standard Linux distribution is usually hopelessly out dated and not well maintained, except for the critical security related fixes. Also you may want to access your distribution remotely by using your browser alone. Would it not be nice to have everything packaged, customized, upgraded with single command, as well as have it in reusable and shared form, so other people can use it as well, and on top of all this, that it works regardless of which platform operating system and package manager you normally use in your everyday work? If answer to any or all of these questions is yes, please read on.


## Why don't just use Anaconda/Homebrew/ActiveState/\<put your favorite Python distribution name here\>??

Because they do not fulfill at least one (in many cases more than one) of the requirements from above. In addition, I wanted to have a solution where both Python and R are treated in the same way, when looking just from user perspective.


## Note on Docker base images

In this project we use latest stable Python images from DockerHub as base images. This makes it possible to always have latest stable bug fixed Python version without having to compile and test it afterwards before using it. Python base images use special version of Debian base image, therefore it is possible to use apt package manager for installing additional system packages. We use this to install latest stable R distribution among other things. See Dockerfile for details if you are interested.

Please note that, in order to add or remove your custom Python modules and R packages, you don't need to edit or even understand Dockerfile logic. Just edit **requirements.txt** and **r_packages.txt** and rebuild container images with single command, as explained below.


## Prerequisites

1. Fast modern hardware. Especially important is fast NVME or SSD flash for building and storing Docker images.

2. Linux or Mac on desktop (or some other Unix on server) operating system installed on your hardware. Local or Cloud VMs are fine, as long as they are properly configured on hypervisor so that they get direct access to fast storage. Building images and/or running Docker container on MS Windows platform is NOT recommended (build may not even work at all). While running container with Docker Desktop on MS Windows may work, it has never been tested and is not supported.

3. Docker Engine, git and make installed on your host platform OS, You are advised to install Docker from docker.io, i. e. not the version available from your platform distribution. Hints how to do it in a way that you get automatic updates are available from link below. Make and git are probably already installed on your system. If not, just use your OS package management tool to install them (or ask your friendly system administrator to do that for you). If you have access to Docker orchestration software like Kubernetes, feel free to use it, but I do not provide hints here how to deploy Docker images there.

4. Reasonably fast Internet connection with low latency and flat traffic rate. Build process currently requires direct Internet connection or transparent proxy. Apt proxy and Pip proxy are supported as well. Their usage is recommended if you plan to rebuild your images frequently. See below for details.

5. At least 100 GB of disk space for Docker containers. In case that you want to use more than one version of base image, you will need more space.


## Proxy Setup

It is strongly recommended to use proxies for Debian packages and Python modules. In enterprise environments, point your proxy to values obtained from your administrator. If you have direct Internet access, you can easily create your own proxies on your laptop or workstation.

Debian packages can be cached by using apt-proxy. If you use Debian as your Desktop OS, then execute as root:

```
# apt-get update && apt-get install apt-cacher-ng
```

You will get apt-proxy with package caching and meta information management listening on port 3142. In case you don't have Debian based desktop, you can use any standard proxy software like Squid for example. Just note the port your proxy is listening to.

Python packages can be cached using devpi module. See this page for more information how to install devpi on your laptop/workstation:
[Quickstart: running a pypi mirror on your laptop](https://devpi.net/docs/devpi/devpi/stable/+d/quickstart-pypimirror.html)

After installation, you can start devpi proxy instance as follows (check your docker network interface configuration first to make sure you have docker proxy running on and listening on 172.17.0.1):

```
$ devpi-server --listen 172.17.0.1:3141
```

Once you have either installed your proxies or obtained proxy information from your administrator, change the values in configuration section of Makefile (see below). 


## Configure and Build your Docker images

Just three simple steps are necessary:

1. Copy pyrlab repository from GitHub to your system using git

```
$ git clone https://github.com/ksparavec/pyrlab.git 
```

2. Change your working directory into **pyrlab** directory and edit configuration section in Makefile:

```
$ vim Makefile

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

### Application proxies (optional)
# Apt proxy
APTPROXY   := "http://172.17.0.1:3142"
# Pip proxy
PIPPROXY   := "http://172.17.0.1:3141"
PIPHOST    := "172.17.0.1"

### End of configuration section
```

Parameters are set to reasonable default values and in most cases you want to keep them as they are. You may want to use different Python base image, disable CUDA support if you don't have NVIDIA hardware available (in that case set CUDA_INSTALL to "no" and DOCKER_ARGS to ""), and change locations of persistent storage for notebooks and docker user configuration. In case you don't have or don't want to use proxies, just comment APTPROXY, PIPPROXY, and PIPHOST out.

You can also add custom init scripts for pylab or rlab images (PYRCS and RRCS variables). You can even replace jupyterlab.sh startup script entirely with your own if so desired (redefine USERLAB variable and provide your own startup script). Doing so is recommended only if you are fairly familiar with Docker containers and environments, i.e. you know exactly what you are doing.

3. Once satisfied with configuration, save it, exit to shell and build all Docker images with single command:

```
$ make build
```

About 15 minutes or so later (depending on how fast/slow your hardware and Internet connection are), you will obtain four Docker images (if you have some other unrelated images with lab in their names, please ignore them):

```
$ docker image ls | grep lab
rlab                                                              3.11-bullseye                       2cbc825fde96   9 days ago     11.1GB
rlab                                                              latest                              2cbc825fde96   9 days ago     11.1GB
pylab                                                             3.11-bullseye                       2d816c0f5c5d   9 days ago     20.2GB
pylab                                                             latest                              2d816c0f5c5d   9 days ago     20.2GB
rlab-base                                                         3.11-bullseye                       d84b299c6cb9   9 days ago     10.6GB
rlab-base                                                         latest                              d84b299c6cb9   9 days ago     10.6GB
pyrlab-base                                                       3.11-bullseye                       e5e8ec5fc688   9 days ago     10.5GB
pyrlab-base                                                       latest                              e5e8ec5fc688   9 days ago     10.5GB
```

**pyrlab-base** image contains all necessary system libraries and packages to run Python as well as full CUDA support if you chose to use it. Its purpose is to be used as base image for building **pylab** and **rlab-base** images.

**pylab** image is final image that contains all custom Python modules to run Python notebooks with **Python** kernel.

**rlab-base** image contains all necessary system libraries and packages to run R. Its purpose is to be used as base image for building **rlab** image.

**rlab** image is final image that contains all custom R modules and necessary Python modules to run Python notebooks with **R** kernel.


## Customization 

Please check following configuration files for customization of packages and modules:

* **base_debs.txt** : you can add Debian packages here if necessary to build custom Python modules
* **requirements.txt** : add here any other **Python** modules you need in your project (or remove those you don't need)
* **r_debs.txt** : you can add Debian packages here if necessary to build custom R modules
* **r_packages.txt** : add here any other **R** modules you need in your project (or remove those you don't need)

After editing any of those files, you will have to rebuild Docker images:

```
$ make build
```

Docker should be able to figure out which images have to be rebuilt automatically and rebuild only those. If you want to be sure nothing stale remains, execute make with clean target before building:

```
$ make clean
$ make build
```

Be aware that make clean target will wipe out complete Docker build cache as well.


## Container Usage

Create directories "notebooks" and "docker" in your home directory to store your Python/R notebooks and user configuration:

```
$ mkdir $HOME/notebooks
$ mkdir $HOME/docker
```

Start your new containers:

```
$ make pylab
$ make rlab
```

You can check that containers are running with:

```
$ docker ps | grep lab
CONTAINER ID   IMAGE                 COMMAND                  CREATED         STATUS         PORTS                                                                      NAMES
ab6aacf417ac   rlab:3.11-bullseye    "/usr/bin/tini -- /b…"   5 seconds ago   Up 4 seconds   0.0.0.0:9999->9999/tcp                                                     rlab_3.11-bullseye
4ba3c45b9519   pylab:3.11-bullseye   "/usr/bin/tini -- /b…"   5 hours ago     Up 5 hours     0.0.0.0:6006->6006/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:40000->40000/tcp   pylab_3.11-bullseye
```

You can now point your browser to use JupyterLab:

* http://127.0.0.1:8888/lab for Python notebooks
* http://127.0.0.1:9999/lab for R notebooks

If you use remote server system instead of local desktop to run containers, you will need to replace localhost IP with your real host IP and make sure you can access it on port specified from your workstation. You may need to open some port on your firewall or do some port redirection with ssh or even create full tunnel to your server system.

For example, let's suppose you have started your pylab instance on remote server with standard port 8888. Also let's suppose that remote server IP number is 192.168.1.100. In this case, in order to connect to remote instance from your workstation, you can use SSH port forwarding like this (this supposes that you use Linux, Unix or Mac OS as your Desktop OS):

```
$ ssh 192.168.1.100 -fN -L 8888:localhost:8888
```

If you have Windows installed on your desktop, you will have to check your ssh client documentation for information how to do port forwarding.

You can now open connection to your container using localhost IP as shown above, just as if container would run locally.

If you have direct access to remote server high ports via tunnel or directly, you still need some kind of port forwarding because listener always binds to localhost interface which is reachable from remote host only. In this case, you might want to use tools like `socat(1)` or `nc(1)` and then replace 127.0.0.1 with remote server IP in link echoed. Nevertheless, the easiest method is to just use ssh like shown above, even if high ports on remote server are reachable directly.

In order to create your Docker instance available from Internet directly (similar to `https://nbviewer.org` for example), you would have to create reverse proxy in front of it and some additional software for user authentication, logging, separate notebook spaces etc. How to do this is obviously beyond the scope of this project. Be aware that in default Dockerfile setup, authentication has been disabled. In general, setting up remote services correctly to be used directly from Internet is fairly difficult to do properly from security standpoint of view if you want to do them alone. Internet deployments are best done using some Cloud provider infrastructure.


## Where to find more information

See references below. Check "Help" tab in Lab interface for further hints. All Python and R modules built into current Docker images are publicly available and well documented.


## License

This Docker image build system is licensed under MIT license. Check for details in **LICENSE** file.


## References

1. How to install Docker Engine on your platform properly: [Install Docker Engine](https://docs.docker.com/engine/install/)

2. Dockerfile Syntax details: [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)

3. Git Reference Documentation: [Reference](https://git-scm.com/docs)

4. Easy way to learn about Makefiles: [Learn Makefiles](https://makefiletutorial.com/)

5. Modern Git Development Strategy: [GiHub flow](https://docs.github.com/en/get-started/quickstart/github-flow)

6. Nice Python reference for engineers and scientists: [Python Programming And Numerical Methods: A Guide For Engineers And Scientists](https://pythonnumericalmethods.berkeley.edu/notebooks/Index.html)

7. R Project: [The R Project for Statistical Computing](https://www.r-project.org/)

8. Jupyter Lab: [Try Jupyter](https://jupyter.org/try)

9. Note on Docker volume permissions: [Why does use of "volumes" directive ruin directory ownership? #5507](https://github.com/docker/compose/issues/5507)

