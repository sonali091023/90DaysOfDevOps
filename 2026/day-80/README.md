# Day 80 -- Helm Project: Multi-Environment Deployment and CI/CD

## Task
Two days of Helm -- chart basics and a custom chart for the AI-BankApp. Today you bring it all together. You will create environment-specific values for dev, staging, and production, add Helm hooks, package the chart, and integrate Helm into the AI-BankApp's CI/CD pipeline.

Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`)

---

## Expected Output
- Environment-specific values files (dev, staging, prod) for the AI-BankApp Helm chart
- Helm hooks for database readiness validation
- A packaged chart (`.tgz` file) ready for distribution
- Understanding of how Helm fits into the AI-BankApp's GitOps pipeline
- A markdown file: `day-80-helm-project.md`

---

## Challenge Tasks

### Task 1: Create Environment-Specific Values
One chart, three environments. The AI-BankApp runs differently in dev vs production.

Create `bankapp/values-dev.yaml`:
```yaml
bankapp:
  replicaCount: 1
  image:
    repository: trainwithshubham/ai-bankapp-eks
    tag: "latest"
    pullPolicy: Always
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "250m"
  autoscaling:
    enabled: false

mysql:
  enabled: true
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "250m"
  persistence:
    size: 2Gi
    storageClass: standard

ollama:
  enabled: true
  model: tinyllama
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "1.5Gi"
      cpu: "1000m"
  persistence:
    size: 5Gi
    storageClass: standard

storageClass:
  create: false
```

Create `bankapp/values-staging.yaml`:
```yaml
bankapp:
  replicaCount: 2
  image:
    repository: trainwithshubham/ai-bankapp-eks
    tag: "v1.2.0"
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 3
    targetCPUUtilization: 75

mysql:
  enabled: true
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  persistence:
    size: 5Gi
    storageClass: gp3

ollama:
  enabled: true
  model: tinyllama
  persistence:
    size: 10Gi
    storageClass: gp3

secrets:
  mysqlRootPassword: StagingPass@456
  mysqlUser: root
  mysqlPassword: StagingPass@456

storageClass:
  create: true
```

Create `bankapp/values-prod.yaml`:
```yaml
bankapp:
  replicaCount: 4
  image:
    repository: trainwithshubham/ai-bankapp-eks
    tag: "v1.2.0"
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 4
    targetCPUUtilization: 70

mysql:
  enabled: true
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
  persistence:
    size: 20Gi
    storageClass: gp3

ollama:
  enabled: true
  model: tinyllama
  resources:
    requests:
      memory: "2Gi"
      cpu: "900m"
    limits:
      memory: "2.5Gi"
      cpu: "1500m"
  persistence:
    size: 10Gi
    storageClass: gp3

secrets:
  mysqlRootPassword: ProdSecure@789
  mysqlUser: root
  mysqlPassword: ProdSecure@789

storageClass:
  create: true

gateway:
  enabled: true
```

**Compare the environments:**

| Setting | Dev | Staging | Prod |
|---------|-----|---------|------|
| BankApp replicas | 1 (fixed) | 2-3 (HPA) | 2-4 (HPA) |
| Image tag | latest | v1.2.0 | v1.2.0 |
| MySQL storage | 2Gi | 5Gi | 20Gi |
| MySQL resources | 128Mi/100m | 256Mi/250m | 512Mi/500m |
| Ollama memory | 1Gi | 2Gi | 2.5Gi |
| Gateway | disabled | disabled | enabled |

**Deploy to different environments:**
```bash
# Dev (on Kind)
helm install bankapp-dev bankapp/ -f bankapp/values-dev.yaml -n dev --create-namespace

# Staging (render to check)
helm template bankapp-staging bankapp/ -f bankapp/values-staging.yaml | grep "replicas:"

# Prod (render to check)
helm template bankapp-prod bankapp/ -f bankapp/values-prod.yaml | grep "replicas:"
```

Same chart, wildly different deployments.

**Steps to follow:**

-->Great! This task is about one of Helm's biggest advantages: using the same chart for multiple environments by changing only the values files.

Step 1: Navigate to Your Chart: ls helm-chart/bankapp/

<img width="1907" height="147" alt="image" src="https://github.com/user-attachments/assets/a76b5077-3866-4aa6-a148-0efb2239fac7" />

Step 2: Create values-dev.yaml: vi helm-chart/bankapp/values-dev.yaml  [Added above mentioned code]

Step 3: Create values-staging.yaml: vi helm-chart/bankapp/values-staging.yaml  [Added above mentioned code]

Step 4: Create values-prod.yaml: vi helm-chart/bankapp/values-prod.yaml  [Added above mentioned code]

Step 5: Verify Files Exist: ls -l helm-chart/bankapp/*.yaml

<img width="1540" height="297" alt="image" src="https://github.com/user-attachments/assets/1f047a06-f45c-40bf-b762-561479bf3ae0" />

Step 6: Validate the Chart: From the helm-chart directory: helm lint helm-bankapp/bankapp

<img width="1522" height="142" alt="image" src="https://github.com/user-attachments/assets/f0f1b636-3489-4a2a-b9e5-14e383446905" />

Step 7: Test the Dev Environment: Render manifests: 

-->helm template bankapp-dev ./helm-chart/bankapp -f ./helm-chart/bankapp/values-dev.yaml OR

-->helm template bankapp-dev helm-chart/bankapp -f helm-chart/bankapp/values-dev.yaml [So here in this command ./in front of helm-chart is not required]

-->Check the BankApp deployment replicas: helm template bankapp-dev helm-chart/bankapp -f helm-chart/bankapp/values-dev
.yaml | grep replicas:

<img width="1645" height="966" alt="image" src="https://github.com/user-attachments/assets/2af58b6b-9571-4725-8684-d1d601a9d866" />

<img width="1840" height="82" alt="image" src="https://github.com/user-attachments/assets/6870fb23-7874-4c6f-8219-0a0b11185f0c" />

-->So the deployment should contain a fixed replica count.

Step 8: Test the Staging Environment: 

-->Check the BankApp deployment replicas: helm template bankapp-staging helm-chart/bankapp -f helm-chart/bankapp/values-staging.yaml | grep replicas:

-->You may not see: replicas: 2 because when HPA is enabled, your deployment template intentionally omits the replicas field & This is correct behavior.

Check below indetail: 

<img width="781" height="557" alt="image" src="https://github.com/user-attachments/assets/536017ce-f9ee-40b5-85ce-8514aec657d8" />

-->To verify the HPA settings, run: helm template bankapp-staging helm-chart/bankapp -f helm-chart/bankapp/values-staging.yaml | grep -A5 HorizontalPodAutoscaler

<img width="1907" height="257" alt="image" src="https://github.com/user-attachments/assets/015cd46c-b17d-4119-a646-6205be9ff5b1" />

-->helm template bankapp-staging helm-chart/bankapp -f helm-chart/bankapp/values-staging.yaml | grep -A20 HorizontalPodAutoscaler

-->helm template bankapp-staging helm-chart/bankapp -f helm-chart/bankapp/values-staging.yaml | grep -A5 HorizontalPodAutoscaler

-->helm template bankapp-staging helm-chart/bankapp -f helm-chart/bankapp/values-staging.yaml | grep minReplicas

-->helm template bankapp-staging helm-chart/bankapp -f helm-chart/bankapp/values-staging.yaml | grep maxReplicas

<img width="1917" height="781" alt="image" src="https://github.com/user-attachments/assets/07297fea-f383-4c8d-aa02-012405e984e0" />

Step 9: Test the Production Environment: helm template bankapp-prod helm-chart/bankapp -f helm-chart/bankapp/values-prod.yaml | grep -A25 HorizontalPodAutoscaler

<img width="1901" height="620" alt="image" src="https://github.com/user-attachments/assets/7da9561f-8eba-424d-9711-1e75e3165df4" />
                                      
---

### Task 2: Add Helm Hooks
The AI-BankApp uses init containers to wait for MySQL. Helm hooks offer another approach -- running pre-install jobs.

Create `bankapp/templates/pre-install-job.yaml`:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "bankapp.fullname" . }}-db-ready
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      containers:
        - name: db-check
          image: busybox:1.36
          command:
            - /bin/sh
            - -c
            - |
              echo "Waiting for MySQL to be ready..."
              until nc -z {{ include "bankapp.fullname" . }}-mysql 3306; do
                echo "MySQL not ready, retrying in 3s..."
                sleep 3
              done
              echo "MySQL is ready!"
          resources:
            requests: { memory: "32Mi", cpu: "50m" }
            limits: { memory: "64Mi", cpu: "100m" }
      restartPolicy: Never
  backoffLimit: 10
```

**How hooks work in the AI-BankApp context:**
- `helm.sh/hook: pre-install,pre-upgrade` -- runs before install and before upgrade
- This ensures MySQL is up before the BankApp Deployment is created
- `before-hook-creation` -- deletes the old job before creating a new one on re-runs
- Combined with init containers in the Deployment, this provides defense-in-depth

**Other useful hook types:**
- `post-install` -- run database migrations after deploy
- `pre-delete` -- backup database before teardown
- `test` -- runs when you execute `helm test`

**Add a Helm test:**

Create `bankapp/templates/tests/test-connection.yaml`:
```yaml
 
```

After deploying, run:
```bash
helm test bankapp-dev -n dev
```

This hits the Spring Boot health endpoint and confirms the app is running.

**Steps to follow:**

Step 1: Create the Pre-Install Hook: vi helm-chart/bankapp/templates/pre-install-job.yaml [Added above mentioned code]

<img width="617" height="717" alt="image" src="https://github.com/user-attachments/assets/52f099d4-2b1c-4ba5-98be-45898fc922a3" />

Step 2: Validate the Hook: Render the chart: helm template bankapp-dev ./helm-chart/bankapp -f ./helm-chart/bankapp/values-dev.yaml

<img width="1907" height="966" alt="image" src="https://github.com/user-attachments/assets/31497007-75c1-455f-a36e-62c3e52f41a5" />

<img width="1632" height="966" alt="image" src="https://github.com/user-attachments/assets/efb45ea8-dfc7-4463-8cf6-8efdfc5e5f70" />

<img width="1557" height="972" alt="image" src="https://github.com/user-attachments/assets/7772c01d-0902-4942-a638-db0710d045f5" />

-->Search for: kind: Job
<img width="1923" height="801" alt="image" src="https://github.com/user-attachments/assets/2d6f92bf-b664-4381-806b-f58d41c2653f" />

-->OR run command: helm template bankapp-dev ./helm-chart/bankapp -f ./helm-chart/bankapp/values-dev.yaml | grep db-ready

<img width="1767" height="67" alt="image" src="https://github.com/user-attachments/assets/d4dffd6b-9b06-472f-b838-6912625bc15a" />

Step 3: Create the Helm Test: 

-->Since you deleted the original tests/ folder earlier, recreate it: mkdir -p helm-chart/bankapp/templates/tests

-->Now create file: vi helm-chart/bankapp/templates/tests/test-connection.yaml [Added above mentioned code]

<img width="612" height="492" alt="image" src="https://github.com/user-attachments/assets/efd0b826-a45a-49fb-b579-9a858d100684" />

Step 4: Lint Again: Run command: helm lint ./helm-chart/bankapp

<img width="1592" height="156" alt="image" src="https://github.com/user-attachments/assets/378887e0-9243-41e3-b618-90b8f509b66d" />

Step 5: Verify the Hook Exists: helm template bankapp-dev ./helm-chart/bankapp -f ./helm-chart/bankapp/values-dev.yaml | grep "helm.sh/hook"

<img width="1907" height="162" alt="image" src="https://github.com/user-attachments/assets/131cd765-965f-489e-8c60-13f16c96f9d8" />

-->So this confirms both resources are being rendered.

Step 6: Deploy a Test Release: If your previous deployment was removed:






---

### Task 3: Package and Version the Chart
Package the chart into a distributable `.tgz` file:

```bash
# Lint first
helm lint bankapp/

# Package
helm package bankapp/
```

This creates `bankapp-0.1.0.tgz`.

**Bump the version after changes:**
Edit `bankapp/Chart.yaml`:
```yaml
version: 0.2.0        # Chart structure changed (added hooks)
appVersion: "1.1.0"    # App version updated
```

Re-package:
```bash
helm package bankapp/
```

Now you have `bankapp-0.1.0.tgz` and `bankapp-0.2.0.tgz`.

**Install from a package:**
```bash
helm install my-bankapp bankapp-0.2.0.tgz -f bankapp/values-dev.yaml -n bankapp --create-namespace
```

**Create a chart repository index** (for sharing via GitHub Pages):
```bash
mkdir chart-repo
cp bankapp-*.tgz chart-repo/
helm repo index chart-repo/ --url https://your-username.github.io/helm-charts
cat chart-repo/index.yaml
```

---

### Task 4: Understand Helm in the AI-BankApp GitOps Pipeline
The AI-BankApp uses a GitOps pipeline. Study how Helm could integrate:

**Current pipeline (from `.github/workflows/gitops-ci.yml`):**
```
Developer pushes code
  -> GitHub Actions builds Docker image
  -> Tags with git commit SHA
  -> Updates image tag in k8s/bankapp-deployment.yml via sed
  -> Commits the change back to the repo
  -> ArgoCD detects the change and syncs to EKS
```

**With Helm, the pipeline becomes:**
```
Developer pushes code
  -> GitHub Actions builds Docker image
  -> Tags with git commit SHA
  -> Updates image.tag in helm-chart/values.yaml (or values-prod.yaml)
  -> Commits the change back to the repo
  -> ArgoCD detects the change and runs helm upgrade on EKS
```

Here is how the CI step would look with Helm (reference pattern):
```yaml
# In the GitHub Actions workflow
- name: Update Helm values with new image tag
  run: |
    TAG=${{ steps.tag.outputs.sha_short }}
    yq -i '.bankapp.image.tag = "'$TAG'"' helm-chart/bankapp/values-prod.yaml

- name: Commit updated Helm values
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add helm-chart/bankapp/values-prod.yaml
    git diff --staged --quiet || git commit -m "ci: update bankapp image to $TAG [skip ci]"
    git push
```

**ArgoCD with Helm** (the ArgoCD Application would change from):
```yaml
# Current: raw manifests
source:
  path: k8s
```

To:
```yaml
# With Helm
source:
  path: helm-chart/bankapp
  helm:
    valueFiles:
      - values-prod.yaml
```

ArgoCD natively supports Helm charts -- it renders templates and applies the result, tracking drift against the rendered output.

**Document:** What are the advantages of ArgoCD syncing a Helm chart vs raw manifests?

---

### Task 5: Helm Best Practices for Production
Review these patterns used in production AI-BankApp deployments:

**1. Always use `helm upgrade --install`:**
```bash
helm upgrade --install bankapp bankapp/ \
  -f bankapp/values-prod.yaml \
  --set bankapp.image.tag=$GIT_SHA \
  -n bankapp --create-namespace \
  --wait --timeout 300s \
  --atomic
```

- `--install` -- creates if missing, upgrades if exists
- `--set bankapp.image.tag=$GIT_SHA` -- pins to exact git commit
- `--wait` -- waits for all pods to be ready
- `--atomic` -- rolls back automatically if the upgrade fails

**2. Use `helm diff` before upgrading:**
```bash
helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade bankapp bankapp/ -f bankapp/values-prod.yaml
```

Shows exactly what would change before you commit to the upgrade.

**3. Resource quotas per namespace:**
```yaml
# Add to templates/resourcequota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: {{ include "bankapp.fullname" . }}-quota
  namespace: {{ .Release.Namespace }}
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
```

**4. Never store real secrets in values.yaml.** In production, use:
- External Secrets Operator with AWS Secrets Manager
- Sealed Secrets
- Vault by HashiCorp

The `values.yaml` defaults are fine for local dev but should be overridden in CI/CD via `--set` with pipeline secrets.

---

### Task 6: Clean Up and Review
Check what you have deployed:
```bash
helm list -A
```

**Reflect and document the 3-day Helm journey:**

| Day | Concept | AI-BankApp Connection |
|-----|---------|----------------------|
| 78 | Helm install, repos, values, upgrade, rollback | Deployed MySQL for the BankApp via Bitnami chart |
| 79 | Custom chart from scratch, Go templates | Converted 12 raw `k8s/` manifests into a Helm chart |
| 80 | Multi-env values, hooks, packaging, CI/CD | Production-ready chart with dev/staging/prod configs |

**When would you use Helm vs raw manifests vs Kustomize?**

| Approach | Best For | AI-BankApp Example |
|----------|---------|-------------------|
| Raw manifests | Simple, single-env deployments | The current `k8s/` directory |
| Helm | Multi-env, complex apps with dependencies | The chart you built (3 services, HPA, hooks) |
| Kustomize | Overlays on existing manifests, no templating | Good if you want to patch `k8s/` without rewriting |

**Clean up:**
```bash
helm uninstall bankapp-dev -n dev
kubectl delete namespace dev
kind delete cluster --name tws-cluster
```

---

## Hints
- Multiple `-f` flags stack: `helm install app chart/ -f values.yaml -f values-prod.yaml` -- later files override earlier ones
- `--atomic` is critical in CI/CD -- it auto-rollbacks on failure, preventing half-deployed states
- `helm diff` plugin is a must-have for production -- never upgrade blind
- `yq` is better than `sed` for updating YAML values in CI pipelines (preserves structure)
- ArgoCD has native Helm support -- you do not need to render templates before pushing to Git
- Helm hooks run outside the normal release lifecycle -- they are not tracked in `helm get manifest`
- The AI-BankApp's Gateway and cert-manager resources could also be templated, but are often managed separately as cluster-level infrastructure
- Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`)

---

## Documentation
Create `day-80-helm-project.md` with:
- All three environment values files with a comparison table
- The Helm hook template with annotations explained
- Screenshot of `helm list -A` showing deployment
- Output of `helm test` on the dev deployment
- How the GitOps CI/CD pipeline would integrate Helm
- Comparison: Helm vs raw manifests vs Kustomize for the AI-BankApp
- What you would add for production secrets management

---

## Submission
1. Add `day-80-helm-project.md` to `2026/day-80/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Completed the Helm block -- built a full Helm chart for the AI-BankApp (Spring Boot + MySQL + Ollama AI), created environment-specific values for dev, staging, and prod, added pre-install hooks, packaged the chart for distribution, and mapped out how it integrates with the GitOps CI/CD pipeline. Same chart, three environments, zero duplication."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
