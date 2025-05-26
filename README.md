# Backstage Helm Chart

This Helm chart deploys [Backstage](https://backstage.io/) with PostgreSQL as a database backend.

## Features

- **Complete Backstage Application**: Deploys the full Backstage application using the official Spotify image
- **PostgreSQL Database**: Uses PostgreSQL subchart for data persistence
- **Lifecycle Management**: Implements Helm hooks for proper application lifecycle
- **GitOps Ready**: Designed to work with ArgoCD in a GitOps workflow
- **Comprehensive Testing**: Includes test templates for quality assurance
- **Chart Schema Validation**: Uses JSON Schema to validate chart values.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for PostgreSQL persistence)

## Installing the Chart

To install the chart with the release name `backstage`:

```bash
helm install backstage ./backstage
```

## Configuration

| Parameter                           | Description                                 | Default                                                 |
|-------------------------------------|---------------------------------------------|---------------------------------------------------------|
| `replicaCount`                      | Number of replicas for the deployment       | `1`                                                     |
| `image.repository`                  | Backstage image repository                  | `roadiehq/community-backstage-image`                                    |
| `image.tag`                         | Backstage image tag                         | `latest`                                               |
| `image.pullPolicy`                  | Image pull policy                           | `IfNotPresent`                                         |
| `service.type`                      | Kubernetes service type                     | `ClusterIP`                                            |
| `service.port`                      | Kubernetes service port                     | `80`                                                   |
| `postgresql.enabled`                | Enable PostgreSQL deployment                | `true`                                                 |
| `postgresql.auth.username`          | PostgreSQL username                         | `backstage`                                            |
| `postgresql.auth.password`          | PostgreSQL password                         | `backstage123`                                         |
| `postgresql.auth.database`          | PostgreSQL database name                    | `backstage`                                            |

## Using Helm Lifecycle Hooks

This chart implements several lifecycle hooks:

- **Pre-install**: Performs database migration setup
- **Post-upgrade**: Clears application caches
- **Pre-rollback**: Creates database snapshots

## Implementing Helm Conditional Dependencies

The PostgreSQL dependency can be enabled or disabled using:

```yaml
postgresql:
  enabled: true  # Set to false to disable PostgreSQL
```

## Dependency Management

This chart uses PostgreSQL as a subchart. Benefits of using subcharts:

- **Encapsulation**: Clean separation of components
- **Versioning**: Each subchart can be versioned independently
- **Reusability**: Subcharts can be reused across different parent charts

## ArgoCD Integration

To deploy this chart using ArgoCD, apply the `argocd-backstage-app.yaml` file:

```bash
kubectl apply -f argocd-backstage-app.yaml
```

## Custom Plugin

This chart comes with a custom Helm plugin for checking the health of Backstage:

```bash
# Install the plugin
mkdir -p ~/.helm/plugins/backstage
cp helm-backstage-plugin.sh ~/.helm/plugins/backstage/backstage.sh
cp plugin.yaml ~/.helm/plugins/backstage/

# Run the plugin
helm backstage-health backstage irembo
```

# Chart Signing & Provenance

This Helm chart is signed and includes a `.prov` file for verifying its authenticity.

## Verifying the Chart

To verify the chart before installation:

```bash
# Add and update the repository
helm repo add irembo-backstage-helm https://1moses1.github.io/irembo-backstage-helm-chart/
helm repo update

# Download the chart and provenance file
helm pull irembo-backstage-helm/backstage --version 0.1.1 --verify
```

🔐 This will check the `.prov` file against the embedded GPG signature used during release.

The `.tgz` and `.prov` files are also available on the GitHub Releases page.

## Installation

After verification, install the chart:

```bash
# Install the chart
helm install my-backstage irembo-backstage-helm/backstage --version 0.1.1

# Or upgrade if already installed
helm upgrade my-backstage irembo-backstage-helm/backstage --version 0.1.1
```

You can also customize the installation with a values file:

```bash
# Install with custom values
helm install my-backstage irembo-backstage-helm/backstage --version 0.1.1 -f values.yaml

# Or set individual values
helm install my-backstage irembo-backstage-helm/backstage --version 0.1.1 --set key=value
```

## Provenance on Artifact Hub

Artifact Hub will show a provenance badge when the `.prov` file is detected. Visit: [Backstage Chart on Artifact Hub](https://artifacthub.io/packages/helm/irembo-backstage-helm/backstage)
```
