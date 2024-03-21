# Helm - Working with files inside template

Helm provides access to files through the `.Files` top-level object:

- `.Files.Get` function returns _a file_ by **name**, e.g. `.Files.Get config.ini`
- `.Files.Glob` function returns _a list of files_ whose names match the given shell **glob pattern**.
- `.Files.GetBytes` function returns a file as an
  **array of _bytes_** (instead of as a string). This is useful for things like images.
- `.Files.Lines` function reads a file as an **array of _lines_** (split by newlines `\n`).
- `.Files.AsConfig` function returns file's content as a **YAML** map.
- `.Files.AsSecrets` function returns file's content as **Base 64 encoded** strings.

## Limitation when accessing files inside template

- Chart must be smaller than 1MB (because of the limitation of Kubernetes)
- Not all the files in the Helm chart can be accessed
  - Files in `/templates`
  - Files ignored by `.helmignore`
  - Files outside of a sub-chart.

## How to read a file?

To read a file, you provide the file name to one of the functions of `.Files` top-level object.

The file name is the name including filepath from the root of the chart.

--- 
Example: Read 3 files into a ConfigMap

- We have 3 files in `/mychart`
  
  ```
  # mychart/config1.toml
  message = Hello from config 1
  ```
  
  ```
  # mychart/config2.toml
  message = This is config 2
  ```
  
  ```
  # mychart/config3.toml
  message = Goodbye from config 3
  ```

- Inject content of these 3 files into our ConfigMap
  
  ```
  # /mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
  data:
    {{- $files := .Files }}
    {{- range tuple "config1.toml" "config2.toml" "config3.toml" }}
    {{ . }}: |-
      {{ $files.Get . }}
    {{- end }}
  ```
  - Create a `$files` variable to hold a reference to the `.Files` object
  - Use the `tuple` function to create a list of files that we loop through
  - Use `range` function to loop through the list of file names. For each file name, print out 2 lines:
    - Line 1: the file name via `{{ . }}` followed by `: |-`
    - Line 2: the file content via ``{{ $files.Get . }}``
- Output
  
  ```
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710497861-configmap
  data:
    config1.toml: |-
      Hello from config 1
    config2.toml: |-
      This is from config 2
    config3.toml: |-
      Goodbye from config 3
  ```

---

### File Path Functions: Working with file path

Helm imports many function from Go `path` package[^go-path-package], and re-export with a lowercase name

| Go    | Helm  |
|-------|-------|
| Base  | base  |
| Dir   | dir   |
| Clean | clean |
| Ext   | ext   |
| IsAbs | isAbs |

For more information see, [Functions List / File Path Functions][^file-path-function]

### `.Files.Glob`: Return only the files whose names match the glob pattern

For a full list of supporting glob patterns, see [`gobwas/glob` package's doc][^gobwas-glob]

> [TIP]
> Glob patterns (aka global patterns) is a way to specify a _**set** of filenames/paths_ using wildcard characters

`.Files.Glob` function:

- receives a `pattern` of type string
- returns a `.Files` type, so we can call any `Files` methods (the same as `.Files` top-level object)

---

e.g.

- Our `mychart` chart has the directory structure
  
  ```
  ./mychart
  ├── foo.txt 
  ├── foo.yaml
  ├── bar.go
  ├── bar.conf
  ├── baz.yaml
  ```

- Loop through the files and get the file:
  - via `$` (top-level scope)
    ```
    {{ range $path, $_ :=  .Files.Glob  "**.yaml" }}
      {{ $.Files.Get $path }}
    {{ end }}
    ```
  
  - via $currentScope (using `with` function)
    ```
    {{ $currentScope := .}}
    {{ range $path, $_ :=  .Files.Glob  "**.yaml" }}
      {{- with $currentScope}}
        {{ .Files.Get $path }}
      {{- end }}
    {{ end }}
    ```

### `AsConfig` & `AsSecrets`: Place file content into Kubernetes `ConfigMap` object & `Secret` object

These methods are usually used with `.Glob` method

e.g.

- `.AsConfig`
  
  ```
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: conf
  data:
  {{ (.Files.Glob "foo/*").AsConfig | indent 2 }}
  ```

- `.AsSecrets`
  
  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: very-secret
  type: Opaque
  data:
  {{ (.Files.Glob "bar/*").AsSecrets | indent 2 }}
  ```

## Encode file with `b64enc` function

Helm has `b64enc` function that can be used to transform the file content

e.g.

- `mychart/templates/secrets.yaml`
  
  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: {{ .Release.Name }}-secret
  type: Opaque
  data:
    token: |-
      {{ .Files.Get "config1.toml" | b64enc }}
  ```

- Output
  
  ```
  # Source: mychart/templates/secret.yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: lucky-turkey-secret
  type: Opaque
  data:
    token: |-
          bWVzc2FnZSA9IEhlbGxvIGZyb20gY29uZmlnIDEK
  ```

### `.Files.Lines` and `range` function

`.Files.Lines` returns the file content as lines, which can be loop through with `range` function

e.g.

```
data:
  {{ range .Files.Lines "foo/bar.txt" }}
  {{ . }}
  {{ end }}
```

[^go-path-package]: https://pkg.go.dev/path

[^file-path-function]: https://helm.sh/docs/chart_template_guide/function_list/#file-path-functions

[^gobwas-glob]: https://pkg.go.dev/github.com/gobwas/glob