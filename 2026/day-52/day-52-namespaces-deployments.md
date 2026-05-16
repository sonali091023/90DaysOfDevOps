# Day 52 – Kubernetes Namespaces and Deployments

## Task
Yesterday you created standalone Pods. The problem? Delete a Pod and it is gone forever — no one recreates it. Today you fix that with Deployments, the real way to run applications in Kubernetes. You will also learn Namespaces, which let you organize and isolate resources inside a cluster.

---

## Expected Output
- At least 2 namespaces created and used
- A Deployment running with multiple replicas
- A scaled Deployment and a rolling update performed
- A markdown file: `day-52-namespaces-deployments.md`
- Screenshot of `kubectl get deployments` and `kubectl get pods` across namespaces

---

## Challenge Tasks

### Task 1: Explore Default Namespaces
Kubernetes comes with built-in namespaces. List them:

```bash
kubectl get namespaces
```
<img width="712" height="222" alt="image" src="https://github.com/user-attachments/assets/a12e93ba-42de-413f-a002-a8a2ecbe062a" />

You should see at least:
- `default` — where your resources go if you do not specify a namespace
- `kube-system` — Kubernetes internal components (API server, scheduler, etc.)
- `kube-public` — publicly readable resources
- `kube-node-lease` — node heartbeat tracking

Check what is running inside `kube-system`:
```bash
kubectl get pods -n kube-system
```
These are the control plane components keeping your cluster alive. Do not touch them.
<img width="982" height="233" alt="image" src="https://github.com/user-attachments/assets/c03a02d9-5326-4dc5-b9da-171010d2fc42" />

**Verify:** How many pods are running in `kube-system`?
--> 8 pods are running in the kube-system.

---

### Task 2: Create and Use Custom Namespaces
Create two namespaces — one for a development environment and one for staging:

```bash
kubectl create namespace dev
kubectl create namespace staging
```

Verify they exist:
```bash
kubectl get namespaces
```

You can also create a namespace from a manifest:
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

```bash
kubectl apply -f namespace.yaml
```
<img width="761" height="638" alt="image" src="https://github.com/user-attachments/assets/460dae75-0526-44d4-a91b-b7681791f69f" />

Now run a pod in a specific namespace:
```bash
kubectl run nginx-dev --image=nginx:latest -n dev
kubectl run nginx-staging --image=nginx:latest -n staging
```

List pods across all namespaces:
```bash
kubectl get pods -A
```
**Verify:** Does `kubectl get pods` show these pods? What about `kubectl get pods -A`?

-->Notice that `kubectl get pods` without `-n` only shows the `default` namespace. You must specify `-n <namespace>` or use `-A` to see everything.

<img width="1237" height="398" alt="image" src="https://github.com/user-attachments/assets/029dcc76-1cca-4760-b085-0e4cc49e4d93" />

---

### Task 3: Create Your First Deployment
A Deployment tells Kubernetes: "I want X replicas of this Pod running at all times." If a Pod crashes, the Deployment controller recreates it automatically.

Create a file `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
        ports:
        - containerPort: 80
```

Key differences from a standalone Pod:
- `kind: Deployment` instead of `kind: Pod`
- `apiVersion: apps/v1` instead of `v1`
- `replicas: 3` tells Kubernetes to maintain 3 identical pods
- `selector.matchLabels` connects the Deployment to its Pods
- `template` is the Pod template — the Deployment creates Pods using this blueprint

Apply it:
```bash
kubectl apply -f nginx-deployment.yaml
```

Check the result:
```bash
kubectl get deployments -n dev
kubectl get pods -n dev
```

You should see 3 pods with names like `nginx-deployment-xxxxx-yyyyy`.

<img width="926" height="656" alt="image" src="https://github.com/user-attachments/assets/c18a24ba-8cb0-4d6a-bc8f-c277d6d58e51" />


**Verify:** What do the READY, UP-TO-DATE, and AVAILABLE columns mean in the deployment output?

-->Ready: container readiness inside Pods eg: 2/3 means 2 Pods are running and ready out of 3.

-->UP-TO-DATE: → using latest version, Number of Pods running the latest deployment spec After an update, new Pods are created → this number increases, Shows rollout progress

-->AVAILABLE: → stable & serving traffic, Number of Pods that are: Running and, Passed readiness checks (ready to serve traffic), These are Pods actually serving users

**Note**: EADY shows how many Pods are ready, UP-TO-DATE shows how many are updated to the latest version, and AVAILABLE shows how many are ready and serving traffic.

---

### Task 4: Self-Healing — Delete a Pod and Watch It Come Back
This is the key difference between a Deployment and a standalone Pod.

```bash
# List pods
kubectl get pods -n dev

# Delete one of the deployment's pods (use an actual pod name from your output)
kubectl delete pod <pod-name> -n dev

# Immediately check again
kubectl get pods -n dev
```

**Note:** The Deployment controller detects that only 2 of 3 desired replicas exist and immediately creates a new one. The deleted pod is replaced within seconds.

**Verify:** Is the replacement pod's name the same as the one you deleted, or different?
-->No both containers name were different.
<img width="930" height="552" alt="image" src="https://github.com/user-attachments/assets/6ec0cd96-f71e-4551-90a6-2c5dd94d4f95" />

---

### Task 5: Scale the Deployment
Change the number of replicas:

```bash
# Scale up to 5
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl get pods -n dev

# Scale down to 2
kubectl scale deployment nginx-deployment --replicas=2 -n dev
kubectl get pods -n dev
```

Watch how Kubernetes creates or terminates pods to match the desired count.

<img width="948" height="418" alt="image" src="https://github.com/user-attachments/assets/6cbafa26-0315-43b5-8756-7ff8682be322" />

You can also scale by editing the manifest — change `replicas: 4` in your YAML file and run `kubectl apply -f nginx-deployment.yaml` again.
<img width="995" height="362" alt="image" src="https://github.com/user-attachments/assets/8daae843-5021-4d6a-8ed9-66e5e2c239ab" />

**Verify:** When you scaled down from 5 to 2, what happened to the extra pods?
-->When scaling down, Kubernetes terminates the extra Pods gracefully until the number of running Pods matches the desired replicas.

**Note:** Desired state updated-->ReplicaSet adjusts-->Pod termination-->Pods deleted

-->Kubernetes doesn’t randomly kill instantly, It tries graceful termination (default ~30 seconds)
---

### Task 6: Rolling Update
Update the Nginx image version to trigger a rolling update:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

Watch the rollout in real time:
```bash
kubectl rollout status deployment/nginx-deployment -n dev
```
Kubernetes replaces pods one by one — old pods are terminated only after new ones are healthy. This means zero downtime.

Check the rollout history:
```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

Now roll back to the previous version:
```bash
kubectl rollout undo deployment/nginx-deployment -n dev
kubectl rollout status deployment/nginx-deployment -n dev
```

Verify the image is back to the previous version:
```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

**Verify:** What image version is running after the rollback?
-->Image version: nginx:1.24

---
<img width="1908" height="805" alt="image" src="https://github.com/user-attachments/assets/4e136efb-ddd0-40a4-a724-740bea36344b" />

### Task 7: Clean Up
```bash
kubectl delete deployment nginx-deployment -n dev
kubectl delete pod nginx-dev -n dev
kubectl delete pod nginx-staging -n staging
kubectl delete namespace dev staging production
```

**Note:** Deleting a namespace removes everything inside it. Be very careful with this in production.

```bash
kubectl get namespaces
kubectl get pods -A
```
<img width="1300" height="718" alt="image" src="https://github.com/user-attachments/assets/4e726428-7114-49c0-bc11-962b87ebf3d2" />

**Verify:** Are all your resources gone?
-->No, All resources are not deleted, Just what namespaces deleted related to that resources got deleted.
<img width="1243" height="267" alt="image" src="https://github.com/user-attachments/assets/f30d877d-d06a-40a8-a8bb-046e114837ce" />

---

## Hints
- `kubectl get <resource> -n <namespace>` — target a specific namespace
- `kubectl get <resource> -A` — list resources across all namespaces
- `selector.matchLabels` in a Deployment must match `template.metadata.labels` — if they do not match, the Deployment will not manage the Pods
- `kubectl scale deployment <name> --replicas=N` — quick way to scale
- `kubectl set image` updates a container image without editing the YAML
- `kubectl rollout undo` rolls back to the previous revision
- `kubectl rollout history` shows past revisions of a Deployment
- Deployments create ReplicaSets behind the scenes — you can see them with `kubectl get replicasets -n <namespace>`

---

## Documentation
Create `day-52-namespaces-deployments.md` with:
- What namespaces are and why you would use them
- Your Deployment manifest and an explanation of each section
- What happens when you delete a Pod managed by a Deployment vs a standalone Pod
- How scaling works (both imperative and declarative)
- How rolling updates and rollbacks work
- Screenshot of your Deployment and Pods running

---

## Submission
1. Add `day-52-namespaces-deployments.md` and your YAML files to `2026/day-52/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Learned Kubernetes Namespaces and Deployments today. Created self-healing deployments, scaled them up and down, and performed a zero-downtime rolling update with rollback."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
