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

**Steps to follow:**

Step 1: Verify the ArgoCD Namespace Exists: kubectl get ns

<img width="977" height="347" alt="image" src="https://github.com/user-attachments/assets/beb1cef4-24d6-4f61-bd34-4932c5667b88" />

Step 2: Verify ArgoCD Pods: kubectl get pods -n argocd

<img width="966" height="527" alt="image" src="https://github.com/user-attachments/assets/587497d9-fffd-425a-827c-a4944f1cdf88" />

<img width="1602" height="462" alt="image" src="https://github.com/user-attachments/assets/72768ae7-4b21-4ea5-9276-3b9e3ee5ef5a" />

-->If any pod is Pending or CrashLoopBackOff, check: kubectl describe pod <pod-name> -n argocd OR kubectl logs <pod-name> -n argocd

Step 3: Get the Admin Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo 

-->[Expected: Hj7kLm9Qw2Ab So Save it because you'll need it to log in.]

-->**You can also save it to a variable:** export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

-->echo $ARGOCD_PASSWORD

<img width="1917" height="182" alt="image" src="https://github.com/user-attachments/assets/96f55d39-8199-4011-90f7-382a2fee56f0" />

Step 4: Check How ArgoCD Is Exposed: kubectl get svc -n argocd [Look at the TYPE column.]

<img width="820" height="237" alt="image" src="https://github.com/user-attachments/assets/ab11994f-4aa4-412d-9679-f02369c28065" />

-->**Case 1: If you see Service Type = LoadBalancer:** 
export ARGOCD_URL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

-->& then to check run command: echo $ARGOCD_URL [Expected: a123456789.us-west-2.elb.amazonaws.com then open in the browser: http://a123456789.us-west-2.elb.amazonaws.com]

**Note:** If the instructions mention http://, try https:// first because ArgoCD serves HTTPS by default. [tried with http and ArgoCD got launched]

<img width="842" height="747" alt="image" src="https://github.com/user-attachments/assets/1085bd82-2196-44fb-a89f-2e43b5f60380" />

<img width="712" height="770" alt="image" src="https://github.com/user-attachments/assets/c0fe022c-93b1-4d19-adbc-56e7073f4a03" />

<img width="1917" height="417" alt="image" src="https://github.com/user-attachments/assets/e3d166aa-c414-43d7-ab3c-819b0df6e8a7" />

-->If you see Case 2 No LoadBalancer: Service TYPE = ClusterIP use port forwarding for that Run in seperate terminal & leave it running: kubectl port-forward svc/argocd-server -n argocd 8443:443 

-->Now run the following in the browser: https://localhost:8443 [Your browser will warn that the certificate isn't trusted, So Choose: Advanced & then 
Proceed to localhost, This is expected because ArgoCD uses a self-signed certificate by default.]

Step 5: Login to the UI: 

<img width="652" height="261" alt="image" src="https://github.com/user-attachments/assets/57042c94-3dba-411f-b6aa-c38a93d10114" />

Step 6: Install the ArgoCD CLI (Ubuntu/Linux): 

-->Download ArgoCD CLI: curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 OR 

-->use following command: curl -L -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

**Note:** If in case Already any dir or file is exists with name argocd then either rename the file or remove the old one and download new one.

-->Make it executable: chmod +x argocd

-->Then move it to bin dir: sudo mv argocd /usr/local/bin/

-->Now verify: argocd version --client

<img width="742" height="782" alt="image" src="https://github.com/user-attachments/assets/d072c17d-34cd-41ee-ba89-ed6024e595df" />
<img width="725" height="442" alt="image" src="https://github.com/user-attachments/assets/8cde3f8f-e7a0-4b9b-b0b0-063c00409495" />
<img width="691" height="737" alt="image" src="https://github.com/user-attachments/assets/16b698ed-dd9b-4d55-bbcd-ff08e9903e17" />
<img width="667" height="816" alt="image" src="https://github.com/user-attachments/assets/dcf667c6-953c-4ba0-a63d-01808dc2f643" />
<img width="786" height="835" alt="image" src="https://github.com/user-attachments/assets/289c6d75-96c0-47ff-a3aa-e679666faae1" />

<img width="1552" height="667" alt="image" src="https://github.com/user-attachments/assets/4f286622-b6fa-431a-9de7-e8ddfe5c0049" />

Step 7: Login from the CLI: 

-->If using the LoadBalancer: argocd login $ARGOCD_URL --username admin --password $ARGOCD_PASSWORD --insecure

-->Or, if you didn't save the password: argocd login $ARGOCD_URL --username admin --password YOUR_PASSWORD --insecure [Expected: 'admin:login' logged in successfully]

-->If using Port Forward: Keep the port-forward terminal running and execute: argocd login a33da2317b9304d68b4c681fe271897f-1613371817.ap-south-1.elb.amazonaws.com --username admin --password $ARGOCD_PASSWORD --insecure

<img width="672" height="752" alt="image" src="https://github.com/user-attachments/assets/8e7bd4e4-b4be-494a-ad5c-05ad7059a6b0" />

<img width="1840" height="116" alt="image" src="https://github.com/user-attachments/assets/7b899bcb-b319-4ae7-a0a8-001c1bb0cedb" />

OR By using Load Balancer:

<img width="1722" height="200" alt="image" src="https://github.com/user-attachments/assets/5fb6153e-8e97-442a-af3c-5b41605efca8" />

<img width="750" height="507" alt="image" src="https://github.com/user-attachments/assets/23d76731-f81c-4d1b-9a51-2033ad1ad795" />

<img width="712" height="446" alt="image" src="https://github.com/user-attachments/assets/b766d58e-f801-4740-8863-e79d0afc2e4a" />

<img width="667" height="697" alt="image" src="https://github.com/user-attachments/assets/8687a523-f37b-4bc9-987b-1192aeefe319" />

<img width="737" height="827" alt="image" src="https://github.com/user-attachments/assets/abfb17b2-3e4a-4855-a293-6fef482f7193" />

<img width="682" height="657" alt="image" src="https://github.com/user-attachments/assets/23c8fb0c-2039-43ee-b8fb-6a83602116bf" />

<img width="702" height="577" alt="image" src="https://github.com/user-attachments/assets/8870fc91-e817-46cb-854d-01462dd0c3da" />

<img width="801" height="527" alt="image" src="https://github.com/user-attachments/assets/aa9f723e-aca7-46aa-99e7-cdcba893c034" />

<img width="721" height="577" alt="image" src="https://github.com/user-attachments/assets/7fd39c4e-0125-49b8-be43-a2a9d7b49245" />

<img width="737" height="731" alt="image" src="https://github.com/user-attachments/assets/e2ecbbc4-4fe0-4288-8c65-0cddc91ed9c3" />

<img width="802" height="827" alt="image" src="https://github.com/user-attachments/assets/96d9b3b5-a25c-4083-b29a-1ba473a543b1" />

<img width="751" height="651" alt="image" src="https://github.com/user-attachments/assets/e926b4e4-77a7-4c86-85bd-514066f7cbb1" />

Step 8: Verify the CLI Connection: 

-->argocd account get-user-info

-->argocd version

<img width="702" height="506" alt="image" src="https://github.com/user-attachments/assets/dd4ce5cc-afa1-4096-a819-235e5902e848" />

<img width="1427" height="572" alt="image" src="https://github.com/user-attachments/assets/aace461b-f094-4c93-9e4b-e8e95c2ef00b" />

Step 9: Explore the UI: 

<img width="810" height="630" alt="image" src="https://github.com/user-attachments/assets/62b2dc1b-fd27-4760-920d-2d16f21c8961" />

Step 10: Useful CLI Commands:

-->List applications: argocd app list [Expected: No applications found]

-->List clusters: argocd cluster list [Expected: Server details]

-->List repositories: argocd repo list [This may be empty until you add a Git repository]

<img width="1112" height="495" alt="image" src="https://github.com/user-attachments/assets/8b04d4fd-22c7-412e-8966-05aefb213018" />

**If you run into any issues, share the outputs of these commands:**

-->kubectl get pods -n argocd

-->kubectl get svc -n argocd

-->kubectl get secrets -n argocd

-->kubectl config current-context

<img width="1917" height="952" alt="image" src="https://github.com/user-attachments/assets/06a2d952-c8d2-43b4-8d99-f1d43d8e1330" />

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

**Steps to follow:**

Step 1: Open the Manifest: Navigate to your AI-BankApp project: cd ~/trainwithshubham/90DaysOfDevOps/2026/day-84/AI-BankApp-DevOps

-->To read the file content use cat command: cat argocd/application.yml OR vi argocd/application.yml

<img width="767" height="712" alt="image" src="https://github.com/user-attachments/assets/36d2e326-31d8-4026-bbb4-622d656880bb" />

Understanding the Manifest: Think of an ArgoCD Application as a deployment instruction for ArgoCD: What should I deploy?, Where should I deploy it? &
How should I keep it synchronized?

<img width="747" height="792" alt="image" src="https://github.com/user-attachments/assets/37702279-663d-4bdd-b27a-3c8245f82088" />

<img width="656" height="826" alt="image" src="https://github.com/user-attachments/assets/fc3fcd0d-f5a2-4e89-b1c5-adda337b004f" />

<img width="735" height="657" alt="image" src="https://github.com/user-attachments/assets/cd062887-73d2-4138-b95e-237ff79cb8cb" />

<img width="702" height="597" alt="image" src="https://github.com/user-attachments/assets/cc67a998-41ba-47a7-aaac-d7bdb6e46a17" />
<img width="761" height="726" alt="image" src="https://github.com/user-attachments/assets/f5856540-e9a7-4c13-8422-af94234dc4b7" />
<img width="717" height="420" alt="image" src="https://github.com/user-attachments/assets/34450e6e-659f-40bb-88cc-85b026c1f827" />

Section 6: Destination: This tells ArgoCD where to deploy the manifests: 
<img width="722" height="597" alt="image" src="https://github.com/user-attachments/assets/91a5e871-d110-4a59-82e0-65aa359165de" />

<img width="692" height="506" alt="image" src="https://github.com/user-attachments/assets/9cb506fc-2b55-4109-8184-5920034ac3fe" />

Section 7: Sync Policy: 

<img width="721" height="792" alt="image" src="https://github.com/user-attachments/assets/2bfede34-a0ba-45d5-b76e-2b2d2bf51139" />

<img width="802" height="496" alt="image" src="https://github.com/user-attachments/assets/4dfca7d2-5894-49fe-b931-af17ae0c811c" />

selfHeal: true:

<img width="652" height="825" alt="image" src="https://github.com/user-attachments/assets/c153ecd6-476f-4322-8fe3-90a109a58811" />

Section 8: Sync Options:

<img width="732" height="762" alt="image" src="https://github.com/user-attachments/assets/51c74561-8941-4a07-9bc4-f0c6a56c31a6" />
<img width="770" height="390" alt="image" src="https://github.com/user-attachments/assets/c7f76817-07a0-4484-b774-18d45d051b09" />

Complete Flow:

<img width="697" height="815" alt="image" src="https://github.com/user-attachments/assets/7ec3cc0d-aa25-4853-9a14-2c1527cc2796" />

Summary Table:

<img width="1062" height="720" alt="image" src="https://github.com/user-attachments/assets/0d3493c1-6963-48bb-a473-cf70f53c6515" />
<img width="1032" height="527" alt="image" src="https://github.com/user-attachments/assets/486ab189-2360-4fe8-9ea4-08013353e26d" />

Key Takeaway: This application.yml file is the heart of the GitOps workflow. It tells ArgoCD:

-->What to deploy (the k8s/ manifests from the Git repository),

-->Which version to watch (the feat/gitops branch),

-->Where to deploy (the bankapp namespace in the in-cluster Kubernetes API),

-->How to manage deployments (automatic sync, pruning deleted resources, self-healing drift, automatic namespace creation, and server-side apply).

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

**Steps to follow:**

-->The goal is to let Argo CD automatically deploy your AI-BankApp from your GitHub repository into your EKS cluster. This is the essence of GitOps. Instead of running: kubectl apply -f deployment.yaml yourself, you'll tell Argo CD: "Here is my Git repository. Watch it continuously. Whatever is in Git should be deployed to Kubernetes."

Overall Flow:

<img width="762" height="427" alt="image" src="https://github.com/user-attachments/assets/3ef8dd95-9fd8-4265-9496-b9f73abbe9b6" />

Step 1 – Delete the Existing Namespace: kubectl delete namespace bankapp 2>/dev/null

<img width="802" height="752" alt="image" src="https://github.com/user-attachments/assets/7583f962-470d-48d8-a363-c4df7450ebdf" />

<img width="1515" height="352" alt="image" src="https://github.com/user-attachments/assets/4840d849-9ecc-414a-871f-dde4697aab74" />

Step 2 – Fork the Repository: Go to: https://github.com/TrainWithShubham/AI-BankApp-DevOps Click Fork.You'll get: https://github.com/sonali091023/AI-BankApp-DevOps

**Why fork?** --> So Argo CD will deploy from your repository. Later, when you make changes (for example, updating the Docker image tag), you'll push to your fork, and Argo CD will automatically detect those commits and synchronize your cluster.

Step 3 – Create the Argo CD Application: 

<img width="702" height="420" alt="image" src="https://github.com/user-attachments/assets/0dd4f126-d561-4193-ac09-ffd4dfb6a939" />

```
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
<img width="1156" height="577" alt="image" src="https://github.com/user-attachments/assets/7d348b84-1ee3-472a-ac4b-2db2d355a39f" />

<img width="682" height="397" alt="image" src="https://github.com/user-attachments/assets/d7f9e3dd-9b14-4a7c-9609-a8b22746d006" />

Understanding the YAML: 

<img width="742" height="472" alt="image" src="https://github.com/user-attachments/assets/788b2461-b123-4aa7-b7a2-4d26695d1256" />

<img width="682" height="817" alt="image" src="https://github.com/user-attachments/assets/c6a45c21-1974-4c96-8ced-521bb9354459" />

<img width="737" height="796" alt="image" src="https://github.com/user-attachments/assets/50b40979-58c1-4283-91c1-adee39b8a0a7" />

<img width="742" height="812" alt="image" src="https://github.com/user-attachments/assets/9e7719b1-6e47-40c9-8777-f99b2bf44517" />

Step 4 – Watch the Deployment:

-->Check the application: argocd app get bankapp

-->argocd app wait bankapp [This command blocks until the application becomes healthy or times out.]

<img width="686" height="482" alt="image" src="https://github.com/user-attachments/assets/2d42afdc-b733-4e94-9b15-a8e2a6f60481" />

<img width="1917" height="947" alt="image" src="https://github.com/user-attachments/assets/c33494c7-6679-4c45-bb79-8e979b7bc717" />

<img width="1917" height="951" alt="image" src="https://github.com/user-attachments/assets/ce27499a-504e-4051-a77d-40931ffbf8d7" />

Step 5 – Watch the Pods: kubectl get pods -n bankapp -w

<img width="711" height="762" alt="image" src="https://github.com/user-attachments/assets/255d4927-63e9-4fc7-8a9a-3cc95f66787b" />

<img width="1410" height="165" alt="image" src="https://github.com/user-attachments/assets/068653cc-b73c-4c56-80bd-39120f843b76" />

Step 6 – Verify Success: argocd app get bankapp

<img width="690" height="635" alt="image" src="https://github.com/user-attachments/assets/6b823fc2-6f35-40a6-a537-17360923396a" />

<img width="1917" height="982" alt="image" src="https://github.com/user-attachments/assets/1f8b567c-cbaa-40f7-bd99-1dd558a77500" />

<img width="1917" height="977" alt="image" src="https://github.com/user-attachments/assets/89bf6b98-b2bb-421f-90aa-d6266d8fb0b9" />

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

**Steps to follow:**

-->Great! 🎉 You've successfully deployed the AI-BankApp. Now you're moving to one of the most important parts of GitOps—understanding how Argo CD visualizes and manages your Kubernetes resources.

This task is about observing rather than creating. Think of it as learning to use the Argo CD dashboard to monitor and troubleshoot applications.

What is the Argo CD Live View?

-->When you open the bankapp application in the Argo CD UI, you're looking at a live representation of your application's current state in Kubernetes.

-->So Instead of running multiple commands like: Argo CD displays everything in one graphical view. Think of it like a live architecture diagram that updates automatically.

- kubectl get deployments

- kubectl get pods

- kubectl get services

- kubectl get pvc

- kubectl get configmaps

<img width="1917" height="982" alt="image" src="https://github.com/user-attachments/assets/1f8b567c-cbaa-40f7-bd99-1dd558a77500" />

<img width="1917" height="977" alt="image" src="https://github.com/user-attachments/assets/89bf6b98-b2bb-421f-90aa-d6266d8fb0b9" />

<img width="707" height="586" alt="image" src="https://github.com/user-attachments/assets/fa6376c5-0c9e-4ae4-9852-a1c78d4af811" />

<img width="685" height="827" alt="image" src="https://github.com/user-attachments/assets/ec07fb8c-2c99-4ff6-80f0-52a3ab4f8c93" />

<img width="631" height="777" alt="image" src="https://github.com/user-attachments/assets/9817b0ca-2df2-45ce-ac9a-78f2667d43c8" />

<img width="687" height="787" alt="image" src="https://github.com/user-attachments/assets/8f443262-6aa4-448d-a551-a024d12c583b" />

<img width="617" height="507" alt="image" src="https://github.com/user-attachments/assets/71c2f328-007b-4f6b-9586-26b97ae85e0f" />

<img width="582" height="772" alt="image" src="https://github.com/user-attachments/assets/27965f16-bace-4f46-98de-3084fbd6108b" />

<img width="632" height="637" alt="image" src="https://github.com/user-attachments/assets/ca521d8d-4259-4389-9cb7-424cdbe9a78e" />

<img width="581" height="671" alt="image" src="https://github.com/user-attachments/assets/c6907cf5-20ff-4ad8-8765-c72c060a086c" />

<img width="630" height="825" alt="image" src="https://github.com/user-attachments/assets/448ca868-3a7e-4eb5-ab7f-9eaa82acb451" />

<img width="717" height="592" alt="image" src="https://github.com/user-attachments/assets/8bcd5c37-2567-41fc-ba47-6b1789cb0d2b" />

<img width="712" height="762" alt="image" src="https://github.com/user-attachments/assets/a5526913-6912-469c-b0dd-b2b3fbd0b1d2" />

<img width="687" height="637" alt="image" src="https://github.com/user-attachments/assets/dd068f16-bf86-415d-8d1c-e5e3a0f46e73" />

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

**Stesp to follow:**

-->Excellent! This is one of the most important tasks in your DevOps journey because it demonstrates the core GitOps principle: Git is the single source of truth.

-->Before starting, let's understand why you're doing these tests.

-->Normally, anyone with Kubernetes access can modify the cluster: kubectl edit deployment bankapp OR kubectl scale deployment bankapp --replicas=10

<img width="667" height="752" alt="image" src="https://github.com/user-attachments/assets/bbbb1206-06cb-47c2-9fa9-8774e0b92d75" />

<img width="702" height="477" alt="image" src="https://github.com/user-attachments/assets/1e38e215-1c3d-4fff-961a-f7b0ec181425" />

-->Step 1: Check the current replicas: kubectl get deployment bankapp -n bankapp [This means Git currently wants 4 replicas.]

-->Step 2: Scale it manually: kubectl scale deployment bankapp -n bankapp --replicas=1

<img width="652" height="657" alt="image" src="https://github.com/user-attachments/assets/1e774139-f0e3-40c6-8217-a771555a7683" />

<img width="697" height="516" alt="image" src="https://github.com/user-attachments/assets/c09d4a83-095a-4697-b6d0-6b4f6c591770" />

<img width="1912" height="976" alt="image" src="https://github.com/user-attachments/assets/6c13fddc-9c21-40eb-8637-dc4981f9c0f3" />

<img width="1617" height="540" alt="image" src="https://github.com/user-attachments/assets/de9c70fa-7b3c-4164-b55a-ea592c42ba12" />

<img width="740" height="641" alt="image" src="https://github.com/user-attachments/assets/05d87f8a-3da5-42e1-8b84-fb575262da27" />

<img width="677" height="486" alt="image" src="https://github.com/user-attachments/assets/afd4a95a-711e-4853-b10e-90028941947e" />

<img width="687" height="571" alt="image" src="https://github.com/user-attachments/assets/65c1735f-f6dc-483c-9a12-2a21138ebbc3" />

-->kubectl get pods -n bankapp -w

-->argocd app get bankapp

<img width="732" height="637" alt="image" src="https://github.com/user-attachments/assets/841e5c34-d805-450a-b602-e3b56bc254ef" />

<img width="1847" height="972" alt="image" src="https://github.com/user-attachments/assets/7b4e6bd4-90e4-4384-ad5c-725801c06faf" />

Test 2 – Delete the ConfigMap

-->kubectl get configmap -n bankapp

-->kubectl delete configmap bankapp-config -n bankapp

<img width="696" height="482" alt="image" src="https://github.com/user-attachments/assets/202d3897-e8f8-47d4-8d05-0190a819e877" />

<img width="692" height="567" alt="image" src="https://github.com/user-attachments/assets/05676939-0eb9-4c30-bf5c-a175d6afee1e" />

<img width="1072" height="135" alt="image" src="https://github.com/user-attachments/assets/2cde8261-1135-4cb8-80a7-6c7e29c1a43e" />

Test 3 – Edit the ConfigMap: kubectl edit configmap bankapp-config -n bankapp

-->Make some chnage like follow: Previously it was: MYSQL_DATABASE: bankappdb & now chnage it to MYSQL_DATABASE: wrongdatabase

-->To verify: kubectl get configmap bankapp-config -n bankapp -o yaml  

-->So Again, Argo CD detects drift. Within a short time it overwrites your change and restores the value from Git.

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/3e0c4600-b32c-4644-b8a6-814a515d0756" />

<img width="1251" height="966" alt="image" src="https://github.com/user-attachments/assets/7b338438-5649-4763-b503-20d01b381b07" />

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/b3e189cf-f8a1-457e-9186-d041a617ae7a" />

<img width="661" height="447" alt="image" src="https://github.com/user-attachments/assets/4aaecbdf-83d2-416a-94ad-81576ebbb77c" />

<img width="672" height="630" alt="image" src="https://github.com/user-attachments/assets/8224bb96-85e9-4d97-b1f8-e672a36679a8" />

<img width="686" height="331" alt="image" src="https://github.com/user-attachments/assets/14327821-33a8-4e23-90c1-fdf065188075" />

<img width="682" height="657" alt="image" src="https://github.com/user-attachments/assets/7649b487-043f-49a5-abbc-53d5de83de48" />

<img width="780" height="372" alt="image" src="https://github.com/user-attachments/assets/40e16ad5-89f2-46b5-b6c8-a53aa74e663a" />

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
