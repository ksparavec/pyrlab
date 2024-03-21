## Proxy configuration

In default configuration, two types of proxies are used:

1. APT Proxy for proxying and caching connections to APT repositories and for downloads via http/s connections in general
2. PIP Proxy for proxying and caching connections to PyPI repositories

### APT Proxy

There is lot of documentation and examples available on Internet how to install and configure remote forward proxy in general. 

In particular, if you decide to follow default configuration and use APT-Cacher-NG (native on Debian and Ubuntu, but available for other distributions as well), see [Apt-Cacher-NG User Manual][1] for details or [Ubuntu Wiki page][2] for more gentle introduction. Main advantage is that it will allow caching of https URLs via HTTPS/// syntax without having to resort to some other more involved techniques commonly known as [SSL Bumping][3].

Another very popular open-source caching proxy is [Squid][5]. In case you want or must use it, you will want to check page on [proxying SSL sites][4]. Squid is more robust and general proxy software than APT-Cacher-NG, however, it is also more difficult to configure and maintain. Again, YMMV.

If you are working in an enterprise environment, you will probably have to use centralized proxy, whether you like it or not. Some proxies will allow just proxying but no caching, some will allow both. Most of them will require special access rules to be entered to restrict reachability. In this case you might have to ask your network administration to allow reaching Debian and PyPI mirrors via proxy, unless someone already has done that before you. Sometimes you will have to use authentication mechanisms as well. Nevertheless, it still may be advantageous configuring APT-Cacher-NG on your local machine, and then configure it to use enterprise proxy as upstream proxy.


### PIP Proxy

Efficient remote caching of packages from PyPI repositories requires specialized application software proxy because of module indexing feature that is required for `pip` client to work properly. It is important not to confuse caching packages locally on file system which is supported by `pip` client itself, and remote caching/proxying for which one needs additional software. Due to the nature of Docker containers, one does not want to use local caching feature (this is reflected in the way how `pip` gets invoked, see `sbin/init_lab.sh` for details). On the other hand, it is very advantageous to use remote caching/proxying software in order to significantly reduce the amount of traffic generated during container builds as well as to speed this process up.

There is one simple well-known solution tailored for Python software development: [devpi: PyPI server and packaging/testing/release tool][6]. In order to get it running quickly on your laptop or server, just [follow these steps][7].


### Proxy configuration in `Configuration.mk`

As already stated in [Configuration document](Configuration.md), there are three parameters related to proxying and caching:

```
APTPROXY   := http://172.17.0.1:3142
APTHTTPS   := yes
PIPPROXY   := http://172.17.0.1:3141
```

If you have installed APT-Cacher-NG on your host, its listener will default to port 3142, as shown in example above for `APTPROXY` parameter value. Also, default Docker gateway IP address will be the one shown in example above. If you had to change it for some reason, you need to adjust this in `Configuration.mk` accordingly.

If the proxy server supports HTTPS/// URL scheme like APT-Cacher-NG does, then set `APTHTTPS` to yes, otherwise to no. If set to yes, docker will communicate URL to the proxy server via http instead of https, and proxy will then connect itself to remote repository via https. This way packages get cached on the proxy server.

The IP address in `PIPPROXY` is again Docker gateway IP address. Port 3141 needs to be specified as parameter value when starting `devpi` server. Once started, `devpi` server will need a few minutes to download package indices from PyPI repository and store them locally, so some patience is recommended before starting to use it. You need to reserve about 20GB of local space on your machine for `.devpi` cache.

Please note that `devpi` server is tailored for software development and single user only. It is not a general robust software like APT proxies mentioned above. You might need to restart your build process couple of times when building your containers for the first time until `devpi` has cached everything. After that, it usually runs pretty smoothly without issues.

In case you don't want to use proxies at all, just comment these parameters in `Configuration.mk` out.


### Note on http transport for fetching packages from remote repositories

All APT repositories have been configured to use http instead of https. This may appear to be a security issue, however, note that:

1. no transport SSL connection encryption is required, because everything in remote APT repositories is public
2. no transport SSL connection validation is required, because upon download all packages get validated using more secure method using GPG keys

That being said, some enterprises may mandate using https transport regardless, mainly because of regulatory and auditing reasons. In this case you need to change http: into https: in `/etc/apt/sources.list` and in Dockerfile configuration sections, unless enterprise proxy does this automatically. Some experimenting might be necessary in this case.


[1]: <https://www.unix-ag.uni-kl.de/~bloch/acng/html/index.html> (Apt-Cacher-NG User Manual)
[2]: <https://help.ubuntu.com/community/Apt-Cacher%20NG> (Apt-Cacher NG Ubuntu Wiki)
[3]: <https://wiki.squid-cache.org/Features/SslPeekAndSplice> (Feature: SslBump Peek and Splice) 
[4]: <https://elatov.github.io/2019/01/using-squid-to-proxy-ssl-sites/> (Using Squid to Proxy SSL Sites)
[5]: <https://www.squid-cache.org/> (Squid: Optimising Web Delivery)
[6]: <https://github.com/devpi/devpi> (devpi: PyPI server and packaging/testing/release tool)
[7]: <https://devpi.net/docs/devpi/devpi/stable/+d/quickstart-pypimirror.html> (Quickstart: running a pypi mirror on your laptop)

