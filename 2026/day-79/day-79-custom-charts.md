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
