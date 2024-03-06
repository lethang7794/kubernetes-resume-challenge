# Step 10: Autoscale Your Application

**Task**: Automate scaling based on CPU usage to handle unpredictable traffic spikes.

1. **Implement HPA**: Create a Horizontal Pod Autoscaler targeting 50% CPU utilization, with a minimum of 2 and a
   maximum of 10 pods.
2. **Apply HPA**: Execute `kubectl autoscale deployment ecom-web --cpu-percent=50 --min=2 --max=10`.
3. **Simulate Load**: Use a tool like Apache Bench to generate traffic and increase CPU load.
4. **Monitor Autoscaling**: Observe the HPA in action with `kubectl get hpa`.
5. **Outcome**: The deployment automatically adjusts the number of pods based on CPU load, showcasing Kubernetes'
   capability to maintain performance under varying loads.

## Implement HPA

```shell
kubectl autoscale deployment ecom-db-deploy --max=10 --min=2 --cpu-percent=50 --dry-run=client -o yaml > ecom-web.hpa.yaml
```

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: null
  name: ecom-db-deploy
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecom-db-deploy
  targetCPUUtilizationPercentage: 50
status:
  currentReplicas: 0
  desiredReplicas: 0
```

This HPA object apiVersion is `autoscaling/v1`, which doesn't work for me.

The version works for me is `autoscaling/v2`.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  creationTimestamp: null
  name: ecom-web-deploy
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecom-web-deploy
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
  behavior: # Default behavior: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#default-behavior
    scaleUp:
      stabilizationWindowSeconds: 0
    scaleDown:
      stabilizationWindowSeconds: 300
status:
  currentReplicas: 0
  desiredReplicas: 0

```

## Apply HPA

```shell
cd ./2100-Autoscale-Your-Application
kubectl apply -f ./ecom-web.hpa.yaml
```

## Simulate Load

## Monitor Autoscaling

```shell
kubectl get hpa,pods
```

```
NAME                                                 REFERENCE                   TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/ecom-db-deploy   Deployment/ecom-db-deploy   <unknown>/50%   1         10        1          8m46s

NAME                                   READY   STATUS    RESTARTS   AGE
pod/ecom-db-deploy-675f97f6f6-95t24    1/1     Running   0          156m
pod/ecom-web-deploy-64455784d8-drz84   1/1     Running   0          60m
pod/ecom-web-deploy-64455784d8-flzmf   1/1     Running   0          60m
pod/ecom-web-deploy-64455784d8-p77j4   1/1     Running   0          60m
pod/ecom-web-deploy-64455784d8-v9ndt   1/1     Running   0          60m
pod/ecom-web-deploy-64455784d8-x942p   1/1     Running   0          60m
pod/ecom-web-deploy-64455784d8-xxt4t   1/1     Running   0          60m
```

Currently, although the HPA is created with a min of pods,

- there are still 6 running pods.
- HPA TARGETS is `<unknown>/50%`

The HPA doesn't know the CPU utilization of pods, so it doesn't tell the Deployment object to scale down.

> How long before HPA scale up & down?