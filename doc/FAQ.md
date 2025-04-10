## Common questions that you might (have) ask(ed) yourself

**Q. I already use a JupterLab based project/IDE that I am quite happy with. Should I switch to your project?**

A. Depends on what features are important to you. See [Architecture document](Architecture.md) for more information on features that may be interesting to you. Simple rule of the thumb: if Docker is important for your use case or you consider using it in the future, then you should definitely check this project out. But there are many other reasons to use it as well. See main [README](../README.md).


**Q. Which version of the project should I install?**

A. In general, it is safe to use the current main branch. I create releases from time to time, but this is more to indicate new major features or important bug fixes. The latest stable version is 1.1.1.


**Q. Is GitLab support complete?**

A. Not at all. Current pipeline is able to build and deploy pylab and rlab images on GitLab server itself under gitlab-runner uid/gid. This is less than ideal. Better implementation would take care of deploying under different uid/gid, use Linux namespaces, push images to remote repositories and deploy them on remote servers. These features will be added within remote deployment support for on prem and cloud environments.


**Q. Will you support CI/CD software other than GitLab?**

A. I would like to see support for Jenkins and perhaps GitHub as well.


**Q. Can I use MS Windows as platform to build and deploy images?**

A. Honestly, I have no idea and can't give you any hints what needs to be done there in order to make it work, or if it is possible at all, even. Frankly speaking, I don't care about it. If you are a big fan of this platform and know what needs to be done, you are welcome to contribute to the project. See below.


**Q. I see that you use PIP for package installations. Can I use Conda as well?**

A. Short answer: no. Long answer: you might have such use case that makes it possible to use them together. See [Using Pip in a Conda Environment][1] for more information. In this case, you will have to extend and manage Dockerfiles with Conda yourself.


**Q. Will you support Conda in PyrLab in the future explicitly?**

A. No. Using PIP and Conda together is generally bad idea, whereas using Conda alone is not enough in general. When creating this project, I decided to go with most general and simplest packaging manager, and that is without any doubt PIP.


**Q. Why do you use separate PyLab image flavors for different compute backends (tensorflow, torch and jax)?**

A. Because some dependencies, especially nvidia modules are incompatible between them, i.e. backends have different nvidia modules version dependencies. In principle, it would be possible to find common set of versions that would work with all three backends, but this would be tedious manual process and it would hold for limited time period only. Also, this would mean some backends would not profit from newer underlying module versions where bugs have been fixed and/or features added. The last argument is also the reason why package versions in general are not pinned at all (but see one notable exception next). Project relies on PIP dependency resolution process to take care of correct and best package versions available at the moment when images are built without having to make manual interventions each time.


**Q. Why do some packages exist only with some backends and not others?**

A. See above. Package that requires tensorflow, like trax for instance, can not be part of torch or jax image.


**Q. But I can see jax library present in tensorflow image. Why is that?**

A. Because trax needs it. However, it does not support GPU and is usually at least one version behind. Therefore, separate jax image exists.


**Q. In default configuration, ports of all PyLab image flavors are the same. Looks like that I can run one flavor only. Could you make it possible to run all container flavors at the same time?**

A. You need to override default port values. For example, imagine that you already have one PYLAB instance running with standard ports defined. In order to start new instance of torch flavor, you need to execute:

```
$ make tag_pylab PYLAB=torch
...
$ make pylab TFPORT=6016 PYPORT=8898 DTPORT=40010
...
```


**Q. All this is nice, but what I also desperately need is automated deployment process to Kubernetes/AWS/Azure/GCP... Will you support this in the future?**

A. Yes, definitely. Plan is to support at least the four platforms mentioned above, and then some. Stay tuned for new releases!


**Q. Are there any security concerns I should be aware of?**

A. Given that project is based on Docker, all [security considerations][2] regarding this platform apply. See also [Architecture document](Architecture.md).


**Q. Can I contribute?**

A. Absolutely. Just create new git branch for your work, do what you need and then create pull request. I shall consider everything that does not defy basic project principles and adds new value to the project. Bug fixes are also welcome. On the other hand, just editing white space or shuffling existing code is not ;)


**Q. Any hints regarding contributions?**

A. Automatic deployment support based on GitLab is top priority right now. Also CI/CD support for building images on other CI/CD platforms comes to mind. Further work on YAML configuration, especially with common configuration file support for both `make` and `docker compose`. Last but not least, automatic image testing based on GitLab pipelines and Python testing frameworks. If you have some experience with automated testing frameworks, let me know.


[1]: <https://www.anaconda.com/blog/using-pip-in-a-conda-environment> (Using Pip in a Conda Environment)

[2]: <https://docs.docker.com/engine/security/> (Docker security)
