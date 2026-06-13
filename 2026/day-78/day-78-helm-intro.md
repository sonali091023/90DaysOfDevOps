# Day 78 -- Introduction to Helm and Chart Basics

## Task
You have deployed applications with raw Kubernetes manifests -- writing Deployments, Services, ConfigMaps, and Secrets by hand. The AI-BankApp project (https://github.com/TrainWithShubham/AI-BankApp-DevOps, branch `feat/gitops`) has 12 YAML files in its `k8s/` directory. Managing those across dev, staging, and production with slightly different configurations is painful.

Helm is the package manager for Kubernetes. It lets you template, package, version, and deploy Kubernetes applications as reusable units called charts. Today you install Helm, understand chart structure, and deploy your first applications using community charts -- including MySQL, which the AI-BankApp depends on.

---

## Expected Output
- Helm installed and connected to your Kubernetes cluster
- At least two applications deployed using Helm from public chart repositories
- Understanding of chart structure: templates, values, Chart.yaml
- Helm release management: install, upgrade, rollback, uninstall
- A markdown file: `day-78-helm-intro.md`

---

## Challenge Tasks

### Task 1: Understand Helm Concepts
Research and write notes on:

1. **What is Helm?**
   - A package manager for Kubernetes (like apt for Ubuntu or yum for RHEL)
   - Packages Kubernetes manifests into reusable, versioned units called **charts**
   - Supports templating -- one chart, many environments
  
<img width="697" height="420" alt="image" src="https://github.com/user-attachments/assets/ad51363a-b997-42aa-b7a7-3f99c4eca630" />

**Helm solves this problem by:**

-->Packaging Kubernetes resources together

-->Supporting reusable templates

-->Managing versions of deployments

-->Allowing easy upgrades and rollbacks

**Note:** Helm packages applications into units called Charts.

<img width="522" height="400" alt="image" src="https://github.com/user-attachments/assets/9572122b-fa45-4677-8cdf-ae5ae83ceb25" />

2. **Core concepts:**
   - **Chart** -- a collection of files that describe a set of Kubernetes resources (Deployment + Service + ConfigMap + Secret = one chart)
   - **Release** -- a running instance of a chart in a cluster. You can install the same chart multiple times with different release names
   - **Repository** -- a place where charts are stored and shared (like DockerHub for images)
   - **Values** -- configuration that customizes a chart for each deployment (replicas, image tag, resource limits)

**Note:** A Chart is a package that contains all Kubernetes resources required for an application.

<img width="561" height="696" alt="image" src="https://github.com/user-attachments/assets/8402cf5d-8a29-492c-96c0-7153b3a4c1b7" />

<img width="496" height="577" alt="image" src="https://github.com/user-attachments/assets/f60d75bd-6711-41cd-8a3c-5397e17b10cc" />

**Note:** A Release is a deployed instance of a chart. 

-->For example Chart is bankapp-chart

<img width="507" height="816" alt="image" src="https://github.com/user-attachments/assets/561e70f6-441d-4334-9d5c-3ed843f11f5c" />

**Note:** A Repository is where Helm charts are stored and shared. 

<img width="595" height="281" alt="image" src="https://github.com/user-attachments/assets/e7a7a977-7518-439d-a026-fa87de542c81" />

-->Add Repository: helm repo add bitnami https://charts.bitnami.com/bitnami

-->Update repository information:: helm repo update

-->Search charts: helm search repo mysql

-->Install MySQL: helm install mysql bitnami/mysql       [This saves you from manually creating MySQL manifests.]

**Example charts available:** MySQL, Redis, PostgreSQL, Prometheus, Grafana, ArgoCD

**Note:** Values are configuration parameters used to customize chart behavior.

<img width="612" height="581" alt="image" src="https://github.com/user-attachments/assets/490775b1-360c-43bc-85ad-06f351273b9a" />

<img width="517" height="397" alt="image" src="https://github.com/user-attachments/assets/e5852d5c-b8b9-4390-928f-85715b7792d8" />

3. **Why Helm over raw manifests?**
   - Look at the AI-BankApp's `k8s/` directory -- 12 separate YAML files. To change the image tag, you edit `bankapp-deployment.yml`. To switch environments, you manually update ConfigMaps and Secrets. Helm solves this:
   - Templating: one chart serves dev, staging, and prod with different values
   - Versioning: charts have version numbers, you can rollback to previous versions
   - Dependencies: a chart can depend on other charts (your app chart depends on a MySQL chart)
   - Community: thousands of pre-built charts for common software (MySQL, Redis, Prometheus, ArgoCD)
  
<img width="632" height="411" alt="image" src="https://github.com/user-attachments/assets/7d469154-0ac6-4e03-8c4e-cc7b81eb568d" />

<img width="632" height="637" alt="image" src="https://github.com/user-attachments/assets/702cd984-b8c9-4afe-bbe3-8e95ca0b75b5" />

<img width="632" height="617" alt="image" src="https://github.com/user-attachments/assets/2257b4f0-8fb8-4d73-ac10-6539a91d6718" />

<img width="607" height="482" alt="image" src="https://github.com/user-attachments/assets/5cc2fece-e4ac-4d7b-8503-4e49f541ab6b" />

<img width="612" height="482" alt="image" src="https://github.com/user-attachments/assets/fbfa556e-4266-4c50-a9ed-2829894df47c" />

<img width="766" height="347" alt="image" src="https://github.com/user-attachments/assets/5dc740b0-3bbf-4817-b37e-eba5cc5dce13" />

**Key Takeaways:**

-->Helm = Package Manager for Kubernetes

-->Chart = Package containing Kubernetes resources

-->Release = Running instance of a chart

-->Repository = Storage location for charts

-->Values = Configuration used to customize deployments

-->Helm provides templating, versioning, rollbacks, dependency management, and reusable deployments

-->For AI-BankApp, Helm can replace 10–12 separate Kubernetes manifests with a single reusable chart and environment-specific values files

**Q: What is the difference between a Chart and a Release?**

-->A Chart is the package/template containing Kubernetes resource definitions. A Release is a deployed instance of that chart running in a Kubernetes cluster.
One chart can create multiple releases with different configurations.
  
---

### Task 2: Install Helm and Explore the AI-BankApp
You need a running Kubernetes cluster. Use any of these:
- **Kind** (recommended for this block): Use the AI-BankApp's Kind config
- **Minikube**: `minikube start`
- **Docker Desktop Kubernetes**: enable in settings

**Set up a Kind cluster using the AI-BankApp's config:**
```bash
git clone -b feat/gitops https://github.com/TrainWithShubham/AI-BankApp-DevOps.git
cd AI-BankApp-DevOps

kind create cluster --config setup-k8s/kind-config.yml
```

This creates a cluster with 1 control plane and 2 worker nodes.

**Install Helm:**
```bash
# macOS
brew install helm

# Linux (script)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

Confirm Helm can talk to your cluster:
```bash
kubectl cluster-info
helm list
```

**Explore the raw manifests you will eventually replace with Helm:**
```bash
ls k8s/
```

```
bankapp-deployment.yml   configmap.yml   gateway.yml   mysql-deployment.yml
namespace.yml   ollama-deployment.yml   pv.yml   pvc.yml   secrets.yml
service.yml   hpa.yml   cert-manager.yml
```

12 files -- Deployments, Services, ConfigMaps, Secrets, PVCs, HPA, and more. All hardcoded values. On Day 79, you will convert these into a Helm chart.

**Steps to follow:**

Step 1: Check Prerequisites: Check docker --version, kubectl version --client, kind --version, git --version installed or not

<img width="1917" height="477" alt="image" src="https://github.com/user-attachments/assets/a0b0efc2-d55c-4800-9892-d92fd2d4c276" />

Step 2: Clone the AI-BankApp Repository: git clone -b feat/gitops https://github.com/TrainWithShubham/AI-BankApp-DevOps.git

<img width="1917" height="342" alt="image" src="https://github.com/user-attachments/assets/e95a67da-0841-4be7-bbe1-b13f85a1a93a" />

Step 3: Examine the Kind Configuration: Before creating the cluster, inspect the config file: cat setup-k8s/kind-config.yml

-->This tells Kind to create: 1 Control plane[master plane] & 2 worker nodes total 3 nodes

<img width="657" height="512" alt="image" src="https://github.com/user-attachments/assets/efcd85f9-621a-43ed-ac84-320d7e2dc0d2" />

<img width="1517" height="425" alt="image" src="https://github.com/user-attachments/assets/3294f716-0997-440d-b330-d3eb14ed07c6" />

Step 4: Create the Kind Cluster: kind create cluster --config setup-k8s/kind-config.yml

<img width="590" height="222" alt="image" src="https://github.com/user-attachments/assets/16caf38a-3a95-448f-bc44-51f55d54f6a3" />

<img width="1817" height="387" alt="image" src="https://github.com/user-attachments/assets/040751d5-78b0-42fd-8e85-78b14acd4839" />

Step 5: Verify Cluster Creation: kubectl get nodes

<img width="1595" height="147" alt="t2i8" src="https://github.com/user-attachments/assets/0e5e3207-0f4b-4c46-8caa-7b7e0644a6d7" />

Step 6: Verify Cluster Information: kubectl cluster-info

<img width="1697" height="502" alt="t2i9" src="https://github.com/user-attachments/assets/9da99dc9-7d96-4c75-9ce2-a27bc958210c" />

-->Also check tbe system pods: kubectl get pods -A

<img width="1697" height="502" alt="image" src="https://github.com/user-attachments/assets/7af36f5a-a16c-4c89-9dcd-f0c522969b66" />

Step 7: Install Helm: For Ubuntu/Linux use command: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

Step 8: Verify Helm Installation: helm version

<img width="1901" height="331" alt="image" src="https://github.com/user-attachments/assets/8add83aa-1c22-47aa-98d9-15b8000cebd7" />

Step 9: Verify Helm Can Reach Kubernetes/cluster: helm list

<img width="1596" height="96" alt="image" src="https://github.com/user-attachments/assets/b1db4dfd-6dad-438b-bd23-b5bd3ca07fd1" />

-->So as above image, Empty output is fine because nothing is installed yet. Helm successfully talking to Kubernetes means: kubeconfig works, kubectl works
Helm works

Step 10: Explore Current Kubernetes Manifests: Run command: ls k8s/

<img width="1637" height="102" alt="image" src="https://github.com/user-attachments/assets/d9890935-fb53-4385-9527-2b27ac06acc2" />

Step 11: Understand What Each File Does:

<img width="860" height="722" alt="image" src="https://github.com/user-attachments/assets/62027cfc-059a-4156-a223-b6ab343955f2" />

Step 12: Inspect a Deployment: Open BankApp deployment: cat k8s/bankapp-deployment.yml 

-->Here Look for hardcoded values like: image: trainwithshubham/ai-bankapp:v1, replicas: 2, container port 8501 These are currently fixed values.

Step 13: Identify What Helm Will Replace: 

<img width="636" height="820" alt="image" src="https://github.com/user-attachments/assets/4217055e-b45b-4198-8c0d-fa7400b37cdb" />

Learning Outcome for This Task:

Kubernetes: 

-->Kind creates local Kubernetes clusters.

AI-BankApp cluster contains: 1 Control Plane & 2 Workers

Helm:

-->Helm is a package manager for Kubernetes.

-->Helm packages resources into Charts. which makes the application reusable across development, staging, and production environments.

-->Helm talks to Kubernetes using the same kubeconfig as kubectl

---

### Task 3: Deploy MySQL Using a Helm Chart
The AI-BankApp needs MySQL. Instead of applying raw YAML like `k8s/mysql-deployment.yml`, deploy it with Helm.

Add the Bitnami chart repository:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Search for MySQL:
```bash
helm search repo bitnami/mysql
```

**Deploy MySQL with the same config the AI-BankApp expects:**
```bash
helm install bankapp-mysql bitnami/mysql \
  --set auth.rootPassword=Test@123 \
  --set auth.database=bankappdb \
  --set primary.resources.requests.memory=256Mi \
  --set primary.resources.requests.cpu=250m \
  --set primary.resources.limits.memory=512Mi \
  --set primary.resources.limits.cpu=500m \
  --set primary.persistence.size=5Gi
```

Compare this single command to the raw manifest approach which needs `mysql-deployment.yml` + `secrets.yml` + `pvc.yml` + `pv.yml` + `service.yml`. Helm handles all of it.

Check what was created:
```bash
helm list
kubectl get all -l app.kubernetes.io/instance=bankapp-mysql
kubectl get pvc -l app.kubernetes.io/instance=bankapp-mysql
kubectl get secret -l app.kubernetes.io/instance=bankapp-mysql
```

Verify MySQL is running:
```bash
kubectl exec -it bankapp-mysql-0 -- mysql -uroot -pTest@123 -e "SHOW DATABASES;"
```

You should see `bankappdb` in the output.

**Steps to follow:**

Step 1: Verify Your Cluster is Running: kubectl get nodes

<img width="1465" height="152" alt="image" src="https://github.com/user-attachments/assets/2f1a8aed-e2a6-4c5e-af84-8b15cebbd8cb" />

Step 2: Add the Bitnami Helm Repository: Helm repositories are similar to apt repositories in Ubuntu.

-->Add Bitnami: helm repo add bitnami https://charts.bitnami.com/bitnami [Expected: "bitnami" has been added to your repositories]

-->Update the repository index: helm repo update [Expected: Hang tight while we grab the latest from your chart repositories Successfully got an update from the "bitnami" chart repository Update Complete.]

-->To verify: helm repo list [Expected: name and URL in return]

<img width="1897" height="247" alt="image" src="https://github.com/user-attachments/assets/e785d7dc-6537-42c5-860c-3a9d5e4e9344" />

**Issue Faced While Deploying MySQL with Bitnami Helm Chart:**

<img width="642" height="690" alt="image" src="https://github.com/user-attachments/assets/85cf5f5e-3e4d-4af9-9a6d-8c2b6c55a9f4" />

<img width="765" height="751" alt="image" src="https://github.com/user-attachments/assets/7b733f08-225a-4143-be40-aed8396722b1" />

<img width="727" height="477" alt="image" src="https://github.com/user-attachments/assets/454896d4-9e56-4658-b0a4-7538761034a0" />

<img width="717" height="552" alt="image" src="https://github.com/user-attachments/assets/4392a7db-6170-4c4b-9855-9c71300305e2" />

-->So went to the page: https://artifacthub.io/ & then search for "mysql helm chart" & then select related option, Used Option 1 here 

<img width="1912" height="962" alt="image" src="https://github.com/user-attachments/assets/cd47be43-0f8f-491a-8dca-f59df405d2b8" />

<img width="1902" height="961" alt="image" src="https://github.com/user-attachments/assets/1b1505e9-ca86-4590-9fd4-5be3065dbf4d" />

<img width="862" height="646" alt="image" src="https://github.com/user-attachments/assets/6c8b51e6-a512-4615-89bd-1bdf1c69a798" />

**Note:** Here in above screenshot we can see at last values.yml file is used that is ulternet options to set the all values which we have set in above command

<img width="817" height="641" alt="image" src="https://github.com/user-attachments/assets/53a77538-f3e4-44a3-8fa4-3fd66a21ac56" />

<img width="822" height="581" alt="image" src="https://github.com/user-attachments/assets/f43e2849-f129-4bbb-86e9-ee9e9ef84a3a" />

Step 3: Search for the MySQL Chart: helm search repo bitnami/mysql [So This confirms Helm can find the chart.]

<img width="1382" height="107" alt="image" src="https://github.com/user-attachments/assets/0f976c13-1ab4-4744-bebc-2cf8ca4823c0" />

Step 4: Understand the Installation Command: 

helm install my-mysql mysql/mysql \
  --set auth.rootPassword=Test@123 \
  --set auth.database=bankappdb \
  --set primary.resources.requests.memory=256Mi \
  --set primary.resources.requests.cpu=250m \
  --set primary.resources.limits.memory=512Mi \
  --set primary.resources.limits.cpu=500m \
  --set primary.persistence.size=5Gi
  
<img width="1836" height="967" alt="image" src="https://github.com/user-attachments/assets/458be5eb-2794-43ff-9b5f-52a417109946" />

<img width="1917" height="417" alt="image" src="https://github.com/user-attachments/assets/99002cb6-49ec-4242-af05-8c00084e8be1" />

Explaination on all above:

<img width="722" height="641" alt="image" src="https://github.com/user-attachments/assets/d48acb41-aa76-4d19-b1d5-c99c267dc012" />

<img width="690" height="742" alt="image" src="https://github.com/user-attachments/assets/0c85a1ec-8769-4a2a-a947-3efe3b629fb7" />

<img width="1667" height="112" alt="image" src="https://github.com/user-attachments/assets/0502ef87-05e7-4888-8ac4-0b027a0c9f0e" />

<img width="605" height="712" alt="image" src="https://github.com/user-attachments/assets/d588d308-3097-4dff-a99c-a81bef51dd4e" />

3. Resource Requests:

<img width="512" height="821" alt="image" src="https://github.com/user-attachments/assets/17b59ee6-fa4d-4456-bf83-41a01495609e" />

4. Resource Limits:

<img width="502" height="777" alt="image" src="https://github.com/user-attachments/assets/fc6660b1-5c96-4497-80d1-002674daafbe" />

<img width="687" height="277" alt="image" src="https://github.com/user-attachments/assets/a97c9632-b357-43f9-ac1c-6c2d06925bd4" />

<img width="507" height="755" alt="image" src="https://github.com/user-attachments/assets/a2aba9a5-1e41-4b7b-8dfd-363ba54c1afd" />

6. Understanding the Output: Helm returned: NAME: bankapp-mysql [Release name] Check it: helm list & we can see STATUS: deployed Means: Chart Installed Successfully

-->Possible other statuses: deployed, failed, pending-install, pending-upgrade, uninstalled etc.

<img width="447" height="467" alt="image" src="https://github.com/user-attachments/assets/4c1738c8-e6d9-499b-ae29-99b5af83c0ef" />

<img width="1792" height="137" alt="image" src="https://github.com/user-attachments/assets/d72ddb84-3731-4be1-8f3c-3af2770067cc" />

<img width="605" height="412" alt="image" src="https://github.com/user-attachments/assets/549bad9b-4f25-4166-bd6b-bcc8deb21f44" />

<img width="635" height="417" alt="image" src="https://github.com/user-attachments/assets/c1fceb58-e153-4d49-8729-a381fb07ef46" />

<img width="592" height="667" alt="image" src="https://github.com/user-attachments/assets/8989b331-d3c0-4006-9b6c-5d7c218e5d6f" />

<img width="1655" height="202" alt="image" src="https://github.com/user-attachments/assets/174cf525-67a3-498b-8bc2-82d40cb6639d" />

10. What Resources Helm Actually Created:

-->kubectl get all -l app.kubernetes.io/instance=bankapp-mysql [we'll likely see: pod/bankapp-mysql-0, service/bankapp-mysql, statefulset.apps/bankapp-mysql etc.]

-->kubectl get svc

-->kubectl get secrets

<img width="1887" height="426" alt="image" src="https://github.com/user-attachments/assets/91eee69b-cab3-4815-a0a9-e4f254a3fbbd" />

-->So one Helm command created: StatefulSet, Service, Secret, PersistentVolumeClaim, ConfigMaps, Storage configuration etc.

11. Understanding the Warning:

<img width="702" height="476" alt="image" src="https://github.com/user-attachments/assets/ec06a65d-b18a-4f85-b0d5-22517897a8d9" />

12. Verify Everything:

-->Check Helm release:: helm list

-->Check pods: kubectl get pods

-->Check storage: kubectl get pvc

-->Check databases: kubectl exec -it bankapp-mysql-0 -- mysql -uroot -pTest@123 -e "SHOW DATABASES;"












  







---

### Task 4: Customize a Deployment with Values Files
`--set` works for quick overrides, but real projects use values files.

Create `mysql-values.yaml`:
```yaml
auth:
  rootPassword: Test@123
  database: bankappdb
primary:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  persistence:
    size: 5Gi
    storageClass: ""
metrics:
  enabled: true
  serviceMonitor:
    enabled: false
```

Deploy with the values file:
```bash
helm install bankapp-mysql-v2 bitnami/mysql -f mysql-values.yaml
```

**To see all configurable values for a chart:**
```bash
helm show values bitnami/mysql | head -80
```

This is your reference for every knob you can turn. Notice how the chart supports metrics, replication, custom init scripts, and dozens more options -- all through values.

**Clean up the second release:**
```bash
helm uninstall bankapp-mysql-v2
```

---

### Task 5: Manage Releases -- Upgrade, Rollback, Uninstall
Helm tracks every change as a **revision**. This lets you upgrade and rollback safely.

**Upgrade MySQL to enable metrics:**
```bash
helm upgrade bankapp-mysql bitnami/mysql \
  --set auth.rootPassword=Test@123 \
  --set auth.database=bankappdb \
  --set metrics.enabled=true
```

Check the revision history:
```bash
helm history bankapp-mysql
```

You should see revision 1 (original) and revision 2 (metrics enabled).

**Rollback to the previous version:**
```bash
helm rollback bankapp-mysql 1
```

Check history again:
```bash
helm history bankapp-mysql
```

Revision 3 appears -- a rollback to revision 1.

**Compare this to raw manifests:** With `kubectl apply`, there is no built-in rollback. You would have to `git revert` or manually re-apply old YAML. Helm gives you `helm rollback` out of the box.

---

### Task 6: Explore a Chart's Structure
Before building your own chart for the AI-BankApp tomorrow, understand what is inside a Helm chart.

Pull the MySQL chart locally:
```bash
helm pull bitnami/mysql --untar
ls mysql/
```

You will see:
```
mysql/
  Chart.yaml              # Chart metadata (name, version, description)
  values.yaml             # Default configuration values
  charts/                 # Subchart dependencies
  templates/              # Kubernetes manifest templates
    primary/
      statefulset.yaml    # StatefulSet template with Go template syntax
      svc.yaml            # Service template
    _helpers.tpl          # Reusable template helpers
    NOTES.txt             # Post-install message shown to the user
    secrets.yaml          # Secret template
```

Open `templates/primary/statefulset.yaml` and look for Go template syntax:
```yaml
replicas: {{ .Values.primary.replicaCount }}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

`{{ .Values.primary.replicaCount }}` pulls from `values.yaml`. When you pass `--set primary.replicaCount=3`, it overrides this value.

Open `Chart.yaml`:
```yaml
apiVersion: v2
name: mysql
description: A Helm chart for MySQL
version: 12.2.1      # Chart version (chart structure changes)
appVersion: "8.0.40"  # Version of MySQL inside the chart
```

**Now compare the Helm chart approach to the AI-BankApp's raw manifests:**

| Aspect | AI-BankApp `k8s/mysql-deployment.yml` | Bitnami MySQL Helm Chart |
|--------|---------------------------------------|--------------------------|
| Secrets | Hardcoded base64 in `secrets.yml` | Generated and managed by Helm |
| Storage | Manual StorageClass + PVC files | Configured via `persistence.size` value |
| Replicas | Hardcoded in YAML | `primary.replicaCount` value |
| Metrics | Not included | `metrics.enabled: true` |
| Rollback | Manual | `helm rollback` |

**Document:** What is the difference between `version` and `appVersion` in Chart.yaml?

Clean up:
```bash
helm uninstall bankapp-mysql
rm -rf mysql/
```

---

## Hints
- `helm install` creates a new release; `helm upgrade` updates an existing one. Use `helm upgrade --install` to do both in one command (install if missing, upgrade if exists)
- `--set` overrides individual values; `-f values.yaml` overrides with a file. `-f` is preferred for anything beyond one or two values
- `helm list` shows releases in the current namespace. Use `helm list -A` for all namespaces
- `helm repo update` refreshes the local cache of chart repositories -- run it before deploying to get the latest versions
- If a deployment fails, check `helm status <release>` and `kubectl describe pod` for details
- `helm template <release> <chart>` renders templates locally without deploying -- great for debugging
- Keep the AI-BankApp repo cloned -- you will build a Helm chart for it tomorrow
- Reference project: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`)

---

## Documentation
Create `day-78-helm-intro.md` with:
- Helm concepts in your own words (chart, release, repository, values)
- Comparison of deploying MySQL with raw YAML vs Helm
- Your `mysql-values.yaml` and explanation of each field
- Screenshot of `helm list` showing your deployed releases
- Screenshot of `helm history` showing upgrade and rollback revisions
- The chart directory structure with explanation of each file
- Why the AI-BankApp's 12 raw YAML files would benefit from being a Helm chart

---

## Submission
1. Add `day-78-helm-intro.md` to `2026/day-78/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Started the Helm block today -- deployed MySQL from a Bitnami Helm chart with one command instead of writing 5 separate YAML files. Upgraded, rolled back, and explored the chart structure. Tomorrow I will convert the AI-BankApp's 12 raw Kubernetes manifests into a proper Helm chart."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
