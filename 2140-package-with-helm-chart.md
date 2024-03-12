# Extra Credit 1: Package Everything in Helm

## What is Helm

Helm is the package manager for Kubernetes

## Why use Helm

**_Find_**, share & **use** software built for Kubernetes.

## Helm concepts

Helm main concepts:

Chart (Helm packaging format)
: A bundle of information necessary to create an instance of a Kubernetes application.
: (~ a Homebrew formula, an Apt dpkg, or a Yum RPM file)

Repository
: A place where charts can be collected and shared

Config
: Configuration information that can be merged into a _chart_ to create a releasable object.

Release
: A running instance of a _chart_, combined with a specific _config_.
: One chart can often be installed many times into the same cluster. And each time it is installed, a new release is
created
: e.g. A MySQL chart can be installed twice to have 2 databases running in the K8s cluster.

> Helm installs _charts_ into Kubernetes, creating a new _release_ for each installation.
>
> To find new charts, you can search Helm chart _repositories_.

## Helm prerequisites

- [x] A Kubernetes cluster
- [x] `kubectl` binary
- [ ] `helm` binary

## Quick start

### Install Helm

- There are a lot of ways to install Helm[^Install Helm], I'll use `brew`

```bash
brew install helm
```

- Verify helm is installed

```bash
helm version
```

### Initialize a Helm Chart Repository

I'll install the [Bitnami's Helm Chart Repository][^Bitnami Repo]

```bash
# Add the bitnami repository for Helm Chart
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### Find the Helm Chart in our installed Helm Chart Repository

```bash
# List all the Helm Chart in all of our installed repository
helm search repo
```

```bash
# Or only chart about something e.g. mysql
helm search repo mysql
```

### Find the Helm Chart in other repositories (via Artifact Hub)

```bash
helm search hub mysql
```

> [!TIP] > [Artifact Hub][^Artifact Hub] is a platform to share and discover artifacts from varying cloud native
> projects.
>
> There are a lot of kind of artifacts available in Artifact Hub:
>
> - Container _images_
> - Open Policy Agent (OPA) _policies_
> - Helm _charts_
> - Argo _templates_
> - kubectl _plugins_
> - ...
>
> Learn more about Artifact Hub at [Introducing The Artifact Hub][^Introducing The Artifact Hub]

### Install an Example Chart

Whenever you install a chart, a new release is created. So one chart can be installed multiple times into the same
cluster. And each can be independently managed and upgraded.

Let's install a chart:

- [Optional] Update data of repositories

  ```bash
  helm repo update # So we can have the latest available charts
  ```

- Install a Helm Chart

  - We need to provide a name for the release

    ```bash
    helm install my-mysql bitnami/mysql # this name should be unique
    ```

  - Or let helm generate a name for the release

    ```bash
    helm install          bitnami/mysql --generate-name # So we can install a helm chart many times into a cluster (without naming our release)
    ```

    ```text
    NAME: mysql-1710079919
    LAST DEPLOYED: Sun Mar 10 21:12:02 2024
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    CHART NAME: mysql
    CHART VERSION: 9.23.0
    APP VERSION: 8.0.36

    ** Please be patient while the chart is being deployed **
    ...
    ```

But what are we installing?

## Get information of a chart (before installing it)

### `helm show`: Show information of a chart

```bash
helm show chart bitnami/mysql
```

```yaml
annotations:
#
description:
  MySQL is a fast, reliable, scalable, and easy to use open source relational
  database system. Designed to handle mission-critical, heavy-load production applications.
#
keywords:
  - mysql
  - database
  - sql
  - cluster
  - high availability
maintainers:
  - name: VMware, Inc.
    url: https://github.com/bitnami/charts
name: mysql
sources:
  - https://github.com/bitnami/charts/tree/main/bitnami/mysql
version: 9.23.0
```

## What we can do with our releases?

### `helm list`: List releases

```bash
helm list # or helm ls
```

```text
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-mysql                default         1               2024-03-10 20:58:02.660466269 +0700 +07 deployed        mysql-9.23.0    8.0.36
mysql-1710079919        default         1               2024-03-10 21:12:02.905513092 +0700 +07 deployed        mysql-9.23.0    8.0.36
```

```shell
kubectl get pods -o wide
```

```txt
NAME                               READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
ecom-db-deploy-bdcd7f588-wqqw2     2/2     Running   0          99m   10.244.0.76   minikube   <none>           <none>
ecom-web-deploy-585c55f9cb-c6vgl   1/1     Running   0          95m   10.244.0.77   minikube   <none>           <none>
ecom-web-deploy-585c55f9cb-z8jgw   1/1     Running   0          95m   10.244.0.78   minikube   <none>           <none>
my-mysql-0                         1/1     Running   0          42m   10.244.0.79   minikube   <none>           <none>
mysql-1710079919-0                 1/1     Running   0          28m   10.244.0.80   minikube   <none>           <none>
```

### `helm status`: Check status of a release

```bash
helm status mysql-1710079919
```

It's what showing after we installed a chart.

```text
NAME: mysql-1710079919
LAST DEPLOYED: Sun Mar 10 21:12:02 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: mysql
CHART VERSION: 9.23.0
APP VERSION: 8.0.36
```

### `helm uninstall`: Uninstall a release

### `helm rollback`: Rollback a release to a previous revision (or any version in the release history)

## Customize the chart before installing

### `helm show values`: See what options are configurable on a chart

> The output of `helm show values` is in YAML format, pipe it to `yq` or `bat`

## Chart 101

### What exactly is a chart?

A chart is a _collection of files_ that describe a related set of Kubernetes resources.

### Structure of a chart

A chart is organized as a collection of files inside of a directory.

```text
# Basic files of a Helm chart
wordpress/    # The directory name is the name of the chart (without versioning)
  Chart.yaml  # A YAML file containing information (description) about the chart
  values.yaml # The default configuration values for this chart
  templates/  # A directory of templates that, when combined with values,
              # will generate valid Kubernetes manifest files.
  charts/     # A directory containing any charts upon which this chart depends.
```

### `Chart.yaml` file

```yaml
apiVersion: # (required) The chart API version
name: # (required) The name of the chart
version: # (required) A SemVer 2 version number
# ... and a lot of fields
appVersion: # (optional) The version of the app that this contains
annotations: # (optional)
# ... any custom metadata can be added here
```

#### `version` field: Chart's version

Every chart must have a `version number` that follow the [SemVer 2 standard][^SemVer 2].

From Helm 2, `version number` is used as release marker of a package. Packages in repositories are identified by `name`
plus `version number`.

e.g. an `nginx` chart whose version field is set to `version: 1.2.3` will be named `nginx-1.2.3.tgz`

#### `apiVersion` field: Helm's version

`v2`: used from Helm 3

`v1` (deprecated): used in Helm 1, 2

#### `appVersion` field: App's version

e.g. For `bitnami/mysql` chart

```yaml
name: mysql
apiVersion: v2 # Version of Helm
appVersion: 8.0.36 # Version of the application (of this Helm chart)
version: 9.23.0 # Version of the Helm chart
```

> [!TIP]
> Wrapping the version in quotes is highly recommended.
>
> - It forces the YAML parser to treat the version number as a string and prevent un-expected situations.
> - As of Helm v3.5.0, `helm create` wraps the default `appVersion` field in quotes.

#### There are still other versions

- `kubeVersion`

- Version of dependencies charts

e.g.

```yaml
dependencies:
  - name: common
    repository: oci://registry-1.docker.io/bitnamicharts
    tags:
      - bitnami-common
    version: 2.x.x # Version of a dependency
```

### Chart README, NOTES, LICENSE

Charts can also contain files that describe the installation, configuration, usage and license of a chart.

README.md
: What hub/other GUI use as the detail for a chart.
: Should contains:
: - Description
: - Prerequisites/requirements
: - Options in `values.yaml` (and default values)
: - Any information needed to get this chart up & running.

NOTES.txt
: What printed out after installation, and when viewing the status of a release

LICENSE
: A plain text file containing the license for the chart.

## Create your own Helm Chart

### `helm create`: Create a new Helm Chart

```bash
helm create mychart
```

Let's see what we got

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

Let's install our chart and see what exactly our release is.

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

Let's compare to chart template for `NOTES.txt`

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

---

[^Install Helm]: https://helm.sh/docs/intro/install/

[^Bitnami Repo]: https://charts.bitnami.com/

[^Artifact Hub]: https://artifacthub.io/

[^SemVer 2]: https://semver.org/spec/v2.0.0.html

[^Introducing The Artifact Hub]: https://codeengineered.com/blog/2020/artifact-hub/
