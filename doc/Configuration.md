## Configuration

There are several places to configure build and run process:

1. `Configuration.mk` Makefile configuration file
2. `base/*.txt`, `rbase/*.txt`, `pylab/*.txt`, `rlab/*.txt` simple text configuration files
3. `docker/Dockerfile*` headers


### `Configuration.mk` Makefile configuration file 

This is the most important place to configure build and run process.

All of parameters have been already commented and should be more or less self-explanatory. Unless you already have listeners running on some of the default ports, there is usually no reason to change them. Same goes for image names, optional default user scripts and environment variables file name.

Some of the more common parameters you may want to customize:

* `BUILD_LOG`: specify log file (can be in absolute or relative path). You can use output of shell command to create log file name with a timestamp like in provided default configuration.

* `PYTHONBASE`: specify base image. Python images from Docker Hub are used for the purpose of this project. Default is 3.12-bullseye.

* `PYLAB`: this is just selector for `pylab` image flavor. You can currently choose between 'mini', 'common', 'torch', 'tf' and 'jax'. Most complete is 'torch'. You may want to select 'jax' if you need latest jax version with CUDA support. Alternatively you could decide to start with 'mini' version and then build incrementaly your own package list.

* `CUDA_INSTALL`: Whether or not install CUDA support into base image. See [GPU document](GPU.md) for details.

* `DOCKER_ARGS`: Additional arguments for docker when using CUDA support. See [GPU document](GPU.md) for details.

* `NOTEBOOKS`: Persistent directory on host for Python/R notebooks. See [Install document](Install.md) for details.

* `DOCKER`: Persistent directory on host for home directory of notebook user. See [Install document](Install.md) for details.

* `APTPROXY`: Apt proxy URL. See [Proxy document](Proxy.md) for details.

* `PIPPROXY`: PIP proxy URL. See [Proxy document](Proxy.md) for details.

* `PYPORT`: Port for JupyterLab in PyLab container (default: 8888)

* `DTPORT`: Port for dtale in PyLab container (default: 40000)

* `TFPORT`: Port for tensorboard in PyLab container (default: 6006)

* `RPORT`: Port for JupyterLab in RLab container (default: 9999)

* `PYRCS`: Optional script to execute in PyLab container before JupyterLab

* `RRCS`: Optional script to execute in RLab container before JupyterLab

* `USERLAB`: Optional script to execute instead of jupyterlab.sh

* `ENVVARS`: Environment variables definitions to be used in container (default: /notebook/.env)

* `UID`: UID of notebook user in container (default: 1000)

* `GID`: GID of notebook user in container (default: 1000)


### Text configuration files

These just list Python or R modules (one per line) that you want to put into your images. You can also specify module versions (output of `pip freeze`), however, contrary to popular belief, this is usually not the best idea. The reason is, you will severely limit pip dependency resolver if you do that and you will probably miss the latest bug fixes. Nevertheless, in enterprise environments, where stability and security are of paramount importance, you may want to restrict module versions. Another use case for this is to document the exact module versions you used when testing image for specific purpose i.e. with specific notebooks and you want these test cases to be perfectly reproducible. As usual, YMMV.

In general, it is advisable to use modules that have been published to PyPI repository. Nevertheless, sometimes you will want to use development version that has not been published yet or you have your own/proprietary modules stored in local Git repository. In this case, make sure they are installable with pip, and then use 'git+https' syntax to include them into Docker images. See `pylab/requirements_repos.txt` for couple of examples.


### Dockerfile headers

Configuration parameters (`ENV` parameters) in Dockerfiles are unlikely to change often, if at all. On the other hand, you may want to add your own if you decide to extend and/or create new Dockerfiles for new image flavors. It is advisable to keep them tight to the image where they are used. Some of the global parameters defined in `Configuration.mk` are propagated into Dockerfiles as well.

See also [Architecture document](Architecture.md) for more information on Dockerfiles structure.

