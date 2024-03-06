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

- Create ConfigMap for non-sensitive data: feature toggles

## Update Deployment
