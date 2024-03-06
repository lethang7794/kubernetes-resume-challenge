# Step 9: Roll Back a Deployment

**Task**: Suppose the new banner introduced a bug. Roll back to the previous version.

1. **Identify Issue**: After deployment, monitoring tools indicate a problem affecting user experience.
2. **Roll Back**: Execute `kubectl rollout undo deployment/ecom-web` to revert to the previous deployment state.
3. **Verify Rollback**: Ensure the website returns to its pre-update state without the promotional banner.
4. **Outcome**: The application's stability is quickly restored, highlighting the importance of rollbacks in deployment
   strategies.

## Identify Issue

## Roll Back

```shell
kubectl rollout undo deployment/ecom-web-deploy
```

## Verify Rollback