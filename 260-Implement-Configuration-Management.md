# Step 6: Implement Configuration Management

**Task**: Add a feature toggle to the web application to enable a "dark mode" for the website.

1. **Modify the Web Application**: Add a simple feature toggle in the application code (e.g., an environment
   variable `FEATURE_DARK_MODE` that enables a CSS dark theme).
2. **Use ConfigMaps**: Create a ConfigMap named `feature-toggle-config` with the data `FEATURE_DARK_MODE=true`.
3. **Deploy ConfigMap**: Apply the ConfigMap to your Kubernetes cluster.
4. **Update Deployment**: Modify the `website-deployment.yaml` to include the environment variable from the ConfigMap.
5. **Outcome**: Your website should now render in dark mode, demonstrating how ConfigMaps manage application features.

## Modify the Web Application

## Use ConfigMaps

## Deploy ConfigMap

## Update Deployment

## Outcome