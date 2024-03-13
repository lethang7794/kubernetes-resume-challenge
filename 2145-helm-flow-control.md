# Helm - Flow Control

Helm's template language provides the following flow control structures:

- `if/else` to create conditional blocks (of text)
- `with` to specify a scope
- `range` to provide a "for each"-style loop

## `if/else` statement

In Helm template language, `if/else` allows conditionally including blocks of text in a template

### `if/else` syntax

```
{{ if PIPELINE }}
  # 1. This block of text is included if PIPELINE is evaluated to true
{{ else if OTHER PIPELINE }}
  # 2. ... this block of text is included if OTHER PIPELINE is evaluated to true
{{ else }}
  # 3. ... this block of text is included
{{ end }}
```

---

> [!IMPORTANT]
> Control structures can evaluate
>
> - a **value**
> - or an entire **pipeline** (The output of the final command in the pipeline is the value of the pipeline)

> [!IMPORTANT]
> A _pipeline_ is a possibly chained sequence of "commands".
>
> A _command_ is
>
> - a simple value (argument)
> - a function call call, possibly with multiple arguments

> [!IMPORTANT]
> The control structures consider a value as `false` if the value is:
>
> - a boolean false
> - a nil (null)
> - a numeric zero
> - an empty string
> - an empty collection (map, slice, tuple, dict, array)
>
> Under all other conditions, the condition is `true`.

---

### `if/else` example

```
{{- if eq .Values.favorite.drink "coffee" -}}
mug: "true"
{{- end -}}
```

> [!IMPORTANT]
> In Helm, when using flow control structure, you also need to control the whitespace
> (that will be included in the block of text created by the control flow).
>
> In short, when using flow control structure:
>
> - Instead of using `{{` and `}}`.
> - Always using `{{-` and `-}}`. Notice the extra dash (`-`) and space (``).
>
> For more information, see [Controlling Whitespace](./2146-helm-controlling-whitespace)

## `with` statement

In Helm template language, `with` set the current scope (`.`) to a particular object.

### `with` syntax

```
{{ with PIPELINE }}
  # restricted scope
{{ end }}
```

### `with` example

- Instead of access `drink`, `food` with
  
  ```
  drink: {{ .Values.favorite.drink }}
  food: {{ .Values.favorite.food }}
  ```

- We can do it with
  
  ```
  {{- with .Values.favorite }}
  drink: {{ .drink }}
  food: {{ .food  }}
  {{- end }}
  ```

> [!NOTE]
> The control structure `with` also acts as an `if`:
>
> The block after with only executes if the value of PIPELINE is not empty.

> [!TIP]
> In Go template language, `with` action is used to set the _cursor_ (represented by a period `.` and called `dot`)
>
> For `{{with pipeline}} T1 {{end}}`:
>
> - If the value of the pipeline is empty, no output is generated;
> - otherwise, dot is set to the value of the pipeline and T1 is executed.

> [!CAUTION]
> The `with` statement can block access to build-in objects, e.g.
>
> ```go
> {{- with .Values.favorite }}
> drink: {{ .drink  | quote }}
> food: {{ .food | upper | quote }}
> release: {{ .Release.Name }} // .Release.Name is inaccessible, which will produce an error
> {{- end }}
> ```
>
> To handle this situation, you can
>
> - Access built-in object outside of `with` statement
>
> ```
> {{- with .Values.favorite }}
> {{- end }}
> release: {{ .Release.Name }}
> ```
>
> - Inside `with` statement, use `$` (to map to the root scope) and access the build-in objects.
>
> ```
> {{- with .Values.favorite }}
> release: {{ $.Release.Name }}
> {{- end }}
> ```

## `range` function

In Helm template language, the way to iterate through a collection is to use the `range` operator.

### `range` syntax

### `range` example

- First, we have a list of pizza toppings in `values.yaml`
  
  ```yaml
  # values.yaml
  pizzaToppings:
    - mushrooms
    - cheese
    - peppers
    - onions
  ```

- Then, in our template, we _**range over**_ (iterate through) the list (called `slice` in Go),
  
  ```
  toppings: |-
  {{- range.Values.pizzaToppings }}
  - {{ .| title | quote }}
  {{- end }}
  ```
  
  Each time through the loop, `.` is set to the _current_ pizza topping

- If the template are executed, we'll got
  
  ```yaml
  toppings: |-
    - "Mushrooms"
    - "Cheese"
    - "Peppers"
    - "Onions"
  ```

> [!IMPORTANT]
> The `|-` marker in YAML takes a _multi-line_ string.
> This can be a useful technique for embedding big blocks of data inside of your manifests, as exemplified here.
