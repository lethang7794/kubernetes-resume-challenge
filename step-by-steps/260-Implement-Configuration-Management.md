# Step 6: Implement Configuration Management

**Task**: Add a feature toggle to the web application to enable a "dark mode" for the website.

1. **Modify the Web Application**: Add a simple feature toggle in the application code (e.g., an environment
   variable `FEATURE_DARK_MODE` that enables a CSS dark theme).
2. **Use ConfigMaps**: Create a ConfigMap named `feature-toggle-config` with the data `FEATURE_DARK_MODE=true`.
3. **Deploy ConfigMap**: Apply the ConfigMap to your Kubernetes cluster.
4. **Update Deployment**: Modify the `website-deployment.yaml` to include the environment variable from the ConfigMap.
5. **Outcome**: Your website should now render in dark mode, demonstrating how ConfigMaps manage application features.

## Modify the Web Application

- Modify the code

    ```
    <?php
    $FEATURE_DARK_MODE = getenv('FEATURE_DARK_MODE');
    if ($FEATURE_DARK_MODE === 'true') {
        echo "<h2>Dark mode is on</h2>";
    } else {
        echo "<h2>Dark mode is off</h2>";
    }
    ?>
    ```

- Verify that the code works depends on the environment
    - Build a new docker image (local)
        ```shell
        cd 220-Containerize-e-commerce-website-and-database/learning-app-ecommerce
        docker build -t lethang7794/ecom-web:v3 .
        ```
    - Verify that the code works by run the container and pass in the environment variable

        ```shell
        docker run --env 'FEATURE_DARK_MODE=true' -p 8080:80  lethang7794/ecom-web:v3
        ```
    - Verify that the deployment can pass environment to the container

        ```yaml
        spec:
          template:
            metadata:
            spec:
              containers:
                - name: ecom-web-pod
                  image: lethang7794/ecom-web:v3
                  env:
                    - name: "FEATURE_DARK_MODE"
                      value: "true"
        ```

        ```shell
        cd 260-Implement-Configuration-Management
        kubectl apply -f ecom-web.deploy.yaml
        ```

## Use ConfigMaps

```yaml
# feature-toggle.configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-toggle-config
data:
  DARK_MODE: "true"
```

## Deploy ConfigMap

- Apply ConfigMap

```shell
cd 260-Implement-Configuration-Management
kubectl apply -f feature-toggle.configmap.yaml
```

## Update Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecom-web-deploy
spec:
  template:
    spec:
      containers:
        - name: ecom-web-pod
          image: lethang7794/ecom-web:v3
          env:
            - name: "FEATURE_DARK_MODE"
              valueFrom:
                configMapKeyRef:
                  name: "feature-toggle-config"
                  key: "DARK_MODE"
```

```shell
cd 260-Implement-Configuration-Management
kubectl apply -f ecom-web.deploy.yaml
```

## Outcome

- Delete the old pod to see if everything works.

- Change the ConfigMap (& apply new the ConfigMap), delete the old pod, to verify the app can get new value.
