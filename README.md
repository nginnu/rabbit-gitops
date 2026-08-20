# Rabbit GitOps

Kubernetes manifests and Helm charts for deploying Rabbit services.

## Structure

- `applicationset.yaml`: ArgoCD ApplicationSet for managing apps
- `charts/`: Helm charts for each service
- `scripts/`: Deployment automation scripts

## Deployment

Deploy via ArgoCD:

```bash
make up
```

## Architecture

- **ArgoCD**: GitOps CD for declarative deployments
- **Helm**: Package management for Kubernetes
- **Traefik**: Ingress Gateway
- **Cert-Manager**: TLS certificate management
