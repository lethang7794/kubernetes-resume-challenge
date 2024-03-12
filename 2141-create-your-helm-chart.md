# Create your own Helm Chart

## `helm create`: Create a new Helm Chart

- Create a chart named `mychart`

  ```bash
  helm create mychart
  ```

- Let's see what we got

  ```bash
  tree mychart
  ```

  ```text
  mychart
  ├── charts
  ├── Chart.yaml
  ├── templates
  │   ├── deployment.yaml
  │   ├── _helpers.tpl
  │   ├── hpa.yaml
  │   ├── ingress.yaml
  │   ├── NOTES.txt
  │   ├── serviceaccount.yaml
  │   ├── service.yaml
  │   └── tests
  │       └── test-connection.yaml
  └── values.yaml
  ```

  There are a lot of stuffs here.

## Use our chart

- Let's install our chart and see what exactly our release is.

  ```bash
  helm install ./mychart/ --generate-name
  ```

  ```text
  NAME: mychart-1710165841
  LAST DEPLOYED: Mon Mar 11 21:04:01 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  NOTES:
  1. Get the application URL by running these commands:
    export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=mychart,app.kubernetes.io/instance=mychart-1710165841" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    echo "Visit http://127.0.0.1:8080 to use your application"
    kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
  ```

- Let's compare to chart template for `NOTES.txt`

  ```
  1. Get the application URL by running these commands:
  {{- if .Values.ingress.enabled }}
  {{- range $host := .Values.ingress.hosts }}
    {{- range .paths }}
    http{{ if $.Values.ingress.tls }}s{{ end }}://{{ $host.host }}{{ .path }}
    {{- end }}
  {{- end }}
  {{- else if contains "NodePort" .Values.service.type }}
    export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "mychart.fullname" . }})
    export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT
  {{- else if contains "LoadBalancer" .Values.service.type }}
       NOTE: It may take a few minutes for the LoadBalancer IP to be available.
             You can watch the status of by running 'kubectl get --namespace {{ .Release.Namespace }} svc -w {{ include "mychart.fullname" . }}'
    export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "mychart.fullname" . }} --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
    echo http://$SERVICE_IP:{{ .Values.service.port }}
  {{- else if contains "ClusterIP" .Values.service.type }}
    export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "mychart.name" . }},app.kubernetes.io/instance={{ .Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod --namespace {{ .Release.Namespace }} $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    echo "Visit http://127.0.0.1:8080 to use your application"
    kubectl --namespace {{ .Release.Namespace }} port-forward $POD_NAME 8080:$CONTAINER_PORT
  {{- end }}
  ```

  I feel a little bit overwhelm.

## Create the chart from scratch

Let's remove the templates `helm create` generated for us and start from scratch.

```bash
rm -rf mychart/templates/*
```

### Create template for a basic ConfigMap object

- Add the template for ConfigMap object

  ```yaml
  # mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-configmap
  data:
    myvalue: "Hello World"
  ```

  > [!TIP]
  > Use `.yaml` for YAML files, `.tpl` for helper files.

- Install our chart

  ```bash
  helm install ./mychart --generate-name
  ```

  ```text
  NAME: mychart-1710232106                                                                        │
  LAST DEPLOYED: Tue Mar 12 15:28:26 2024                                                         │
  NAMESPACE: default                                                                              │
  STATUS: deployed                                                                                │
  REVISION: 1                                                                                     │
  TEST SUITE: None
  ```

  We got a _release_ named `mychart-1710232106`.

- Get the `manifest` of the release

  > [!NOTE]
  > A _manifest_[^manifest] is a YAML-encoded representation of the Kubernetes resources
  > that were generated from this release's chart(s)

  ```shell
  helm get manifest mychart-1710232106
  ```

  ```text
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-configmap
  data:
    myvalue: "Hello World"
  ```

  - The manifest contains all the Kubernetes resources (files).
  - Each file:

    - begins with `---` to indicate the start of a YAML document
    - followed by an automatically generated comment line that tells us what template file generated this YAML document.

      `# Source: ...`

- Cleanup our chart

  ```bash
  helm uninstall mychart-1710232106
  ```

Currently, our chart cannot be installed more than once.

Why? Because the chart's template has a hard-coding name (which mean our
release also has a hard-coding name).

```shell
helm install ./mychart --generate-name
```

```
Error: INSTALLATION FAILED: Unable to continue with install: ConfigMap "mychart-configmap" in namespace "default" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "mychart-1710233795": current value is "mychart-1710233793"
```

### Create a template that can be install many times

- Let's use the release name as a part of our ConfigMap name

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
  name: {{ .Release.Name }}-configmap
  data:
  myvalue: "Hello World!"
  ```

- You use _template directive_ `{{ .Release.Name }}` to inject the release name (a value) into the template.

  - A _template directive_

    - is enclosed in `{{` and `}}` blocks.

      e.g. `.Release.Name`

    - contains **namespaced _objects_** separated by a dot (`.`)

  - Helm uses _template directive_ to _access_ **values** (through objects) and pass (these values) to templates.
  - We read `.Release.Name` as
    - (start at the `top` namespace), find the `Release` (top-level) object
    - then look inside of it for an object called `Name`

> [!NOTE]
> The `Release` object is one of the built-in objects[^build-in-objects] for Helm.

> [!TIP]
> Under the hood[^helm-template], Helm use Go template[^go-template].

- Install our chart many times

  ```bash
  helm install ./mychart --generate-name
  ```

  ```bash
  helm install ./mychart --generate-name
  ```

- See our releases

  ```bash
  helm list
  ```

  ```
  NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
  mychart-1710233793      default         1               2024-03-12 15:56:33.632927991 +0700 +07 deployed        mychart-0.1.0   1.16.0
  mychart-1710237563      default         1               2024-03-12 16:59:23.588047296 +0700 +07 deployed        mychart-0.1.0   1.16.0
  mychart-1710237581      default         1               2024-03-12 16:59:41.404678238 +0700 +07 deployed        mychart-0.1.0   1.16.0
  ```

- See the manifest of our new release

  ```bash
  helm get manifest mychart-1710237563
  ```

  ```text
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710237563-configmap
  data:
    myvalue: "Hello World"
  ```

- Or you can run `helm install` with `--dry-run` flag to simulate an installation

  ```bash
  helm install ./mychart --generate-name --dry-run
  ```

  The output will contains 2 things of the release:

  - Status
  - Manifest

  ```
  NAME: mychart-1710238778
  LAST DEPLOYED: Tue Mar 12 17:19:38 2024
  NAMESPACE: default
  STATUS: pending-install
  REVISION: 1
  TEST SUITE: None
  HOOKS:
  MANIFEST:
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710238778-configmap
  data:
    myvalue: "Hello World
  ```

- If you need even more, use `--debug`

  ```bash
  helm install ./mychart --generate-name --debug
  ```

  There are a lot of information here:

  - **Chart version/path**
  - Release status
  - **Computed values**
  - **Hooks**
  - Manifest

  ```
  install.go:214: [debug] Original chart version: ""
  install.go:231: [debug] CHART PATH: /home/lqt/go/src/github.com/lethang7794/kubernetes-resume-challenge/mychart

  client.go:142: [debug] creating 1 resource(s)
  NAME: mychart-1710239005
  LAST DEPLOYED: Tue Mar 12 17:23:25 2024
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  USER-SUPPLIED VALUES:
  {}

  COMPUTED VALUES:
  affinity: {}
  autoscaling:
    enabled: false
    maxReplicas: 100
    minReplicas: 1
    targetCPUUtilizationPercentage: 80
  fullnameOverride: ""
  image:
    pullPolicy: IfNotPresent
    repository: nginx
    tag: ""
  imagePullSecrets: []
  ingress:
    annotations: {}
    className: ""
    enabled: false
    hosts:
    - host: chart-example.local
      paths:
      - path: /
        pathType: ImplementationSpecific
    tls: []
  livenessProbe:
    httpGet:
      path: /
      port: http
  nameOverride: ""
  nodeSelector: {}
  podAnnotations: {}
  podLabels: {}
  podSecurityContext: {}
  readinessProbe:
    httpGet:
      path: /
      port: http
  replicaCount: 1
  resources: {}
  securityContext: {}
  service:
    port: 80
    type: ClusterIP
  serviceAccount:
    annotations: {}
    automount: true
    create: true
    name: ""
  tolerations: []
  volumeMounts: []
  volumes: []

  HOOKS:
  MANIFEST:
  ---
  # Source: mychart/templates/configmap.yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: mychart-1710239005-configmap
  data:
    myvalue: "Hello World"
  ```

### What's next

See [Build-in objects](./2142-helm-buildin-objects.md)

[^manifest]: <https://helm.sh/docs/helm/helm_get_manifest/>
[^go-template]: <https://pkg.go.dev/text/template>
[^build-in-objects]: <https://helm.sh/docs/chart_template_guide/builtin_objects/>
[^helm-template]: <https://helm.sh/docs/chart_template_guide/functions_and_pipelines/>
