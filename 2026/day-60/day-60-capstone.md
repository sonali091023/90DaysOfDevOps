# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

## Task
Ten days of Kubernetes — clusters, Pods, Deployments, Services, ConfigMaps, Secrets, storage, StatefulSets, resource management, autoscaling, and Helm. Today you put it all together. Deploy a real WordPress + MySQL application using every major concept you have learned.

---

## Expected Output
- A complete WordPress + MySQL stack in a `capstone` namespace
- Self-healing and data persistence verified
- A markdown file: `day-60-capstone.md`
- Screenshot of the running WordPress site and `kubectl get all -n capstone`

---

## Challenge Tasks

### Task 1: Create the Namespace (Day 52)
1. Create a `capstone` namespace
2. Set it as your default: `kubectl config set-context --current --namespace=capstone`

**Steps to follow:**

-->Create the capstone Namespace: kubectl create namespace capstone

-->To verify namespaces: kubectl get namespaces

-->Set capstone as Default Namespace: kubectl config set-context --current --namespace=capstone      [This makes capstone your default namespace, so you don’t need to add -n capstone every time.]

-->Verify Default Namespace: kubectl config view --minify | grep namespace

-->Create a pod without specifying namespace:: kubectl run test-pod --image=nginx

-->Then check: kubectl get pods                                                                      [If you see test-pod, it means you're working inside the capstone namespace by default.]

-->Delete the created pod: kubectl delete pod test-pod
<img width="1787" height="845" alt="image" src="https://github.com/user-attachments/assets/bfa57d38-f988-43df-9f1f-d132f7de45ff" />

---

### Task 2: Deploy MySQL (Days 54-56)
1. Create a Secret with `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` using `stringData`
2. Create a Headless Service (`clusterIP: None`) for MySQL on port 3306
3. Create a StatefulSet for MySQL with:
   - Image: `mysql:8.0`
   - `envFrom` referencing the Secret
   - Resource requests (cpu: 250m, memory: 512Mi) and limits (cpu: 500m, memory: 1Gi)
   - A `volumeClaimTemplates` section requesting 1Gi of storage, mounted at `/var/lib/mysql`
4. Verify MySQL works: `kubectl exec -it mysql-0 -- mysql -u <user> -p<password> -e "SHOW DATABASES;"`

**Steps to follow:**

-->Make sure you're in the correct namespace: kubectl config view --minify | grep namespace

-->Create MySQL Secret (using stringData): vi mysql-secret.yaml                      [mysql-secret.yaml]()

-->kubectl apply -f mysql-secret.yaml

-->Create Headless Service: vi mysql-service.yaml                                    [mysql-service.yaml]()

-->kubectl apply -f mysql-service.yaml

-->kubectl get svc

-->Create MySQL StatefulSet: vi mysql-statefulset.yaml                               [mysql-statefulset.yaml]()

-->kubectl apply -f mysql-statefulset.yaml

-->Wait for Pod to be Ready: kubectl get pods -w

-->Verify MySQL is Working: kubectl exec -it mysql-0 -- mysql -u wpuser -pwppass -e "SHOW DATABASES;"
<img width="1907" height="886" alt="image" src="https://github.com/user-attachments/assets/55e72199-3896-4b00-8785-a7704918894c" />
<img width="427" height="271" alt="image" src="https://github.com/user-attachments/assets/f4fae7d3-c363-4fd0-a96a-2aee91383a52" />

**Verify:** Can you see the `wordpress` database?

-->Yes i can see Workpress database, Also Secret worked, Env vars injected correctly, MySQL initialized properly etc.

**Common Issues may face:**

-->Pod stuck in Pending: kubectl get pvc

-->Pod CrashLoopBackOff: kubectl logs mysql-0

-->Can't connect to MySQL: Make sure your UN & PSWD is correct.

---

### Task 3: Deploy WordPress (Days 52, 54, 57)
1. Create a ConfigMap with `WORDPRESS_DB_HOST` set to `mysql-0.mysql.capstone.svc.cluster.local:3306` and `WORDPRESS_DB_NAME`
2. Create a Deployment with 2 replicas using `wordpress:latest` that:
   - Uses `envFrom` for the ConfigMap
   - Uses `secretKeyRef` for `WORDPRESS_DB_USER` and `WORDPRESS_DB_PASSWORD` from the MySQL Secret
   - Has resource requests and limits
   - Has a liveness probe and readiness probe on `/wp-login.php` port 80
3. Wait until both pods show `1/1 Running`

**Steps to follow:**

-->Confirm namespace: kubectl config view --minify | grep namespace

-->vi mysql-secret.yaml

-->kubectl apply -f mysql-secret.yaml

-->kubectl get secret

-->vi mysql-service.yaml

-->kubectl apply -f mysql-service.yaml

-->kubectl get svc

-->kubectl vi mysql-statefulset.yaml

-->kubectl apply -f mysql-statefulset.yaml

-->kubectl get statefulset

kubectl vi wordpress-config.yaml

-->kubectl apply -f wordpress-config.yaml

-->kubectl get cm

-->vi wordpress-deployment.yaml

-->kubectl apply -f wordpress-deployment.yaml

-->kubectl get deployment

kubectl vi wordpress-secret.yaml

-->kubectl apply -f wordpress-secret.yaml

-->kubectl get secret

<img width="1607" height="882" alt="image" src="https://github.com/user-attachments/assets/61aa14dd-1cd2-40ba-94e9-aa9fb86484f2" />
-->After wait for sometime we can see container Ready 1/1 status,
<img width="1381" height="637" alt="image" src="https://github.com/user-attachments/assets/3143f748-bd6f-41c0-8f53-139883129539" />

**Verify:** Are both WordPress pods running and ready?
-->Yes
<img width="1381" height="637" alt="image" src="https://github.com/user-attachments/assets/aa7a51f7-e84c-4d7f-992a-c59b4fd44455" />

---

### Task 4: Expose WordPress (Day 53)
1. Create a NodePort Service on port 30080 targeting the WordPress pods
2. Access WordPress in your browser:
   - Minikube: `minikube service wordpress -n capstone`
   - Kind: `kubectl port-forward svc/wordpress 8080:80 -n capstone`
3. Complete the setup wizard and create a blog post

**Steps to follow:**
-->Create NodePort Service: vi wordpress-service.yaml       [wordpress-service.yml]()
-->kubectl apply -f wordpress-service.yaml
-->Verify Service: kubectl get svc -n capstone
-->Access WordPress
**Option 1: Minikube:** minikube service wordpress -n capstone
**Option 2: Kind / Other clusters:** nohup kubectl port-forward svc/wordpress 8081:80 -n capstone > pf.log 2>&1 &  [Note: > pf.log 2>&1 &: this part will send the unwanted o/p to unwanted place or that data itself is unwanted which is no more needed]
-->Now check the same in the browser: http://localhost:8081

<img width="1917" height="967" alt="image" src="https://github.com/user-attachments/assets/aa4d1ca5-8511-42ec-939a-25a56cb1d186" />
<img width="1907" height="955" alt="image" src="https://github.com/user-attachments/assets/2678ae9a-9ec9-4895-a72d-e6023d9511be" />
<img width="1906" height="851" alt="image" src="https://github.com/user-attachments/assets/1461eac9-bc87-4293-9b2d-8d4bff850ceb" />
<img width="1917" height="917" alt="image" src="https://github.com/user-attachments/assets/b543f565-0440-45c6-bfd3-f74b36c485c9" />

**Verify:** Can you see the WordPress setup page?
-->Yes

---

### Task 5: Test Self-Healing and Persistence
1. Delete a WordPress pod — watch the Deployment recreate it within seconds. Refresh the site.
<img width="1497" height="402" alt="image" src="https://github.com/user-attachments/assets/a46cc84d-ec6e-47c3-8243-b36e8535dcfb" />

3. Delete the MySQL pod: `kubectl delete pod mysql-0 -n capstone` — watch the StatefulSet recreate it
<img width="1302" height="235" alt="image" src="https://github.com/user-attachments/assets/5a762fb3-5112-4da0-b52e-3b43f935cca2" />
5. After MySQL recovers, refresh WordPress — your blog post should still be there

**Verify:** After deleting both pods, is your blog post still there?

-->After deleting both pods WordPress pod → recreated by Deployment, MySQL pod → recreated by StatefulSet & Data → stored in Persistent Volume

-->So when you refresh your WordPress site Your blog post should still be there, This is happening because, Pods are temporary but Data in PVC is permanent, Even though MySQL pod was deleted It reattached to the same storage → data not lost.

**Note:** Yes, after deleting both WordPress and MySQL pods, the blog post is still present because Kubernetes recreated the pods and the data persisted using a Persistent Volume.

---

### Task 6: Set Up HPA (Day 58)
1. Write an HPA manifest targeting the WordPress Deployment with CPU at 50%, min 2, max 10 replicas
2. Apply and check: `kubectl get hpa -n capstone`
3. Run `kubectl get all -n capstone` for the complete picture

**Steps to follow:**

-->Create HPA YAML: vi wordpress-hpa.yaml

-->kubectl apply -f wordpress-hpa.yaml

-->kubectl get hpa -n capstone

-->Full cluster view: kubectl get all -n capstone     [We can see Deployment (wordpress), Pods (2 running), Service, HPA, MySQL StatefulSet etc.]
<img width="1175" height="745" alt="image" src="https://github.com/user-attachments/assets/75db220e-5335-4e8c-a594-993ea3b2b7ca" />

**Note:** HPA works only when Metrics server is installed. 

**Verify:** Does the HPA show correct min/max and target?

-->Yes, the HPA shows correct min replicas (2), max replicas (10), and CPU target utilization (50%).

---

### Task 7: (Bonus) Compare with Helm (Day 59)
1. Install WordPress using `helm install wp-helm bitnami/wordpress` in a separate namespace
2. Compare: how many resources did each approach create? Which gives more control?
3. Clean up the Helm deployment

**Steps to follow:**

-->Create separate namespace: kubectl create namespace helm-lab

-->Install WordPress using Helm: helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update

-->Now install it: helm install wp-helm bitnami/wordpress -n helm-lab

--<Check what helm created: kubectl get all -n helm-lab     [So we can see MANY resources automatically created, like: Deployment / StatefulSet, Service, Secret, PVC, ConfigMap etc.]

-->Compare with your manual setup: kubectl get all -n capstone     [Here as well we created things by ourself: Deployment (WordPress), StatefulSet (MySQL), Service, ConfigMap, Secret, PVC, HPA etc.]

<img width="1740" height="967" alt="image" src="https://github.com/user-attachments/assets/926666a4-1742-4414-b88e-e5fca556fe7e" />
<img width="1827" height="962" alt="image" src="https://github.com/user-attachments/assets/df24dcfa-2e34-4dae-b818-805780686db9" />

-->Clean up Helm deployment: helm uninstall wp-helm -n helm-lab

-->Delete namespace: kubectl delete namespace helm-lab
<img width="1006" height="31" alt="image" src="https://github.com/user-attachments/assets/5e18df61-a255-4fe0-8029-92532e411673" />
<img width="1087" height="82" alt="image" src="https://github.com/user-attachments/assets/b385a67c-966e-43e9-af77-4a84814416c7" />

**Note:** IN manual way we have more control over helm chart more efforts as well, But in Helm automatically creates: WordPress + MySQL setup, Secrets (auto-generated passwords), PVCs, Services, Configs etc. 

-->So helm way is Very fast & easy, But Less visibility/control unless customized.

-->The Helm deployment created more resources automatically compared to the manual setup. Helm simplifies deployment and is faster, but the manual approach provides more control and deeper understanding of Kubernetes components.

---

### Task 8: Clean Up and Reflect
1. Take a final look: `kubectl get all -n capstone`
2. Count the concepts you used: Namespace, Secret, ConfigMap, PVC, StatefulSet, Headless Service, Deployment, NodePort Service, Resource Limits, Probes, HPA, Helm — twelve concepts in one deployment
3. Delete the namespace: `kubectl delete namespace capstone`
4. Reset default: `kubectl config set-context --current --namespace=default`

**Steps to follow:**

-->To check all the namespaces: kubectl get all -n capstone                                          [We can see everything you created: Pods, Services, Deployment, StatefulSet, HPA etc.]

-->Following Concepts used successfully: Namespace, Secret, ConfigMap, PVC, StatefulSet, Headless Service, Deployment, NodePort Service, Resource Limits, Probes (liveness/readiness), HPA & Helm etc.

-->Delete the namespace: kubectl delete namespace capstone

-->Watch deletion: kubectl get ns

-->Verify everything is gone: kubectl get all -n capstone

-->Reset namespace: kubectl config set-context --current --namespace=default
<img width="1222" height="846" alt="image" src="https://github.com/user-attachments/assets/e8b29a75-5e23-45d8-8fa8-f15e4bc00667" />

**Verify:** Did deleting the namespace remove everything?
-->Yes, deleting the namespace removed everything.

## Hints
- If MySQL takes long to start, check: `kubectl logs mysql-0 -n capstone`
- `WORDPRESS_DB_HOST` must match the StatefulSet DNS pattern: `<pod>.<service>.<namespace>.svc.cluster.local`
- WordPress probes may fail initially — `initialDelaySeconds` gives it time to boot
- If PVC stays Pending, check `kubectl get storageclass`
- `nodePort` must be in range 30000-32767
- The Bitnami chart uses MariaDB instead of MySQL — compatible but not identical

---

## Documentation
Create `day-60-capstone.md` with:
- Architecture of your deployment (which resources connect to which)
- Results of self-healing and persistence tests
- A table mapping each concept to the day you learned it
- Reflection: what was hardest, what clicked, what you would add for production

---

## Submission
1. Add `day-60-capstone.md` to `2026/day-60/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Completed the Kubernetes capstone — deployed WordPress + MySQL using twelve K8s concepts: Namespaces, Deployments, StatefulSets, Services, ConfigMaps, Secrets, PVCs, resource limits, probes, and HPA. Ten days of learning, one real application."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
