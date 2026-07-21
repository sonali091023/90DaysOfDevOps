# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

## Task
Containers are ephemeral — when a Pod dies, everything inside it disappears. That is a serious problem for databases and anything that needs to survive a restart. Today you fix this with Persistent Volumes and Persistent Volume Claims.

---

## Expected Output
- Data loss demonstrated with an ephemeral Pod
- A PV and PVC created, bound, and data persisting across Pod deletions
- A markdown file: `day-55-persistent-volumes.md`

---

## Challenge Tasks

### Task 1: See the Problem — Data Lost on Pod Deletion
1. Write a Pod manifest that uses an `emptyDir` volume and writes a timestamped message to `/data/message.txt`
2. Apply it, verify the data exists with `kubectl exec`
3. Delete the Pod, recreate it, check the file again — the old message is gone

**Steps to follow:**

-->This task demonstrates that emptyDir is temporary storage. When the Pod is deleted, all data inside the emptyDir volume is lost.

Step 1: Create the Pod: vi pod-with-emptydir.yml   
```
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  containers:
  - name: app
    image: busybox
    command:
      - sh
      - -c
      - |
        mkdir -p /data
        date > /data/message.txt
        echo "Pod started at $(cat /data/message.txt)"
        sleep 3600
    volumeMounts:
    - name: data-volume
      mountPath: /data

  volumes:
  - name: data-volume
    emptyDir: {}
```
Step 2: Apply the Pod: kubectl apply -f pod-with-emptydir.yml

-->verify: kubectl get pods [Expected: Pod should be Running.]

Step 3: Check the File: kubectl exec -it emptydir-demo -- cat /data/message.txt

Step 4: Delete the Pod: kubectl delete pod pod-with-emptydir

Step 5: Recreate the Pod: kubectl apply -f pod-with-emptydir.yml

Wait until it's running:: kubectl get pods

Step 6: Check the File Again: kubectl exec -it emptydir-pod -- cat /data/message.txt

<img width="1895" height="587" alt="image" src="https://github.com/user-attachments/assets/2ce49255-a215-4bca-b673-d34704cf6710" />

**Verify:** Is the timestamp the same or different after recreation?

-->The timestamp is different because an emptyDir volume is tied to the Pod’s lifecycle, not the container, When the Pod is deleted: The emptyDir volume is destroyed & All data inside it is permanently lost

-->When a new Pod is created: A fresh emptyDir volume is created & The container runs again and writes a new timestamp to the file Therefore, the timestamp changes after Pod recreation. So the Old timestamp gone & New timestamp freshly created.

**Note:** “data is lost when Pod is deleted”, But also remember If the container restarts inside the same Pod, the data is NOT lost.

-->emptyDir is a temporary volume that is created when a Pod starts and deleted when the Pod is removed. It is commonly used for sharing data between containers in the same Pod or for storing transient data like cache or logs.

-->How do you prove it's ephemeral?” -->I create a Pod that writes a timestamp to an emptyDir volume, delete the Pod, recreate it, and observe that the timestamp changes—proving data does not persist.

---

### Task 2: Create a PersistentVolume (Static Provisioning)
1. Write a PV manifest with `capacity: 1Gi`, `accessModes: ReadWriteOnce`, `persistentVolumeReclaimPolicy: Retain`, and `hostPath` pointing to `/tmp/k8s-pv-data`
2. Apply it and check `kubectl get pv` — status should be `Available`

-->yes i can see the status as Available, That is because PV is created, But no PersistentVolumeClaim (PVC) is using it yet. When a matching PVC is created and successfully attached to the PV, At the time PV become Bound.

**Steps to follow:**

**Create a PersistentVolume (Static Provisioning):**

Step 1: Create the PV Manifest: vi persistentvolume.yml      
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: static-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/k8s-pv-data
```
Step 2: Apply the PV: kubectl apply -f persistentvolume.yml

Step 3: Verify: kubectl get pv

<img width="1445" height="237" alt="image" src="https://github.com/user-attachments/assets/f5b8304a-f0f0-42e7-89f9-9aa1da14c206" />

**PV Lifecycle status: Q. Why is the status Available?**

-->The PersistentVolume (PV) has been created successfully, but no PersistentVolumeClaim (PVC) is requesting storage from it yet. Since there is no matching PVC, Kubernetes marks the PV as Available, meaning it is ready to be claimed. When a compatible PVC is created (matching storage size, access mode, and storage class if applicable), Kubernetes binds the PVC to this PV, and the PV's status changes to Bound.

-->So Kubernetes marks it as: Available = ready to be claimed

**Access modes to know:**
- `ReadWriteOnce (RWO)` — read-write by a single node
- `ReadOnlyMany (ROX)` — read-only by many nodes
- `ReadWriteMany (RWX)` — read-write by many nodes

**PV Lifecycle:**

<img width="637" height="282" alt="image" src="https://github.com/user-attachments/assets/ed73199d-96cc-497e-a18e-d8f49014852e" />

`hostPath` is fine for learning, not for production.

**Verify:** What is the STATUS of the PV?
-->So status of the pv is Available, Because the PersistentVolume exists but is not yet claimed by any PersistentVolumeClaim (PVC). Once a matching PVC is created, Kubernetes binds them together, and the PV status changes from Available to Bound.

---

### Task 3: Create a PersistentVolumeClaim
1. Write a PVC manifest requesting `500Mi` of storage with `ReadWriteOnce` access
2. Apply it and check both `kubectl get pvc` and `kubectl get pv`
3. Both should show `Bound` — Kubernetes matched them by capacity and access mode

**Steps to follow:**

-->Great! Since your PV is already Available, the next step is to create a PersistentVolumeClaim (PVC) that matches it.

Step 1: Create the PVC Manifest: vi persistentvolumeclaim.yml      
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```
Why 500Mi?
PV capacity: 1Gi
PVC request: 500Mi

-->So A PV can satisfy a PVC request if its capacity is greater than or equal to the requested storage.

Step 2: Apply the PVC: kubectl apply -f persistentvolumeclaim.yml

Step 3: Verify the PVC: kubectl get pvc

Step 4: Verify the PV: kubectl get pv

<img width="675" height="257" alt="image" src="https://github.com/user-attachments/assets/1e503e97-bfb5-437e-a81f-97d38643f19a" />

<img width="1742" height="317" alt="image" src="https://github.com/user-attachments/assets/7977a030-cec2-44d3-bf4e-cfd20c859c3b" />

Q. Why did the PV become Bound?

-->Kubernetes automatically matched the PV and PVC because:

<img width="712" height="202" alt="image" src="https://github.com/user-attachments/assets/dc257389-9dda-4437-89bc-654f131102a7" />

Q: How does Kubernetes decide which PV to bind to a PVC?

-->Kubernetes compares the PVC's requested storage, access modes, and (if specified) storage class with the available PVs. It selects a compatible PV that satisfies the request and binds them automatically.

**Verify:** What does the VOLUME column in `kubectl get pvc` show?
-->It shows demo-pv
**Note:** Issue faced: That PVC status showed pending to resolve added following line of code: **storageClassName: ""** under **spec** 

**Note:** #If we dont dfine it bydefault it shows storageClass=standard, So due to this we cas see PVC status as pending, Due to unmatch criteria with PV, So Kubernetes cannot match them

-->And important key Rule is PVC and PV must match on StorageClass (if specified)

---

### Task 4: Use the PVC in a Pod — Data That Survives
1. Write a Pod manifest that mounts the PVC at `/data` using `persistentVolumeClaim.claimName`
2. Write data to `/data/message.txt`, then delete and recreate the Pod
3. Check the file — it should contain data from both Pods

**Verify:** Does the file contain data from both the first and second Pod?
-->yes file contens the data of both the pods, This is happened because, PVC is backed by a PersistentVolume & Pod is ephemeral, but storage is not, So when Pod is deleted Container dies, But volume data stays, So New Pod mounts same PVC and then we can sees old data.

**Steps to follow:**

-->Prerequisit: pv and pvc already created and bound with each other as well.

-->Create pod manifest: vi pod-manifest-with-pvc.yml       [pod-manifest-with-pvc.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-55/k8s-manifest-files/pod-manifest-with-pvc.yml)

-->apply the kubectl: kubectl apply -f pod-manifest-with-pvc.yml

-->verify the created pod: kubectl get pods

-->verfy the created pvc: kubectl get pvc

-->Go inside nodeand check the content of the message file: kubectl exec -it pvc-pod -- cat /data/message.txt

-->Now delete the pod: kubectl delete pod pvc-pod

-->Now again go inside pod file and edit it: vi pod-manifest-with-pvc.yml     -->Edit the file and save 

-->Apply again: kubectl apply -f pod-manifest-with-pvc.yml

-->Now again go inside node and check the message file content: kubectl exec -it pvc-pod -- cat /data/message.txt

<img width="1415" height="642" alt="image" src="https://github.com/user-attachments/assets/53d7d829-4657-4ab4-9f75-d2871bdede00" />

---

### Task 5: StorageClasses and Dynamic Provisioning
1. Run `kubectl get storageclass` and `kubectl describe storageclass`
2. Note the provisioner, reclaim policy, and volume binding mode
3. With dynamic provisioning, developers only create PVCs — the StorageClass handles PV creation automatically

**Verify:** What is the default StorageClass in your cluster?

-->Default StorageClass = the one marked with (default)

-->The default StorageClass is the one annotated with (default) in kubectl get storageclass., It is used automatically when a PVC does not specify a storageClassName.

**Steps to follow:**

-->Step 1: List StorageClasses: kubectl get storageclass

-->Step 2: Identify Default StorageClass: Look for (default) next to the name, Just like standard (default) [standard is the default StorageClass]

-->Step 3: Describe the StorageClass: kubectl describe storageclass standard

**Now let see What Each Field Means:**

-->**Provisioner**: rancher.io/local-path = This tells Kubernetes: "Who will actually create the volume?"

-->Other examples: kubernetes.io/aws-ebs, kubernetes.io/gce-pd, kubernetes.io/no-provisioner (manual) etc.

-->**Reclaim Policy:** Delete = What happens when PVC is deleted? then Delete → Volume also deleted & Retain → Volume kept (manual cleanup needed)

-->******Volume Binding Mode**:** WaitForFirstConsumer = "When is the volume created? -->Answer is **Immediate** → created instantly **WaitForFirstConsumer** → created only, when Pod is scheduled, This avoids wrong node placement (VERY important in real clusters).

-->**Step 4: Dynamic Provisioning:** Earlier (static provisioning): Admin creates PV, Dev creates PVC & Now(dynamic provisioning): Dev creates PVC only, StorageClass automatically creates PV

<img width="1916" height="348" alt="image" src="https://github.com/user-attachments/assets/c6ed0c0d-e5ce-4645-929e-7b12c23bb41a" />

---

### Task 6: Dynamic Provisioning
1. Write a PVC manifest that includes `storageClassName: standard` (or your cluster's default)
2. Apply it — a PV should appear automatically in `kubectl get pv`
3. Use this PVC in a Pod, write data, verify it works

**Steps to follow:**

-->To verify the storage class details: kubectl get storageclass

-->Now create dynamic-provisioning-pvc yml file: vi dynamic-provisioning-pvc.yml   
[dynamic-provisioning-pvc.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-55/k8s-manifest-files/dynamic-provisioning-pvc.yml)

-->Apply the kubectl: kubectl apply -f dynamic-provisioning-pvc.yml

-->kubectl get pvc      --->Here we can see status as pending due to following parameter VOLUMEBINDINGMODE = WaitForFirstConsumer, So to satisfied this have to created pod then status will change

-->kubectl get pv       --->Here we can see status as pending due to following parameter VOLUMEBINDINGMODE = WaitForFirstConsumer, So to satisfied this have to created pod then status will change

-->Now create dynamic-provisioning-pod yml file: vi dynamic-provisioning-pod.yml 
[dynamic-provisioning-pod.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-55/k8s-manifest-files/dynamic-provisioning-pod.yml)

-->Apply the kubectl: kubectl apply -f dynamic-provisioning-pod.yml

-->kubectl get pvc

-->kubectl get pv

-->Then verify the data inside node: kubectl exec -it dynamic-pod -- cat /data/message.txt

<img width="1722" height="763" alt="image" src="https://github.com/user-attachments/assets/529f64b9-d4ed-493a-9d4e-fa33946dd7dd" />

**Verify:** How many PVs exist now? Which was manual, which was dynamic?
-->Because StorageClass uses WaitForFirstConsumer, so PV is created only when a Pod uses the PVC, And there were 2 pvc's available one is **demo-pv** which is manual one & the other one is **dynamic-pvc** this one is dynamic pvc which is created after pod creation

**Note:** When using a StorageClass with WaitForFirstConsumer, the PVC remains in Pending state until a Pod is scheduled. This ensures the volume is provisioned in the correct node context. Once a Pod uses the PVC, Kubernetes dynamically creates and binds the PV.

**Let see whay it is called dynamic-pvc?**
-->In static provisioning, PersistentVolumes are created manually in advance and Kubernetes binds them to claims. In dynamic provisioning, developers only create a PVC, and Kubernetes automatically provisions a PV using a StorageClass. If the StorageClass uses WaitForFirstConsumer, the PV is created only when a Pod consumes the PVC, which is why the claim initially stays in Pending state.

---

### Task 7: Clean Up
1. Delete all pods first
2. Delete PVCs — check `kubectl get pv` to see what happened
3. The dynamic PV is gone (Delete reclaim policy). The manual PV shows `Released` (Retain policy).
4. Delete the remaining PV manually

**Steps to follow:**

-->kubectl get pods

-->kubectl delete pod --all

-->kubectl get pods

-->kubectl get pvc

-->kubectl delete vpc --all

-->kubectl get pvc

-->kubectl get pv

-->kubectl delete pv --all

-->kubectl get pv

<img width="1407" height="628" alt="image" src="https://github.com/user-attachments/assets/c93b2c24-f472-47f5-aaa3-ca8e2fb5c114" />

**Verify:** Which PV was auto-deleted and which was retained? Why?

-->Dynamic PV → deleted automatically (ReclaimPolicy: Delete)

-->Manual PV → moved to Released state (ReclaimPolicy: Retain)

-->Manual PV must be deleted manually

**Note:** Reclaim policy controls what happens to storage after a PVC is deleted.

-->**Delete** → removes storage automatically (used in dynamic provisioning)

-->**Retain** → keeps data for manual recovery (used in critical systems)

---

## Hints
- PVs are cluster-wide (not namespaced), PVCs are namespaced
- PV status: `Available` -> `Bound` -> `Released`
- If a PVC stays `Pending`, check for matching capacity and access modes
- `hostPath` data is lost if the Pod moves to a different node
- `storageClassName: ""` disables dynamic provisioning
- Reclaim policies: `Retain` (keep data) vs `Delete` (remove data)

---

## Documentation
Create `day-55-persistent-volumes.md` with:
- Why containers need persistent storage
- What PVs and PVCs are and how they relate
- Static vs dynamic provisioning
- Access modes and reclaim policies

---

## Submission
1. Add `day-55-persistent-volumes.md` to `2026/day-55/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Learned Kubernetes Persistent Volumes and PVCs today. Proved container data is ephemeral, then fixed it with PVs. Also explored dynamic provisioning with StorageClasses."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
