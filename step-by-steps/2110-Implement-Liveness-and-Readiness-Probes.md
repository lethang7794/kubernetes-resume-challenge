# Step 11: Implement Liveness and Readiness Probes

**Task**: Ensure the web application is restarted if it becomes unresponsive and doesn’t receive traffic until ready.

1. **Define Probes**: Add liveness and readiness probes to `website-deployment.yaml`, targeting an endpoint in your
   application that confirms its operational status.
2. **Apply Changes**: Update your deployment with the new configuration.
3. **Test Probes**: Simulate failure scenarios (e.g., manually stopping the application) and observe Kubernetes'
   response.
4. **Outcome**: Kubernetes automatically restarts unresponsive pods and delays traffic to newly started pods until
   they're ready, enhancing the application's reliability and availability.

## Define Probes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecom-web-deploy
spec:
  selector:
    matchLabels:
      name: ecom-web-deploy
  template:
    spec:
      containers:
        - name: ecom-web-pod
          image: lethang7794/ecom-web:v5
          livenessProbe:
            tcpSocket:
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
          readinessProbe:
            httpGet:
              port: 80
              path: /
            initialDelaySeconds: 10
            periodSeconds: 5
```

## Apply Changes

```shell
cd 2110-Implement-Liveness-and-Readiness-Probes
kubectl apply -f ecom-web.deploy.yaml
```

## Test Probes

Go inside a container

```shell
kubectl exec -it <POD_NAME> -- bash
```

Shutdown it

```shell
kill -s TERM 1
```

Watch the pod restart automatically

```shell
kubectl get deploy,pods
```
