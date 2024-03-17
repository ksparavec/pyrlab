# Python/R Jupyter Lab Docker Container Image Project


## What is the goal of this project

This project builds easy to use custom Docker containers with custom Python modules and custom R modules built-in based on current stable Python and R distributions. Please see links below for more information on Docker, Python and R.


## Release Notes

Starting with Release 1.0.0, there is a list of release notes available. See [Release Notes](doc/Release.md).


## Quick Start

See [Installation document](doc/Install.md) for detailed instructions. In a nutshell, you need Linux or Mac workstation/server with Docker Engine, Make and Git installed. Then execute following command sequence:

```
$ git clone https://github.com/ksparavec/pyrlab.git
...
$ cd pyrlab
$ make build
...
$ make tag_pylab PYLAB=torch
$ mkdir ${HOME}/notebooks
$ mkdir ${HOME}/docker
$ make pylab
```

and point your browser to `http://127.0.0.1:8888/lab`.


## Available project documentation

* [Installation document](doc/Install.md)
* [Configuration document](doc/Configuration.md)
* [Proxy usage document](doc/Proxy.md)
* [Docker Imaging document](doc/Images.md)
* [GPU support document](doc/GPU.md)
* [Remote access document](doc/Remote.md)
* [Architecture document](doc/Architecture.md) - not yet written.


## Why another Python/R build and deployment system?

Because I became annoyed with managing Python environments manually. I never know for sure what packages I have installed without performing inspection. I also don't want to upgrade my Python distribution manually either from time to time or build it entirely from scratch by copy-pasting commands from online manuals. Python distribution that comes with your standard Linux distribution is usually hopelessly out dated and not well maintained, except for the critical security related fixes. Also you may want to access your distribution remotely by using your browser alone. Would it not be nice to have everything packaged, customized, upgraded with single command, as well as have it in reusable and shared form, so other people can use it as well, and on top of all this, that it works regardless of which platform operating system and package manager you normally use in your everyday work?


## Where to find more information

Project documentation contains links to specific material. For general information on Docker, Make, Git, JupyterLab, Python and R see [References document](doc/References.md).

Also check "Help" tab in Lab interface for further hints. All Python and R modules built into current Docker images are publicly available and well documented.

For specific shell commands help, check manual pages in Terminal using standard `man` utility.


## License

This Docker image build system is licensed under MIT license. Check for details in [LICENSE](LICENSE.md) file.
