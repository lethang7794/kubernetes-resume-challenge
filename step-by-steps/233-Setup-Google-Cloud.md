# Step 3.3 - Setup Google Cloud

## Sign up

- [Create a new Google account](https://accounts.google.com/ServiceLogin) / Create account

- [Google Cloud - Sign up](https://console.cloud.google.com/freetrial)

## Setup Google Kubernetes Engine

This interactive tutorials "Deploy a containerized web application with GKE" is very useful for someone new to the
Google Cloud (like me)

But for real world Google Cloud experience, I will follow the
guide [Deploy an app in a container image to a GKE cluster](https://cloud.google.com/kubernetes-engine/docs/quickstarts/deploy-app-container-image)

### Set up prerequisite

- Init gloud CLI

```shell
gcloud init

# You must log in to continue. Would you like to log in (Y/n)?
# -> Press y to login

## Browser
# Choose an account to continue to Google Cloud SDK
# -> Choose your account
# Sign in to Google Cloud SDK 
# -> Continue
# Google Cloud SDK wants to access your Google Account
# -> Allow
# Redirect to https://cloud.google.com/sdk/auth_success

## Back to CLI
# You are logged in as: [YOUR_EMAIL_HERE].
# Pick cloud project to use:
# ...
# Please enter numeric choice or text value (must exactly match list item):
# -> Enter the project numeric
# Your current project has been set to: [YOUR_PROJECT_HERE].
# Do you want to configure a default Compute Region and Zone? (Y/n)?
# -> y
# Which Google Compute Engine zone would you like to use as project default?
# If you do not specify a zone via a command line flag while working with Compute Engine resources, the default is assumed.
# ...
# ...
# Please enter numeric choice or text value (must exactly match list item):  8
#
# Your project default Compute Engine zone has been set to [us-central1-a].
# You can change it by running [gcloud config set compute/zone NAME].
#
# Your project default Compute Engine region has been set to [us-central1].
# You can change it by running [gcloud config set compute/region NAME].
```

- To use kubectl for managing GKE cluster we need to install `gke-gcloud-auth-plugin`

```shell
sudo dnf install google-cloud-sdk-gke-gcloud-auth-plugin
```

- Get Google Cloud Project ID

```shell
gcloud config get-value project | read PROJECT_ID
```

- To store container image, you create a repository named hello-repo in Artifact Registry (in the same location as your
  cluster)

```shell
gcloud artifacts repositories create hello-repo \
    --project=$PROJECT_ID \
    --repository-format=docker \
    --location=us-central1 \
    --description="Docker repository"
```

- Build your container image using Cloud Build, which is similar to running docker build and docker push, but the build
  happens on Google Cloud:

```shell
# cd to Dockerfile's dir
gcloud builds submit \
  --tag us-central1-docker.pkg.dev/$PROJECT_ID/hello-repo/helloworld-gke .
```

### Setup GKE cluster

```shell
gcloud container clusters \
   --location "us-central1-a" \
   create "example-cluster" \
      --disk-size 30 \
      --disk-type "pd-standard" \
      --machine-type "e2-medium" \
      --node-locations "us-central1-a" \
      --num-nodes 1 \
      --spot
```

We need at least 4 nodes of e2-micro (2 x 7.5$/month, which is equal to 1 e2-medium - $30/month) for a basic working
GKE cluster.

- Let's see out GKE cluster

```
❯ kubectl get all
NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.79.112.1   <none>        443/TCP   13m

kubernetes-resume-challenge on  main [!+?⇡] on ☁️   fullquack@gmail.com(us-central1) took 6s
❯ kubectl cluster-info
Kubernetes control plane is running at https://35.188.198.181
GLBCDefaultBackend is running at https://35.188.198.181/api/v1/namespaces/kube-system/services/default-http-backend:http/proxy
KubeDNS is running at https://35.188.198.181/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://35.188.198.181/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubernetes-resume-challenge on  main [!+?⇡] on ☁️   fullquack@gmail.com(us-central1)
❯ kubectl get nodes
NAME                                                STATUS   ROLES    AGE   VERSION
gke-helloworld-cluster-default-pool-8118cadf-vd99   Ready    <none>   15m   v1.27.8-gke.1067004
gke-helloworld-cluster-default-pool-8118cadf-z8ts   Ready    <none>   15m   v1.27.8-gke.1067004
gke-helloworld-cluster-default-pool-ba4313aa-cl13   Ready    <none>   15m   v1.27.8-gke.1067004
gke-helloworld-cluster-default-pool-ba4313aa-ssth   Ready    <none>   15m   v1.27.8-gke.1067004
```

### Deploy our pods

- Create a deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-gke
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
        - name: hello-app
          image: us-central1-docker.pkg.dev/kubernetes-cloud-resume/hello-repo/helloworld-gke:latest
          # This app listens on port 8080 for web traffic by default.
          ports:
            - containerPort: 8080
          env:
            - name: PORT
              value: "8080"
          resources:
            requests:
              memory: "128M"
              cpu: "250m"
              ephemeral-storage: "1Gi"
            limits:
              memory: "1Gi"
              cpu: "500m"
              ephemeral-storage: "1Gi"
```

- Apply the deployment

```shell
kubectl apply -f deployment.yaml
```

- Let's track the status of our deployment & pods

```
❯ kubectl get deployments,pods
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld-gke   0/1     1            0           5m41s

NAME                                 READY   STATUS    RESTARTS   AGE
pod/helloworld-gke-7c4cfd998-sxzzw   0/1     Pending   0          5m41s
```

- Why our pod is pending???

```
❯ kubectl events
LAST SEEN                TYPE      REASON                                   OBJECT                                                   MESSAGE
...
7m58s                    Normal    SuccessfulCreate                         ReplicaSet/helloworld-gke-7c4cfd998                      Created pod: helloworld-gke-7c4cfd998-sxzzw
7m58s                    Normal    ScalingReplicaSet                        Deployment/helloworld-gke                                Scaled up replica set helloworld-gke-7c4cfd998 to 1
2m52s (x32 over 7m55s)   Normal    NotTriggerScaleUp                        Pod/helloworld-gke-7c4cfd998-sxzzw                       pod didn't trigger scale-up:
2m36s (x3 over 7m58s)    Warning   FailedScheduling                         Pod/helloworld-gke-7c4cfd998-sxzzw                       0/4 nodes are available: 4 Insufficient memory. preemption: 0/4 nodes are available: 4 No preemption victims found for incoming pod..
```

`0/4 nodes are available: 4 Insufficient memory. preemption: 0/4 nodes are available: 4 No preemption victims found for incoming pod..`.

- Let's reduce pod request memory from `128M` to only `64M` and apply the new deployment configuration

- Now our pod is running

```
❯ kubectl get deployments,pods
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld-gke   1/1     1            1           11m

NAME                                  READY   STATUS    RESTARTS   AGE
pod/helloworld-gke-6b6b8cfd98-vlrk8   1/1     Running   0          39s
```

```
❯ kubectl events
LAST SEEN                TYPE      REASON                                   OBJECT                                                   MESSAGE
...
28s                  Normal    SuccessfulCreate                         ReplicaSet/helloworld-gke-6b6b8cfd98                     Created pod: helloworld-gke-6b6b8cfd98-vlrk8
28s                  Normal    Scheduled                                Pod/helloworld-gke-6b6b8cfd98-vlrk8                      Successfully assigned default/helloworld-gke-6b6b8cfd98-vlrk8 to gke-helloworld-cluster-default-pool-8118cadf-vd99
28s                  Normal    ScalingReplicaSet                        Deployment/helloworld-gke                                Scaled up replica set helloworld-gke-6b6b8cfd98 to 1
25s                  Normal    Pulling                                  Pod/helloworld-gke-6b6b8cfd98-vlrk8                      Pulling image "us-central1-docker.pkg.dev/kubernetes-cloud-resume/hello-repo/helloworld-gke:latest"
21s                  Normal    Created                                  Pod/helloworld-gke-6b6b8cfd98-vlrk8                      Created container hello-app
21s                  Normal    Started                                  Pod/helloworld-gke-6b6b8cfd98-vlrk8                      Started container hello-app
21s                  Normal    Pulled                                   Pod/helloworld-gke-6b6b8cfd98-vlrk8                      Successfully pulled image "us-central1-docker.pkg.dev/kubernetes-cloud-resume/hello-repo/helloworld-gke:latest" in 3.19954925s (3.199607297s including waiting)
20s                  Warning   FailedScheduling                         Pod/helloworld-gke-7c4cfd998-sxzzw                       skip schedule deleting pod: default/helloworld-gke-7c4cfd998-sxzzw
20s                  Normal    SuccessfulDelete                         ReplicaSet/helloworld-gke-7c4cfd998                      Deleted pod: helloworld-gke-7c4cfd998-sxzzw
20s                  Normal    ScalingReplicaSet                        Deployment/helloworld-gke                                Scaled down replica set helloworld-gke-7c4cfd998 to 0 from 1
```

### Expose our app

- Create a service

```yaml
# The hello service provides a load-balancing proxy over the hello-app
# pods. By specifying the type as a 'LoadBalancer', Kubernetes Engine will
# create an external HTTP load balancer.
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  type: LoadBalancer
  selector:
    app: hello
  ports:
    - port: 80
      targetPort: 8080
```

- Apply the service

```shell
cd 233-Setup-Google-Kubernetes-Engine/helloworld-gke
kubectl apply -f service.yaml
```

- Check our service

```shell
❯ kubectl get services                                                                                    │❯
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE                            │
hello        LoadBalancer   10.79.120.180   34.69.173.181   80:31616/TCP   2m32s                          │
kubernetes   ClusterIP      10.79.112.1     <none>          443/TCP        47m
```

- View our deploy app

```shell
curl 34.69.173.181
```

## Let's create another GKE cluster

### Generate kubeconfig context for GKE cluster

```shell
gcloud container clusters get-credentials example-cluster
```