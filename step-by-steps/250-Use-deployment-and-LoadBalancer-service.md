# Step 5: Use deployment & LoadBalancer service

## Use deployment instead of pod

```shell
cd 250-Use-deployment-and-LoadBalancer-service
kubectl apply -f ecom-web.deploy.yaml
```

```shell
cd 250-Use-deployment-and-LoadBalancer-service
kubectl apply -f ecom-db.deploy.yaml
```