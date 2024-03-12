# Helm - Build-in objects

## What is Helm object?

> [!NOTE]
> Helm _built-in_ objects is a.k.a _top-level_ objects

## Built-in objects

### `Release`: describes the release itself

- `Release.Name`
- `Release.Namespace`
- `Release.Revision`

### `Values`: values passed into the template

The values are from

- the `values.yaml` file
- user-supplied files

### `Chart`: `Chart.yaml` file

e.g. `.Chart.Name`, `.Chart.Version`

### `Subcharts`

e.g. `.Subcharts.mySubChart.myValue`

### `Files`: non-special files in a chart

### `Capabilities`: what capabilities the Kubernetes cluster supports

- `Capabilities.APIVersions`
- `Capabilities.APIVersions.Has $version`
- `Capabilities.KubeVersion`
- `Capabilities.HelmVersion`

### `Template`: the current template that is being executed

- `Template.Name`

  e.g. `mychart/templates/mytemplate.yaml`

- `Template.BasePath`

  e.g. `mychart/templates`
