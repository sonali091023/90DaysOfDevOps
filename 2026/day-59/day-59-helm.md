# Day 59 – Helm — Kubernetes Package Manager

## Task
Over the past eight days you have written Deployments, Services, ConfigMaps, Secrets, PVCs, and more — all as individual YAML files. For a real application you might have dozens of these. Helm is the package manager for Kubernetes, like apt for Ubuntu. Today you install charts, customize them, and create your own.

---

## Expected Output
- Helm installed and a chart deployed from Bitnami
- A release customized, upgraded, and rolled back
- A custom chart created and installed
- A markdown file: `day-59-helm.md`

---

## Challenge Tasks

### Task 1: Install Helm
1. Install Helm (brew, curl script, or chocolatey depending on your OS)
2. Verify with `helm version` and `helm env`

Three core concepts:

Chart — a package of Kubernetes manifest templates
Release — a specific installation of a chart in your cluster
Repository — a collection of charts (like a package repo)
Verify: What version of Helm is installed?

**Steps to follow:**

Step 1: Install Helm:

-->Install Helm On Linux: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

-->Install Helm On macOS: brew install helm

-->Install Helm On Windows: choco install kubernetes-helm

Step 2: Verify the Installation: helm version

-->Now check Helm environment: helm env

Step 3: Understand the Three Core Concepts: 

1. Chart: A Chart is a package containing Kubernetes resource templates.

<img width="661" height="557" alt="image" src="https://github.com/user-attachments/assets/0039ca44-70e1-451c-86c2-ff79f611b6cf" />

2. Release: A Release is a running instance of a chart inside your Kubernetes cluster.

<img width="677" height="642" alt="image" src="https://github.com/user-attachments/assets/5055ac40-fd68-40c0-af9a-c068a8684e79" />

3. Repository: A Repository is a collection of Helm charts, similar to:
- apt repositories for Ubuntu
- npm registry for Node.js
- Docker Hub for Docker images

**Popular Helm repositories:**
- Bitnami
- Prometheus Community
- Grafana
- Jetstack

-->Add the Bitnami repository: helm repo add bitnami https://charts.bitnami.com/bitnami

-->Update repository: helm repo update

-->Search available charts: helm search repo nginx

Verify: What version of Helm is installed?

-->Helm version v3.18.4 is installed.

Quick Revision Table: 

<img width="717" height="170" alt="image" src="https://github.com/user-attachments/assets/431538c9-d9ad-495c-8c86-0b7020a75580" />

<img width="1847" height="897" alt="image" src="https://github.com/user-attachments/assets/a1bff161-15b2-45b8-bf38-27bbe71e8226" />

---

### Task 2: Add a Repository and Search
1. Add the Bitnami repository: `helm repo add bitnami https://charts.bitnami.com/bitnami`
2. Update: `helm repo update`
3. Search: `helm search repo nginx` and `helm search repo bitnami`

Verify: How many charts does Bitnami have?

**Steps to follow:**

-->Great! This task helps you understand how to use Helm repositories and search for available charts.

Step 1: Add the Bitnami Repository: helm repo add bitnami https://charts.bitnami.com/bitnami [Expected: "bitnami" has been added to your repositories]

Step 2: Update the Repository: helm repo update      [This fetches the latest list of charts from all repos]

Step 3: Search for the NGINX Chart: helm search repo nginx

Step 4: Search All Bitnami Charts: helm search repo bitnami     [This will print a long list of available charts]

Step 5: Count the Number of Charts: helm search repo bitnami | wc -l     [This counts the number of lines] 

-->Verify the Repository: helm repo list

**Verify:** How many charts does Bitnami have?
-->Subtract 1 for the header line. The remaining number is the current number of Bitnami charts available in your local Helm repository index: 145

<img width="1907" height="972" alt="image" src="https://github.com/user-attachments/assets/25fcb691-63a2-4497-87cd-4948e58a5244" />

<img width="1902" height="967" alt="image" src="https://github.com/user-attachments/assets/7c8c5738-7a34-49bf-b6de-6b916fa96885" />

---

### Task 3: Install a Chart
1. Deploy nginx: `helm install my-nginx bitnami/nginx`
2. Check what was created: `kubectl get all`
3. Inspect the release: `helm list`, `helm status my-nginx`, `helm get manifest my-nginx`

One command replaced writing a Deployment, Service, and ConfigMap by hand.

Verify: How many Pods are running? What Service type was created?

**Steps to follow:**

-->Excellent! This task demonstrates one of Helm's biggest advantages: deploying an application with a single command instead of manually creating multiple Kubernetes manifests.

Step 1: Install the NGINX Chart: helm install my-nginx bitnami/nginx      [This creates a Release named my-nginx from the Bitnami chart]

**What this command means:**
- helm install → Install a Helm chart.
- my-nginx → Name of the Helm release.
- bitnami/nginx → Chart to install.

Step 2: Verify the Resources Created: kubectl get all   

**Notice that one Helm command created:**
- Deployment
- Pod
- Service
- ReplicaSet

**Depending on the chart version, it may also create:**
- ServiceAccount
- ConfigMap
- Secret
- NetworkPolicy

Step 3: List Installed Releases: helm list     [This confirms the release is installed.]

Step 4: Check the Release Status: helm status my-nginx   [This provides information about the release, its status, and deployment history.]

Step 5: View the Generated Kubernetes Manifests: helm get manifest my-nginx     [This is the YAML that Helm generated from the chart templates.]

Q. Why Helm Is Powerful?

-->**Without Helm**, you would need to create several files manually:
- deployment.yaml
- service.yaml
- configmap.yaml
- serviceaccount.yaml
- secret.yaml
- networkpolicy.yaml

-->**With helm**: helm install my-nginx bitnami/nginx [Expected: A single command generates and applies all the required Kubernetes resources.]

**Verify:** How many Pods are running? What Service type was created?

-->Verification How many Pods are running?: kubectl get pods            [1 Pod (default replica count in Bitnami nginx chart)]

-->What Service type was created?: kubectl get svc                      [Most likely: ClusterIP gets create]

**Note:** Note: Some versions of the Bitnami NGINX chart may default to LoadBalancer instead of ClusterIP, depending on the chart version and its default values. Always verify by running kubectl get svc in your cluster.

<img width="1901" height="827" alt="image" src="https://github.com/user-attachments/assets/ca9d1b47-a678-4332-89c2-8fc1d5b0c423" />

<img width="1797" height="966" alt="image" src="https://github.com/user-attachments/assets/f9bbc1af-70b6-4199-b3f0-1f99d68c5a25" />

<img width="1852" height="977" alt="image" src="https://github.com/user-attachments/assets/2c202e28-db30-46fd-8f6d-992ed02d7204" />

<img width="1912" height="972" alt="image" src="https://github.com/user-attachments/assets/5b34c416-5fde-4c27-bfaa-2f3b50b03c36" />

<img width="1817" height="972" alt="image" src="https://github.com/user-attachments/assets/72f33d64-f219-4ebf-870b-ca3651615afc" />

---

### Task 4: Customize with Values
1. View defaults: `helm show values bitnami/nginx`
2. Install a custom release with `--set replicaCount=3 --set service.type=NodePort`
3. Create a `custom-values.yaml` file with replicaCount, service type, and resource limits
4. Install another release using `-f custom-values.yaml`
5. Check overrides: `helm get values <release-name>`

Verify: Does the values file release have the correct replicas and service type?

**Steps to follow:**

-->Excellent! This task teaches one of Helm's most important features: customizing a chart without editing its templates.

-->View Default Values: helm show values bitnami/nginx                   [This shows all configurable options like: replicaCount, service.type, resources]

-->Install with --set Overrides: helm install nginx-set bitnami/nginx --set replicaCount=3 --set service.type=NodePort     [This creates a release named nginx-set with: 3 Pods & NodePort service]

-->Create vi custom-values.yaml

-->Install Using Values File: helm install nginx-file bitnami/nginx -f custom-values.yaml          [This creates another release: nginx-file]

-->Check Applied Values: helm get values nginx-file                                                [You should see your custom values reflected]

-->Check number of replicas: kubectl get pods

-->Check Service type: kubectl get svc

<img width="1917" height="961" alt="image" src="https://github.com/user-attachments/assets/ddad847a-7ff3-492d-8255-b03f033d671a" />
<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/be675d7c-3a3a-4e3e-8218-0e0c4f772fe0" />
<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/c46dae53-353d-426f-af57-9f7e00218b0d" />

**Verify:** Does the values file release have the correct replicas and service type?
-->Yes, if Pods count = 2 & Service type = NodePort

**Note:** --set → quick changes (good for testing) & values.yaml → best for real projects (clean + reusable)

---

### Task 5: Upgrade and Rollback
1. Upgrade: `helm upgrade my-nginx bitnami/nginx --set replicaCount=5`
2. Check history: `helm history my-nginx`
3. Rollback: `helm rollback my-nginx 1`
4. Check history again — rollback creates a new revision (3), not overwriting revision 2

**Steps to follow:**

-->Upgrade the Release: helm upgrade my-nginx bitnami/nginx --set replicaCount=5        [This creates a new revision (2) Now your app should have 5 Pods]

-->Check History: helm history my-nginx

-->Rollback to Revision 1: helm rollback my-nginx 1

-->Check History Again: helm history my-nginx

<img width="412" height="137" alt="image" src="https://github.com/user-attachments/assets/0cb75695-2e35-43f3-9c1d-9d5f2b8aebab" />

**Note:** Helm behaves like version control, Here Every change = new revision, Rollback = new revision (not delete history) & You can move forward and backward safely.

Same concept as Deployment rollouts from Day 52, but at the full stack level.

**Verify:** How many revisions after the rollback?
<img width="1777" height="845" alt="image" src="https://github.com/user-attachments/assets/8f055802-b90e-4e10-b7c7-6ce959675500" />

**Note:** So here basically learned how Helm manages application changes like version control. First, you upgraded your existing release (my-nginx) by changing the replica count to 5. Helm didn’t replace the old setup—it created a new revision (version 2) with the updated configuration. Then, you checked the history to see all versions of your release. After that, you performed a rollback to go back to the original version (revision 1). Instead of deleting anything, Helm created another new revision (version 3) that represents the rollback state.
So in short: You changed your app (upgrade), viewed its version history, and safely reverted it (rollback), while Helm kept a full record of every change.

---

### Task 6: Create Your Own Chart
1. Scaffold: `helm create my-app`
2. Explore the directory: `Chart.yaml`, `values.yaml`, `templates/deployment.yaml`
3. Look at the Go template syntax in templates: `{{ .Values.replicaCount }}`, `{{ .Chart.Name }}`
4. Edit `values.yaml` — set replicaCount to 3 and image to nginx:1.25
5. Validate: `helm lint my-app`
6. Preview: `helm template my-release ./my-app`
7. Install: `helm install my-release ./my-app`
8. Upgrade: `helm upgrade my-release ./my-app --set replicaCount=5`

**Steps to follow:**
-->Scaffold a Chart: helm create my-app
-->ls
-->cd my-app
-->ls
-->Explore Structure: 
<img width="551" height="147" alt="image" src="https://github.com/user-attachments/assets/e8e44582-4fb9-4804-a68e-a4c6165f347c" />
-->Understand Templates:
<img width="531" height="267" alt="image" src="https://github.com/user-attachments/assets/90d1be69-d6c3-4b72-841b-36a57d23ee55" />
-->Edit values.yaml file, Add beow line of code:
<img width="177" height="127" alt="image" src="https://github.com/user-attachments/assets/ebf455ea-9ff1-456f-8cb2-1a67cdd7b6cb" />
-->Validate Chart: helm lint my-app
-->Preview (Dry Run): helm template my-release ./my-app            [This shows generated Kubernetes YAML without deploying]
-->Install Chart: helm install my-release ./my-app
-->Upgrade Release: helm upgrade my-release ./my-app --set replicaCount=5
-->After Install (should be 3 replicas): kubectl get pods           [You should see 3 Pods]
-->After Upgrade (should be 5 replicas): kubectl get pods           [Now you should see 5 Pods]

<img width="942" height="965" alt="image" src="https://github.com/user-attachments/assets/50852fa0-312a-44d4-b028-c4416edf8baf" />
<img width="1247" height="977" alt="image" src="https://github.com/user-attachments/assets/9f0c4e2e-9b9a-4487-b41a-4d956b40e735" />
<img width="1217" height="417" alt="image" src="https://github.com/user-attachments/assets/a9473203-112d-4120-8b76-662188174fc6" />

-->So here You created your own Helm chart, customized it using values, previewed it safely, deployed it, and then updated it — all using Helm instead of writing raw YAML.

**Verify:** After installing, 3 replicas? After upgrading, 5?
-->After installing 3 replicas, 3pods will display & After upgrading to 5 replicas we can see 5 pods

---

### Task 7: Clean Up
1. Uninstall all releases: `helm uninstall <name>` for each
2. Remove chart directory and values file
3. Use `--keep-history` if you want to retain release history for auditing

**Steps to follow:**
-->Uninstall All Helm Releases: helm list
-->Then uninstall all following,
helm uninstall my-release && helm uninstall my-nginx && helm uninstall nginx-set && helm uninstall nginx-file
-->If you want to keep history (for auditing): helm uninstall my-release --keep-history
-->Remove Chart Files: rm -rf my-app && rm -f custom-values.yaml
-->Verify Cleanup: helm list OR helm list -A

<img width="977" height="311" alt="image" src="https://github.com/user-attachments/assets/f29ff9d6-2887-4b43-a403-1e2e569289aa" />

**Verify:** Does `helm list` show zero releases?
-->Yes

---

## Hints
- `helm show values <chart>` — see what you can customize
- `--set key=value` for single overrides, `-f values.yaml` for files
- Nested values use dots: `--set service.type=NodePort`
- `helm get values <release>` shows overrides, `--all` for everything
- `helm template` renders without installing — great for debugging
- `helm lint` validates chart structure before installing
- Templates: `{{ .Values.key }}`, `{{ .Chart.Name }}`, `{{ .Release.Name }}`

---

## Documentation
Create `day-59-helm.md` with:
- What Helm is and the three core concepts
- How to install, customize, upgrade, and rollback
- The structure of a Helm chart and how Go templating works
- Your `custom-values.yaml` with explanations

---

## Submission
1. Add `day-59-helm.md` and `custom-values.yaml` to `2026/day-59/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Learned Helm today — deployed charts, customized with values, performed rollbacks, and created my own chart from scratch. One command replaces dozens of YAML files."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
