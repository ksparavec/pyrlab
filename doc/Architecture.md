## Architecture

PyRLab project follows very basic and simple, yet powerful enough strategy to build and run Docker containers in an efficient and structured manner. Main principles are as follows:

* builds are always reproducible when using same set of parameters saved in configuration file
* builds use standard OS, Python and R tools only - no special tooling or knowledge how to use it is required
* builds can be done in command line as well as within GitLab CI/CD locally or remote with exactly the same results
* running containers does not require any kind of orchestration software, but can profit from it if you have it
* images use hierarchical structure that can easily be extended to add new images - see [Imaging document](Images.md) for details
* configurable parameters are passed between images in consistent manner without cluttering configuration file
* user can install additional JupyterLab extensions into persistent storage area without having to rebuild Docker image
* session details are saved into persistent storage area - container can always be restarted with session state fully preserved
* Python and R are installed into `/usr/local` container storage, however, user may install additional modules into persistent storage as well
* while it would be possible to use Python venvs, this is not recommended - after all, one of the main reasons to use Docker containers is to avoid messing with venv installations
* images can be pushed into public repositories and used on remote locations as well, including on premise and different cloud environments

While one might argue that many of these points are valid for any container based project, here all decisions have been made following these principles in consistent manner. You can easily extend the project with new modules and/or software packages without even touching Dockerfiles. If Dockerfiles need to be modified, this can easily be done just by following the style they are written in - you can find more about that below.

One more thing worth mentioning: building own containers from scratch has certain advantages compared to just using ones built be third parties. For example, if you would like to use NVIDIA GPU hardware, you might just use Docker containers available from NGC repository. But then if you want to extend them with new modules or software packages, you need to understand their architecture exactly. This may or may not be as easy as it is the case with PyRLab project.


### Dockerfile structure

If you look into Dockerfiles, you will find that they all follow same basic structure that can be summarized as follows:

* header block: ARG section is followed by ENV section and COPY section
* after header block, what follows are RUN blocks that always have embedded bash scripts starting with inclusion of some common variables and/or functions
* by using embedded bash scripts, we avoid the need to use for Dockerfiles typical multiline inline scripting style cluttered with ampersands and backslashes
* each RUN block is one logical layer that gets cached when succesfully built. If an error appears somewhere below, then image rebuilds are much faster by reusing cached layers before the block where error appeared, while at the same time avoiding creation of too many layers just by using RUN for each shell command separately
* depending on whether an image is thought for container instance creation or not, you will find final runtime block with ENTRYPOINT and CMD blocks preceeded with USER block

The last point requires a bit more explanation. The reason we use ENTRYPOINT with `tini` binary is that this binary is capable of OS signal handling so that all signals sent to container are always properly handled, without the need for user software like JupyterLab to handle them. CMD block makes it possible to provide own shell startup script or just use the provided default script `sbin/jupyterlab.sh`. Unless you are Docker container specialist, you will probably want to stick with default script, because it makes sure that:

* script commands get echoed into log file, all command errors break the script execution immediately and unset variables and parameters other than the special parameters are treated as an error when performing parameter expansion (`set -eux`, see bash(1) manual page for details)
* user defined environments variables, with path to configuration file stored in `ENVVARS` environment variable will get properly sourced into running shell
* `PATH`, `LD_LIBRARY_PATH`, and `JUPYTERLAB_DIR` environment variables are all properly set before JupyterLab execution
* JupyterLab is properly initialized for the user if necessary
* JupyterLab session is started in correct directory with custom listener and proxy port
* user may optionally supply its own script referenced by `RCS` environment variable that will be executed as well before invoking JupyterLab

You will also notice that PyLab and RLab Dockerfiles all use identical structure by using common template. Python modules are always installed with same `pip_install` shell function defined in shell header file. RLab Dockerfile has its specific RUN block that installs R packages from R-CRAN repository in an efficient manner from source. This RUN block would surely profit from some code refactoring to make it more readable and parametrizable, which is one of the planned future feature tasks.


### Security considerations

Please note that build phase commands are always executed in the context of `root` user in container, whereas run phase commands are executed in the context of `notebook` user in container, which is mapped to real user via `UID` and `GID` parameters specified in configuration file. Now, `root` user is required during build phase. Some Docker orchestration environments may restrict or even completely ban usage of `root` user even during build phase for security reasons. Avoid using such environments at all costs. Contrary to popular belief and marketing material distributed by software manufacturers of these environments, restricting build phase with such rules will have nearly zero positive impact on your security but will make it virtually impossible to work with containers efficiently. That being said, you may be forced into using them anyway. In that case, you are unfortunately out of luck and can't make use of PyRLab project.

One thing to be mentioned though in the context of security: `notebook` user is added `sudo` rights after created. This is useful when experimenting with containers in development environments where you want to be able to change into root shell to install some additional software before rebuilding the image. Once you reach production environment, you may want to remove these rights for security reasons. Currently you must comment out the appropriate line in `Dockerfile.Base` (second to the last line). This will be parametrized in the future so that you will be able to specify which environment you use to run the container in, and then apply appropriate security policy to the container image. Another future feature task. Please note that just for normal container runs, `sudo` rights are not necessary.

If your containers are running on remote servers, you will want to implement at least user authentication on application level. To achieve that, just remove `--LabApp.token=''` from the last line in `sbin/jupyterlab.sh`. Now you will need login token for the session. You can find it by inspecting runtime Docker logs. For example, in case of Pylab container with all default parameters set, just execute:

```
$ docker logs pylab_3.11-bullseye
```

and copy the security token mentioned at the end of the log file into browser session.


### Deployment considerations

Finally, couple of comments wrt. to Docker orchestration software. Currently there is no explicit support. Well, actually not quite true, there is some effort going on to support Docker Composer with YAML configuration file. This is planned feature as well. Currently, plans exists to support Kubernetes on prem and three major cloud providers (AWS, Azure and GCP). Please note though that the way images are built will stay the same, only deployment will be augmented to support these environments explicitly.

