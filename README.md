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

Many hundreds of lines and several minutes later (depending on how fast/slow your hardware and Internet connection are), you will obtain three Docker images as follows:

```
$ docker image ls | grep pyrlab
pyrlab-latex              latest              b8f64b3c9a0d   2 hours ago    1.5GB
pyrlab-slim               latest              32f27ebd2439   2 hours ago    957MB
pyrlab-build              latest              fe4060bf6672   2 hours ago    1.81GB
```

**pyrlab-slim** image is complete run time image with all custom Python and R modules, but without development tools. Python and R modules are stored in highly compressed tarballs so that total size of Docker image is still under 1 GB. These tarballs get automatically uncompressed before starting Jupyter Lab at runtime - this is the reason you need to wait a bit. Note that "slim" is a relative term here - Jupyter Lab requires lots of support software packages to run properly, and R distribution is not that small either. Custom Python and R modules do get compressed, but even these highly compressed tarballs still take more than half of total Docker image size with distributed extra Python modules list.

**pyrlab-latex** is the same as **pyrlab-slim**, but with LaTeX support for Jupyter notebooks.

**pyrlab-build** image has all development tools installed and is used to fetch/compile/install new Python and R packages from remote repositories and compress them. If you use Python C/C++ extensions like Cython, you will need to load this image instead of **pyrlab-slim** or **pyrlab-latex** to compile your extensions before using them. It is recommended to keep your extensions together with notebooks in external directory which is also local copy of your git repository so you can track changes in your notebooks and software properly. See References section below for more information how to use git, if for some reason you are not familiar with it.

Please note that using this image for Jupyter Lab containers is definitely not recommended on remote server systems, especially if they are available to general public, because of possible security risks. See notes on security below as well.


## Customization 

Please check **requirements.txt** and **r_packages.txt** for the list of included Python and R modules/packages and edit according to your needs. You are advised to remove any unneeded modules from **requirements.txt**. List distributed with project is geared towards engineers and scientists that need tools for numerical analysis and machine learning (not accidentally the areas that I am currently actively involved with). YMMV, of course.

After editing, you will have to rebuild all three images:

```
$ make clean
...
$ make build
...
```

First command will wipe old pyrlab images if present, and second one will rebuild them from scratch.


## Usage

After build process has finished successfully, you can start your new container in the following way:

```
$ docker run -it --rm -v ${MY_NOTEBOOK_REPOSITORY}:/notebook/files -e PORT=${PORT} -p ${PORT}:${PORT} ${IMAGE}
```

You need to replace MY_NOTEBOOK_REPOSITORY, PORT, and IMAGE with actual values. For example, if you use bash, you could do:

```
$ export MY_NOTEBOOK_REPOSITORY=$HOME/notebooks
$ export PORT=9000
$ export IMAGE=pyrlab-latex
```

Important: MY_NOTEBOOK_REPOSITORY must exist and be writable directory on the local system available to docker daemon (usually your workstation, but not necessarily). If you use Makefile targets, make sure that you have it defined properly on top of Makefile (FILES parameter).

If you point MY_NOTEBOOK_REPOSITORY to non-existent directory on Docker host system, Docker will create it itself, but unfortunately with wrong permissions (see link below for detailed discussion why). This is not what you want, so please make sure that this directory really exists and has correct permissions **before** starting your container. See note below in References section for more information.

Now, just execute Docker command above. This will start new container instance running on localhost:port specified. Exact URL for your browser is shown at the end of the Docker logs. You just need to copy paste it into your browser address input line. Container remains in foreground and keeps your terminal locked.

If you don't want this behavior, there is one Makefile target that starts container in background, waits 60 seconds, and then picks the correct URL from Docker logs and executes browser on your machine in single step:

```
$ make lab
```

Please note that start will take (at least) 60 seconds because module images must be uncompressed first. In case that you get an error, this probably means that your machine needs more than 60 seconds to uncompress and start Jupyter Lab. In this case, you can increase number of seconds, I have not found any nice and simple way how to wait for Docker container to start if put into background and execute browser command afterwards. If you have it, please let me know about it.

You can change default parameter values defined at the top of Makefile for Docker image, port, notebook directory and wait time by adding parameters to command above. For example, to start container based on **pyrlab-slim** image with listener on port 9346, with notebooks stored under ~/workdir and reduce wait time to 45 seconds, if your machine is at least as fast as mine, type:

```
$ make lab IMAGE=pyrlab-slim PORT=9346 FILES=~/workdir PAUSE=45
```

This will produce output similar to this one and fire your browser 45 seconds later:

```
docker run -it --rm -v /home/user/workdir:/notebook/files -e PORT=9346 -p 9346:9346 -d pyrlab-slim
8519010aad8f5c88c71c4d451eab239584f29c422b95747879c16e571c88d03d
sleep 45
python3 -m webbrowser -t http://127.0.0.1:9346/lab?token=9369873c0aeee047593763d1351622aaff13e71df1265776

```

If you hate waiting 45 seconds for modules tarballs to uncompress each time you start new container instance and don't care about Docker image sizes, i.e. want to trade size for speed, just remove single line from Dockerfile (search for `./compress.sh; \` in single line and remove it). You can then reduce PAUSE parameter to something like 3 seconds or even less.

If you use remote server system, then http link echoed by Docker will obviously not work, because it contains localhost as IP. You will need to replace it with your real host IP and make sure you can access it on port specified from your workstation. You may need to open some port on your firewall or do some port redirection with ssh or even create full tunnel to your server system. How to do any of that is beyond the scope of this document. Contact your friendly system and network administrator for help. Same remark goes for typical corporate environments where direct Internet access is either forbidden or mandated through some proprietary external proxy that you don't have access to. Support for in-container proxy to do local caching is a planned feature though. It may also enable using of external proxies that require user authentication. Stay tuned!


## Testing of new modules before building new image

You can manually load and test modules before building images. For this purpose you can use:

```
$ make bash
```

This will start new container instance based on pyrlab-build image and spawn new bash shell for you. First thing to do inside container is to manually uncompress the custom Python and R module tarballs:

```
notebook@e0a35c8c449d:~$ ./uncompress.sh
```

After that, you can work with pip and python as usual. For example:

```
notebook@e0a35c8c449d:~$ pip list
...
notebook@e0a35c8c449d:~$ pip install --user hg2g
...
notebook@e0a35c8c449d:~$ ipython
Python 3.9.11 (main, Mar 17 2022, 00:56:40)
Type 'copyright', 'credits' or 'license' for more information
IPython 8.1.1 -- An enhanced Interactive Python. Type '?' for help.

In [1]: from hg2g import *

In [2]: answer = Deep_Thought.question("What is the Answer to Ultimate Question of Life, the Universe, and Everything???")

(wait for couple of million years...)

In [3]: print(answer)
42
```

OK, OK, I know that last Python example is a bit of stretch, but I could not resist ;)

Note that you have to use **--user** option with pip. Also note that modules will be installed in temporary container image which will be discarded after container termination.

You can do the same in your Jupyter Lab web interface using Terminal App from Launcher. I prefer working in classical terminal instead of browser when typing commands. YMMV, of course :)


## Notes on security

Docker, in general, does not provide or provision any kind of security policies automatically for you. This means that you need to take care about them. As long as you use it on your local workstation with localhost links, this does not present much of the issue (at least not more than you already have). If you decide to use Jupyter Lab on remote server machines, you need to take some measures to reduce potential security risks:

1. Always use authentication, either by token or user/password with Jupyter Lab instances,

2. Don't start Jupyter Lab containers on remote server machines based on **pyrlab-build** image because it contains C compiler and linker among other things,

3. Make sure that access to remote container is protected by proper firewall rules,

4. Restrict direct Internet access to links/domains from your container instance to those that you really need. This can be done with the help of an external Web Application Proxy. Ask your friendly network administrator for help if you need it. Please note that you will have to define this proxy in your Python session first in order to access external links (for example Yahoo Finance portal to get financial data for analysis). See documentation for your Python module for details,

5. Use your common sense (good thing to do in general, not only when it comes to security).


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

