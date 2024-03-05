# Step 3: Set Up Kubernetes on a Public Cloud Provider

For this challenge, we need a fully operation Kubernetes cluster ready for deployment. All public cloud provider has a
service that provide a managed Kubernetes cluster for us.

For now we will use a `minikube` cluster and deploy locally on our machine.

When everything works, we will choose one 1 provider and deploy another environment on it.

## Tasks:

- [x] Setup minikube
- [ ] Decide which cloud provider to use
- [ ] Setup cloud account
- [ ] Setup cluster on that cloud provider

## Setup minikube

- Install minikube:

  The instruction to install minikube can be found at https://minikube.sigs.k8s.io/docs/start/

- Start minikube cluster

  ```shell
  minikube start
  ```
  ```
  😄  minikube v1.32.0 on Fedora 39
  ...
  🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
  ...
  🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
  ```  

  Confirm minikube is working

    ```shell
    minikube status
    ```

    ```
    minikube
    type: Control Plane
    host: Running
    kubelet: Running
    apiserver: Running
    kubeconfig: Configured
    ```
  Config kubectl works with minikube

    ```shell
    kubectl cluster-info
    ```

    ```
    Kubernetes control plane is running at https://127.0.0.1:35321
    CoreDNS is running at https://127.0.0.1:35321/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
      
    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    ```
