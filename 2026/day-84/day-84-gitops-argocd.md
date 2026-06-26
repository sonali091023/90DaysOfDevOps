# Day 84 -- Introduction to GitOps and ArgoCD

## Task
You have deployed the AI-BankApp on EKS using `kubectl apply`. That works, but who ran the command? From which machine? Was the YAML they applied the same as what is in Git? If someone manually edits a Deployment in the cluster, how do you know?

GitOps solves all of this. Git becomes the single source of truth. A tool watches your Git repository and continuously ensures the cluster matches what is committed. That tool is ArgoCD.

The AI-BankApp project (https://github.com/TrainWithShubham/AI-BankApp-DevOps, branch `feat/gitops`) already has ArgoCD installed via Terraform and an Application manifest ready to go. Today you understand GitOps principles, explore ArgoCD, and deploy the AI-BankApp through ArgoCD for the first time.

---

## Expected Output
- Understanding of GitOps principles and how they differ from traditional CI/CD
- ArgoCD running on your EKS cluster (installed by Terraform on Day 81)
- ArgoCD UI accessible and explored
- The AI-BankApp deployed and managed by ArgoCD
- A markdown file: `day-84-gitops-argocd.md`

---

## Challenge Tasks

### Task 1: Understand GitOps
Research and write notes on:

1. **What is GitOps?**
   - A deployment methodology where Git is the single source of truth for infrastructure and application state
   - An operator (ArgoCD) watches Git and ensures the live cluster matches the desired state in the repository
   - If someone changes something in the cluster manually, the operator reverts it (self-healing)
   - All changes go through Git -- pull requests, code review, audit trail

2. **GitOps vs traditional CI/CD:**

| Aspect | Traditional CI/CD | GitOps |
|--------|------------------|--------|
| Deployment trigger | CI pipeline runs `kubectl apply` | Git commit triggers sync |
| Source of truth | Pipeline scripts | Git repository |
| Drift detection | None | Continuous reconciliation |
| Rollback | Re-run pipeline or manual | `git revert` |
| Audit trail | Pipeline logs | Git history |
| Access control | Pipeline needs cluster credentials | Only ArgoCD has cluster access |
| Security | CI server has broad cluster access | Developers push to Git, never to the cluster |

3. **The AI-BankApp's GitOps flow:**
```
Developer pushes code to feat/gitops
         |
    [GitHub Actions CI]
    - Build Maven project
    - Run tests
    - Build Docker image
    - Push to DockerHub (tagged with git SHA)
    - Update image tag in k8s/bankapp-deployment.yml
    - Commit the change back to Git
         |
    [ArgoCD watches the repo]
    - Detects the new commit
    - Compares k8s/ manifests with live cluster
    - Syncs the change (rolling update)
    - BankApp pods restart with the new image
         |
    [Zero human intervention after git push]
```

4. **Four GitOps principles** (from OpenGitOps):
   - **Declarative** -- the desired state is expressed declaratively (Kubernetes YAML)
   - **Versioned and immutable** -- the desired state is stored in Git (versioned, auditable)
   - **Pulled automatically** -- agents (ArgoCD) pull the desired state, not pushed by CI
   - **Continuously reconciled** -- agents continuously compare desired vs actual and correct drift
  
**Steps to follow:**

Task 1: Understand GitOps: 

**1. What is GitOps?**

-->GitOps is a modern deployment methodology where Git acts as the single source of truth for both infrastructure and application configuration. Instead of 
administrators manually running commands such as kubectl apply, all changes are made by updating files in a Git repository. A GitOps tool such as ArgoCD 
continuously monitors the repository and automatically synchronizes the Kubernetes cluster with the desired state stored in Git.

**How GitOps works:**

-->Developer updates Kubernetes YAML files or application code.

-->Changes are committed and pushed to Git.

-->ArgoCD detects the new commit.

-->ArgoCD compares the desired state in Git with the actual cluster state.

-->If differences exist, ArgoCD updates the cluster automatically.

-->The cluster always matches what is stored in Git.

**Example:** Suppose your deployment YAML specifies:

<img width="802" height="660" alt="image" src="https://github.com/user-attachments/assets/6457278e-a6a5-4a66-8502-817b7113bc9c" />

**Why GitOps?** GitOps provides several important benefits:

-->Git becomes the single source of truth.

-->Every change is version-controlled.

-->Easy rollback using Git.

-->Automatic deployments.

-->Automatic drift detection.

-->Better security.

-->Complete audit history.

<img width="797" height="742" alt="image" src="https://github.com/user-attachments/assets/34f39747-aced-40e5-8444-74a82626b376" />

**Traditional CI/CD Flow:** Developer --> Git Push --> GitHub Actions --> kubectl apply --> Kubernetes Cluster

**Problems:** 

-->CI pipeline needs cluster credentials.

-->Manual changes can remain unnoticed.

-->No automatic drift correction.

-->Rollback usually requires another deployment.

**GitOps Flow:** Developer --> Git Push --> GitHub Actions --> Update Kubernetes YAML --> Git Repository --> ArgoCD --> Kubernetes Cluster

**Advantages:**

-->CI never directly talks to Kubernetes.

-->Git stores the desired state.

-->Automatic synchronization.

-->Automatic rollback.

-->Self-healing.

**AI-BankApp GitOps Flow:** The AI-BankApp project follows a complete GitOps workflow: Developer pushes code --> Feature Branch (feat/gitops) --> GitHub Actions CI

<img width="617" height="756" alt="image" src="https://github.com/user-attachments/assets/0acbcf01-13ed-4eb4-82ea-78080a962320" />

<img width="612" height="812" alt="image" src="https://github.com/user-attachments/assets/f449ae15-9e56-4cff-97fd-66914c0068ee" />

<img width="572" height="806" alt="image" src="https://github.com/user-attachments/assets/79dc7b49-8a5c-4a11-b1f3-4f65538f2a8e" />

<img width="625" height="336" alt="image" src="https://github.com/user-attachments/assets/0a62fd90-69e3-4ba9-92c2-bf074cbe4f09" />

**Final Workflow: Result:** Once the developer pushes code, the entire build and deployment process happens automatically with zero human intervention.

<img width="860" height="642" alt="image" src="https://github.com/user-attachments/assets/d50f5e91-5cc0-4d60-b1dc-cadda20e6ce3" />

**Four GitOps Principles (OpenGitOps):** 

<img width="982" height="452" alt="image" src="https://github.com/user-attachments/assets/99ad42a4-dd1a-4957-a9d4-af6686b0050d" />

<img width="911" height="702" alt="image" src="https://github.com/user-attachments/assets/09bc7d94-930b-4ea9-a1ea-2553c18ce627" />

<img width="917" height="632" alt="image" src="https://github.com/user-attachments/assets/b138aeb5-6834-408f-b0c8-2fbc76226e08" />

<img width="927" height="666" alt="image" src="https://github.com/user-attachments/assets/79eb3015-bdf2-40f1-8d4e-18f6d65bdf64" />

<img width="972" height="382" alt="image" src="https://github.com/user-attachments/assets/c35c45ee-da6c-42ff-a5cc-38e61c98f3f6" />

---

### Task 2: Access ArgoCD on Your EKS Cluster
ArgoCD was installed by Terraform on Day 81 (via `terraform/argocd.tf`). Verify it is running:

```bash
kubectl get pods -n argocd
```

You should see pods for: `argocd-server`, `argocd-repo-server`, `argocd-application-controller`, `argocd-applicationset-controller`, `argocd-redis`, and `argocd-dex-server`.

**Get the ArgoCD admin password:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

**Access the ArgoCD UI:**

Option A -- via LoadBalancer (if Terraform exposed it):
```bash
export ARGOCD_URL=$(kubectl get svc argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ArgoCD URL: http://$ARGOCD_URL"
```

Option B -- via port-forward:
```bash
kubectl port-forward svc/argocd-server -n argocd 8443:443
```

Open `https://localhost:8443` (accept the self-signed certificate). Log in with:
- Username: `admin`
- Password: the value from the command above

**Install the ArgoCD CLI:**
```bash
# macOS
brew install argocd

# Linux
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Verify
argocd version --client
```

Log in via CLI:
```bash
argocd login $ARGOCD_URL --username admin --password <your-password> --insecure
# or for port-forward:
argocd login localhost:8443 --username admin --password <your-password> --insecure
```

**Explore the ArgoCD UI:**
- **Applications** -- shows all managed applications (empty for now)
- **Settings > Repositories** -- Git repos ArgoCD can access
- **Settings > Clusters** -- Kubernetes clusters ArgoCD manages (your EKS cluster is the default `in-cluster`)

---

### Task 3: Study the AI-BankApp's ArgoCD Application Manifest
Open `argocd/application.yml` from the AI-BankApp repo:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bankapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/TrainWithShubham/AI-BankApp-DevOps.git
    targetRevision: feat/gitops
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: bankapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

**Break down every field:**

| Field | Value | Purpose |
|-------|-------|---------|
| `source.repoURL` | The AI-BankApp GitHub repo | Where ArgoCD fetches manifests from |
| `source.targetRevision` | `feat/gitops` | Which Git branch to watch |
| `source.path` | `k8s` | The directory containing Kubernetes manifests |
| `destination.server` | `kubernetes.default.svc` | Deploy to the local cluster (in-cluster) |
| `destination.namespace` | `bankapp` | Target namespace for resources |
| `syncPolicy.automated` | enabled | ArgoCD syncs automatically on Git changes |
| `prune: true` | enabled | Delete resources removed from Git |
| `selfHeal: true` | enabled | Revert manual changes made directly to the cluster |
| `CreateNamespace=true` | enabled | Create the `bankapp` namespace if it does not exist |
| `ServerSideApply=true` | enabled | Use server-side apply for better conflict handling |

---

### Task 4: Deploy the AI-BankApp via ArgoCD
First, make sure the BankApp is NOT already deployed (clean slate):
```bash
kubectl delete namespace bankapp 2>/dev/null
```

**Fork the AI-BankApp repo** -- you need your own copy to push changes later:
1. Go to https://github.com/TrainWithShubham/AI-BankApp-DevOps
2. Click "Fork" and create your fork
3. Note your fork URL: `https://github.com/<your-username>/AI-BankApp-DevOps.git`

**Create the ArgoCD Application** (update the repoURL to your fork):
```bash
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bankapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-username>/AI-BankApp-DevOps.git
    targetRevision: feat/gitops
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: bankapp
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
EOF
```

**Watch ArgoCD deploy the app:**
- In the ArgoCD UI, click on the `bankapp` application
- You will see a visual tree of all Kubernetes resources being created
- Each resource shows its sync and health status (green = healthy, yellow = progressing, red = degraded)

Or watch via CLI:
```bash
argocd app get bankapp
argocd app wait bankapp
```

Monitor pods coming up:
```bash
kubectl get pods -n bankapp -w
```

The deployment order is automatic -- ArgoCD applies all manifests from the `k8s/` directory. MySQL and Ollama start first, then the BankApp's init containers wait for dependencies.

After everything is healthy (5-10 minutes):
```bash
argocd app get bankapp
```

Status should show: `Health: Healthy`, `Sync: Synced`.

---

### Task 5: Explore ArgoCD's Live View
Click on the `bankapp` application in the ArgoCD UI. You will see:

**The resource tree:**
```
bankapp (Application)
  |-- Namespace: bankapp
  |-- StorageClass: gp3
  |-- PVC: mysql-pvc (Bound)
  |-- PVC: ollama-pvc (Bound)
  |-- ConfigMap: bankapp-config
  |-- Secret: bankapp-secret
  |-- Deployment: mysql -> ReplicaSet -> Pod
  |-- Deployment: ollama -> ReplicaSet -> Pod
  |-- Deployment: bankapp -> ReplicaSet -> Pod (x4)
  |-- Service: mysql-service
  |-- Service: ollama-service
  |-- Service: bankapp-service
  |-- HPA: bankapp-hpa
```

**Click on any resource** to see its details:
- Pod logs (live streaming)
- Events
- YAML manifest (as applied to the cluster)
- Diff (what changed since last sync)

**App Details tab shows:**
- Source repo and path
- Last sync time and revision (git commit SHA)
- Sync status and health status
- History of all syncs

**Check the sync history:**
```bash
argocd app history bankapp
```

This shows every revision that was synced, when, and the commit SHA.

---

### Task 6: Test Self-Healing
ArgoCD's `selfHeal: true` means it reverts any manual changes made directly to the cluster.

**Test 1 -- Manually scale the BankApp:**
```bash
kubectl scale deployment bankapp -n bankapp --replicas=1
```

Watch what happens:
```bash
kubectl get pods -n bankapp -w
```

Within 3-5 minutes, ArgoCD detects the drift and scales it back to the value defined in Git (4 replicas, or whatever the HPA decides). Check the ArgoCD UI -- you will see a sync event.

**Test 2 -- Manually delete a ConfigMap:**
```bash
kubectl delete configmap bankapp-config -n bankapp
```

ArgoCD will recreate it from Git within minutes.

**Test 3 -- Manually change an environment variable:**
```bash
kubectl edit configmap bankapp-config -n bankapp
# Change MYSQL_DATABASE to something wrong
```

ArgoCD will overwrite your change with the value from Git.

**This is the core GitOps promise:** The cluster always matches Git. Manual changes do not survive. All changes must go through Git (pull requests, review, merge).

**Document:** What happened during each self-healing test? How quickly did ArgoCD revert the changes?

---

## Hints
- ArgoCD syncs every 3 minutes by default. You can trigger an immediate sync via the UI ("Sync" button) or CLI (`argocd app sync bankapp`)
- `selfHeal: true` requires `automated` sync policy -- without automation, ArgoCD only detects drift but does not fix it
- The ArgoCD Application resource itself lives in the `argocd` namespace, but it deploys resources to the `bankapp` namespace
- If the app shows `OutOfSync`, it means Git and the cluster differ. Click "Diff" to see exactly what changed
- ArgoCD only needs read access to your Git repo. It never pushes to Git -- that is the CI pipeline's job
- The `ServerSideApply=true` option avoids annotation conflicts when multiple tools manage the same resource
- ArgoCD tracks resources by label -- if you `kubectl apply` a resource directly (outside ArgoCD), it may conflict
- Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`) -- `argocd/application.yml`

---

## Documentation
Create `day-84-gitops-argocd.md` with:
- GitOps principles in your own words
- GitOps vs traditional CI/CD comparison table
- The AI-BankApp's GitOps flow diagram
- Screenshot of the ArgoCD UI showing the bankapp Application resource tree
- The Application manifest with every field explained
- Screenshot of ArgoCD after self-healing (sync event showing drift was corrected)
- What `prune`, `selfHeal`, and `ServerSideApply` do

---

## Submission
1. Add `day-84-gitops-argocd.md` to `2026/day-84/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Started the GitOps block today -- deployed the AI-BankApp through ArgoCD on EKS instead of kubectl apply. ArgoCD watches the Git repo and syncs changes automatically. Tested self-healing by manually scaling pods and deleting ConfigMaps -- ArgoCD reverted every change within minutes. The cluster now always matches Git. No more 'who ran kubectl on Friday night?'"

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
