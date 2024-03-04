# Step 1.1: Deploy voting-app with `pod` & `service`

## Create pod & service for postgres

```shell
kubectl create -f ./postgres-pod.yaml
kubectl create -f ./postgres-service.yaml
```

```shell
kubectl get pods,services
```

## Create pod & service for redis

```shell
kubectl create -f ./redis-pod.yaml
kubectl create -f ./redis-service.yaml
```

```shell
kubectl get pods,services
```

## Create pod & service for result-app

```shell
kubectl create -f ./result-app-pod.yaml
kubectl create -f ./result-app-service.yaml
```

```shell
kubectl get pods,services
```

Something went wrong with the result-app-pod `Error: ErrImagePull`. The image cannot be pulled, let's update the image
and apply the new pod definition.

```shell
kubectl apply -f ./result-app-pod.yaml
```

## Create pod & service for voting-app

```shell
kubectl create -f ./voting-app-pod.yaml
kubectl create -f ./voting-app-service.yaml
```

```shell
kubectl get pods,services
```

## Create pod & service for worker-app

```shell
kubectl create -f ./worker-app-pod.yaml
```

```shell
kubectl get pods,services
```

## Let's access the voting-app & result app

### Use minikube to get the URL for a service

On minikube, the LoadBalancer type makes the Service accessible through the minikube service command.

First, let's see which services you are having

```shell
kubectl get services
```

```
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
db           ClusterIP   10.110.160.200   <none>        5432/TCP       14m
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        47h
redis        ClusterIP   10.99.171.159    <none>        6379/TCP       14m
result-app   NodePort    10.98.41.9       <none>        80:30002/TCP   13m
voting-app   NodePort    10.109.109.5     <none>        80:30001/TCP   4m34s
```

```shell
minikube service voting-app
```

```
|-----------|------------|-------------|---------------------------|
| NAMESPACE |    NAME    | TARGET PORT |            URL            |
|-----------|------------|-------------|---------------------------|
| default   | voting-app |          80 | http://192.168.49.2:30001 |
|-----------|------------|-------------|---------------------------|
🏃  Starting tunnel for service voting-app.
|-----------|------------|-------------|------------------------|
| NAMESPACE |    NAME    | TARGET PORT |          URL           |
|-----------|------------|-------------|------------------------|
| default   | voting-app |             | http://127.0.0.1:39175 |
|-----------|------------|-------------|------------------------|
🎉  Opening service default/voting-app in default browser...
❗  Because you are using a Docker driver on linux, the terminal needs to be open to run it.
Opening in existing browser session.
```

Ref:

- [Access applications running within minikube](https://minikube.sigs.k8s.io/docs/handbook/accessing/#nodeport-access)

### Use kubectl port-forward to forward a local port a port on the pod

```shell
# see which pods are available
kubectl get pods
```

```
NAME             READY   STATUS    RESTARTS   AGE
postgres-pod     1/1     Running   0          44m
redis-pod        1/1     Running   0          41m
result-app-pod   1/1     Running   0          40m
voting-app-pod   1/1     Running   0          31m

```

```shell
# forward traffic to voting-app-pod
kubectl port-forward pod/voting-app-pod :80
```

```
Forwarding from 127.0.0.1:34607 -> 80
Forwarding from [::1]:34607 -> 80
```

Ref:

- [Use Port Forwarding to Access Applications in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)