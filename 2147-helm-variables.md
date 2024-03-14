# Helm - Variables

## What is variable?

In Helm templates, a _variable_

- is a named reference to another object.

- has the syntax `$var`.
  
  A variable starts with a dollar sign (`$`)

- are typed.
  
  Once a variable is created for one type, such as a string, you cannot set the value to another type, such as an integer.

## How to use variable?

To create/initialize a variable, you use the syntax `:=`, e.g.

```gotemplate
{{ $var := .Values.character }}
```

- A variable `var` is created.
- The value of `.Values.character` is assigned to it.

This variable can be used elsewhere, e.g.

```gotemplate
character: {{ $var | default "Sylvester" | quote }}
```

You can assign a new value to a variable with the syntax `=`, e.g.

```gotemplate
{{ $var := .Values.character }}
{{ $var = "Tweety" }}
```

> [!TIP]
> Variable in Helm works almost exactly as in Go programming language

## The scope of variable

The scope of a variable is the **block** in which they are _declared_.

A variable is accessible inside its scope, which can be:

- the top-level block ("global" scope) ([See The special variable `$`](#the-special-variable-))
- a control structure block ("local" scope), e.g. block created with `if`, `with`, `range`
  
  - `{{ if }}{{ end }}`
  - `{{ with }}{{ end }}`
  - `{{ range... }}{{ end }}`

## When to use a variable?

1. A variable can be used (inside a block) to access values outside of that block, e.g.
   
   ```gotemplate
   {{- $relName := .Release.Name -}}
   {{- with .Values.favorite }}
   release: {{ $relName }}
   {{- end }}
   ```
   
   Inside the `with` block, the `$relName` variable still points to the release name.

2. Variables can be used in `range` to capture

- The index & value of a list (Go slice)
  
  ```yaml
  # values.yaml
  pizzaToppings:
    - mushrooms
    - cheese
    - peppers
    - onions
  ```
  
  ```yaml
  # template.yaml
  toppings: |-
    {{- range $index, $topping := .Values.pizzaToppings }}
      {{ $index }}: {{ $topping }}
    {{- end }}    
  ```
  
  ```yaml
  # Output:
  toppings: |-
    0: mushrooms
    1: cheese
    2: peppers
    3: onions      
  ```

- The key & value of a dictionary (Go map)
  
  ```yaml
  # values.yaml
  myValue: Hello World
  drink: coffee
  food: pizza
  ```
  
  ```text
  # template.yaml
  {{- range $key, $val := .Values.favorite }}
    {{ $key }}: {{ $val | quote }}
  {{- end }}
  ```
  
  ```yaml
  # Output:
  myValue: "Hello World"
  drink: "coffee"
  food: "pizza"
  ```

## The special variable `$`

The variable `$` always point to the top-level block (root context).

It's very useful when using with blocks created with `if`, `with`, `range`.

- e.g.
  
  ```
  {{- range .Values.tlsSecrets }}
  apiVersion: v1
  kind: Secret
  metadata:
    name: {{ .name }}
    labels:
      app.kubernetes.io/name: {{ template "fullname" $ }}
      helm.sh/chart: "{{ $.Chart.Name }}-{{ $.Chart.Version }}"
      app.kubernetes.io/instance: "{{ $.Release.Name }}"
  type: kubernetes.io/tls
  data:
    tls.crt: {{ .certificate }}
    tls.key: {{ .key }}
  ---
  {{- end }}
  ```
  
  There are 3 different ways to access values in this template:
  - `.`: The _current_ iterate object is used to access the current tlsSecket values
    
    e.g. `.name`, `.certificate`, `.key`.
  
  - `$`: The top-level object is passed to `template` function (`template "fullname" $`)
  - `$.`: (Via top-level object) access the built-in objects, e.g. `$.Chart`, `$.Release`