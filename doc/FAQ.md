## Common questions that you might (have) ask(ed) yourself

Q. I already use a JupterLab based project/IDE that I am quite happy with. Why should I switch to your project?

A. Depends on what features are important to you. See [Architecture document](Architecture.md) for more information on features that may be interesting to you. Simple rule of the thumb: if Docker is important for your use case or you consider using it in the future, then you should definitely check this project out. But there are many other reasons to use it as well. See main [README](../README.md).


Q. I see that you use PIP for package installations. Can I use Conda as well?

A. Short answer: no. Long answer: you might have such use case that makes it possible to use them together. See [Using Pip in a Conda Environment][1] for more information. In this case, you will have to extend and manage Dockerfiles with Conda yourself.


Q. Will you support Conda in PyrLab in the future explicitly?

A. No. Using PIP and Conda together is generally bad idea, whereas using Conda alone is not enough in general. When creating this project, I decided to go with most general and simplest packaging manager, and that is without any doubt PIP.


Q. Why do you use separate PyLab image flavors for different compute backends (tensorflow, torch and jax)?

A. Because some dependencies, especially nvidia modules are incompatible between them, i.e. backends have different nvidia modules version dependencies. In principle, it would be possible to find common set of versions that would work with all three backends, but this would be tedious manual process and it would hold for limited time period only. Also, this would mean some backends would not profit from newer underlying module versions where bugs have been fixed and/or features added. The last argument is also the reason why package versions in general are not pinned at all (but see one notable exception next). Project relies on PIP dependency resolution process to take care of correct and best package versions available at the moment when images are built without having to make manual interventions each time.


Q. Why do some packages exist only with some backends and not others?

A. See above. Package that requires tensorflow, like trax for instance, can not be part of torch or jax image.


Q. But I can see jax library present in tensorflow image. Why is that?

A. Because trax needs it. However, it does not support GPU and is usually at least one version behind. Therefore, separate jax image exists.


Q. Why did you pin tensorflow version?

A. Because current tensorflow version does not work with current nvidia toolkit and libraries. As soon as this has been fixed, pin will be removed. Nvidia toolkit and libraries have always higher update priority than application software on top of them.


Q. In default configuration, ports of all PyLab image flavors are the same. That means I can run only one flavor at time. Could you make it possible to run all container flavors at once?

A. You can do it yourself. You need to override ports in command line. See [Install document](Install.md) for an example how to do this.


Q. All this is nice, but what I desperately need is automated deployment process to Kubernetes/AWS/Azure/GCP... Will you support this in the future?

A. Yes, definitely. Plan is to support at least the four platforms mentioned above, and then some. Stay tuned for new releases!


Q. Can I contribute?

A. Absolutely. Just create new git branch for your work, do what you need and then create pull request. I shall consider everything that does not defy basic project principles and adds new value to the project. Bug fixes are also welcome. On the other hand, just editing white space or shuffling existing code is not ;)


Q. Any hints regarding contributions?

A. Automatic deployment support is really in focus now. If you have some experience with Ansible and platforms mentioned above, let me know.


[1]: <https://www.anaconda.com/blog/using-pip-in-a-conda-environment> (Using Pip in a Conda Environment)

