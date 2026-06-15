# Day 79 -- Creating a Custom Helm Chart for AI-BankApp

## Task
Yesterday you deployed MySQL with a community Helm chart. Today you build a custom Helm chart for the AI-BankApp itself -- converting the 12 raw YAML files from the `k8s/` directory into a templated, configurable, reusable Helm chart.

The AI-BankApp (https://github.com/TrainWithShubham/AI-BankApp-DevOps, branch `feat/gitops`) has three services: the Spring Boot banking app, a MySQL database, and an Ollama AI chatbot. By the end of today, all of this will be deployable with a single `helm install` command.

---

## Expected Output
- A custom Helm chart that deploys the entire AI-BankApp stack
- Templates for Deployments, Services, ConfigMap, Secrets, PVCs, and HPA
- Init containers and lifecycle hooks preserved from the original manifests
- Chart validated with `helm lint` and `helm template`
- A markdown file: `day-79-custom-charts.md`

---

## Challenge Tasks

### Task 1: Scaffold the Chart and Study the Raw Manifests
Make sure you have the AI-BankApp repo cloned:
```bash
cd AI-BankApp-DevOps
```

Study the raw manifests you are converting:
```bash
ls k8s/
```

Map each file to what it does:

| File | Purpose |
|------|---------|
| `namespace.yml` | Creates `bankapp` namespace |
| `configmap.yml` | MySQL host, port, database, Ollama URL |
| `secrets.yml` | MySQL credentials (base64 encoded) |
| `pv.yml` | StorageClass (gp3 via EBS CSI) |
| `pvc.yml` | PVCs for MySQL (5Gi) and Ollama (10Gi) |
| `bankapp-deployment.yml` | BankApp with init containers, probes, envFrom |
| `mysql-deployment.yml` | MySQL with EBS volume mount, probes |
| `ollama-deployment.yml` | Ollama with postStart model pull, probes |
| `service.yml` | ClusterIP services for all 3 components |
| `hpa.yml` | HPA for BankApp (2-4 replicas, 70% CPU) |
| `gateway.yml` | Envoy Gateway + HTTPRoute + TLS |
| `cert-manager.yml` | Let's Encrypt ClusterIssuer |

Now scaffold a Helm chart:
```bash
mkdir helm-chart && cd helm-chart
helm create bankapp
```

Delete the generated template files -- you will write your own from the raw manifests:
```bash
rm -rf bankapp/templates/*.yaml bankapp/templates/tests/
```

Keep `_helpers.tpl` and `NOTES.txt` -- you will customize them.

**Steps to follow:**

Step 1: Move into the Project: cd AI-BankApp-DevOps

Step 2: Examine the Existing Kubernetes Manifests: ls k8s

<img width="1917" height="227" alt="image" src="https://github.com/user-attachments/assets/3af48412-84cd-4fb6-adbd-f8025b9ac60a" />

Step 3: Understand What Each Manifest Does: Before converting anything into Helm templates, understand the purpose of every file.

-->namespace.yml: Creates a dedicated namespace:

<img width="532" height="437" alt="image" src="https://github.com/user-attachments/assets/5913b6a4-1f77-4537-9ebd-e691a452c5af" />

-->configmap.yml: Stores non-sensitive configuration.

<img width="501" height="362" alt="image" src="https://github.com/user-attachments/assets/f086f215-4fc5-41ad-8e3c-3a43745966db" />

-->secrets.yml: Stores sensitive information.

<img width="547" height="480" alt="image" src="https://github.com/user-attachments/assets/98b719e4-6adf-4f6a-a8fc-9972838a5a37" />

-->pv.yml: Defines storage. In AWS EKS this usually creates:

<img width="605" height="197" alt="image" src="https://github.com/user-attachments/assets/db73fd6d-647e-44b5-bf15-c0ed5cdae6f4" />

-->pvc.yml: Requests storage from Kubernetes.

<img width="607" height="436" alt="image" src="https://github.com/user-attachments/assets/b45b37ef-8c95-4128-90a8-fc8d988376ef" />

-->mysql-deployment.yml: Deploys MySQL.

<img width="595" height="432" alt="image" src="https://github.com/user-attachments/assets/912cfe27-7223-4e36-b476-a1c746ef770f" />

-->bankapp-deployment.yml: Deploys the main application. Which contains Init Containers whcich are Used to wait for dependencies:

<img width="582" height="612" alt="image" src="https://github.com/user-attachments/assets/444bc709-653b-4de7-8b9d-77d4799ca46e" />

-->ollama-deployment.yml: Deploys Ollama LLM service. which contains Persistent Storage whcih Stores downloaded models. 

<img width="632" height="436" alt="image" src="https://github.com/user-attachments/assets/31fd4f24-1a61-4099-aedc-3e5f6ef8f6b4" />

-->service.yml: Creates internal networking.

<img width="460" height="440" alt="image" src="https://github.com/user-attachments/assets/91a53d84-1698-4737-a60c-81847cc6cbe0" />

-->hpa.yml: Horizontal Pod Autoscaler.

<img width="592" height="572" alt="image" src="https://github.com/user-attachments/assets/54326106-7160-49a6-8813-c7ece20f15b4" />

-->gateway.yml: Exposes the application externally Which contains Envoy Gateway. Traffic entry point.

<img width="505" height="440" alt="image" src="https://github.com/user-attachments/assets/528dd8cf-be01-494c-b1ed-76f525d1e824" />

-->cert-manager.yml: Creates a Let's Encrypt issuer.

<img width="570" height="382" alt="image" src="https://github.com/user-attachments/assets/4484d059-fee9-45b1-a2a0-b5a413c9392f" />

Step 4: Create a New Helm Chart: 

-->Move to the location where the chart should live: mkdir helm-chart && cd helm-chart

-->Create a Helm chart: helm create bankapp

-->Inspect it: tree bankapp

<img width="1912" height="667" alt="image" src="https://github.com/user-attachments/assets/bcb52d4c-317e-49eb-8896-4a769fdd8f75" />

Step 5: Remove the Sample Templates: The generated templates are generic examples and won't match AI-BankApp. So Delete them: rm -rf bankapp/templates/*.yaml
&& rm -rf bankapp/templates/tests/

-->After deletation lets verify: tree bankapp

<img width="1765" height="292" alt="image" src="https://github.com/user-attachments/assets/bca5ecb5-e16b-4a97-b9a5-077cf93faf64" />

Step 6: Keep These Two Files: 

-->Do not delete: **_helpers.tpl** Whcih Contains reusable template functions such as: {{ include "bankapp.fullname" . }} & You'll use it repeatedly 
across deployments, services, PVCs, etc.

-->NOTES.txt: Displays information after installation. For Example: helm install bankapp . & then Output can include: Application URL, kubectl commands, 
Troubleshooting steps etc. & You will customize this later.

---

### Task 2: Define Chart.yaml and values.yaml
Edit `bankapp/Chart.yaml`:
```yaml
apiVersion: v2
name: bankapp
description: AI-BankApp -- Spring Boot banking application with MySQL and Ollama AI chatbot
type: application
version: 0.1.0
appVersion: "1.0.0"
maintainers:
  - name: TrainWithShubham
    url: https://github.com/TrainWithShubham
keywords:
  - bankapp
  - spring-boot
  - mysql
  - ollama
  - ai
```

Now create `bankapp/values.yaml` -- extract every hardcoded value from the raw manifests into configurable values:
```yaml
# BankApp configuration
bankapp:
  replicaCount: 4
  image:
    repository: trainwithshubham/ai-bankapp-eks
    tag: "latest"
    pullPolicy: Always
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  service:
    type: ClusterIP
    port: 8080
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 4
    targetCPUUtilization: 70

# MySQL configuration
mysql:
  enabled: true
  image:
    repository: mysql
    tag: "8.0"
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  persistence:
    size: 5Gi
    storageClass: gp3

# Ollama AI configuration
ollama:
  enabled: true
  image:
    repository: ollama/ollama
    tag: "latest"
  model: tinyllama
  resources:
    requests:
      memory: "2Gi"
      cpu: "900m"
    limits:
      memory: "2.5Gi"
      cpu: "1500m"
  persistence:
    size: 10Gi
    storageClass: gp3

# Shared configuration
config:
  mysqlDatabase: bankappdb
  ollamaUrl: ""  # Auto-generated from service name if empty

# Secrets
secrets:
  mysqlRootPassword: Test@123
  mysqlUser: root
  mysqlPassword: Test@123

# Storage
storageClass:
  create: true
  name: gp3
  provisioner: ebs.csi.aws.com

# Gateway (optional -- for EKS with Envoy Gateway)
gateway:
  enabled: false
  hostname: ""
  tls:
    enabled: false
```

**Compare:** The raw `k8s/secrets.yml` has base64-encoded credentials hardcoded. The Helm chart uses `values.yaml` and templates the Secret, so each environment can override credentials without editing YAML.

**Steps to follow:**

Step 1: Update Chart.yaml: vi bankapp/chart.yaml [Delete everything and paste new code]

<img width="680" height="402" alt="image" src="https://github.com/user-attachments/assets/c96b7267-b4ec-4010-a960-38477fef6730" />

<img width="1452" height="477" alt="image" src="https://github.com/user-attachments/assets/be754e06-938f-46c8-9751-50603408d9d5" />

Step 2: Replace values.yaml: vi bankapp/values.yaml [Delete everything and paste new code]

-->Note: Code is provided above

Step 3: Understand Why We Use values.yaml: In the original Kubernetes manifests, values were hardcoded. 

<img width="672" height="477" alt="image" src="https://github.com/user-attachments/assets/38745c60-f9b4-4bf7-a3da-4f9bcb5b830b" />

Step 4: Verify the YAML: Run command: helm lint bankapp

<img width="611" height="297" alt="image" src="https://github.com/user-attachments/assets/1d4bc33e-780d-4be9-92fe-778fe8998674" />

Step 5: Inspect Values Like Helm Does: helm show values bankapp

-->So You should see all sections: bankapp:, mysql:, ollama:, config:, secrets:, storageClass:, gateway: etc.

Step 6: Understand What Will Become Templates: 

<img width="781" height="502" alt="image" src="https://github.com/user-attachments/assets/4a56a44a-8e1c-4eb1-8555-7b4a09dcdeab" />

-->Validation Checklist: So here run command: cat bankapp/Chart.yaml & then run command: helm lint bankapp

---

### Task 3: Write the Core Templates
Convert the raw manifests into Helm templates. Each template uses `{{ .Values }}` instead of hardcoded values.

**`bankapp/templates/configmap.yaml`** (from `k8s/configmap.yml`):
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "bankapp.fullname" . }}-config
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
data:
  MYSQL_HOST: {{ include "bankapp.fullname" . }}-mysql
  MYSQL_PORT: "3306"
  MYSQL_DATABASE: {{ .Values.config.mysqlDatabase | quote }}
  OLLAMA_URL: {{ default (printf "http://%s-ollama:11434" (include "bankapp.fullname" .)) .Values.config.ollamaUrl | quote }}
  SERVER_FORWARD_HEADERS_STRATEGY: "native"
```

**`bankapp/templates/secrets.yaml`** (from `k8s/secrets.yml`):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "bankapp.fullname" . }}-secret
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: {{ .Values.secrets.mysqlRootPassword | b64enc | quote }}
  MYSQL_USER: {{ .Values.secrets.mysqlUser | b64enc | quote }}
  MYSQL_PASSWORD: {{ .Values.secrets.mysqlPassword | b64enc | quote }}
```

Notice: `b64enc` automatically base64 encodes the values. No more manual encoding.

**`bankapp/templates/storage.yaml`** (from `k8s/pv.yml` + `k8s/pvc.yml`):
```yaml
{{- if .Values.storageClass.create }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ .Values.storageClass.name }}
provisioner: {{ .Values.storageClass.provisioner }}
parameters:
  type: gp3
  fsType: ext4
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
{{- end }}
---
{{- if .Values.mysql.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "bankapp.fullname" . }}-mysql-pvc
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  storageClassName: {{ .Values.mysql.persistence.storageClass }}
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.mysql.persistence.size }}
{{- end }}
---
{{- if .Values.ollama.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "bankapp.fullname" . }}-ollama-pvc
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  storageClassName: {{ .Values.ollama.persistence.storageClass }}
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.ollama.persistence.size }}
{{- end }}
```

**Steps to follow:**

Step 1: Verify _helpers.tpl Exists: So Before creating templates, check: ls helm-chart/bankapp/templates [Expected: We should see: _helpers.tpl, NOTES.txt]

-->to open this file _helpers.tpl: vi helm-chart/bankapp/templates/_helpers.tpl

-->If it still contains the default Helm content, keep it for now because it already provides: {{ include "bankapp.fullname" . }}{{ include "bankapp.labels" . }} which your templates depend on.

<img width="1762" height="216" alt="image" src="https://github.com/user-attachments/assets/bbd33f62-1436-4f8b-a97c-bc87715206c4" />

<img width="1915" height="982" alt="image" src="https://github.com/user-attachments/assets/a5a38b0e-dfd6-4e11-b0c3-7c07963adfea" />

Step 2: Create configmap.yaml: Create file: vi helm-chart/bankapp/templates/configmap.yaml [Code is given above] & then do ls to verify

<img width="1716" height="122" alt="image" src="https://github.com/user-attachments/assets/89ff4d40-df21-47b8-92b9-cc8eabea3dda" />

**Understanding What Changed:**

<img width="565" height="632" alt="image" src="https://github.com/user-attachments/assets/3fcb11f3-1e71-43ca-832f-8c32708b0b93" />

Step 3: Create secrets.yaml: vi helm-chart/bankapp/templates/secrets.yaml & then do ls to verify

<img width="1585" height="101" alt="image" src="https://github.com/user-attachments/assets/3a65712b-bd66-4c9a-be1f-ac97771dc801" />

Why b64enc Is Useful: 

<img width="512" height="592" alt="image" src="https://github.com/user-attachments/assets/1727e681-d33e-42f9-866a-8c916b77a2a2" />

Step 4: Create storage.yaml: vi helm-chart/bankapp/templates/storage.yaml & then do ls to verify

Step 5: Verify Files Exist: tree tree helm-chart/bankapp

<img width="1765" height="885" alt="image" src="https://github.com/user-attachments/assets/ac38fdab-0c25-4b20-ab48-6beb96e978e7" />

Step 6: Render the Templates Locally: So Before deploying, ask Helm to render them: helm template bankapp ./helm-chart/bankapp

While Rendering the template locally i was faced this issue,

<img width="1917" height="121" alt="image" src="https://github.com/user-attachments/assets/90793fdb-3d05-47a1-8478-ef20786a13dc" />

-->So Helm is not failing on your configmap.yaml, secrets.yaml, or storage.yaml, It's failing inside templates/NOTES.txt:

<img width="597" height="551" alt="image" src="https://github.com/user-attachments/assets/6bfbc1e4-67dd-4fee-95ac-c86db67a40cf" />

<img width="567" height="482" alt="image" src="https://github.com/user-attachments/assets/06cc915f-d505-45e8-a60d-eb01787f4870" />

To Fix this i made chnages in NOTES.txt file as below,

<img width="577" height="267" alt="image" src="https://github.com/user-attachments/assets/68e13f81-c272-4b95-a652-6530fa5039ff" />

**Note:** Alternative is If you don't need NOTES.txt right now: rm helm-chart/bankapp/templates/NOTES.txt Helm charts work perfectly without it 

-->Now run again 6th Step command: **helm template bankapp ./helm-chart/bankapp** OR **helm lint ./helm-chart/bankapp**

<img width="1566" height="972" alt="image" src="https://github.com/user-attachments/assets/59a9feb9-722f-460e-b3e8-ab09c36f33e4" />

<img width="1752" height="971" alt="image" src="https://github.com/user-attachments/assets/6a424aa8-6e61-441d-83d9-660df8c857de" />

<img width="1181" height="130" alt="image" src="https://github.com/user-attachments/assets/ef654d51-4e94-4248-8912-16a6930d0c66" />

-->Perfect, verification step has passed successfully. So What the output confirms is:

<img width="602" height="541" alt="image" src="https://github.com/user-attachments/assets/2e10fb6b-c8ca-48b5-b289-860c9576005c" />

<img width="607" height="517" alt="image" src="https://github.com/user-attachments/assets/765533a2-6380-492f-9b5d-11daeb92d977" />

<img width="575" height="422" alt="image" src="https://github.com/user-attachments/assets/420aba7e-7546-467b-9e48-f60e3191b80e" />

<img width="571" height="542" alt="image" src="https://github.com/user-attachments/assets/47d71b6a-6b2d-44cb-810a-99983fd2ef54" />

<img width="617" height="742" alt="image" src="https://github.com/user-attachments/assets/fe922fa8-beeb-4d92-9827-aaa7239b64b7" />

Step 7: Inspect Specific Output: 

-->Check ConfigMap: helm template bankapp ./helm-chart/bankapp | grep MYSQL_DATABASE -A 2

-->Check secret: helm template bankapp ./helm-chart/bankapp | grep MYSQL_PASSWORD 

-->So here we will get Expected output will be base64 encoded, even though values.yaml contains: mysqlPassword: Test@123

Step 8: Run Helm Validation: Always lint after creating templates: helm lint helm-chart/bankapp

<img width="1785" height="257" alt="image" src="https://github.com/user-attachments/assets/59bc768e-f768-47ec-8137-4492b219e5ad" />

<img width="821" height="327" alt="image" src="https://github.com/user-attachments/assets/f888fbca-ac42-45cb-8b63-28312b9fa7bc" />

---

### Task 4: Write the Deployment Templates
**`bankapp/templates/bankapp-deployment.yaml`** (from `k8s/bankapp-deployment.yml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "bankapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  {{- if not .Values.bankapp.autoscaling.enabled }}
  replicas: {{ .Values.bankapp.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      app: {{ include "bankapp.fullname" . }}
  template:
    metadata:
      labels:
        app: {{ include "bankapp.fullname" . }}
    spec:
      initContainers:
        - name: wait-for-mysql
          image: busybox:1.36
          command: ["/bin/sh", "-c", "until nc -z {{ include "bankapp.fullname" . }}-mysql 3306; do sleep 2; done"]
          resources:
            requests: { memory: "32Mi", cpu: "50m" }
            limits: { memory: "64Mi", cpu: "100m" }
        {{- if .Values.ollama.enabled }}
        - name: wait-for-ollama
          image: busybox:1.36
          command: ["/bin/sh", "-c", "until nc -z {{ include "bankapp.fullname" . }}-ollama 11434; do sleep 2; done"]
          resources:
            requests: { memory: "32Mi", cpu: "50m" }
            limits: { memory: "64Mi", cpu: "100m" }
        {{- end }}
      containers:
        - name: bankapp
          image: "{{ .Values.bankapp.image.repository }}:{{ .Values.bankapp.image.tag }}"
          imagePullPolicy: {{ .Values.bankapp.image.pullPolicy }}
          ports:
            - containerPort: 8080
          envFrom:
            - configMapRef:
                name: {{ include "bankapp.fullname" . }}-config
            - secretRef:
                name: {{ include "bankapp.fullname" . }}-secret
          {{- with .Values.bankapp.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 30
            failureThreshold: 15
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 10
            failureThreshold: 5
```

**Key template decisions:**
- Init containers dynamically reference the MySQL and Ollama service names via `{{ include "bankapp.fullname" . }}`
- Ollama init container is conditional (`{{- if .Values.ollama.enabled }}`)
- Health probes use `/actuator/health` -- Spring Boot's built-in health endpoint
- `replicas` is omitted when HPA is enabled (HPA manages the count)

**`bankapp/templates/mysql-deployment.yaml`** (from `k8s/mysql-deployment.yml`):
```yaml
{{- if .Values.mysql.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "bankapp.fullname" . }}-mysql
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      app: {{ include "bankapp.fullname" . }}-mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: {{ include "bankapp.fullname" . }}-mysql
    spec:
      containers:
        - name: mysql
          image: "{{ .Values.mysql.image.repository }}:{{ .Values.mysql.image.tag }}"
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "bankapp.fullname" . }}-secret
                  key: MYSQL_ROOT_PASSWORD
            - name: MYSQL_DATABASE
              valueFrom:
                configMapKeyRef:
                  name: {{ include "bankapp.fullname" . }}-config
                  key: MYSQL_DATABASE
          {{- with .Values.mysql.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
          readinessProbe:
            exec:
              command: ["mysqladmin", "ping", "-h", "localhost"]
            initialDelaySeconds: 15
            failureThreshold: 10
          livenessProbe:
            exec:
              command: ["mysqladmin", "ping", "-h", "localhost"]
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 5
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: {{ include "bankapp.fullname" . }}-mysql-pvc
{{- end }}
```

**`bankapp/templates/ollama-deployment.yaml`** (from `k8s/ollama-deployment.yml`):
```yaml
{{- if .Values.ollama.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "bankapp.fullname" . }}-ollama
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      app: {{ include "bankapp.fullname" . }}-ollama
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: {{ include "bankapp.fullname" . }}-ollama
    spec:
      containers:
        - name: ollama
          image: "{{ .Values.ollama.image.repository }}:{{ .Values.ollama.image.tag }}"
          ports:
            - containerPort: 11434
          {{- with .Values.ollama.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: ollama-storage
              mountPath: /root/.ollama
          lifecycle:
            postStart:
              exec:
                command:
                  - /bin/sh
                  - -c
                  - |
                    until ollama list > /dev/null 2>&1; do sleep 2; done
                    ollama pull {{ .Values.ollama.model }}
          readinessProbe:
            exec:
              command: ["/bin/sh", "-c", "ollama list | grep -q {{ .Values.ollama.model }}"]
            initialDelaySeconds: 30
            failureThreshold: 30
          livenessProbe:
            httpGet:
              path: /
              port: 11434
            initialDelaySeconds: 60
            periodSeconds: 10
            failureThreshold: 5
      volumes:
        - name: ollama-storage
          persistentVolumeClaim:
            claimName: {{ include "bankapp.fullname" . }}-ollama-pvc
{{- end }}
```

Notice: the Ollama model name (`tinyllama`) is now a value (`{{ .Values.ollama.model }}`). You can switch models without editing YAML.

**Steps to follow:**

Step 1: Create bankapp-deployment.yaml: 

-->vi helm-chart/bankapp/templates/bankapp-deployment.yaml

Important Things to Understand: 

<img width="631" height="576" alt="image" src="https://github.com/user-attachments/assets/007afe00-6ce5-4f85-8374-b34b5bfb129e" />

<img width="642" height="481" alt="image" src="https://github.com/user-attachments/assets/7f36d696-740e-4927-92ff-f792937fc6c2" />

<img width="625" height="477" alt="image" src="https://github.com/user-attachments/assets/11807a72-2d17-4829-aaad-1ff86deb9bb4" />

Step 2: Create mysql-deployment.yaml: vi helm-chart/bankapp/templates/mysql-deployment.yaml

**Why Recreate Strategy?**

<img width="495" height="737" alt="image" src="https://github.com/user-attachments/assets/57bede3b-c061-47d5-8339-907d35620a52" />

Step 3: Create ollama-deployment.yaml: vi helm-chart/bankapp/templates/ollama-deployment.yaml

<img width="377" height="705" alt="image" src="https://github.com/user-attachments/assets/bddfdeec-17f0-49e6-9371-cd270074fc75" />

Step 4: Validate Template Syntax: ls helm-chart/bankapp/templates

<img width="1882" height="162" alt="image" src="https://github.com/user-attachments/assets/6777aad9-02e8-4252-9bb8-a9f7823c30dd" />

Step 5: Render Everything: helm template bankapp ./helm-chart/bankapp

<img width="1657" height="977" alt="image" src="https://github.com/user-attachments/assets/9d0a1209-b4cf-441d-aadc-24def098b71f" />

<img width="1461" height="975" alt="image" src="https://github.com/user-attachments/assets/668afeab-a204-4d5d-8c80-824351b153f2" />

<img width="1596" height="977" alt="image" src="https://github.com/user-attachments/assets/ba465a47-df95-4a6a-aea4-25853749633a" />

<img width="1420" height="977" alt="image" src="https://github.com/user-attachments/assets/477fd648-27ab-4336-8b10-115659fd0ed0" />

<img width="1517" height="990" alt="image" src="https://github.com/user-attachments/assets/44fbcdf7-65fe-4dd2-9665-db206a2a4a6c" />

Step 6: Quick Deployment Checks: helm template bankapp ./helm-chart/bankapp | grep image:

<img width="1681" height="245" alt="image" src="https://github.com/user-attachments/assets/c0c1886b-b71d-4ab3-b01f-c10848a7609b" />

Step 7: Lint Again: helm lint ./helm-chart/bankapp

<img width="1587" height="122" alt="image" src="https://github.com/user-attachments/assets/9a5e56d7-54fd-4784-a735-a6550d190c79" />

<img width="751" height="382" alt="image" src="https://github.com/user-attachments/assets/0445e83d-eacf-444c-8c36-20f48529a248" />

---

### Task 5: Write the Services and HPA Templates
**`bankapp/templates/services.yaml`** (from `k8s/service.yml`):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "bankapp.fullname" . }}-mysql
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    app: {{ include "bankapp.fullname" . }}-mysql
  ports:
    - port: 3306
---
{{- if .Values.ollama.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "bankapp.fullname" . }}-ollama
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    app: {{ include "bankapp.fullname" . }}-ollama
  ports:
    - port: 11434
{{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "bankapp.fullname" . }}-service
  namespace: {{ .Release.Namespace }}
spec:
  type: {{ .Values.bankapp.service.type }}
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
  selector:
    app: {{ include "bankapp.fullname" . }}
  ports:
    - port: {{ .Values.bankapp.service.port }}
      targetPort: 8080
```

**`bankapp/templates/hpa.yaml`** (from `k8s/hpa.yml`):
```yaml
{{- if .Values.bankapp.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "bankapp.fullname" . }}-hpa
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "bankapp.fullname" . }}
  minReplicas: {{ .Values.bankapp.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.bankapp.autoscaling.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.bankapp.autoscaling.targetCPUUtilization }}
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Pods
          value: 1
          periodSeconds: 60
{{- end }}
```
**Steps to follow:**

Step 1: Create services.yaml: vi helm-chart/bankapp/templates/services.yaml [Pasted above mentioned code here]

Step 2: Understand the Service Design: This single template creates three Services:

<img width="540" height="710" alt="image" src="https://github.com/user-attachments/assets/9290f25e-d631-4463-8890-3366638b36b2" />

<img width="522" height="382" alt="image" src="https://github.com/user-attachments/assets/b8944af5-d39d-41c9-a050-1430137511d9" />

Step 3: Create hpa.yaml: vi helm-chart/bankapp/templates/hpa.yaml [Pasted above code here]

Step 4: Verify Files Exist: ls helm-chart/bankapp/templates

Step 5: Render the Chart: Render everything: helm template bankapp ./helm-chart/bankapp

<img width="1817" height="977" alt="image" src="https://github.com/user-attachments/assets/2a05fc03-e131-4668-ab77-5c4f49250438" />

<img width="1476" height="976" alt="image" src="https://github.com/user-attachments/assets/802c0339-6db2-402d-b568-58dbe3d0e161" />

<img width="1410" height="977" alt="image" src="https://github.com/user-attachments/assets/58f4851d-98fd-44a7-8e06-bbdb1cfd3a7b" />

<img width="1390" height="982" alt="image" src="https://github.com/user-attachments/assets/28cacbca-89be-4522-a7bf-c95e65893269" />

Step 6: Verify Services: Check generated Services: helm template bankapp ./helm-chart/bankapp | grep "^kind: Service" -A 10

<img width="1702" height="717" alt="image" src="https://github.com/user-attachments/assets/e9ae7f51-199f-49f5-995c-538d66d10904" />

Step 7: Verify HPA: Check HPA rendering: helm template bankapp ./helm-chart/bankapp | grep "HorizontalPodAutoscaler" -A 20

<img width="1690" height="450" alt="image" src="https://github.com/user-attachments/assets/4dc6e4be-558c-46ec-81d6-b400dabb1e6d" />

Step 8: Test Conditional Logic: Temporarily disable autoscaling: 

-->helm template bankapp ./helm-chart/bankapp --set bankapp.autoscaling.enabled=false

<img width="1731" height="960" alt="image" src="https://github.com/user-attachments/assets/a2327eb8-364f-4975-b362-3c6825817fef" />

<img width="1402" height="982" alt="image" src="https://github.com/user-attachments/assets/1f386e79-3dd5-45c9-8c7b-15908281bf29" />

<img width="1481" height="981" alt="image" src="https://github.com/user-attachments/assets/caee6a11-b971-4b2f-82b1-0c534bb43434" />

<img width="1477" height="987" alt="image" src="https://github.com/user-attachments/assets/df5d7ace-d33b-41bb-b71f-9a614a768216" />

-->Now verify: helm template bankapp ./helm-chart/bankapp --set bankapp.autoscaling.enabled=false | grep HorizontalPodAutoscaler

-->Expected: (no output) And verify Deployment now contains: replicas: 4 because HPA is disabled. So You can check it in a few ways as below,

**Method 1: Render and Search for replicas (Recommended)**

-->helm template bankapp ./helm-chart/bankapp --set bankapp.autoscaling.enabled=false | grep replicas

**Method 2: Inspect Only the Deployment Section:** 

-->helm template bankapp ./helm-chart/bankapp --set bankapp.autoscaling.enabled=false | less

-->Then Search for: kind: Deployment by using: /Deployment You should see something like:

<img width="1547" height="977" alt="image" src="https://github.com/user-attachments/assets/0b788f1d-e2d0-4fed-bbec-821245e5346f" />

**Method 3: Save Rendered Output to a File:** Generate the manifests:

-->helm template bankapp ./helm-chart/bankapp --set bankapp.autoscaling.enabled=false > output.yaml

-->grep -A 10 "kind: Deployment" output.yaml

<img width="1917" height="732" alt="image" src="https://github.com/user-attachments/assets/2fec5390-bb56-40c8-86b5-3a4c1955a472" />

<img width="716" height="477" alt="image" src="https://github.com/user-attachments/assets/6d4e5482-c43f-46b0-a911-8af3997103b6" />

<img width="682" height="712" alt="image" src="https://github.com/user-attachments/assets/8def5c5d-1ea5-4b75-a220-29be742c2b77" />

Step 9: Test Ollama Disable: 

-->helm template bankapp ./helm-chart/bankapp --set ollama.enabled=false

<img width="1627" height="967" alt="image" src="https://github.com/user-attachments/assets/79f076b9-9c95-461d-a33f-face51a7de41" />

<img width="1282" height="977" alt="image" src="https://github.com/user-attachments/assets/d152d792-f2e9-40d3-bf05-65394b5e9948" />

<img width="1471" height="975" alt="image" src="https://github.com/user-attachments/assets/b3a9fe0c-b3ee-42b0-812e-6c7734dd0429" />

-->helm template bankapp ./helm-chart/bankapp --set ollama.enabled=false | grep ollama

-->Expected: No Ollama Deployment, No Ollama Service, No Ollama PVC, No Ollama initContainer This confirms your conditional templating works.

<img width="1461" height="55" alt="image" src="https://github.com/user-attachments/assets/704bf094-3b39-4ec3-98b7-1472123559bd" />

Step 10: Final Validation: helm lint ./helm-chart/bankapp

<img width="786" height="412" alt="image" src="https://github.com/user-attachments/assets/5f860f89-b279-4e5c-8eee-e5f58bc0c539" />

---

### Task 6: Validate and Deploy
**Lint the chart:**
```bash
helm lint bankapp/
```

**Render templates locally** -- see the final YAML without deploying:
```bash
helm template my-bankapp bankapp/
```

Review the output. Every `{{ }}` should be resolved to actual values.

**Render with overrides:**
```bash
helm template my-bankapp bankapp/ \
  --set bankapp.image.tag=abc1234 \
  --set bankapp.replicaCount=2 \
  --set ollama.enabled=false
```

Notice: setting `ollama.enabled=false` removes the Ollama Deployment, Service, PVC, and the init container from the BankApp. One boolean controls an entire component.

**Dry run against the cluster:**
```bash
helm install my-bankapp bankapp/ --dry-run --debug -n bankapp --create-namespace
```

**Deploy for real (on Kind -- skip StorageClass creation since Kind uses its own):**
```bash
helm install my-bankapp bankapp/ \
  -n bankapp --create-namespace \
  --set storageClass.create=false \
  --set mysql.persistence.storageClass=standard \
  --set ollama.persistence.storageClass=standard
```

Verify:
```bash
helm list -n bankapp
kubectl get all -n bankapp
kubectl get pvc -n bankapp
kubectl get configmap,secret -n bankapp
```

Wait for all pods to be ready (Ollama takes time to pull the model):
```bash
kubectl get pods -n bankapp -w
```

Access the app:
```bash
kubectl port-forward svc/my-bankapp-bankapp-service -n bankapp 8080:8080
```

Open `http://localhost:8080` -- you should see the AI-BankApp login page.

**Compare: 12 raw YAML files vs 1 Helm command.** Same result, but now configurable, versionable, and rollback-safe.

**Clean up:**
```bash
helm uninstall my-bankapp -n bankapp
```

**Stesp to follow:** 

Step 1: Verify Current Chart Structure: tree helm-chart/bankapp

<img width="1461" height="386" alt="image" src="https://github.com/user-attachments/assets/1369f319-076f-4d1e-b36f-626d22bef439" />

Step 2: Lint the Chart: helm lint ./helm-chart/bankapp

<img width="1402" height="132" alt="image" src="https://github.com/user-attachments/assets/a7bad759-79a1-4008-a9f5-95152bccd632" />

**Note:** If lint fails: helm lint ./helm-chart/bankapp --debug and inspect the error line.

Step 3: Render Templates Locally: This shows the final Kubernetes manifests Helm will generate.

-->helm template my-bankapp ./helm-chart/bankapp

<img width="1492" height="972" alt="image" src="https://github.com/user-attachments/assets/1e705477-59f4-4dd5-a30e-01f850e10b83" />

<img width="1222" height="967" alt="image" src="https://github.com/user-attachments/assets/115b2a74-a755-4d2e-ae5d-4dffc11ebceb" />

<img width="1290" height="976" alt="image" src="https://github.com/user-attachments/assets/3a1ed92d-4aa1-4f66-818f-748c4c9c4208" />

-->Review the output & Things to verify:

<img width="562" height="562" alt="image" src="https://github.com/user-attachments/assets/a753f8f4-8369-401d-a5a7-a87eb3c90d6d" />

<img width="502" height="702" alt="image" src="https://github.com/user-attachments/assets/26fee8ce-6e98-4de0-b64e-b74ee2badc8e" />

Step 4: Test Overrides: Render with custom values:

-->helm template my-bankapp ./helm-chart/bankapp --set bankapp.image.tag=abc1234 --set bankapp.replicaCount=2 --set ollama.enabled=false

<img width="1917" height="960" alt="image" src="https://github.com/user-attachments/assets/44ce63ba-a55a-4072-b4d4-1e655ddc9777" />

-->**Verify: Image Tag Changed:** helm template my-bankapp ./helm-chart/bankapp --set bankapp.image.tag=abc1234 | grep image:

-->Expected: image: "trainwithshubham/ai-bankapp-eks:abc1234"

<img width="1917" height="137" alt="image" src="https://github.com/user-attachments/assets/a4718593-6a7a-4b82-b7ee-1aa0ea8451cc" />

-->**verify: Ollama Removed:** helm template my-bankapp ./helm-chart/bankapp --set ollama.enabled=false | grep "name: my-bankapp-ollama"

-->Expected: (no output)

-->**Check PVC:** helm template my-bankapp ./helm-chart/bankapp --set ollama.enabled=false | grep ollama-pvc

-->Expected: (no output) So This proves the conditional logic works.

<img width="1905" height="67" alt="image" src="https://github.com/user-attachments/assets/3e3bb3dd-2dda-4132-b499-81fd3014b514" />

Step 5: Dry Run Against Kubernetes: This validates against the cluster API without creating resources.

-->helm install my-bankapp ./helm-chart/bankapp --dry-run --debug -n bankapp --create-namespace

<img width="1917" height="971" alt="image" src="https://github.com/user-attachments/assets/af86f11f-9950-458f-aef8-96e4af77201e" />

<img width="1521" height="972" alt="image" src="https://github.com/user-attachments/assets/757c0b8f-f58c-491b-ac5c-67f2363afc3c" />

<img width="1422" height="972" alt="image" src="https://github.com/user-attachments/assets/520a8c08-e11a-47d1-b1c4-2f9f86def717" />

<img width="1176" height="975" alt="image" src="https://github.com/user-attachments/assets/71375b5b-3a79-44cb-9c60-9860a4cd561e" />

Step 6: Confirm Storage Class on Kind: Check available StorageClasses:

-->kubectl get storageclass

<img width="1625" height="96" alt="image" src="https://github.com/user-attachments/assets/eb9cf040-5e9f-4931-a863-68b401900fc3" />





---

## Hints
- `helm template` is your best debugging tool -- always render locally before deploying
- `helm lint` catches common issues: missing required fields, YAML syntax errors, template bugs
- Go template whitespace is tricky -- use `{{-` to trim leading whitespace and `-}}` to trim trailing
- `b64enc` is a Helm function that base64 encodes strings -- no need to manually encode secrets
- `toYaml` converts a YAML object from values into proper YAML in the template -- always pair with `nindent`
- `include` calls a helper function and returns a string (pipeable). `template` streams directly (not pipeable)
- The `{{- if }}` / `{{- end }}` pattern for MySQL and Ollama means the chart works with or without those components
- Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`) -- the `k8s/` directory has the original manifests

---

## Documentation
Create `day-79-custom-charts.md` with:
- Side-by-side comparison: raw `k8s/` manifests vs Helm templates (pick 2-3 files)
- Your complete `values.yaml` with explanations
- Go template syntax cheat sheet: `{{ .Values }}`, `if`, `range`, `with`, `include`, `toYaml`, `nindent`, `b64enc`
- Output of `helm template` showing rendered manifests
- Screenshot of the AI-BankApp running via Helm on Kind
- How disabling Ollama (`ollama.enabled=false`) removes all related resources

---

## Submission
1. Add `day-79-custom-charts.md` to `2026/day-79/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Converted the AI-BankApp's 12 raw Kubernetes manifests into a single Helm chart today. Three deployments (Spring Boot, MySQL, Ollama AI), services, secrets, PVCs, and HPA -- all templated and configurable through values.yaml. One command deploys the entire stack. One boolean disables the AI chatbot. This is what production packaging looks like."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
