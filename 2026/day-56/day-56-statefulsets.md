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

-->vi nginx-deployment.yml     [nginx-deployment.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-56/k8s-manifest-files/nginx-deployment.yml)

-->kubectl apply -f nginx-deployment.yml

-->kubectl get pods

-->kubectl delete pod <paste pod name>

-->kubectl get pods
<img width="1382" height="471" alt="image" src="https://github.com/user-attachments/assets/9dd563bd-b2e2-4bb5-bc44-1b79cd265897" />

This is fine for web servers but not for databases where you need stable identity.

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |

Delete the Deployment before moving on.

**Verify:** Why would random pod names be a problem for a database cluster?
-->Because databases need stable identity, not replaceable instances.
-->In in case replacable instance used in database cluster then we may face issue:
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

-->vi headless-service.yml          [headless-service.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-56/k8s-manifest-files/headless-service.yml)

-->kubectl apply -f headless-service.yml

-->kubectl get svc
<img width="1275" height="391" alt="image" src="https://github.com/user-attachments/assets/73098681-fbbf-4abe-b9ed-5b86c1974d41" />

A Headless Service creates individual DNS entries for each pod instead of load-balancing to one IP. StatefulSets require this.

**Verify:** What does the CLUSTER-IP column show?

-->It shows None, In Kubernetes, a normal Service assigns a single virtual IP (ClusterIP) that acts as a load balancer, so any request sent to that IP is automatically distributed across all matching pods. This works well for stateless applications like web servers, where it doesn’t matter which pod handles the request. However, a Headless Service behaves differently—it does not allocate a single IP address (clusterIP: None). Instead, it creates individual DNS records for each pod, such as pod-0.service-name, pod-1.service-name, and so on. This allows clients to connect to specific pods directly rather than going through a load balancer. StatefulSets depend on this behavior because stateful applications like databases require stable identities and predictable network endpoints for each node. For example, database nodes must consistently recognize and communicate with each other using fixed names. If you forget to set clusterIP: None, Kubernetes will create a regular Service, and you’ll lose this per-pod DNS resolution—breaking the stable networking that StatefulSets rely on.

---

### Task 3: Create a StatefulSet
1. Write a StatefulSet manifest with `serviceName` pointing to your Headless Service
2. Set replicas to 3, use the nginx image
3. Add a `volumeClaimTemplates` section requesting 100Mi of ReadWriteOnce storage
4. Apply and watch: `kubectl get pods -l <your-label> -w`

**Steps to follow:**

-->Write StatefulSet Manifest: vi web-statefulset.yml

-->Apply It: kubectl apply -f web-statefulset.yml

-->Watch statefulset Creation: kubectl get statefulset

-->Watch Pod Creation, We can keep continuous watch: kubectl get pods -l app=web -w

-->Watch Pod Creation: kubectl get pods -l app=web

-->Watch pvc Creation: kubectl get pvc

-->Watch pv Creation: kubectl get pv

-->To test dekete one of the pod: kubectl delete pod web-1

-->Verify once again created pod: kubectl get pods 
<img width="1892" height="961" alt="image" src="https://github.com/user-attachments/assets/a8300569-e688-44c4-9919-985932aa06f6" />

Observe ordered creation — `web-0` first, then `web-1` after `web-0` is Ready, then `web-2`.

Check the PVCs: `kubectl get pvc` — you should see `web-data-web-0`, `web-data-web-1`, `web-data-web-2` (names follow the pattern `<template-name>-<pod-name>`).

**Verify:** What are the exact pod names and PVC names?
-->here we can see exact pod name, pvc name & pv name as below,
<img width="1895" height="437" alt="image" src="https://github.com/user-attachments/assets/fecd4df0-9f50-4925-bc5f-4da61fffa85d" />
-->This is ordered creation as below, Unlike deployment
<img width="365" height="171" alt="image" src="https://github.com/user-attachments/assets/20aeb5ae-a284-4518-aa35-7778a0385163" />

-->**Key insite:** Here each pod Has a fixed identity (web-0)
-->Each pod gets its own storage (web-data-web-0)
-->Keeps that storage even if the pod restarts

-->**Note:** This is exactly why databases work on StatefulSets.

**What is a Pod here?**

-->A Pod in your StatefulSet is one running instance of your app.

-->In your case, the pods are: web-0, web-1, web-2

-->Each of these is one nginx container, With its own identity

**What does “gets its own storage” mean?**
-->Kubernetes automatically creates one PVC and pv per pod.
So mapping happens like below,
<img width="593" height="200" alt="image" src="https://github.com/user-attachments/assets/f0cb0c7e-9957-40b4-af9b-aa805d646e36" />
-->That means web-0 uses only web-data-web-0 & web-1 uses only web-data-web-1 No sharing

-->And if we delete the for example pod1 suppose, So k8s will create new pod with same name, So It reattaches with web-data-web-0 which is same same storage so Data is NOT lost
& Identity stays same

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
-->Confirm your Service name: kubectl get svc
-->Then run the temp busybox pod: kubectl run dns-test --image=busybox:1.28 --rm -it --restart=Never -- sh
-->And then inside pod run nslookup command: nslookup web-0.nginx-headless.default.svc.cluster.local   [Here each pod will return different ip]
-->And then inside pod run nslookup command: nslookup web-1.nginx-headless.default.svc.cluster.local
-->And then inside pod run nslookup command: nslookup web-2.nginx-headless.default.svc.cluster.local
-->Get actual Pod IPs: kubectl get pods -o wide -l app=web

[headless-service.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-56/k8s-manifest-files/headless-service.yml)
 & [web-statefulset.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-56/k8s-manifest-files/web-statefulset.yml)

**Faced issue:** inside busybox temp container nslookup command was failing & that is due to missmatching og the lable and selector of the headless 
service and statefulset yml file, So ya that should be match. To debug all this use commands as below,

-->Check if the pods are running: kubectl get pods -l app=web

-->Check Service: kubectl get svc nginx-headless   [Here o/p must show CLUSTER-IP: None]

-->Now check full yml: kubectl get svc nginx-headless -o yaml   [Here we can see selector is diff from the statefulset that should be same]

-->in case Label mismatch to check run command: kubectl get pods --show-labels

-->To it go to headless yml file and edit it: kubectl edit svc nginx-headless
<img width="92" height="47" alt="image" src="https://github.com/user-attachments/assets/c5e92b76-fbb1-470b-98f8-b17a18a6b9d7" />

-->Now Restart the DNS test: kubectl run dns-test --image=busybox:1.28 --rm -it --restart=Never -- sh

-->nslookup web-0.nginx-headless.default.svc.cluster.local   [This time we can see the output & for each pod we can see differrent output.]
<img width="1780" height="809" alt="image" src="https://github.com/user-attachments/assets/3c26a0e1-3b1c-4d44-b75f-6176aa34db9d" />

**Verify:** Does the nslookup IP match the pod IP?

-->Yes, each DNS entry resolves to the exact IP address of its corresponding pod.

-->Unlike a normal service You don’t get load balancing, You get direct pod-to-pod communication, So pods can directly talk to each other using stable DNS names like below,
<img width="190" height="77" alt="image" src="https://github.com/user-attachments/assets/99682bb5-9f13-48d8-b9a7-159e0e31bfa1" />

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

[web-statefulset.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-56/k8s-manifest-files/web-statefulset.yml)

**Steps to follow:**
-->Confirm your StatefulSet is running: kubectl get pods
-->Write unique data to web-0: kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"  [This writes data inside the mounted volume, not just container memory.]
-->Verify the data before deletion: kubectl exec web-0 -- cat /usr/share/nginx/html/index.html
-->now lets delete the pod: kubectl delete pod web-0
-->Now immediately check: kubectl get pods -w
-->Wait until it is Running again: kubectl get pods
-->Verify data AFTER recreation: kubectl exec web-0 -- cat /usr/share/nginx/html/index.html

The new pod reconnected to the same PVC.
<img width="1583" height="563" alt="image" src="https://github.com/user-attachments/assets/9c93e2d8-b30b-4fc3-9274-dda4a8f94992" />

**Verify:** Is the data identical after pod recreation?

-->Yes, the data is identical Because The data is stored in a PersistentVolume via a PVC, The PVC is bound to the Pod identity (web-0) & When the Pod is recreated, it mounts the same volume.

--> When pod web-0 got Terminated but PVC is NOT deleted, Then Kubernetes recreates new pod automatically, This happens because the StatefulSet controller ensures web-0 always exists, After this newly created pod reattaches to the same PVC & Reads the same stored data.

---

### Task 6: Ordered Scaling
1. Scale up to 5: `kubectl scale statefulset web --replicas=5` — pods create in order (web-3, then web-4)
2. Scale down to 3 — pods terminate in reverse order (web-4, then web-3)
3. Check `kubectl get pvc` — all five PVCs still exist. Kubernetes keeps them on scale-down so data is preserved if you scale back up.

**Steps to follow:**

-->Check current state of the statefulset: kubectl get pods -l app=web

-->Also check the status of pvc: kubectl get pvc

-->Scale UP to 5 replicas: kubectl scale statefulset web --replicas=5

-->watch pod creation order: kubectl get pods -w      [So here we can see Pods are created one-by-one in order & Kubernetes will NOT create web-4 until web-3 is fully ready]

-->Verify PVCs after scale-up: kubectl get pvc        [Each pod gets its own dedicated storage.]

-->Now Scale DOWN to 3 replicas: kubectl scale statefulset web --replicas=3

-->Watch again: kubectl get pods -w                   [What we should observe: Pods terminate in reverse order]

-->Check PVCs after scale-down: kubectl get pvc
<img width="1152" height="951" alt="image" src="https://github.com/user-attachments/assets/3d5f8f4e-ef30-4265-89e5-8839c4704870" />

**Verify:** After scaling down, how many PVCs exist?

-->After scaling down, there are still 5 PVCs available, That is because StatefulSets do NOT delete PVCs automatically

-->This ensures: Data is not lost, If you scale back to 5 → web-3 and web-4 reuse old data

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
<img width="1135" height="685" alt="image" src="https://github.com/user-attachments/assets/c713feb8-7cae-4518-bc22-25c49294bbef" />

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
