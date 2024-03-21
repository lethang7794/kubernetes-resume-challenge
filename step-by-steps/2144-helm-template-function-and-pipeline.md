# Helm - Template Function & Pipeline

Sometimes we want to _transform_ the supplied data (values) in a way that makes it more _useful_ (to us).

Helm do that with `template function` & `template pipeline`

> [!NOTE]
> Useful information that users should know, even when skimming content.

## Helm template function

A template function has the following syntax

```
functionName arg1 arg2....
```

e.g.

- Template function (with raw value)

  ```
  title 'hello world' # Output: Hello World
  ```

  ```
  max 1 2 3           # Output: 6 
  ```

- Template function with injected values

  ```
  upper .Release.Name
  ```

## Calling function inside template

1. A template function can be called inside template with its normal syntax

    ```
    {{ upper .Release.Name }}
    ```

2. or by using `pipeline`

- e.g.

  ```
  {{ .Release.Name | upper }}
  ```

- Instead of calling & pass in the argument:  `upper ARG`,

- we "sent" a value (as the _last argument_) to the function using a pipeline (`|`): `ARG | upper`.

- Using pipelines, we can chain several functions together

  ```gotemplate
  {{ "hello!" | upper | repeat 5 }}
  ```
  ```
  # Output: HELLO!HELLO!HELLO!HELLO!HELLO!
  ```

> [!NOTE]
> How should you call a template function?
>
> Either practice is fine. But you will see `.val | someFunc` more often than `someFunc .val`.

### Where are the template functions

- Go's template functions: https://pkg.go.dev/text/template?utm_source=godoc#hdr-Functions
- Sprig's functions: https://masterminds.github.io/sprig/
- Helm's functions: https://helm.sh/docs/chart_template_guide/function_list/
- YAML: To Quote or not to quote? https://www.yaml.info/learn/quote.html

### Is Helm docs good?

I don't think so.

Where do you think you can file the docs about `include` function?

- Template Functions and Pipelines: The page introduce template function? No.
- Template Function List: No
- Somewhere in the docs.
