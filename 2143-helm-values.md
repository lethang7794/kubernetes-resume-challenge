# Helm - Values Files

## Where are values from?

- The top-level `Values` object content come from multiple sources:

  - The chart's `values.yaml` file (a.k.a _default values_)
  - The parent chart's `values.yaml` file (for a subchart)
  - A user-supplied values file passed with `-f` flag (to `helm install`/`helm upgrade`)

    e.g. `helm install ./mychart --generate-name -f myvals.yaml`

  - Individual parameter passed with `--set`

    e.g. `helm install ./mychart --generate-name --set foo=bar`

- These sources list are in order of increasing precedence. The latter can take precedence over the former.

- Values file are in YAML format.

## Let's provide our first value for the chart

- Replace `values.yaml` default content with `favoriteDrink: coffee`

  ```yaml
  # values.yaml
  favoriteDrink: coffee
  ```

- In the template, use value `coffee` via `.Values.favoriteDrink`

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
  data:
    myvalue: "Hello World"
    drink: {{ .Values.favoriteDrink }}
  ```
- Install our chart (with new default values)

  ```shell
  helm install ./mychart --generate-name --debug
  ```

  ```
  install.go:214: [debug] Original chart version: ""
  install.go:231: [debug] CHART PATH: /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart
  
  client.go:142: [debug] creating 1 resource(s)
  NAME: mychart-1710253837
  LAST DEPLOYED: Tue Mar 12 21:30:37 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  USER-SUPPLIED VALUES:
  {}
  
  COMPUTED VALUES:
  favoriteDrink: coffee
  
  HOOKS:
  MANIFEST:
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710253837-configmap
  data:
    myvalue: "Hello World"
    drink: coffee
  ```

- Try overriding values with `--set`

  ```shell
  helm install ./mychart --generate-name --debug --set favoriteDrink=milk
  ```

  ```
  install.go:214: [debug] Original chart version: ""
  install.go:231: [debug] CHART PATH: /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart
  
  client.go:142: [debug] creating 1 resource(s)
  NAME: mychart-1710254007
  LAST DEPLOYED: Tue Mar 12 21:33:27 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  USER-SUPPLIED VALUES:
  favoriteDrink: milk
  
  COMPUTED VALUES:
  favoriteDrink: milk
  
  HOOKS:
  MANIFEST:
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710254007-configmap
  data:
    myvalue: "Hello World"
    drink: milk
  ```

## Values file can contain structured content

- The `values.yaml` with structured content
  ```yaml
  # mychart/templates/values.yaml
  favorite:
    drink: coke
    food: pizza
  ```
- Use both fields of the object

  ```
  # mychart/templates/yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ .Release.Name }}-configmap
  data:
    myvalue: "Hello World"
    drink: {{ .Values.favorite.drink }}
    food: {{ .Values.favorite.food }}
  ```

- Let's see what we got

  ```shell
  helm install ./mychart --generate-name --debug
  ```

  ```
  install.go:214: [debug] Original chart version: ""
  install.go:231: [debug] CHART PATH: /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart
  
  client.go:142: [debug] creating 1 resource(s)
  NAME: mychart-1710254482
  LAST DEPLOYED: Tue Mar 12 21:41:22 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  USER-SUPPLIED VALUES:
  {}
  
  COMPUTED VALUES:
  favorite:
    drink: coke
    food: pizza
  
  HOOKS:
  MANIFEST:
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710254482-configmap
  data:
    drink: coke
    food: pizza
  ```

## Delete a default value

Sometimes we don't want a default _value_ or even the value _key_.

In that case, we override the value of the key with `null`, so Helm will remove that key from the overridden merged
values.

e.g.

- The default values of `stable/drupal` chart

  ```yaml
  livenessProbe:
    httpGet:            # We don't need this key or its children
      path: /user/login #
      port: http        #
    initialDelaySeconds: 120
  ```
- What we need

  ```yaml
  livenessProbe:
    exec:
      command:
        - cat
        - docroot/CHANGELOG.txt
    initialDelaySeconds: 120
  ```

- What we do

  ```shell
  helm install stable/drupal \
    --set image=my-registry/drupal:0.1.0 \
    --set livenessProbe.exec.command=[cat,docroot/CHANGELOG.txt] \ # Provide additional values/keys
    --set livenessProbe.httpGet=null                               # Delete what we don't need
  ```