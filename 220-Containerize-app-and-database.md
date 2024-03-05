# Step 2: Containerize Your E-Commerce Website and Database

## A. Storing a Script in a ConfigMap

### Config Goland with Docker Desktop for Linux

- Change docker context to desktop-linux

  ```shell
  docker context ls
  docker context use desktop-linux
  ```

- Config Goland - Docker Tools - Execution path
    - `Settings / Build, Execution, Deployment / Docker / Tools / Docker execution` to `/usr/local/bin/docker`
    - `Settings / Build, Execution, Deployment / Docker / Tools / Docker Compose execution` to `/usr/local/bin/docker`

- Config Goland - Docker Tools - Docker run configuration
    - Connect to Docker daemon with:
        - Unix socket: `desktop-linux` `unix:///home/USER/.docker/desktop/docker.sock`

### Containerize the app

```Dockerfile
# Use `php:7.4-apache` as the base image.
FROM php:7.4-apache

# Install `mysqli` extension for PHP.
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && install-php-extensions mysqli

# Copy the application source code to `/var/www/html/`.
COPY ./* /var/www/html/

# Update database connection strings to point to a Kubernetes service named `mysql-service`.
ENV DB_HOST="mysql-service"

# Expose port `80` to allow traffic to the web server.
EXPOSE 80
```

### Build & Push the Docker image

- Build the image

```shell
cd 220-Containerize-e-commerce-website-and-database/learning-app-ecommerce
docker build -t lethang7794/ecom-web:v1 .
```

- Make sure command is not saved int the history

```shell
setopt HIST_IGNORE_SPACE
```

- Login to Docker hub

```shell
gpg --generate-key
pass init  <generated gpg-id public key>
docker login
```

- Push the image

```shell
docker push lethang7794/ecom-web:v1
```

The image is available at Docker
Hub [lethang7794/ecom-web](https://hub.docker.com/repository/docker/lethang7794/ecom-web/)

Ref:

- [Install Docker Desktop on Linux](https://docs.docker.com/desktop/install/linux-install/)
- [Docker connection settings](https://www.jetbrains.com/help/go/settings-docker.html)
- [php:7.4-apache Docker image](https://hub.docker.com/layers/library/php/7.4-apache/images/sha256-18b3497ee7f2099a90b66c23a0bc3d5261b12bab367263e1b40e9b004c39e882?context=explore)
- [mysqli | Installation](https://www.php.net/manual/en/mysqli.installation.php)
- [Easy installation of PHP extensions in official PHP Docker images](https://github.com/mlocati/docker-php-extension-installer)
- [Sign in to Docker Desktop](https://docs.docker.com/desktop/get-started/)
- [docker login returns "error getting credentials - err: exit status 1 ..." | Github](https://github.com/docker/docker-credential-helpers/issues/60)

## B. Database Containerization

### Use the official MariaDB image

### Prepare the database initialize script with ConfigMap

- Store the script in a ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-load-script-configmap
data:
  db-load-script.sql: |
    USE ecomdb;
    CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
    INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
```

- Mount the ConfigMap as a volume in the Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: my-image
      volumeMounts:
        - name: script-volume
          mountPath: /scripts
  volumes:
    - name: script-volume
      configMap:
        name: db-load-script-configmap
```

- Execute the script inside the container

```shell
#!/bin/bash
/scripts/my-script.sh
```
