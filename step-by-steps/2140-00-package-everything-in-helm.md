# Extra credit 1: Package Everything In Helm

Task: Utilize Helm to package your application, making deployment and management on Kubernetes clusters more efficient and scalable.

1. Create Helm Chart: Start by creating a Helm chart for your application. This involves setting up a chart directory with the necessary templates for your Kubernetes resources.
2. Define Values: Customize your application deployment by defining variables in the `values.yaml` file. This allows for flexibility and reusability of your Helm chart across different environments or configurations.
3. Package and Deploy: Use Helm commands to package your application into a chart and deploy it to your Kubernetes cluster. Ensure to test your chart to verify that all components are correctly configured and working as expected.
4. Outcome: Your application is now packaged as a Helm chart, simplifying deployment processes and enabling easy versioning and rollback capabilities.

## Create Helm Chart

- The structure of our Helm chart will look like this:

  ```
   └──  ecom                # The Helm chart for our application (parent chart)
      ├──  charts
      │  ├──  common        # A sub-chart for common logic (Bitnami Common Library Chart)
      │  │  └──  templates
      │  └──  mariadb       # A sub-chart for mariadb
      │     └──  templates
      └──  templates
  ```

- We'll put everything in `infra/helm`:

  ```bash
  mkdir -p infra/helm
  cd infra/helm
  ```

- Create the Helm chart for our application

  ```bash
  helm create wordpress
  mv wordpress ecom     # Change the chart folder name to ecom to make things match with our previous structure
  ```

- Create the Helm chart for the database. It will be a subchart of the chart for our application.

  ```bash
  # From infra/helm
  cd ecom/charts
  helm create mariadb
  ```

- Clone the [source code][bitnami-common-lib-source] for [Bitnami Common Library Chart][bitnami-common-lib] to `infra/helm/ecom/charts/common`

- Move the YAML templates for our web application to helm chart `ecom`'s templates.

  - `ecom-web.deploy.yaml` to `ecom/templates/deployment.yaml`
  - `ecom-web.service.yaml` to `ecom/templates/service.yaml`
  - `ecom-web.hpa.yaml` to `ecom/templates/hpa.yaml`

- Move the YAML templates for our database to subchart `mariadb`'s templates

  - `ecom-db.deploy.yaml` to `ecom/charts/mariadb/templates/deployment.yaml`
  - `ecom-db.service.yaml` to `ecom/charts/mariadb/templates/service.yaml`

- Previously, we hardcode the service name that exposing `mariadb` (`mysql_service`) in the definition of our web app.

  Now, the service name that exposing `mariadb` is dynamic (it's depend on the release name), which allows us to install our chart as many times as we want.

- The ConfigMap, and Secret will also be a little different.
  - For the Secret, both the parent chart, and subchart will have their our Secret template, which get the same values from parent chart's `values.yaml`
  - Previously, the ConfigMap is used to store configuration for other object. Now with Helm chart, we can directly use the chart values in our charts' templates.

## Define Values

## Package and Deploy

## Outcome

[bitnami-common-lib-source]: https://github.com/bitnami/charts/tree/main/bitnami/common
[bitnami-common-lib]: https://artifacthub.io/packages/chart/bitnami/common
