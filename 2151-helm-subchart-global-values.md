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

