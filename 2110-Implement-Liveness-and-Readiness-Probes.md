# Step 11: Implement Liveness and Readiness Probes

**Task**: Ensure the web application is restarted if it becomes unresponsive and doesn’t receive traffic until ready.

1. **Define Probes**: Add liveness and readiness probes to `website-deployment.yaml`, targeting an endpoint in your
   application that confirms its operational status.
2. **Apply Changes**: Update your deployment with the new configuration.
3. **Test Probes**: Simulate failure scenarios (e.g., manually stopping the application) and observe Kubernetes'
   response.
4. **Outcome**: Kubernetes automatically restarts unresponsive pods and delays traffic to newly started pods until
   they're ready, enhancing the application's reliability and availability.