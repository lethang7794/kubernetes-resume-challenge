# Step 4: Deploy Your Website to Kubernetes

## First use pod & service to expose our ecom-app

- Pod for `ecom-web` container

```yaml
# ecom-web.pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: ecom-web-pod
  labels:
    name: ecom-web-pod
    app: ecom-app
spec:
  containers:
    - name: ecom-web-pod
      image: lethang7794/ecom-web:v1
```

```shell
cd "240-Deploy-website-to-Kubernetes"
kubectl apply -f "./ecom-web.pod.yaml"
```

- Pod for `ecom-db` container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ecom-db-pod
  labels:
    name: ecom-db-pod
    app: ecom-app
spec:
  containers:
    - name: ecom-db-pod
      image: lethang7794/ecom-db:v1
      ports:
        - containerPort: 3036
      env:
        - name: MARIADB_DATABASE
          value: "ecomdb"
        - name: MARIADB_ROOT_PASSWORD
          value: "password"
```

```shell
cd "240-Deploy-website-to-Kubernetes"
kubectl apply -f "./ecom-db.pod.yaml"
```

- Service that expose `ecom-db` inside the cluster

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: mysql-service
    spec:
      selector:
        name: ecom-db-pod
        app: ecom-app
      ports:
        - protocol: TCP
          port: 3036
          targetPort: 3036
      type: ClusterIP
      
    ```

    ```shell
    cd "240-Deploy-website-to-Kubernetes"
    kubectl apply -f "./ecom-db.service.yaml"
    ```

- Service that expose `ecom-web` outside the cluster

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: ecom-web-service
  spec:
    selector:
      name: ecom-web-pod
      app: ecom-app
    ports:
      - protocol: TCP
        nodePort: 30001
        port: 80
        targetPort: 80
    type: NodePort
  ```

  ```shell
  cd "240-Deploy-website-to-Kubernetes"
  kubectl apply -f "./ecom-web.service.yaml"
  ```