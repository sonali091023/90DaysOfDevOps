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

**Steps to follow:**

**1. Install Helm On Linux:**
-->curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

**2. Install Helm On macOS:** 
-->brew install helm

**3. Install Helm On Windows:**
-->choco install kubernetes-helm

-->Verify the installed Helm: helm version

-->Now check Helm environment: helm env
<img width="1512" height="687" alt="image" src="https://github.com/user-attachments/assets/f9c1e7a9-410a-4ed7-8c7c-d7be5bfbc37a" />

Three core concepts:
- **Chart** — a package of Kubernetes manifest templates
- **Release** — a specific installation of a chart in your cluster
- **Repository** — a collection of charts (like a package repo)

**Verify:** What version of Helm is installed?
-->v3.20.2
<img width="1356" height="46" alt="image" src="https://github.com/user-attachments/assets/46d1d02c-0375-4c78-83f6-c359a729bfa8" />

---

### Task 2: Add a Repository and Search
1. Add the Bitnami repository: `helm repo add bitnami https://charts.bitnami.com/bitnami`
2. Update: `helm repo update`
3. Search: `helm search repo nginx` and `helm search repo bitnami`

**Steps to follow:**

-->Add Bitnami Repository: helm repo add bitnami https://charts.bitnami.com/bitnami

-->Update Repositories: helm repo update      [This fetches the latest list of charts from all repos]

-->Search Chart for the nginx: helm search repo nginx

-->Search all botnami charts: helm search repo bitnami     [This will print a long list of available charts]

-->Let see how many charts does have bitnami: helm search repo bitnami | wc -l     [This counts the number of lines] 

**Verify:** How many charts does Bitnami have?
-->145
<img width="1211" height="972" alt="image" src="https://github.com/user-attachments/assets/977f7709-f2b1-479b-888a-5da3d23c4902" />
<img width="1210" height="972" alt="image" src="https://github.com/user-attachments/assets/a5f434dd-7a05-484b-a1d4-52a7b682425c" />
<img width="1192" height="867" alt="image" src="https://github.com/user-attachments/assets/4ca3c2d6-0bbd-4755-8d4a-f1946f5014e7" />

---

### Task 3: Install a Chart
1. Deploy nginx: `helm install my-nginx bitnami/nginx`
2. Check what was created: `kubectl get all`
3. Inspect the release: `helm list`, `helm status my-nginx`, `helm get manifest my-nginx`

**Steps to follow:**

-->Install NGINX Chart: helm install my-nginx bitnami/nginx      [This creates a Release named my-nginx from the Bitnami chart]

-->Check What Was Created: kubectl get all   [We can see after installation Pods, Service, Deployment (or ReplicaSet) & Possibly ConfigMap/Secret all this objects got installed]

-->Inspect the Helm Release List releases: helm list

-->Inspect the Helm Release Detailed releases: helm status my-nginx

-->Inspect the Helm Full generated YAML: helm get manifest my-nginx     [This shows all Kubernetes resources Helm created (like Deployment, Service, etc.)]

-->Verification How many Pods are running?: kubectl get pods            [1 Pod (default replica count in Bitnami nginx chart)]

-->What Service type was created?: kubectl get svc                      [Most likely: ClusterIP gets create]

<img width="1902" height="970" alt="image" src="https://github.com/user-attachments/assets/68f25365-6e5e-4f06-8471-1e65bbd4d32b" />

**Note:** Helm just did this in one command: Created Deployment, Created Service, Applied labels, Managed configs, Instead of writing multiple YAML files manually.

One command replaced writing a Deployment, Service, and ConfigMap by hand.

**Verify:** How many Pods are running? What Service type was created?

---

### Task 4: Customize with Values
1. View defaults: `helm show values bitnami/nginx`
2. Install a custom release with `--set replicaCount=3 --set service.type=NodePort`
3. Create a `custom-values.yaml` file with replicaCount, service type, and resource limits
4. Install another release using `-f custom-values.yaml`
5. Check overrides: `helm get values <release-name>`

**Steps to follow:**

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
