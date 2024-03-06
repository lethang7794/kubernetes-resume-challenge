# Step 7: Scale Your Application

**Task**: Prepare for a marketing campaign expected to triple traffic.

1. **Evaluate Current Load**: Use `kubectl get pods` to assess the current number of running pods.
2. **Scale Up**: Increase replicas in your deployment or use `kubectl scale deployment/ecom-web --replicas=6` to handle
   the increased load.
3. **Monitor Scaling**: Observe the deployment scaling up with `kubectl get pods`.
4. **Outcome**: The application scales up to handle increased traffic, showcasing Kubernetes' ability to manage
   application scalability dynamically.

## Evaluate Current Load

```shell
kubectl get pods
```

```
NAME                               READY   STATUS    RESTARTS   AGE
ecom-db-deploy-675f97f6f6-95t24    1/1     Running   0          6m12s
ecom-web-deploy-64455784d8-jvnk2   1/1     Running   0          82m
```

## Scale Up

```shell
kubectl scale deployments/ecom-web-deploy --replicas 6
```

## Monitor Scaling

```shell
kubectl get pods
```

```
NAME                               READY   STATUS    RESTARTS   AGE
ecom-db-deploy-675f97f6f6-95t24    1/1     Running   0          6m53s
ecom-web-deploy-64455784d8-4lnzr   1/1     Running   0          12s
ecom-web-deploy-64455784d8-52sv6   1/1     Running   0          12s
ecom-web-deploy-64455784d8-br5sl   1/1     Running   0          12s
ecom-web-deploy-64455784d8-gpf2m   1/1     Running   0          12s
ecom-web-deploy-64455784d8-jvnk2   1/1     Running   0          83m
ecom-web-deploy-64455784d8-vnm44   1/1     Running   0          12s
```

## Load test our app

```
minikube service ecom-web-service --url
```

```shell
# Use 200 worker to make 5000 requests
hey -n 5000 -c 200 http://127.0.0.1:35173`
```

```
Summary:
  Total:        30.3095 secs
  Slowest:      18.3882 secs
  Fastest:      0.0159 secs
  Average:      1.0551 secs
  Requests/sec: 164.9647


Response time histogram:
  0.016 [1]     |
  1.853 [4323]  |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  3.690 [473]   |■■■■
  5.528 [102]   |■
  7.365 [43]    |
  9.202 [47]    |
  11.039 [7]    |
  12.877 [3]    |
  14.714 [0]    |
  16.551 [0]    |
  18.388 [1]    |


Latency distribution:
  10% in 0.2172 secs
  25% in 0.3931 secs
  50% in 0.6244 secs
  75% in 1.1575 secs
  90% in 2.3065 secs
  95% in 3.2525 secs
  99% in 7.7801 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.0011 secs, 0.0159 secs, 18.3882 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:    0.0004 secs, 0.0000 secs, 0.0401 secs
  resp wait:    1.0526 secs, 0.0153 secs, 18.3415 secs
  resp read:    0.0008 secs, 0.0004 secs, 0.0276 secs

Status code distribution:
  [200] 5000 responses
```