# Backstage Helm Chart

This Helm chart deploys [Backstage](https://backstage.io/) with PostgreSQL as a database backend.

## Features

- **Complete Backstage Application**: Deploys the full Backstage application using the official Spotify image
- **PostgreSQL Database**: Uses PostgreSQL subchart for data persistence
- **Lifecycle Management**: Implements Helm hooks for proper application lifecycle
- **GitOps Ready**: Designed to work with ArgoCD in a GitOps workflow
- **Comprehensive Testing**: Includes test templates for quality assurance
- **Chart Schema Validation**: Uses JSON Schema to validate chart values

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
| `image.repository`                  | Backstage image repository                  | `spotify/backstage`                                    |
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

## Chart Signing

The chart can be signed for security and integrity verification. Generate a PGP key:

```bash
gpg --gen-key
```

Sign the chart:

```bash
helm package .
helm gpg sign backstage-0.1.0.tgz
```

Verify the chart:

```bash
helm gpg verify backstage-0.1.0.tgz
```