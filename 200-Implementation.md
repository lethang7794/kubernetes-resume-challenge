# KRC Implementation

## Step 1: Certification

To tackle this challenge effectively, challenger needs to have a solid understanding of Kubernetes concepts and
practical experience - equivalent to passed a Certified Kubernetes Application Developer (CKAD).

Before this challenge,

- I've used K8s at work to develope Go web application & deploy containerized app to AWS EKS.
- I've read (& followed) 2 famous books about Kubernetes
    - Kubernetes: Up and Running: Dive into the Future of Infrastructure (3rd Edition)
    - Kubernetes in Action, Second Edition

But it's almost one year ago, so I'll

- follow KodeKloud Kubernetes Crash Course to regain my knowledge about K8s for this challenge
- take the CKDA certification later (in this year)

## Step 2: Containerize Your E-Commerce Website and Database

```markdown
### A. Web Application Containerization

1. **Create a Dockerfile**: Navigate to the root of the e-commerce application and create a Dockerfile. This file should
   instruct Docker to:

    - Use `php:7.4-apache` as the base image.
    - Install `mysqli` extension for PHP.
    - Copy the application source code to `/var/www/html/`.
    - Update database connection strings to point to a Kubernetes service named `mysql-service`.
    - Expose port `80` to allow traffic to the web server

2. **Build and Push the Docker Image**:

    - Execute `docker build -t yourdockerhubusername/ecom-web:v1 .` to build your image.
    - Push it to Docker Hub with `docker push yourdockerhubusername/ecom-web:v1`.
    - **Outcome**: Your web application Docker image is now available on Docker Hub.

### B. Database Containerization

- **Database Preparation**: Instead of containerizing the database yourself, you'll use the official MariaDB image.
  Prepare the database initialization script (`db-load-script.sql`) to be used with Kubernetes ConfigMaps or as an
  entrypoint script.
```

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

## Step 3: Set Up Kubernetes on a Public Cloud Provider

## Step 4: Deploy Your Website to Kubernetes

## Step 5: Expose Your Website

## Step 6: Implement Configuration Management

## Step 7: Scale Your Application

## Step 8: Perform a Rolling Update

## Step 9: Roll Back a Deployment

## Step 10: Auto-scale Your Application

## Step 11: Implement Liveness and Readiness Probes

## Step 12: Utilize ConfigMaps and Secrets

## Step 13: Document Your Process
