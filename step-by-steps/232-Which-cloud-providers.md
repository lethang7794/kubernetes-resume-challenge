# Step 3.2: Which cloud provider to deploy Kubernetes cluster?

Design decision:

- The cloud provider allow us to deploy a managed Kubernetes cluster.
- It's free for our demo project.

| Cloud Provider              | AWS                                                           | Google Cloud                                                                                                                                                               | Azure                 |
|-----------------------------|---------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| Cloud Free Tier             | 1 year                                                        | 90 days via [Google Cloud Free Program](https://cloud.google.com/free/docs/free-cloud-features)                                                                            | 30 days ($200 credit) | 
| K8s Control Plane           | EKS                                                           | Google Kubernetes Engine (GKE)                                                                                                                                             | AKS                   |
| K8s Worker Node             | EC2 / Fargate                                                 | Autopilot / Compute Engine                                                                                                                                                 | Azure Virtual Machine |
| K8s Control Plane - Pricing | EKS:<br/> - No free tier <br /> - $0.10/hour for each cluster | GKE: <br /> - Free tier: No cluster management fee for **one** Autopilot or Zonal cluster per Cloud Billing account. <br /> - Standard edition: $0.10 per cluster per hour |                       |
| K8s Worker Node - Pricing   |                                                               | 1. Autopilot: For clusters created in Autopilot mode, pods are billed per second for vCPU, memory and disk resource requests                                               |                       |
|                             |                                                               | 2. Compute Engine:                                                                                                                                                         |                       |
|                             |                                                               | - For clusters created in Standard mode, each user node is charged at standard Compute Engine pricing.                                                                     |                       |
|                             |                                                               | - Compute Engine: 1 non-preemptible e2-micro VM instance per month)                                                                                                        |                       |

[1]: https://cloud.google.com/kubernetes-engine#pricing

Ref:

- [Run a Google Kubernetes Engine Cluster for Under $25/Month](https://thenewstack.io/run-a-google-kubernetes-engine-cluster-for-under-25-month/)
- [How to Run a GKE Cluster on the Cheap](https://github.com/murphye/cheap-gke-cluster)
- [Get your very own GKE cluster for next to nothing!](https://github.com/Neutrollized/free-tier-gke?tab=readme-ov-file)