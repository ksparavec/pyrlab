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

### Security Considerations for Remote Access

When setting up remote access, consider the following security measures:

1. **Enable Authentication**: By default, JupyterLab runs without authentication. For remote access, you should enable it by removing the `--LabApp.token=''` parameter from the `jupyterlab.sh` script.

2. **Use HTTPS**: If exposing your JupyterLab instance to the internet, always use HTTPS. You can set this up using a reverse proxy like Nginx or Apache with SSL certificates.

3. **Firewall Configuration**: Only open the necessary ports (default: 8888 for PyLab, 9999 for RLab) and consider using a VPN for additional security.

4. **User Management**: Consider implementing user management and access control if multiple users will access the instance.

5. **Logging and Monitoring**: Set up proper logging and monitoring to track access and detect potential security issues.

### Reverse Proxy Setup Example

Here's a basic example of setting up Nginx as a reverse proxy for JupyterLab:

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/your/cert.pem;
    ssl_certificate_key /path/to/your/key.pem;

    location / {
        proxy_pass http://localhost:8888;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Remember to:
1. Replace `your-domain.com` with your actual domain
2. Update the SSL certificate paths
3. Adjust the port if you're using a non-default port
4. Add any additional security headers or configurations as needed

### Using Docker Compose for Remote Deployment

For more complex remote deployments, you might want to use Docker Compose. Here's a basic example:

```yaml
version: '3'
services:
  jupyter:
    image: pylab:latest
    ports:
      - "8888:8888"
    volumes:
      - ${HOME}/notebooks:/volumes/notebooks
      - ${HOME}/docker:/notebook
    environment:
      - ENVVARS=/notebook/.env
      - PORT=8888
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

This can be extended with additional services like Nginx for reverse proxy, monitoring tools, etc.

