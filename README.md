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

---

# Chart Signing & Provenance

This Helm chart is cryptographically signed with a GPG key and includes a `.prov` file for provenance verification.

## 🔐 Verifying the Chart Signature

To verify the chart before installation, follow these steps:

### 1. Download the public GPG key
Visit the [Releases](https://github.com/1moses1/irembo-backstage-helm-chart/releases) page and download the corresponding `public-key-<version>.asc` file for your chart release. Example:

```bash
curl -LO https://github.com/1moses1/irembo-backstage-helm-chart/releases/download/backstage-v0.1.7/public-key-v0.1.7.asc
````

### 2. Import the public key into your GPG keyring

```bash
gpg --import public-key-v0.1.7.asc
```

### 3. Add and update the Helm repo

```bash
helm repo add irembo-backstage-helm https://1moses1.github.io/irembo-backstage-helm-chart/
helm repo update
```

### 4. Download the chart and verify

```bash
helm pull irembo-backstage-helm/backstage --version 0.1.7 --verify
```

This command checks the chart’s `.prov` file against the GPG signature and confirms the integrity and authenticity of the Helm release.

> The `.tgz`, `.prov`, and `.asc` files are also available on the [GitHub Releases](https://github.com/1moses1/irembo-backstage-helm-chart/releases) page.

---

## 📦 Installing the Chart

After successful verification, you can proceed to install the chart:

```bash
helm install my-backstage irembo-backstage-helm/backstage --version 0.1.7
```

To upgrade an existing release:

```bash
helm upgrade my-backstage irembo-backstage-helm/backstage --version 0.1.7
```

### Optional: Customize with values

```bash
helm install my-backstage irembo-backstage-helm/backstage --version 0.1.7 -f values.yaml

# Or with specific values
helm install my-backstage irembo-backstage-helm/backstage --version 0.1.7 --set key=value
```

---

## 🔎 Provenance on Artifact Hub

Once indexed, Artifact Hub will display a **Verified Provenance** badge for this chart version.
View it here: [Backstage Chart on Artifact Hub](https://artifacthub.io/packages/helm/irembo-backstage-helm/backstage)

```
