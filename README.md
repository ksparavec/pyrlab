# Python/R Jupyter Lab Docker Container Image Project

## What is the goal of this project

This project builds easy to use custom Docker containers with custom Python modules and custom R modules built-in based on current stable Python and R distributions. Please see links below for more information on Docker, Python and R. After starting Docker container, you will obtain Jupyter Lab web interface link ready to use with your web browser.


## Why another Python/R build and deployment system?

Because I became annoyed with managing Python environments manually. I never know for sure what packages I have installed without performing inspection. I also don't want to upgrade my Python distribution manually either from time to time or build it entirely from scratch by copy-pasting commands from online manuals. Python distribution that comes with your standard Linux distribution is usually hopelessly out dated and not well maintained, except for the critical security related fixes. Also you may want to access your distribution remotely by using your browser alone. Would it not be nice to have everything packaged, customized, upgraded with single command, as well as have it in reusable and shared form, so other people can use it as well, and on top of all this, that it works regardless of which platform operating system and package manager you normally use in your everyday work? If answer to any or all of these questions is yes, please read on.


## Why don't just use Anaconda/Homebrew/ActiveState/\<put your favorite Python distribution name here\>??

Because they do not fulfill at least one (in many cases more than one) of the requirements from above. In addition, I wanted to have a solution where both Python and R are treated in the same way, when looking just from user perspective.


## Note on Docker base images

In this project we use latest stable Python images from DockerHub as base images. This makes it possible to always have latest stable bug fixed Python version without having to compile and test it afterwards before using it. Python base images use special version of Debian base image, therefore it is possible to use apt package manager for installing additional system packages. We use this to install latest stable R distribution among other things. See Dockerfile for details if you are interested.

Please note that, in order to add or remove your custom Python modules and R packages, you don't need to edit or even understand Dockerfile logic. Just edit **requirements.txt** and **r_packages.txt** and rebuild container images with single command, as explained below.


## Prerequisites

1. Fast modern hardware. Especially important is fast NVME or SSD flash for image storage and as package build space. Using classical disks is for the lack of performance not recommended,

2. Linux or Mac on desktop (or some other Unix on server) operating system installed on your hardware. Local or Cloud VMs are fine, as long as they are properly configured on hypervisor so that they get direct access to fast storage. Using MS Windows is NOT recommended, neither as Docker host platform, nor as VM hypervisor. Use it only if you believe that you really must, but do not ask me to help you if you are hit with problems (and you will be, sooner or later),

3. Docker Engine, git and make installed on your host platform OS, You are advised to install Docker from docker.io, i. e. not the version available from your platform distribution. Hints how to do it in a way that you get automatic updates are available from link below. Make and git are probably already installed on your system. If not, just use your OS package management tool to install them (or ask your friendly system administrator to do that for you). If you have access to Docker orchestration software like Kubernetes, feel free to use it, but I do not provide hints here,

4. Reasonably fast Internet connection with low latency and unlimited traffic. Build process currently requires direct Internet connection or transparent proxy. Using explicitly configured proxies is currently not supported, but is a planned feature for future release.


## Build your Docker images

Just two simple steps are necessary:

1. Copy pyrlab repository from GitHub to your system using git

```
$ git clone https://github.com/ksparavec/pyrlab.git 
```

2. Change your working directory into **pyrlab** directory and build Docker images

```
$ cd pyrlab
$ make build
...
```

Thousands of lines and several minutes later (depending on how fast/slow your hardware and Internet connection are), you will obtain four Docker images (if you have some other unrelated images with lab in their names, please ignore them):

```
$ docker image ls | grep lab
rlab                    latest          eca0464b8954   36 minutes ago   3.08GB
rlab-base               latest          017d55bc3964   44 minutes ago   1.84GB
pylab                   latest          56678e3118cf   2 hours ago      6.79GB
pyrlab-base             latest          d90e81da4fd5   2 hours ago      1.69GB
```


**pyrlab-base** image contains all necessary system libraries and packages to run Python. You can't create container from this image. Its only purpose is to be used as base image for building **pylab** and **rlab-base** images.

**pylab** image is final image that contains all custom Python modules to run Python notebooks with **Python** kernel.

**rlab-base** image contains all necessary system libraries and packages to run R. You can't create container from this image. Its only purpose is to be used as base image for building **rlab** image.

**rlab** image is final image that contains all custom R modules and necessary Python modules to run Python notebooks with **R** kernel.


## Customization 

Please check following configuration files for customization of packages and modules:

* **base_debs.txt** : you can add Debian packages here if necessary to build custom Python modules
* **requirements.txt** : add here any other **Python** modules you need in your project
* **r_debs.txt** : you can add Debian packages here if necessary to build custom R modules
* **r_packages.txt** : add here any other **R** modules you need in your project

After editing, you will have to rebuild images:

```
$ make build
```

Docker should be able to figure out which images have to be rebuilt automatically and rebuild only those. If you want to be sure nothing stale remains, execute make with clean target before building:

```
$ make clean
$ make build
```


## Usage

After build process has finished successfully, you can start your new containers and point browser to them in the following way:

```
$ make pylab
$ make rlab IMAGE=rlab PORT=9999
```

If you use remote server system, then http link echoed by Docker will obviously not work, because it contains localhost as IP. You will need to replace it with your real host IP and make sure you can access it on port specified from your workstation. You may need to open some port on your firewall or do some port redirection with ssh or even create full tunnel to your server system. Instead of pylab and rlab, use start_pylab and start_rlab targets just to start containers without browser.

Please note that you must use different ports for pylab and rlab containers for obvious reasons. In case of rlab, you must specify both IMAGE and PORT parameters, otherwise defaults from Makefile will be taken, which is not what you want (defaults are suitable for pylab container).


## Further work

Planned features include adding support for corporate proxies, frontend proxy with certificates so you can access your containers on remote infrastructure securely, adding support for starting and running containers in parallel on remote infrastructure. Stay tuned!


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

