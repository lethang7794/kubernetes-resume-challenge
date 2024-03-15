# Helm - Named Template

## What is named template?

Named Template (aka partial, subtemplate)
: A template defined inside of a file, and given a name

## Why use named template?

When we have more than one template and we need to used template inside other templates.

## How named template works?

### Go handling of named templates

#### Go `template` action

`{{template "name"}}`
: The template with the specified name is executed with nil data.

`{{template "name" pipeline}}`
: The template with the specified name is executed with dot set to the value of the pipeline.

#### Go `define` action

In Go, `define` let you define nested templates (in a template).

An example of `define` in Go

- Define nested templates
  
  ```
  {{define "T1"}}ONE{{end}}
  {{define "T2"}}TWO{{end}}
  {{define "T3"}}{{template "T1"}} {{template "T2"}}{{end}}
  ```

- Use the final template
  
  ```
  {{template "T3"}}
  ```

- Result
  
  ```
  # Output:
  ONE TWO
  ```

#### Go `block` action

In Go, a `block`, `{{block "name" pipeline}} T1 {{end}}`, is **shorthand** for

- _defining_ a template: `{{define "name"}} T1 {{end}}`

- (and then) _executing_ it in place `{{template block"name" pipeline}}`

The typical use is to define a set of root templates that are then customized by redefining the block templates within.

### Helm handling of named templates

Helm template language reuses 3 action from Go template language:

- `define` action: create a new named template inside of a template file
- `template` action: use a named template
- `block` action: declares a special kind of fill-able template area

Helm also adds an extra action for named template, it's `include` function.

> [!WARNING]
> Template names are global.
>
> If there are many templates with the same name, the last one loaded will be used.

> [!WARNING]
> Templates in subcharts are compiled together with top-level templates.
>
> You should prefix each template with name of the chart, .e.g `{{ define "mychart.labels" }}`

### Named templates and `_` files

For a Helm chart, most of the files in `/templates` are treated as they contain Kubernetes objects (and have the extension of `.yaml`), except:

- The `NOTES.txt` file
- Files whose names start with an underscore `_`.

These `_` files are the named templates (aka partials, sub-templates), and are usually used in files for Kubernetes objects.

> [!INFO]
> The default location of named templates is `_helpers.tpl` (which `helm create` creates for us)s

> [!NOTE]
> `_` files usually has the extension of `tpl`.

## How to use named template?

### `define` action create a new named template inside of a template file

#### `define` syntax

```
{{- define "MY.NAME" }}
  # body of template here
{{- end }}
```

#### `define` example

- Define a template (to encapsulate labels)
  
  ```
  # configmap.yaml
  {{- define "mychart.labels" }}
    labels:
      generator: helm
      date: {{ now | htmlDate }}
  {{- end }}
  ```
  NOTE: The template content is already indented.

> [!WARNING]
> A `define` does not produce output unless it is called with a `template`.

> [!NOTE]
> By convention, `define` functions should
> - have a simple documentation block (`{{/* ... */}}`) describing what they do.
> - be in the `_helpers.tpl` file.
>
> e.g.
>
> ```
> # templates/_helpers.tpl
> {{/* Generate basic labels */}}
> {{- define "mychart.labels" }}
>   labels:
>     generator: helm
>     date: {{ now | htmlDate }}
> {{- end }}
> ```

### `template` action: insert a named template inside a template

#### `template` syntax

In Helm, the `template` action has 2 syntax:

- `{{- template "mychart.mytemplate" }}`
- `{{- template "mychart.mytemplate" PIPELINE }}`

#### `template` example

- Use [`mychart.labels` template](#define-example) in out template for ConfigMap object
  
  ```
  # configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
    {{- template "mychart.labels" }}
  ```

- The output
  
  ```
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: running-panda-configmap
    labels:
      generator: helm
      date: 2016-11-02
  ```
  NOTE: The output has correct indentation because our named template has already been indented.

> [!NOTE]
> Even though the `define` functions is in `_helpers.tpl`, they can still be accessed in other K8s object templates.
>
> Remember, named templates are global and you need to provide a prefix yourself to distinguish named templates of all chart/sub-charts.

#### Pass the scope to `template` action

When a named template (created with define) is rendered, it will receive the scope passed in by the template call.

e.g.

- Define a template that access to top-level object
  
  ```
  {{/* Generate basic labels */}}
  {{- define "mychart.labels" }}
    labels:
      generator: helm
      date: {{ now | htmlDate }}
      chart: {{ .Chart.Name }}
      version: {{ .Chart.Version }}
  {{- end }}
  ```

- Use `mychart.labels` template as before (without passing in any object)
  
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
    {{- template "mychart.labels" }}
  ```
  Output:
  ```
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: moldy-jaguar-configmap
    labels:
      generator: helm
      date: 2021-03-06
      chart:
      version:
  ```

- Use `mychart.labels` template and pass in top-level object
  
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
    {{- template "mychart.labels" $ }}
  ```
  Output:
  ```
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710444556-configmap
    labels:
      generator: helm
      date: 2024-03-15
      chart: mychart
      version: 0.1.0
  ```

- Use `mychart.labels` template and pass in `.` also works
  
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
    {{- template "mychart.labels" $ }}
    {{- template "mychart.labels" . }}
  ```
  Output
  ```
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710445641-configmap
    labels:
      generator: helm
      date: 2024-03-15
      chart: mychart
      version: 0.1.0
    labels:
      generator: helm
      date: 2024-03-15
      chart: mychart
      version: 0.1.0
  ```

### `block` action

### `include` action: import a named template into the present pipeline (where it can be passed along to other functions in the pipeline)

#### `include` syntax

Just like `template` action, include has 2 syntax

- `{{- include "mychart.mytemplate" }}`
- `{{- include "mychart.mytemplate" PIPELINE }}`

#### `include` example

- Use `include` & pipeline to handle indentation
  
  ```
  # _helpers.tpl
  {{- define "mychart.app" -}}
  myAppName: {{ .Chart.Name }}
  myAppVersion: "{{ .Chart.Version }}"
  {{- end -}}
  ```
  
  ```
  # configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
    labels:
  {{ include "mychart.app" . | indent 4 }}
  data:
    myValue: "Hello World"
  {{ include "mychart.app" . | indent 2 }}
  ```
  
  Output:
  
  ```
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710493714-configmap
    labels:
      myAppName: mychart
      myAppVersion: "0.1.0"
  data:
    myValue: "Hello World"
    myAppName: mychart
    myAppVersion: "0.1.0"
  ```

> [!TIP]
> What happen if we use `template`?
>
> ```
> apiVersion: v1
> kind: ConfigMap
> metadata:
>   name: {{ .Release.Name }}-configmap
>   labels:
>     {{ template "mychart.app" . }}
> data:
>   myValue: "Hello World"
>   {{ template "mychart.app" . }}
> ```
>
> The output will have wrong indentations, only the first line (of the named template content) has the correct indentation.
>
> ```
> # Source: mychart/templates/configmap.yaml
> apiVersion: v1
> kind: ConfigMap
> metadata:
>   name: mychart-1710492695-configmap
>   labels:
>     myAppName: mychart
> myAppVersion: "0.1.0"
> 
> data:
>   myValue: "Hello World"
>   myAppName: mychart
> myAppVersion: "0.1.0"
> ```

