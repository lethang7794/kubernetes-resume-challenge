# Helm - Debugging templates

## Render a chart locally (~ before a chart is installed)

```bash
helm template --debug <CHART_NAME>
```

- e.g.
  
  ```
  helm template --debug ./mychart
  ```
  
  ```text
  ---
  # Source: mychart/charts/mysubchart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: release-name-cfgmap2
  data:
    dessert: "ice cream"
    salad: "caesar"
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: release-name-configmap
  data:
    salad: "caesar"
  ```

## Examine a chart for possible issues with `helm lint` (~ after a chart is written, but before it's installed)

```bash
helm lint <CHART_NAME>
```

- e.g.
  
  ```bash
  helm lint ./mychart
  ```
  
  ```
  ==> Linting ./mychart
  [INFO] Chart.yaml: icon is recommended
  [ERROR] /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart: chart metadata is missing these dependencies: mysubchart
  
  Error: 1 chart(s) linted, 1 chart(s) failed
  ```

## Simulate an install (~ a chart is install)

1. Simulate an install locally (without connecting to the cluster)
   
   ```bash
   helm install --dry-run --debug  --generate-name <CHART_NAME>
   ```
   
   e.g.
   
   ```bash
   helm install --dry-run --debug  --generate-name ./mychart
   ```
   
   ```text
   helm install --generate-name --dry-run --debug ./mychart
   install.go:218: [debug] Original chart version: ""
   install.go:235: [debug] CHART PATH: /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart
 
   NAME: mychart-1710677622
   LAST DEPLOYED: Sun Mar 17 19:13:42 2024
   NAMESPACE: default
   STATUS: pending-install
   REVISION: 1
   TEST SUITE: None
   USER-SUPPLIED VALUES:
   {}
 
   COMPUTED VALUES:
   favorite:
     drink: coke
     food: pizza
   global:
     salad: caesar
   mysubchart:
     dessert: ice cream
     global:
       salad: caesar
 
   HOOKS:
   MANIFEST:
   ---
   # Source: mychart/charts/mysubchart/templates/configmap.yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: mychart-1710677622-cfgmap2
   data:
     dessert: "ice cream"
     salad: "caesar"
   ---
   # Source: mychart/templates/configmap.yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: mychart-1710677622-configmap
   data:
     salad: "caesar"
   ```

2. Simulate an install (with connecting to the cluster) by using [`--dry-run=server`](https://helm.sh/blog/helm-3.13#dry-run--template-can-connect-to-servers)
   
   Helm will communicate with the the cluster, execute a `lookup`...
   
   ```bash
   helm install --dry-run=server --debug --generate-name <CHART_NAME>
   ```

## See the manifest for a named release (~ after a chart is installed)

```bash
helm get manifest <RELEASE_NAME>
```

- e.g.
  
  ```bash
  helm get manifest mychart-1710443886
  ```
  
  ```text
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710443886-configmap
    labels:
      generator: helm
      date: 2024-03-15
      chart: 
      version:
  ```