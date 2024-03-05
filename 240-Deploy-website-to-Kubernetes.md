# Step 4: Deploy Your Website to Kubernetes

## First use the Pod object

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

## Use the Deployment object