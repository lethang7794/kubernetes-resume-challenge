# KRC Prerequisites

This setup guide is for Fedora (Linux)

## Docker and Kubernetes CLI Tools: Essential for building, pushing Docker images, and managing Kubernetes resources

- Docker

  ```bash
  mkdir setup-krc
  cd setup-krc

  DOCKER_DESKTOP_VERSION=4.28.0
  DOCKER_DESKTOP_ARCH=x86_64
  DOCKER_DESKTOP_PACKAGE_NAME=docker-desktop-$DOCKER_DESKTOP_VERSION-$DOCKER_DESKTOP_ARCH.rpm

  # Install Docker Desktop for Linux (which includes Docker Engine)

  # Download RPM package
  curl "https://desktop.docker.com/linux/main/amd64/139021/$DOCKER_DESKTOP_PACKAGE_NAME" --output "$DOCKER_DESKTOP_PACKAGE_NAME"

  # Install RPM package
  sudo dnf install "./$DOCKER_DESKTOP_PACKAGE_NAME"
  ```

  ```bash
  # Verify docker is installed
  docker version
  # docker --version
  # docker compose version
  ```

  Ref: [Install Docker Desktop on Fedora](https://docs.docker.com/desktop/install/fedora/)

- Kubernetes

  ```bash
  # Use brew to install kubectl
  brew install kubectl

  # Verify kubectl
  kubectl version --client
  ```

  Ref: [Install and Set Up kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

- [Optional] Minikube

  ```bash
  # Install minikube
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
  sudo rpm -Uvh minikube-latest.x86_64.rpm

  # Make docker the default driver
  minikube config set driver docker

  # Starts a local Kubernetes cluster
  minikube start

  # Display cluster information
  kubectl cluster-info
  ```

  Ref:

  - [minikube start](https://minikube.sigs.k8s.io/docs/start/)
  - [docker driver | minikube](https://minikube.sigs.k8s.io/docs/drivers/docker/)

## Cloud Provider Account: Access to AWS, Azure, or GCP for creating a Kubernetes cluster

AWS:

- [Login](https://console.aws.amazon.com/console/home) or [Create a new account](https://portal.aws.amazon.com/billing/signup)

## GitHub Account: For version control and implementing CI/CD pipelines

- [Login](https://github.com/login) or [Create a new account](https://github.com/signup)

## Kubernetes Crash Course: This free course from KodeKloud contains a number of helpful labs to get you familiar with K8s basics

- [Video (on Youtube)](https://www.youtube.com/watch?v=XuSQU5Grv1g)
- [The course website](https://kodekloud.com/courses/labs-kubernetes-crash-course/): needs a KodeKloud account (create one [here](https://kodekloud.com/join-us/))
  - [PDF](https://kodekloud.com/lessons/download-resources/)
  - [Hand-on Labs](https://kodekloud.com/lessons/hands-on-labs-3/)

## E-commerce Application Source Code and DB Scripts: Available at kodekloudhub/learning-app-ecommerce. Familiarize yourself with the application structure and database scripts provided

Cloned to <https://github.com/lethang7794/learning-app-ecommerce>
