# Day 56 – Kubernetes StatefulSets

## Task
Deployments work great for stateless apps, but what about databases? You need stable pod names, ordered startup, and persistent storage per replica. Today you learn StatefulSets — the workload designed for stateful applications like MySQL, PostgreSQL, and Kafka.

---

## Expected Output
- A StatefulSet with 3 replicas and stable pod names
- DNS resolution tested for individual pods
- Data persistence verified across pod deletion
- A markdown file: `day-56-statefulsets.md`

---

## Challenge Tasks

### Task 1: Understand the Problem
1. Create a Deployment with 3 replicas using nginx
2. Check the pod names — they are random (`app-xyz-abc`)
3. Delete a pod and notice the replacement gets a different random name

**Steps to follow:**

-->This task is about understanding why Kubernetes Pod names change when managed by a Deployment. This is fine for web servers but not for databases where you need stable identity.

Step 1: Create a Deployment with 3 replicas: kubectl create deployment nginx-deployment --image=nginx --replicas=3

Step 2: Verify the Pods: kubectl get pods

<img width="597" height="276" alt="image" src="https://github.com/user-attachments/assets/d20fb1fd-1d6a-4649-8f64-67a52931fc8e" />

Step 3: Delete one Pod: Delete any pod: kubectl delete pod nginx-deployment-7d8b49557c-4h2kp

Step 4: Watch the replacement: kubectl get pods -w

<img width="641" height="162" alt="image" src="https://github.com/user-attachments/assets/0d498e50-721b-4189-8ecd-608584aa23b7" />

<img width="1572" height="372" alt="image" src="https://github.com/user-attachments/assets/66d13ad2-14c9-4844-a942-701a00b5c403" />

Q. Why does this happen?
- A Deployment maintains the desired number of replicas (3).
- When a Pod is deleted, the Deployment (through its ReplicaSet) creates a new Pod.
- Each new Pod gets a unique random name to avoid naming conflicts.
- Pods are ephemeral (temporary)—they are meant to be replaced rather than reused.

Verify:

-->kubectl get deployment

-->kubectl get pods 

-->kubectl get rs

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |

Delete the Deployment before moving on.

**Verify:** Why would random pod names be a problem for a database cluster?
-->Because databases need stable identity, not replaceable instances.
-->In case replacable instance used in database cluster then we may face issue:
**1. Cluster Membership Breaks**

-->Databases like MongoDB, Cassandra, MySQL cluster rely on fixed node names, So if a pod name changes → cluster can't recognize it

**2. Data Mapping Problem**

-->Pod db-1 should always map to its own storage, With random names → no guarantee

**3. Replication & Leader Election Fail**

-->Nodes identify each other using consistent hostnames, Changing names = broken communication

**4. Stable Network Identity Needed**

-->Databases use DNS like: db-0.db-service, db-1.db-service

**Note:** Deployment cannot provide this, Deployments create stateless pods with random identities, but databases require stable pod names, persistent storage, and predictable networking—this is why StatefulSets are used.”

---

### Task 2: Create a Headless Service
1. Write a Service manifest with `clusterIP: None` — this is a Headless Service
2. Set the selector to match the labels you will use on your StatefulSet pods
3. Apply it and confirm CLUSTER-IP shows `None`

**Steps to follow:**

-->This task prepares a Headless Service, which is required by a StatefulSet to give each Pod a stable DNS name.

-->vi headless-service.yml 
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```
**Explanation:**
- clusterIP: None → Makes it a Headless Service.
- selector: app: nginx → Must match the labels that you'll use in your StatefulSet Pods.
- port: 80 → Exposes the Pods on port 80.

Step 2: Apply the Service: kubectl apply -f headless-service.yml

Step 3: Verify the Service: kubectl get svc [Expected: Notice that the CLUSTER-IP is None, confirming it is a Headless Service.]

<img width="1527" height="515" alt="image" src="https://github.com/user-attachments/assets/b43b1d18-ff97-410e-8cbb-fd0a1b6368e4" />

**Note:** A Headless Service creates individual DNS entries for each pod instead of load-balancing to one IP. StatefulSets require this.

verify: kubectl describe svc nginx-headless
You should see:
- Name: nginx-headless
- Type: ClusterIP
- IP: None
- Selector: app=nginx

**Note:** At this stage, the Endpoints section may be empty because the StatefulSet Pods haven't been created yet. Once you create the StatefulSet with the label app: nginx, the endpoints will be populated automatically.

Q. What does the CLUSTER-IP column show?

-->It shows None, In Kubernetes, a normal Service assigns a single virtual IP (ClusterIP) that acts as a load balancer, so any request sent to that IP is automatically distributed across all matching pods. This works well for stateless applications like web servers, where it doesn’t matter which pod handles the request. However, a Headless Service behaves differently—it does not allocate a single IP address (clusterIP: None). Instead, it creates individual DNS records for each pod, such as pod-0.service-name, pod-1.service-name, and so on. This allows clients to connect to specific pods directly rather than going through a load balancer. StatefulSets depend on this behavior because stateful applications like databases require stable identities and predictable network endpoints for each node. For example, database nodes must consistently recognize and communicate with each other using fixed names. If you forget to set clusterIP: None, Kubernetes will create a regular Service, and you’ll lose this per-pod DNS resolution—breaking the stable networking that StatefulSets rely on.

---

### Task 3: Create a StatefulSet
1. Write a StatefulSet manifest with `serviceName` pointing to your Headless Service
2. Set replicas to 3, use the nginx image
3. Add a `volumeClaimTemplates` section requesting 100Mi of ReadWriteOnce storage
4. Apply and watch: `kubectl get pods -l <your-label> -w`

**Steps to follow:**

-->This task teaches how a StatefulSet creates Pods with stable names and dedicated storage.

Step 1: Create the StatefulSet Manifest: vi web-statefulset.yml
```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-statefulset
spec:
  serviceName: nginx-headless
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
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: nginx-storage
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
```
**Key Points:**
- serviceName: nginx-headless → Points to the Headless Service you created.
- replicas: 3 → Creates three Pods.
- image: nginx → Uses the NGINX image.
- volumeClaimTemplates → Automatically creates one PVC per Pod (100Mi, ReadWriteOnce).

Step 2: Apply the StatefulSet: kubectl apply -f web-statefulset.yml

-->Watch statefulset Creation: kubectl get statefulset

-->Watch Pod Creation, We can keep continuous watch: kubectl get pods -l app=web -w

Step 3: Watch the Pods: kubectl get pods -l app=web

<img width="670" height="311" alt="image" src="https://github.com/user-attachments/assets/164ab319-6817-4350-b22e-cd0adcacd039" />

Step 4: Verify the PVCs: kubectl get pvc

<img width="637" height="192" alt="image" src="https://github.com/user-attachments/assets/94e82e82-17c4-4466-829f-e63a74788db4" />

-->Watch pv Creation: kubectl get pv

-->To test delete one of the pod: kubectl delete pod web-1

-->Verify once again created pod: kubectl get pods 

Observe ordered creation — `web-0` first, then `web-1` after `web-0` is Ready, then `web-2`.

Check the PVCs: `kubectl get pvc` — you should see `web-data-web-0`, `web-data-web-1`, `web-data-web-2` (names follow the pattern `<template-name>-<pod-name>`).

<img width="1912" height="862" alt="image" src="https://github.com/user-attachments/assets/f7c8a06b-563b-43df-b2fc-d0d6a95ab1d4" />

**Verify:** What are the exact pod names and PVC names?
-->here we can see exact pod name, pvc name & pv name as below,
<img width="1895" height="437" alt="image" src="https://github.com/user-attachments/assets/fecd4df0-9f50-4925-bc5f-4da61fffa85d" />
-->This is ordered creation as below, Unlike deployment
<img width="365" height="171" alt="image" src="https://github.com/user-attachments/assets/20aeb5ae-a284-4518-aa35-7778a0385163" />

**Key insite:** Here each pod Has a fixed identity (web-0)
- Each pod gets its own storage (web-data-web-0)
- Keeps that storage even if the pod restarts

-->**Note:** This is exactly why databases work on StatefulSets.

**Q. What is a Pod here?**

-->A Pod in your StatefulSet is one running instance of your app. In your case, the pods are: web-0, web-1, web-2. Each of these is one nginx container, With its own identity

**Q. What does “gets its own storage” mean?**
-->Kubernetes automatically creates one PVC and pv per pod. That means web-0 uses only web-data-web-0 & web-1 uses only web-data-web-1 No sharing, And if we delete the for example pod1 suppose, So k8s will create new pod with same name, So It reattaches with web-data-web-0 which is same same storage so Data is NOT lost
& Identity stays same.

-->And in deployment Pods are random → abc123, Storage is usually shared or temporary

-->In StatefulSet: Pod = identity + storage tied together

-->A pod in a StatefulSet is a stateful instance that always keeps the same name and its own dedicated storage.

---

### Task 4: Stable Network Identity
Each StatefulSet pod gets a DNS name: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`

1. Run a temporary busybox pod and use `nslookup` to resolve `web-0.<your-headless-service>.default.svc.cluster.local`
2. Do the same for `web-1` and `web-2`
3. Confirm the IPs match `kubectl get pods -o wide`

**Steps to follow:**

-->This task demonstrates that each StatefulSet Pod has a stable DNS name.

**Note:** Replace web with your StatefulSet name (nginx-statefulset) and replace the service name with your Headless Service (nginx-headless).
**So your Pod DNS names are:**
- web-0.nginx-headless.default.svc.cluster.local
- web-1.nginx-headless.default.svc.cluster.local
- web-2.nginx-headless.default.svc.cluster.local

-->Confirm your Service name: kubectl get svc
Step 1: Run a temporary BusyBox Pod: kubectl run dns-test --image=busybox:1.28 --rm -it --restart=Never -- sh [Expected: This opens a shell inside the BusyBox container.]
Step 2: Resolve Pod DNS Names: 

-->nslookup web-0.nginx-headless.default.svc.cluster.local   [Here each pod will return different ip]

-->nslookup web-1.nginx-headless.default.svc.cluster.local

-->nslookup web-2.nginx-headless.default.svc.cluster.local

-->exit  [Exit BusyBox when you're done]

Step 3: Verify the Pod IPs: kubectl get pods -o wide [**Note:** Compare these IPs with the nslookup results—they should match.]

-->To get the endpoints: kubectl get endpoints nginx-headless [Note: This confirms that your Headless Service is correctly pointing to the StatefulSet Pods.]

<img width="691" height="372" alt="image" src="https://github.com/user-attachments/assets/79d85f0c-a4d7-45c3-abc2-a1dc87e0ebb7" />

<img width="1830" height="797" alt="image" src="https://github.com/user-attachments/assets/47044b93-c42e-4245-8668-b916737559d5" />

**Faced issue:** inside busybox temp container nslookup command was failing & that is due to missmatching og the lable and selector of the headless 
service and statefulset yml file, So ya that should be match. To debug all this use commands as below,

**Verify:** Does the nslookup IP match the pod IP?

-->Yes, each DNS entry resolves to the exact IP address of its corresponding pod.

-->Unlike a normal service You don’t get load balancing, You get direct pod-to-pod communication, So pods can directly talk to each other using stable DNS names like below,
<img width="1830" height="797" alt="image" src="https://github.com/user-attachments/assets/47044b93-c42e-4245-8668-b916737559d5" />

-->So this is direct communication, not load-balanced, So this is how databases Discover peers, Replicate data & Elect leaders etc.

**Note:** “In StatefulSets, each pod gets a stable DNS name via a headless service, which resolves directly to the pod’s IP—enabling predictable, peer-to-peer communication.” 

**So the Final Checklist to confirm that StateFulSet is working fine,**

-->Pods are Running

-->Service has clusterIP: None

-->Service selector matches pod labels

-->Endpoints are populated

---

### Task 5: Stable Storage — Data Survives Pod Deletion
1. Write unique data to each pod: `kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"`
2. Delete `web-0`: `kubectl delete pod web-0`
3. Wait for it to come back, then check the data — it should still be "Data from web-0"

**Steps to follow:**

-->This task demonstrates one of the biggest advantages of a StatefulSet: data survives Pod deletion because each Pod has its own PersistentVolumeClaim (PVC).

Step 1: Write data to each Pod: 

-->kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"

-->kubectl exec web-1 -- sh -c "echo 'Data from web-1' > /usr/share/nginx/html/index.html"

-->kubectl exec web-2 -- sh -c "echo 'Data from web-2' > /usr/share/nginx/html/index.html"

Step 2: Verify the data: 

-->kubectl exec web-0 -- cat /usr/share/nginx/html/index.html

-->kubectl exec web-1 -- cat /usr/share/nginx/html/index.html

-->kubectl exec web-2 -- cat /usr/share/nginx/html/index.html

Step 3: Delete web-0: kubectl delete pod web-0

Step 4: Wait for it to be recreated: kubectl get pods -w

<img width="632" height="230" alt="image" src="https://github.com/user-attachments/assets/20b401f6-a1c0-4df2-a05c-1d29fae3db82" />

Step 5: Check the data again: kubectl exec web-0 -- cat /usr/share/nginx/html/index.html

The data is still there because:
- web-0 reused its existing PVC (web-data-web-0).
- The PersistentVolume was not deleted when the Pod was deleted. 

-->Verify the PVC is unchanged: kubectl get pvc [Note: The same PVC (web-data-web-0) is attached to the recreated web-0.]

<img width="1866" height="691" alt="image" src="https://github.com/user-attachments/assets/2c40d1c5-442a-440a-8da0-b0a9fab224ab" />

**Note:**
- Deployment Pods are replaceable and usually use shared or ephemeral storage.
- StatefulSet Pods have:
  - Stable Pod names (web-0, web-1, web-2)
  - Stable DNS names
  - Dedicated PVCs
  - Persistent data that survives Pod deletion

-->This is why StatefulSets are used for applications like databases (MySQL, PostgreSQL, MongoDB, Kafka, etc.), where each instance needs its own persistent storage.

**Verify:** Is the data identical after pod recreation?

-->Yes, the data is identical Because The data is stored in a PersistentVolume via a PVC, The PVC is bound to the Pod identity (web-0) & When the Pod is recreated, it mounts the same volume.

--> When pod web-0 got Terminated but PVC is NOT deleted, Then Kubernetes recreates new pod automatically, This happens because the StatefulSet controller ensures web-0 always exists, After this newly created pod reattaches to the same PVC & Reads the same stored data.

---

### Task 6: Ordered Scaling
1. Scale up to 5: `kubectl scale statefulset web --replicas=5` — pods create in order (web-3, then web-4)
2. Scale down to 3 — pods terminate in reverse order (web-4, then web-3)
3. Check `kubectl get pvc` — all five PVCs still exist. Kubernetes keeps them on scale-down so data is preserved if you scale back up.

**Steps to follow:**

-->This task demonstrates that StatefulSets scale in a predictable order and keep storage even after scaling down.

-->Check current state of the statefulset: kubectl get pods -l app=web

-->Also check the status of pvc: kubectl get pvc

Step 1: Scale up to 5 replicas: kubectl scale statefulset web --replicas=5

Step 2: Watch the Pods being created: kubectl get pods -w

<img width="692" height="276" alt="image" src="https://github.com/user-attachments/assets/c41afb3f-4031-4877-9921-d567bf8a2440" />

Step 3: Verify all Pods: kubectl get pods

Step 4: Scale down to 3 replicas: kubectl scale statefulset web --replicas=3

Step 5: Watch Pods terminate: kubectl get pods -w

<img width="670" height="272" alt="image" src="https://github.com/user-attachments/assets/ad5f4ef6-0686-48f3-9110-fadc3c9a266f" />

Step 6: Check the PVCs: kubectl get pvc [Even though web-3 and web-4 Pods were deleted, their PVCs still exist.]

<img width="1877" height="852" alt="image" src="https://github.com/user-attachments/assets/9ff047e1-8967-47fa-a1ca-f0e97c347a4a" />

<img width="1807" height="467" alt="image" src="https://github.com/user-attachments/assets/2c566303-bfe9-4337-9f41-22eb519a041b" />

**Summary:**

<img width="655" height="215" alt="image" src="https://github.com/user-attachments/assets/e92cba5d-fe43-440d-8a22-de1329242c95" />

**Verify:** After scaling down, how many PVCs exist?

-->After scaling down, there are still 5 PVCs available, That is because StatefulSets do NOT delete PVCs automatically, This ensures: Data is not lost, If you scale back to 5 → web-3 and web-4 reuse old data

**Note:** “StatefulSet deletes pods, not storage. PVCs persist across scaling.”

---

### Task 7: Clean Up
1. Delete the StatefulSet and the Headless Service
2. Check `kubectl get pvc` — PVCs are still there (safety feature)
3. Delete PVCs manually

**Steps to follow:**

-->Delete the statefulste: kubectl delete statefulset web

-->Delete the Headless Service: kubectl delete service web

-->Now as we have deleted statefulset & headless service now check the pvc: kubectl get pvc

-->Delete PVCs manually: kubectl delete pvc --all OR selectlively delete the pvc: kubectl delete pvc www-web-0 www-web-1 www-web-2 www-web-3 www-web-4

<img width="1741" height="762" alt="image" src="https://github.com/user-attachments/assets/3e33a1d9-e436-49ad-a8c4-dcafe038c1f1" />

**Verify:** Were PVCs auto-deleted with the StatefulSet?
-->No. PVCs are NOT auto-deleted, That is because, This is a data safety feature, StatefulSets assume data is critical, So Auto-deleting PVCs could cause permanent data loss, So Kubernetes requires explicit manual deletion.

**Note:** “Deleting a StatefulSet removes Pods but preserves PVCs to prevent accidental data loss.”, PVC lifecycle is independent of StatefulSet

---

## Hints
- `kubectl get sts` is the short name for StatefulSets
- `serviceName` must match an existing Headless Service
- Pod DNS: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`
- PVC naming: `<template-name>-<statefulset-name>-<ordinal>`
- Pods create in order (0, 1, 2) and terminate in reverse (2, 1, 0)
- Scaling down does not delete PVCs — data is preserved
- Deleting a StatefulSet does not delete PVCs — clean up separately

---

## Documentation
Create `day-56-statefulsets.md` with:
- What StatefulSets are and when to use them vs Deployments
- The comparison table
- How Headless Services, stable DNS, and volumeClaimTemplates work
- Screenshots of pods, PVCs, and DNS resolution

---

## Submission
1. Add `day-56-statefulsets.md` to `2026/day-56/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Learned Kubernetes StatefulSets today. Stable pod names, per-pod DNS, and persistent storage that survives deletion — now I understand why databases need StatefulSets."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
