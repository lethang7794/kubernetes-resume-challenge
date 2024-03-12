# Helm - Values Files

- The top-level `Values` object content come from multiple sources:

  - The chart's `values.yaml` file
  - The parent chart's `values.yaml` file (for a subchart)
  - A user-supplied values file passed with `-f` flag (to `helm install`/`helm upgrade`)

    e.g. `helm install ./mychart --generate-name -f myvals.yaml`

  - Individual parameter passed with `--set`

    e.g. `helm install ./mychart --generate-name --set foo=bar`

  These sources list are in order of increasing precedence. The latter can take precedence over the former.

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

- Values file can contain more structured content

  ```yaml
  # mychart/templates/values.yaml
  favorite:
    drink: coke
    food: pizza
  ```

  ```yaml
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