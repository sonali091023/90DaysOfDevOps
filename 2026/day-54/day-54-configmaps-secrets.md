# Day 54 – Kubernetes ConfigMaps and Secrets

## Task
Your application needs configuration — database URLs, feature flags, API keys. Hardcoding these into container images means rebuilding every time a value changes. Kubernetes solves this with ConfigMaps for non-sensitive config and Secrets for sensitive data.

---

## Expected Output
- ConfigMaps created from literals and from a file
- Secrets created and consumed in a Pod
- A markdown file: `day-54-configmaps-secrets.md`

---

## Challenge Tasks

### Task 1: Create a ConfigMap from Literals
1. Use `kubectl create configmap` with `--from-literal` to create a ConfigMap called `app-config` with keys `APP_ENV=production`, `APP_DEBUG=false`, and `APP_PORT=8080`
2. Inspect it with `kubectl describe configmap app-config` and `kubectl get configmap app-config -o yaml`
3. Notice the data is stored as plain text — no encoding, no encryption

**Verify:** Can you see all three key-value pairs?

-->Yes — i can see clearly see all three key-value pairs: APP_ENV=production, APP_DEBUG=false, APP_PORT=8080

**Steps to perform:**

-->kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_DEBUG=false --from-literal=APP_PORT=8080

-->kubectl describe configmap app-config

-->kubectl get configmap app-config -o yaml

<img width="1900" height="971" alt="image" src="https://github.com/user-attachments/assets/fdd02ce9-82b5-42b7-9572-ca968e3a24d1" />

---

### Task 2: Create a ConfigMap from a File
1. Write a custom Nginx config file that adds a `/health` endpoint returning "healthy"
2. Create a ConfigMap from this file using `kubectl create configmap nginx-config --from-file=default.conf=<your-file>`
3. The key name (`default.conf`) becomes the filename when mounted into a Pod

**Verify:** Does `kubectl get configmap nginx-config -o yaml` show the file contents?
-->yes, i can see the full Nginx config content under data.default.conf.

**Steps to perform:**
-->Create file vi default.conf
-->kubectl create configmap nginx-config --from-file=default.conf=default.conf   [Left side default.conf = key name & Right side default.conf = your local file]
-->To inspect the config-map: kubectl get configmap nginx-config -o yaml
<img width="1607" height="640" alt="image" src="https://github.com/user-attachments/assets/49cec14f-cf5d-401d-bec4-c724534a0615" />
-->So here what is happening is The file content becomes the value, The key (default.conf) becomes the filename when mounted into a Pod so inside container it will appear like "/etc/nginx/conf.d/default.conf"

[default.conf](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-54/k8s-mainfest-files/default.conf)

---

### Task 3: Use ConfigMaps in a Pod
1. Write a Pod manifest that uses `envFrom` with `configMapRef` to inject all keys from `app-config` as environment variables. Use a busybox container that prints the values.
2. Write a second Pod manifest that mounts `nginx-config` as a volume at `/etc/nginx/conf.d`. Use the nginx image.
3. Test that the mounted config works: `kubectl exec <pod> -- curl -s http://localhost/health`

Use environment variables for simple key-value settings. Use volume mounts for full config files.

**Verify:** Does the `/health` endpoint respond?

**Steps to follow:**

-->vi busybox-env-pod.yml  [busybox-env-pod.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-54/k8s-mainfest-files/busybox-env-pod.yaml)

-->kubectl apply -f busybox-env-pod.yml

-->kubectl get pods

-->kubectl logs busybox-env

-->kubectl apply -f nginx-config-pod.yaml

-->kubectl exec -it nginx-config-pod -- sh

-->curl -s http://localhost/health [In caseneed to install apt update && apt install -y curl] OR wget -qO- http://localhost/health

-->If config-map not applied use command: kubectl exec nginx-config-pod -- cat /etc/nginx/conf.d/default.conf

-->If pod not running use command: kubectl get pods & to get more details use command: kubectl describe pod nginx-config-pod

<img width="1203" height="426" alt="image" src="https://github.com/user-attachments/assets/d3c80c0c-24ad-4aca-b7c2-b315c69987ba" />
<img width="1918" height="803" alt="image" src="https://github.com/user-attachments/assets/1d2c09ba-3dc7-4d17-8a7e-266d5809a310" />
<img width="1520" height="365" alt="image" src="https://github.com/user-attachments/assets/ebb420f5-8a7b-4105-9db6-789fa93c035e" />
<img width="1640" height="980" alt="image" src="https://github.com/user-attachments/assets/0c88bcc9-077c-4768-88d5-412231f8fb26" />
<img width="1237" height="282" alt="image" src="https://github.com/user-attachments/assets/00223cab-2425-4d5e-802d-3d2e3ae8a1d5" />

Note: **envFrom** → injects key-value pairs as environment variables & **volumeMounts** → injects files into container filesystem

-->This is exactly how real apps load: ENV → DB URLs, ports, flags

-->Files → Nginx configs, app configs, certificates

**Note:** Pods are immutable

-->Lets see waht we did in this taask:

-->**Part 1: ConfigMap → Environment Variables:** Created a **ConfigMap: app-config** then Injected it into a **Pod** using **envFrom**, then what happened inside container it prints the valuse with the help of echo and we saw them in the logs as well, So this proves ConfigMap → ENV injection works.

-->**Part 2: ConfigMap → File (Volume Mount):** Created a file **default.conf** (custom Nginx config) Stored it in ConfigMap **nginx-config** & then Mounted it into the Pod, Then k8s Took your file & Injected it into container at location "/etc/nginx/conf.d/default.conf"

**Important Rule:**

-->ConfigMap key = filename

-->ConfigMap value = file content

-->**Part 3: Nginx used your config:** custom config added, So when Nginx started It loaded config from "/etc/nginx/conf.d" & Your file overrode default behavior

-->**Part 4: Testing inside the Pod:** Here we used command to go inside pod: **kubectl exec -it nginx-config-pod -- sh** & then used command **curl http://localhost/health** After this exection of the command we can see healthy as output it measn it is working fine.

---

### Task 4: Create a Secret
  1. Use `kubectl create secret generic db-credentials` with `--from-literal` to store `DB_USER=admin` and `DB_PASSWORD=s3cureP@ssw0rd`
  2. Inspect with `kubectl get secret db-credentials -o yaml` — the values are base64-encoded
  3. Decode a value: `echo '<base64-value>' | base64 --decode`

**Steps to follow:**

-->Create the Secret: kubectl create secret generic db-credentials --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cureP@ssw0rd

-->Check secret exists: kubectl get secret db-credentials

-->Inspect the Secret: kubectl get secret db-credentials -o yaml [**Note:** Values are under data, They are base64-encoded, not plaintext]

-->Decode a value: echo 'YWRtaW4=' | base64 --decode & echo 'czNjdXJlUEBzc3cwcmQ=' | base64 --decode

[pod-secret.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-54/k8s-mainfest-files/pod-secret.yml)

**Note:** Kubernetes stores Secrets as base64-encoded in etcd (not encrypted by default)

-->When used in Pods Env vars → automatically decoded & Volume mounts → automatically decoded 

-->used for Fasr decoding: kubectl get secret db-credentials -o jsonpath="{.data.DB_USER}" | base64 --decode

**base64 is encoding, not encryption.** Anyone with cluster access can decode Secrets. The real advantages are RBAC separation, tmpfs storage on nodes, and optional encryption at rest.

**Verify:** Can you decode the password back to plaintext?

-->Yes, For that we use command: echo 'czNjdXJlUEBzc3cwcmQ=' | base64 --decode -->o/p is: s3cureP@ssw0rd

**Important Understanding:**

-->Base64 = encoding, not security, Anyone with kubectl access + RBAC permission can decode it

-->Real security comes from: RBAC (who can read secrets), Encryption at rest (etcd), External secret managers (Vault, AWS Secrets Manager, etc.)

<img width="1692" height="411" alt="image" src="https://github.com/user-attachments/assets/c1e6cdc6-f6d2-4ecc-8ee2-ca19dab7e2a0" />

---

### Task 5: Use Secrets in a Pod
1. Write a Pod manifest that injects `DB_USER` as an environment variable using `secretKeyRef`
2. In the same Pod, mount the entire `db-credentials` Secret as a volume at `/etc/db-credentials` with `readOnly: true`
3. Verify: each Secret key becomes a file, and the content is the decoded plaintext value

**To verify follow the steps:**

-->Exec into the Pod: kubectl exec -it secret-demo-pod -- sh

-->Check environment variable: echo $DB_USER

-->Check mounted files: ls /etc/db-credentials [Here each key become file]

-->Read file content: cat /etc/db-credentials/DB_USER & cat /etc/db-credentials/DB_PASSWORD

**Verify:** Are the mounted file values plaintext or base64?
-->Mounted secret values are basically Plaintext, That is because in Kubernetes Secrets are stored in etcd as base64-encoded, But when injected as env vars & mounted as files, So due to this Kubernetes automatically decodes them.

**Note:** base64 ≠ encryption (just encoding) Anyone with access to the Pod can read secrets, For real security: Use RBAC, Use external secret managers (Vault, AWS Secrets Manager) etc.

<img width="1547" height="323" alt="image" src="https://github.com/user-attachments/assets/d41b3319-f65b-45a9-838a-2879f2eed445" />

**Debugging Checklist:** If in case secrect is not set properly & secret not appearing in Pod

-->Check if Secret exists: kubectl get secret db-credentials

-->To fix it run the command: kubectl create secret generic db-credentials --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cureP@ssw0rd

-->kubectl describe secret db-credentials

-->Check Pod events: kubectl describe pod secret-demo-pod

-->Incase Pod created before Secret then Kubernetes does NOT always auto-refresh env vars & If Secret was created AFTER Pod then we have to delete tyhe pod and recreate it: kubectl delete pod secret-demo-pod & kubectl apply -f pod.yaml

-->Check volume mount path: kubectl exec -it secret-demo-pod -- sh then run ls /etc/db-credentials

-->If Volume name mismatch, Like volumeMounts & volumes If different → volume won’t mount.

-->if in case Container crashed? then use command: kubectl get pods if in case facing CrashLoopBackOff To check more use command kubectl logs secret-demo-pod [Sometimes app crashes before you can check env/volume]

**Note:** Env vars from Secrets are NOT updated dynamically & Volume-mounted Secrets ARE updated automatically.

---

### Task 6: Update a ConfigMap and Observe Propagation
1. Create a ConfigMap `live-config` with a key `message=hello` 
2. Write a Pod that mounts this ConfigMap as a volume and reads the file in a loop every 5 seconds 
3. Update the ConfigMap: `kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'`
4. Wait 30-60 seconds — the volume-mounted value updates automatically
5. Environment variables from earlier tasks do NOT update — they are set at pod startup only

**Steps to follow:**

-->Create ConfigMap: kubectl create configmap live-config --from-literal=message=hello

-->Create pod: vi pod-read-file-every-five-sec.yml  [pod-read-file-every-five-sec.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-54/k8s-mainfest-files/pod-read-file-every-five-sec.yml)

-->kubectl apply -f pod-read-file-every-five-sec.yml.yaml

-->Watch the output: kubectl logs -f configmap-live-pod

<img width="1885" height="722" alt="image" src="https://github.com/user-attachments/assets/4559b5d4-4a58-4129-947e-97112d1412a7" />

-->Update the ConfigMap: kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'

-->After chnages Wait ~30–60 seconds, And then Watch the output: kubectl logs -f configmap-live-pod [Message will update automatically]

<img width="1906" height="806" alt="image" src="https://github.com/user-attachments/assets/b76df592-ba8d-47d7-843c-42e09c7685d0" />

**Verify:** Did the volume-mounted value change without a pod restart?

-->yes, The file /etc/config/message gets updated automatically, No Pod restart needed.

**Note:** Menthod Volume mount Updates automatically whereas Environment var does not u[date automatically & Env vars are fixed at Pod startup 
<img width="272" height="261" alt="image" src="https://github.com/user-attachments/assets/56754190-4752-4456-850c-4aacc7ec834a" />

-->So what is happening is Kubernetes updates mounted ConfigMaps using a background sync (~30 sec), It replaces the file atomically inside the container & Your app sees the new value automatically (if it rereads the file)

-->Real world example is Use volume mounts for dynamic configs (feature flags, toggles) & Use env vars for static configs (DB host, ports) etc.

---

### Task 7: Clean Up
Delete all pods, ConfigMaps, and Secrets you created.

<img width="1330" height="962" alt="image" src="https://github.com/user-attachments/assets/a21dfc86-bc26-4ca7-9446-4555a3b670a9" />

**What is kube-root-ca.crt?**

-->kube-root-ca.crt is a default ConfigMap automatically created by Kubernetes in every namespace.

-->It contains the cluster’s root CA certificate, Used for secure communication with the API server, Mounted into Pods so they can trust the Kubernetes API

-->So yes, it’s expected, but it’s not the one you created

---

## Hints
- `--from-literal=KEY=VALUE` for command-line values, `--from-file=key=filename` for file contents
- `envFrom` injects all keys; `env` with `valueFrom` injects individual keys
- `echo -n 'value' | base64` — always use `-n` to avoid encoding a trailing newline
- Volume-mounted ConfigMaps/Secrets auto-update; environment variables do not
- `kubectl get secret <name> -o jsonpath='{.data.KEY}' | base64 --decode` extracts and decodes a value

---

## Documentation
Create `day-54-configmaps-secrets.md` with:
- What ConfigMaps and Secrets are and when to use each
- The difference between environment variables and volume mounts
- Why base64 is encoding, not encryption
- How ConfigMap updates propagate to volumes but not env vars

---

## Submission
1. Add `day-54-configmaps-secrets.md` to `2026/day-54/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Learned Kubernetes ConfigMaps and Secrets today. Injected config as environment variables and volume mounts, and discovered that base64 encoding is not encryption."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
