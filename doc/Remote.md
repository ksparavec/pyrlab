## Remote considerations

If you use remote server system instead of local desktop to run containers, you will need to replace localhost IP with your real host IP and make sure you can access it on port specified from your workstation. You may need to open some port on your firewall or do some port redirection with ssh or even create full tunnel to your server system.

If you have ssh access to remote server system, you can create internal ssh tunnel with port forwarding instead. Such setup is useful for testing purposes.

For example, let's suppose you have started your pylab instance on remote server with standard port 8888. Also let's suppose that remote server IP number is 192.168.1.100. In this case, in order to connect to remote instance from your workstation, you can use SSH port forwarding like this (this supposes that you use Linux, Unix or Mac OS as your Desktop OS):

```
$ ssh 192.168.1.100 -fN -L 8888:localhost:8888
```

If you have MS Windows installed on your desktop, you will have to check your ssh client documentation for information how to do port forwarding. All major ssh clients are able to do it.

You can now open connection to your container using localhost IP as usual.

In order to create your Docker instance available from Internet directly (similar to `https://nbviewer.org` for example), you would have to create reverse proxy in front of it and some additional software for user authentication, logging, separate notebook spaces etc. Be aware that in default Dockerfile setup, user authentication has been disabled. At the bare minimum, you would need to reenable user authentication for containers.

In general, exposing public remote access requires proper security mechanisms in place. How to do this is obviously outside of the project scope.

