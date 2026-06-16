# Helm Learning Journey

## Day 78 - Helm Fundamentals

### Concepts Learned

* Helm installation
* Helm repositories
* Installing charts
* Upgrading releases
* Rollbacks
* Values files

### AI-BankApp Connection

Used the Bitnami MySQL chart to deploy MySQL for the AI-BankApp.

---

## Day 79 - Building a Custom Chart

### Concepts Learned

* Chart.yaml
* values.yaml
* Templates
* Go templating
* ConfigMaps
* Secrets
* PVCs
* Deployments
* Services
* HPA

### AI-BankApp Connection

Converted 12 Kubernetes manifests into a reusable Helm chart.

---

## Day 80 - Production Helm

### Concepts Learned

* Environment-specific values files
* Helm hooks
* Helm tests
* Chart packaging
* Versioning
* GitOps integration
* ArgoCD with Helm

### AI-BankApp Connection

Created a production-ready chart supporting:

* Dev
* Staging
* Production

with separate configurations.

---

## Helm vs Raw Manifests vs Kustomize

### Raw Manifests

Best for:

* Small projects
* Single environments
* Learning Kubernetes

Example:
Original AI-BankApp k8s directory.

### Helm

Best for:

* Multi-environment deployments
* Complex applications
* Reusable templates
* CI/CD pipelines

Example:
AI-BankApp Helm chart with MySQL, Ollama, HPA, hooks and environment-specific values.

### Kustomize

Best for:

* Overlay-based customization
* Existing Kubernetes manifests
* Teams that want YAML-only configuration

Example:
Keeping the current k8s manifests and applying dev/staging/prod patches.

