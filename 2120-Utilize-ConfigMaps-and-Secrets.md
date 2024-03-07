# Step 12: Utilize ConfigMaps and Secrets

**Task**: Securely manage the database connection string and feature toggles without hardcoding them in the application.

1. **Create Secret and ConfigMap**: For sensitive data like DB credentials, use a Secret. For non-sensitive data like
   feature toggles, use a ConfigMap.
2. **Update Deployment**: Reference the Secret and ConfigMap in the deployment to inject these values into the
   application environment.
3. **Outcome**: Application configuration is externalized and securely managed, demonstrating best practices in
   configuration and secret management.

## Create Secret and ConfigMap

- Create Secret for sensitive data: DB credentials

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
stringData:
  DB_PASSWORD: "password"
  DB_ROOT_PASSWORD: "root_password"
```

K8s Secret objects store the data in plaintext format (even when the secret is stored as base 64, it's still plaintext)
inside the cluster storage.

For better security (maybe), use any external secret store provider, such as Google Cloud Secret
Manager, AWS Secret Manager or HashiCorp Vault.

- Create ConfigMap for non-sensitive data: feature toggles

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  DB_USER: "db_user"
  DB_DATABASE: "ecomdb"
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-toggle-config
data:
  DARK_MODE: "true"
```

## Update Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecom-web-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      name: ecom-web-pod
  template:
    metadata:
      name: ecom-web-pod
    spec:
      containers:
        - name: ecom-web-pod
          image: lethang7794/ecom-web:v5
          env:
            - name: "DB_USER"
              valueFrom:
                configMapKeyRef:
                  name: "db-config"
                  key: "DB_USER"
            - name: "DB_PASSWORD"
              valueFrom:
                secretKeyRef:
                  name: "db-secret"
                  key: "DB_PASSWORD"
            - name: "DB_NAME"
              valueFrom:
                configMapKeyRef:
                  name: "db-config"
                  key: "DB_DATABASE"
            - name: "FEATURE_DARK_MODE"
              valueFrom:
                configMapKeyRef:
                  name: "feature-toggle-config"
                  key: "DARK_MODE"
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecom-db-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      name: ecom-db-pod
  template:
    metadata:
      name: ecom-db-pod
      labels:
        name: ecom-db-pod
    spec:
      containers:
        - name: ecom-db-pod
          image: lethang7794/ecom-db:v1
          ports:
            - containerPort: 3306
          env:
            - name: MARIADB_USER
              valueFrom:
                configMapKeyRef:
                  name: "db-config"
                  key: "DB_USER"
            - name: MARIADB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: "db-secret"
                  key: "DB_PASSWORD"
            - name: MARIADB_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: "db-secret"
                  key: "DB_ROOT_PASSWORD"
            - name: MARIADB_DATABASE
              valueFrom:
                configMapKeyRef:
                  name: "db-config"
                  key: "DB_DATABASE"
```

## Apply Serret, Configmap & Deployment

```shell
cd 2120-Utilize-ConfigMaps-and-Secrets
kubectl apply -f db.configmap.yaml
kubectl apply -f db.secret.yaml
kubectl apply -f feature-toggle.configmap.yaml
```

```shell
cd 2120-Utilize-ConfigMaps-and-Secrets
kubectl apply -f ecom-db.deploy.yaml
kubectl apply -f ecom-web.deploy.yaml
```