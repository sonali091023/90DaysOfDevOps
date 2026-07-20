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

**Steps to follow:**

**Explore Default Namespaces:**

Step 1: List all namespaces: kubectl get namespaces

**What they are:**
- default → Default namespace for your applications.
- kube-system → Kubernetes system components.
- kube-public → Publicly readable resources.
- kube-node-lease → Stores node heartbeat information.

Step 2: View pods in kube-system: kubectl get pods -n kube-system [Expected: This lists all the system pods that keep the cluster running.]

-->kubectl get pods -n kube-system --no-headers | wc -l

**Verify:** How many pods are running in `kube-system`?
--> There are 8 pods running in the kube-system namespace.

<img width="1572" height="657" alt="image" src="https://github.com/user-attachments/assets/1a1ae263-0757-4886-9e08-aaf153a83ee2" />

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

**Steps to follow:**

Step 1: Create namespaces: 

-->kubectl create namespace dev

-->kubectl create namespace staging

-->Then to verify: kubectl get namespaces

Step 2: Create a namespace using YAML: vi namespace.yml

<img width="457" height="142" alt="image" src="https://github.com/user-attachments/assets/78b19321-10d2-4821-ab10-4db5585421de" />

-->Now apply: kubectl apply -f namespace.yml

-->Now to verify: kubectl get namespaces

Step 3: Create pods in specific namespaces: 

-->kubectl run nginx-dev --image=nginx:latest -n dev

-->kubectl run nginx-staging --image=nginx:latest -n staging

-->Check the pods: kubectl get pods -n dev

-->kubectl get pods -n staging

Step 4: List pods across all namespaces: kubectl get pods -A

<img width="1492" height="825" alt="image" src="https://github.com/user-attachments/assets/ac125b58-d252-4432-85ec-8b9aac143625" />

<img width="1555" height="596" alt="image" src="https://github.com/user-attachments/assets/9b2629c9-fd9a-45d8-bee1-c240e4f71be0" />

Q. Verify Does this show the new pods?

-->kubectl get pods: No. It only shows pods in the default namespace.

Q. Does this show the new pods?

-->kubectl get pods -A: Yes. It shows pods from all namespaces, including dev and staging.

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

**Verify:** What do the READY, UP-TO-DATE, and AVAILABLE columns mean in the deployment output?

---

**Steps to follow:**

Step 1: Create the Deployment manifest: Create nginx-deployment.yaml with the given YAML:

Key points:
- kind: Deployment → Creates and manages Pods.
- replicas: 3 → Keeps 3 Pods running.
- selector.matchLabels → Identifies which Pods belong to the Deployment.
- template → Blueprint used to create the Pods.

Step 2: Apply the Deployment: kubectl apply -f nginx-deployment.yaml

Step 3: Verify the Deployment: kubectl get deployments -n dev

-->Check the Pods: kubectl get pods -n dev

<img width="1477" height="482" alt="image" src="https://github.com/user-attachments/assets/086f1a29-84d8-455c-ad7a-7a1ffbe7fe72" />

Verify:

- READY → Number of Pods ready to serve traffic (e.g., 3/3 means all 3 are ready).
- UP-TO-DATE → Number of Pods updated to the latest Deployment version.
- AVAILABLE → Number of Pods currently running and available to handle requests.

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
The Deployment controller detects that only 2 of 3 desired replicas exist and immediately creates a new one. The deleted pod is replaced within seconds.

**Steps to follow:**

-->Self-Healing — Delete a Pod and Watch It Come Back

Step 1: List the Pods: kubectl get pods -n dev

Step 2: Delete one Pod: kubectl delete pod nginx-deployment-7d8f9c5d4-abc12 -n dev

Step 3: Watch Kubernetes recreate it: kubectl get pods -n dev OR kubectl get pods -n dev -w

<img width="1637" height="387" alt="image" src="https://github.com/user-attachments/assets/e4089f29-e2af-4526-9346-dc4b486c90d2" />

We will see:
- The deleted Pod disappears.
- A new Pod with a different name is created automatically.
- The Deployment returns to 3 Running Pods.

**Verify:**
- The deleted Pod is automatically recreated.
- The Deployment maintains 3 replicas at all times.
- This is called self-healing—the Deployment controller ensures the desired state is always maintained.

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

You can also scale by editing the manifest — change `replicas: 4` in your YAML file and run `kubectl apply -f nginx-deployment.yaml` again.

**Verify:** When you scaled down from 5 to 2, what happened to the extra pods?

**Steps to follow:**

-->Scale the Deployment

Step 1: Scale up to 5 replicas: kubectl scale deployment nginx-deployment --replicas=5 -n dev

-->Now to verify: kubectl get pods -n dev [Expected: You should see 5 Running Pods.]

Step 2: Scale down to 2 replicas: kubectl scale deployment nginx-deployment --replicas=2 -n dev

-->Now verify again: kubectl get pods -n dev [Expected: Now you should see 2 Running Pods.]

Step 3: Scale using the YAML file: edit the nginx-deployment.yaml: change replicas: 2

-->Apply the changes: kubectl apply -f nginx-deployment.yaml

Now verify:

-->kubectl get deployments -n dev [Expected: You should now have 6 Running Pods.]

-->kubectl get pods -n dev

<img width="1837" height="822" alt="image" src="https://github.com/user-attachments/assets/9e01d023-400b-489d-b03f-4b9149a6cfd6" />

Verify:

Q. When you scaled down from 5 to 2, what happened to the extra pods?

-->Kubernetes terminated (deleted) the extra 3 Pods, leaving only 2 Pods running. The Deployment automatically adjusted the number of Pods to match the desired replica count.

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

**Steps to follow:**

-->**Rolling Update & Rollback:**

Step 1: Update the image: Change the Nginx image from 1.24 to 1.25:

-->kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev

Step 2: Watch the rollout: kubectl rollout status deployment/nginx-deployment -n dev

**Note:** Kubernetes updates the Pods one at a time, ensuring the application remains available.

Step 3: View rollout history: kubectl rollout history deployment/nginx-deployment -n dev [This shows the deployment revisions.]

Step 4: Roll back to the previous version: kubectl rollout undo deployment/nginx-deployment -n dev

-->Wait for the rollback to finish: kubectl rollout status deployment/nginx-deployment -n dev

Step 5: Verify the image version: kubectl describe deployment nginx-deployment -n dev | grep Image

<img width="1917" height="925" alt="image" src="https://github.com/user-attachments/assets/8dc789c8-a19f-4842-800e-a693ede5f0e9" />

Verify:

Q. What image version is running after the rollback?
-->After the rollback, the Deployment runs nginx:1.24, which is the previous image version before the update.

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

**Verify:** Are all your resources gone?

**Steps to follow:**

Step 1: Delete the Deployment: kubectl delete deployment nginx-deployment -n dev

Step 2: Delete the standalone Pods: 

-->kubectl delete pod nginx-dev -n dev

-->kubectl delete pod nginx-staging -n staging

Step 3: Delete the custom namespaces: kubectl delete namespace dev staging production

**Note:** Note: Deleting a namespace deletes all resources inside it.

Step 4: Verify the cleanup: Check the remaining namespaces: kubectl get namespaces [Expected: Only the default namespaces should remain, for example:]

-->Check all the pods: kubectl get pods -A [Expected: You should only see Pods in Kubernetes system namespaces (such as kube-system).]

<img width="1601" height="906" alt="image" src="https://github.com/user-attachments/assets/899b4ab4-42e0-48a4-9529-4999758af4a7" />

**Verify:**

Q. Are all your resources gone?
-->Yes. The Deployment, standalone Pods, and custom namespaces (dev, staging, and production) have been deleted. Only Kubernetes' default namespaces and system Pods remain.

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
