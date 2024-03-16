# Helm - Subchart & Global values

## What is subchart?

Chart
: A chart is a set of **files & directories** that adhere to the chart specification for _describing the
resources_ to be installed into Kubernetes

Application chart
: Application charts are a collection of **templates** that can be packaged into versioned archives to be _deployed_.

Library chart
: Library charts provide useful **utilities** or **functions** for the chart developer.
: They're included as a dependency of application charts to inject those utilities and functions into the rendering pipeline
: Library charts do not define any templates and therefore cannot be deployed.

Subchart
: Charts can have dependencies, called _subcharts_, that also have their own values and templates.

## Why use subchart?

Subcharts are used to modularize and encapsulate complex Helm charts into smaller, reusable components.

Unlike library chart (which only includes utilities/functions), subcharts can include templates & values (that can be overridden by its parent chart).

A subchart is considered a _stand-alone_ chart, which:

- doesn't depend on its parent chart.
  
  As subchart cannot access the values of its parent.

- but can be overridden by its parent chart.

## How to create a subchart?

### Create a subchart skeleton with `helm create`

Inside the parent chart `charts` directory, run the `helm create <SUB_CHART_NAME>`

```bash
cd mychart/charts && helm create mysubchart
```

> [!TIP]
> A subchart is created with the same command as a normal chart (`helm create`)

### Add values & templates to subchart

Let's start the subchart from scratch

- Remove the generated chart's templates in `/templates/*` & `values.yaml` content
  
  ```bash
  cd mychart/charts && echo > mysubchart/values.yaml
  cd mychart/charts && rm -rf mysubchart/templates/*
  ```

- Our `values.yaml` & `configmap.yaml` template
  
  ```kubernetes helm
  # mychart/charts/mysubchart/values.yaml
  dessert: cake
  ```
  
  ```kubernetes helm
  # mychart/charts/mysubchart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-cfgmap2
  data:
    dessert: {{ .Values.dessert }}
  ```

- Output
  
  ```bash
  helm install --generate-name --dry-run mychart/charts/mysubchart
  ```
  
  ```bash
  helm install --generate-name --debug mychart/charts/mysubchart
  ```
  
  ```bash
  helm install --generate-name --dry-run --debug mychart/charts/mysubchart
  ```
  
  ```bash
  helm template mychart/charts/mysubchart
  ```
  
  ```
  # Source: mysubchart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mysubchart-1710585530-cfgmap2
  data:
    dessert: "cake"
  ```

## The relationship between parent chart & subchart

- Let's install the parent chart
  
  ```bash
  helm install --generate-name --dry-run --debug mychart
  ```

- Output
  
  ```shell
  install.go:218: [debug] Original chart version: ""
  install.go:235: [debug] CHART PATH: /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart
  
  NAME: mychart-1710586517
  LAST DEPLOYED: Sat Mar 16 17:55:17 2024
  NAMESPACE: default
  STATUS: pending-install
  REVISION: 1
  TEST SUITE: None
  USER-SUPPLIED VALUES:
  {}
  
  COMPUTED VALUES:
  favorite:
    drink: coke
  mysubchart:
    dessert: cake
    global: {}
  
  HOOKS:
  MANIFEST:
  ---
  # Source: mychart/charts/mysubchart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710586517-cfgmap2
  data:
    dessert: "cake"
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710586517-configmap
  data:
    config1.toml: |-
      Hello from config 1
  ```

The `subchart` is now a part of the `parent chart` manifest.

Currently, the final manifest use the values from the subchart's `values.yaml`, which means `{{ .Values.dessert }}` will be substitute with `cake`.

### Override values of subchart (with parent chart's values)

Because `mysubchart` is a subchart of `mychart`, you can provides values to `mychart` and let these values passed to `mysubchart`.

- Provide values to `mychart` (the parent chart)
  
  ```kubernetes helm
  # mychart/values.yaml
  favorite:
    drink: coffee
  
  mysubchart:
    dessert: ice cream
  ```

- Let's see the subchart manifest
  
  ```bash
  helm install --generate-name --dry-run --debug mychart
  ```
  
  ```shell
  MANIFEST:
  ---
  # Source: mychart/charts/mysubchart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710587051-cfgmap2
  data:
    dessert: "ice cream"
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710587051-configmap
  data:
    config1.toml: |-
      Hello from config 1
  ```
  
  The values of `mychart` has overridden the values of `mysubchart`.

> [!INFO]
> Helm docs for how Helm handles chart/subchart's values is not too clear, for the exact behavior, see the [CoalesceValues function][^CoalesceValues-function] in Helm source code

## Chart's Global Values

Global values
: values that can be accessed from any chart or subchart by exactly the same name.

Globals values require explicit declaration.

The Values data type has a reserved section called `Values.global` where global values can be set.

e.g.

- Set global values in `values.yaml`
  
  ```
  # mychart/values.yaml
  favorite:
    drink: coffee
  
  mysubchart:
    dessert: ice cream
  
  global:
    salad: caesar
  ```

- Global values can be accessed in
  - The parent chart - `mychart/templates/configmap.yaml`
    
    ```kubernetes helm
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ .Release.Name }}-configmap
    data:
      salad: {{ .Values.global.salad }}
    ```
  
  - Any sub chart, e.g. `/mysubchart/templates/configmap.yaml`
    
    ```kubernetes helm
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ .Release.Name }}-cfgmap2
    data:
      dessert: {{ .Values.dessert }}
      salad: {{ .Values.global.salad }}
    ```
- Output:
  
  ```
  MANIFEST:
  ---
  # Source: mychart/charts/mysubchart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710611666-cfgmap2
  data:
    dessert: "ice cream"
    salad: "caesar"
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710611666-configmap
  data:
    salad: "caesar"
  ```

## Sharing Templates with Subcharts

As we've already know, named templates are global (in the parent chart). They're also global to any subcharts.

Any defined template in any chart is available to other charts (whether it's the parent chart, or a subchart)

[^CoalesceValues-function]: https://pkg.go.dev/k8s.io/helm/pkg/chartutil#CoalesceValues