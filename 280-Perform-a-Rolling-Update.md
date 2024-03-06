# Step 8: Perform a Rolling Update

**Task**: Update the website to include a new promotional banner for the marketing campaign.

1. **Update Application**: Modify the web application's code to include the promotional banner.
2. **Build and Push New Image**: Build the updated Docker image as `yourdockerhubusername/ecom-web:v2` and push it to
   Docker Hub.
3. **Rolling Update**: Update `website-deployment.yaml` with the new image version and apply the changes.
4. **Monitor Update**: Use `kubectl rollout status deployment/ecom-web` to watch the rolling update process.
5. **Outcome**: The website updates with zero downtime, demonstrating rolling updates' effectiveness in maintaining
   service availability.

## Update Application

## Build and Push New Image

```shell
cd 220-Containerize-e-commerce-website-and-database/learning-app-ecommerce
docker build -t lethang7794/ecom-web:v4 .
```

```shell
docker push lethang7794/ecom-web:v4
```

## Rolling Update

```shell
cd 280-Perform-a-Rolling-Update
kubectl apply -f ecom-web.deploy.yaml
```

## Monitor Update

```shell
kubectl rollout status deployment/ecom-web-deploy
```

```
Waiting for deployment "ecom-web-deploy" rollout to finish: 4 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 4 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 4 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 4 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 4 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 5 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 5 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 5 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 5 out of 6 new replicas have been updated...
Waiting for deployment "ecom-web-deploy" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "ecom-web-deploy" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "ecom-web-deploy" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "ecom-web-deploy" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "ecom-web-deploy" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "ecom-web-deploy" rollout to finish: 1 old replicas are pending termination...
deployment "ecom-web-deploy" successfully rolled out
```
