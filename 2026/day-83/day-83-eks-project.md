# Day 83 -- EKS Project: Production Deployment of AI-BankApp

## Task
Three days of EKS -- cluster provisioning with Terraform, Gateway API networking, EBS storage, and TLS. Today you put it all together and deploy the AI-BankApp as a production-grade application on EKS. Full stack: Spring Boot app with MySQL and Ollama AI, persistent storage, autoscaling, monitoring, and the complete end-to-end validation.

This is the kind of deployment you would do on the job.

Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`)

---

## Expected Output
- Complete AI-BankApp stack deployed on EKS
- MySQL with persistent EBS storage, Ollama with model loaded
- Gateway API routing traffic, HPA scaling pods
- Monitoring stack (Prometheus + Grafana) observing the cluster
- Full end-to-end validation checklist passed
- Complete teardown of all AWS resources
- A markdown file: `day-83-eks-project.md`

---

## Challenge Tasks

### Task 1: Deploy the Complete AI-BankApp Stack
Make sure your EKS cluster is running:
```bash
kubectl get nodes
```

If you destroyed the cluster, re-provision it:
```bash
cd AI-BankApp-DevOps/terraform
terraform apply
aws eks update-kubeconfig --name bankapp-eks --region us-west-2
```

Deploy the entire application stack in order:
```bash
cd AI-BankApp-DevOps

# 1. Namespace and storage
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml

# 2. Configuration
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secrets.yml

# 3. Database and AI service
kubectl apply -f k8s/mysql-deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/ollama-deployment.yml

# 4. Wait for dependencies
echo "Waiting for MySQL..."
kubectl wait --for=condition=ready pod -l app=mysql -n bankapp --timeout=120s

echo "Waiting for Ollama (this takes 2-5 minutes for model pull)..."
kubectl wait --for=condition=ready pod -l app=ollama -n bankapp --timeout=600s

# 5. Application
kubectl apply -f k8s/bankapp-deployment.yml
kubectl apply -f k8s/hpa.yml

# 6. Wait for BankApp
echo "Waiting for BankApp..."
kubectl wait --for=condition=ready pod -l app=bankapp -n bankapp --timeout=300s
```

Verify everything is running:
```bash
kubectl get all -n bankapp
kubectl get pvc -n bankapp
```

You should see:
- MySQL: 1 pod running with 5Gi PVC bound
- Ollama: 1 pod running with 10Gi PVC bound
- BankApp: 2-4 pods running (managed by HPA)
- Services: 3 ClusterIP services

**Steps to follow:**

-->This task is essentially your full application deployment validation after recreating the EKS infrastructure with Terraform. Follow it in phases so you can identify failures 
quickly instead of applying everything at once.

Phase 1: Verify EKS Cluster: Check whether your cluster exists and nodes are ready: kubectl get nodes

-->& If this fails: cd terraform && terraform apply && aws eks update-kubeconfig --region us-west-2 --name bankapp-eks

-->Then verify: kubectl cluster-info && kubectl get nodes

<img width="1511" height="190" alt="image" src="https://github.com/user-attachments/assets/6d663823-2912-482e-8ddd-10002b867eba" />

Phase 2: Deploy Namespace: kubectl apply -f k8s/namespace.yml

-->& then to verify: kubectl get ns

<img width="1465" height="312" alt="image" src="https://github.com/user-attachments/assets/39884005-b03d-4134-a214-e4a4817ceb21" />

Phase 3: Deploy Storage: Create Persistent Volume and Persistent Volume Claims.

-->kubectl apply -f k8s/pv.yml

-->kubectl apply -f k8s/pvc.yml

-->To verify: kubectl get pv

-->kubectl get pvc -n bankapp

-->& if PVC remains Pending: kubectl describe pvc mysql-pvc -n bankapp

-->kubectl describe pvc ollama-pvc -n bankapp

<img width="642" height="752" alt="image" src="https://github.com/user-attachments/assets/ddb62a0b-bafe-4e89-89e7-9c39a107571a" />

Phase 4: Deploy Configurations: Create ConfigMap and Secrets.

-->kubectl apply -f k8s/configmap.yml

-->kubectl apply -f k8s/secrets.yml

-->Verify: kubectl get configmap -n bankapp

-->kubectl get secrets -n bankapp

Phase 5: Deploy MySQL: Deploy database.

-->kubectl apply -f k8s/mysql-deployment.yml

-->kubectl apply -f k8s/service.yml

-->Verify: kubectl get pods -n bankapp

Wait until MySQL is ready: kubectl wait --for=condition=ready pod -l app=mysql -n bankapp --timeout=120s

Check logs: kubectl logs -l app=mysql -n bankapp

If MySQL doesn't start: kubectl describe pod -l app=mysql -n bankapp

Phase 6: Deploy Ollama: Deploy AI service: kubectl apply -f k8s/ollama-deployment.yml

-->Then check: kubectl get pods -n bankapp

-->Wait for sometime: kubectl wait --for=condition=ready pod -l app=ollama -n bankapp --timeout=600s

-->Monitor progress: kubectl logs -f -l app=ollama -n bankapp

**Important:** The first startup may take 2–5 minutes because Ollama downloads the model.

-->Check storage: kubectl get pvc -n bankapp

Phase 7: Deploy BankApp: Once MySQL and Ollama are healthy: 

-->kubectl apply -f k8s/bankapp-deployment.yml

-->kubectl apply -f k8s/hpa.yml

-->Wait for readiness: kubectl wait --for=condition=ready pod -l app=bankapp -n bankapp --timeout=300s

-->Verify: kubectl get pods -n bankapp

Phase 8: Verify HPA: Check autoscaler: kubectl get hpa -n bankapp

-->If metrics show: unknown/80% then verify Metrics Server: kubectl get deployment metrics-server -n kube-system

Phase 9: Final Validation: kubectl get all -n bankapp

<img width="485" height="787" alt="image" src="https://github.com/user-attachments/assets/d2c243d4-5064-4422-9359-7fc790b6fa63" />

Phase 10: Check Storage: kubectl get pvc -n bankapp



**Troubleshooting Commands:** If something isn't working, these commands usually reveal the issue:

-->kubectl get events -n bankapp --sort-by=.metadata.creationTimestamp

-->kubectl describe pod <pod-name> -n bankapp

-->kubectl logs <pod-name> -n bankapp

-->kubectl get pvc -n bankapp

-->kubectl describe pvc <pvc-name> -n bankapp

**For a quick health check after deployment:**

-->kubectl get all -n bankapp

-->kubectl get pvc -n bankapp

-->kubectl get hpa -n bankapp

-->kubectl top pods -n bankapp

-->kubectl top nodes

<img width="707" height="376" alt="image" src="https://github.com/user-attachments/assets/ce07c76a-0517-484b-98a2-ec8c56b97ad5" />

**If you hit an error during any phase, share the output of:**

-->kubectl get all -n bankapp

-->kubectl get pvc -n bankapp

-->kubectl get events -n bankapp --sort-by=.metadata.creationTimestamp

---

### Task 2: Set Up Gateway API and Access the App
Install Envoy Gateway (if not done on Day 82):
```bash
helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version v1.4.0 \
  -n envoy-gateway-system --create-namespace \
  --wait 2>/dev/null || echo "Already installed"
```

Apply the Gateway configuration:
```bash
kubectl apply -f k8s/gateway.yml
```

Wait for the NLB:
```bash
kubectl get gateway -n bankapp -w
```

Get the external address:
```bash
export APP_URL=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}')
echo "AI-BankApp URL: http://$APP_URL"
```

Test the application:
```bash
# Health check (Spring Boot Actuator)
curl -s http://$APP_URL/actuator/health | python3 -m json.tool

# Load the home page
curl -s -o /dev/null -w "%{http_code}" http://$APP_URL
```

Open `http://$APP_URL` in your browser:
1. Click "Register" and create an account
2. Log in with your credentials
3. Perform banking operations (deposit, withdraw, transfer)
4. Try the AI chatbot -- ask a financial question
5. Toggle dark/light mode

**The full stack is running on EKS:** Spring Boot serves the UI, MySQL stores accounts and transactions, Ollama's TinyLlama model powers the AI chatbot -- all on managed Kubernetes with persistent storage and autoscaling.

**Steps to follow:**

-->This task is about exposing your AI-BankApp to the internet through Gateway API + Envoy Gateway + AWS Network Load Balancer (NLB) and verifying that all components (Spring Boot, MySQL, Ollama) are working together.

Step 1: Verify the Application Stack First: 

-->Before exposing the app, confirm all workloads are healthy: kubectl get all -n bankapp

-->Verify services: kubectl get svc -n bankapp


Step 2: Verify Envoy Gateway Installation: 

-->Check whether Envoy Gateway is already installed: kubectl get pods -n envoy-gateway-system

-->If the namespace does not exist, install Envoy Gateway: helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm --version v1.4.0 -n envoy-gateway-system --create-namespace \
  --wait

-->Verify: kubectl get pods -n envoy-gateway-system


Step 3: Verify Gateway API CRDs: 

-->Ensure Gateway API resources exist: kubectl api-resources | grep gateway

-->Also check: kubectl get gatewayclass

<img width="617" height="587" alt="image" src="https://github.com/user-attachments/assets/df79422f-6018-4568-bb0a-6ddbd145b74c" />



Step 4: Deploy Gateway Configuration: 

-->Apply the Gateway resource: kubectl apply -f k8s/gateway.yml

-->Verify: kubectl get gateway -n bankapp [This is normal while AWS provisions the load balancer.]



Step 5: Watch Gateway Status: 

-->Monitor the gateway: kubectl get gateway -n bankapp -w

<img width="717" height="710" alt="image" src="https://github.com/user-attachments/assets/8646139a-01a0-4e64-a699-8bc385af3902" />


Step 6: Verify Gateway Conditions: 

-->If ADDRESS never appears: kubectl describe gateway bankapp-gateway -n bankapp

-->And If Programmed=False, inspect Envoy Gateway: kubectl logs -n envoy-gateway-system deployment/envoy-gateway

<img width="702" height="432" alt="image" src="https://github.com/user-attachments/assets/f27ff03c-84bd-432f-8937-7997a04a408c" />



Step 7: Obtain the Public URL: 

-->Extract the NLB hostname: export APP_URL=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}')

-->To verify: echo $APP_URL

-->Display it: echo "AI-BankApp URL: http://$APP_URL"

<img width="647" height="582" alt="image" src="https://github.com/user-attachments/assets/b92201f1-60c4-48f7-9b86-9135e8199202" />

Step 8: Test Connectivity: 

-->**Health Endpoint:** curl http://$APP_URL/actuator/health

-->Pretty print: curl -s http://$APP_URL/actuator/health | python3 -m json.tool

<img width="727" height="595" alt="image" src="https://github.com/user-attachments/assets/77ba91f5-b58b-4124-99d4-badf52710b55" />

-->**Home Page Test:**  curl -s -o /dev/null -w "%{http_code}" http://$APP_URL

<img width="696" height="412" alt="image" src="https://github.com/user-attachments/assets/57fdb893-d230-40b4-a90a-230c800401bf" />

Step 9: If You Get 503: 

-->Check route: kubectl get httproute -n bankapp

-->Check service: kubectl get svc -n bankapp

-->Check endpoints: kubectl get endpoints -n bankapp

-->If endpoints are empty: kubectl describe svc bankapp-service -n bankapp

-->kubectl get pods --show-labels -n bankapp   [Likely a selector mismatch.]

Step 10: Access Through Browser: 

-->Open: http://<NLB-DNS-NAME> Ex: http://a1b2c3d4e5f6.us-west-2.elb.amazonaws.com

Step 11: Functional Testing: 

<img width="562" height="656" alt="image" src="https://github.com/user-attachments/assets/344deda2-ac31-495a-b217-22ae1a9802b0" />

<img width="405" height="812" alt="image" src="https://github.com/user-attachments/assets/031ada68-06da-4dfd-b935-a7bbe2dd6e49" />

Step 12: Verify Backend Connectivity: Watch logs while testing:

-->BankApp: kubectl logs -f deployment/bankapp -n bankapp

-->Ollama: kubectl logs -f deployment/ollama -n bankapp

-->MySQL: kubectl logs -f deployment/mysql -n bankapp

-->**You should see:** BankApp serving requests, MySQL queries executing, Ollama generating responses

Step 13: Confirm AWS Resources: 

-->Check the Envoy service created by Gateway API: kubectl get svc -A

-->You can also verify directly in AWS: aws elbv2 describe-load-balancers --region us-west-2 [You should see an AWS Network Load Balancer associated with Envoy Gateway.]

<img width="672" height="592" alt="image" src="https://github.com/user-attachments/assets/242f74a6-752e-4c2e-bd35-574857aacbf1" />

**Final Validation Checklist:**

-->kubectl get gateway -n bankapp

-->kubectl get httproute -n bankapp
kubectl get all -n bankapp
curl http://$APP_URL/actuator/health












Step 4: Deploy Gateway Configuration:

-->Apply the Gateway resource: kubectl apply -f k8s/gateway.yml

-->Verify: kubectl get gateway -n bankapp [This is normal while AWS provisions the load balancer.]

<img width="632" height="586" alt="image" src="https://github.com/user-attachments/assets/dced4fc7-a302-4f08-8faf-32b456280a29" />



Step 5: Watch Gateway Status: 

-->Monitor the gateway: kubectl get gateway -n bankapp -w   [Provisioning usually takes: 2–5 minutes, Sometimes up to 10 minutes]



Step 6: Verify Gateway Conditions: 

-->If ADDRESS never appears: kubectl describe gateway bankapp-gateway -n bankapp

-->& if Programmed=False, inspect Envoy Gateway: kubectl logs -n envoy-gateway-system deployment/envoy-gateway

<img width="605" height="437" alt="image" src="https://github.com/user-attachments/assets/62471c97-ebdc-4dff-9622-1cdd44af2de0" />



Step 7: Obtain the Public URL: 

-->Extract the NLB hostname: export APP_URL=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}')

-->To verify: echo $APP_URL

-->Display it: echo "AI-BankApp URL: http://$APP_URL"

<img width="587" height="532" alt="image" src="https://github.com/user-attachments/assets/35291a5a-d218-47ee-abf8-5decb2f77445" />


Step 8: Test Connectivity: 

-->Health Endpoint: curl http://$APP_URL/actuator/health

-->curl -s http://$APP_URL/actuator/health | python3 -m json.tool

<img width="710" height="636" alt="image" src="https://github.com/user-attachments/assets/4e6cbf43-7acd-4dc0-8004-a8462aaa42bd" />

-->Home Page Test: curl -s -o /dev/null -w "%{http_code}" http://$APP_URL

<img width="762" height="282" alt="image" src="https://github.com/user-attachments/assets/334f6869-02ff-40d2-b3a2-a2a86a587436" />

Step 9: If You Get 503: 

-->Check route: kubectl get httproute -n bankapp

-->Check service: kubectl get svc -n bankapp

-->Check endpoints: kubectl get endpoints -n bankapp

-->If endpoints are empty: kubectl describe svc bankapp-service -n bankapp

-->kubectl get pods --show-labels -n bankapp  [Here Likely a selector mismatch.]

Step 10: Access Through Browser: 

-->Open: http://<NLB-DNS-NAME> Ex: http://a1b2c3d4e5f6.us-west-2.elb.amazonaws.com

Step 11: Functional Testing: 

<img width="652" height="656" alt="image" src="https://github.com/user-attachments/assets/a359374b-1b3d-4f81-af10-734f23cbd11f" />

<img width="625" height="432" alt="image" src="https://github.com/user-attachments/assets/cc75b8b7-8351-4499-a840-f769bf4fca6d" />

<img width="707" height="372" alt="image" src="https://github.com/user-attachments/assets/7bc45d8c-7c71-4c49-ba44-2c75643d0605" />

Step 12: Verify Backend Connectivity: Watch logs while testing:

-->BankApp: kubectl logs -f deployment/bankapp -n bankapp

-->Ollama: kubectl logs -f deployment/ollama -n bankapp

-->MySQL: kubectl logs -f deployment/mysql -n bankapp

-->You should see: BankApp serving requests, MySQL queries executing, Ollama generating responses etc.

Step 13: Confirm AWS Resources: 

-->Check the Envoy service created by Gateway API: kubectl get svc -A

-->You can also verify directly in AWS: aws elbv2 describe-load-balancers --region us-west-2 [You should see an AWS Network Load Balancer associated with Envoy Gateway.]

**Final Validation Checklist:**

-->kubectl get gateway -n bankapp

-->kubectl get httproute -n bankapp

-->kubectl get all -n bankapp

-->curl http://$APP_URL/actuator/health

<img width="631" height="357" alt="image" src="https://github.com/user-attachments/assets/3fb920c0-a87e-4fa3-866f-9ee6863f3054" />

-->kubectl get gateway -n bankapp -o yaml

-->kubectl get gatewayclass

-->kubectl get pods -n envoy-gateway-system

kubectl logs -n envoy-gateway-system deployment/envoy-gateway


---

### Task 3: Deploy the Monitoring Stack
Deploy Prometheus and Grafana to monitor the AI-BankApp on EKS.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=3d \
  --set prometheus.prometheusSpec.resources.requests.memory=256Mi \
  --set prometheus.prometheusSpec.resources.requests.cpu=100m \
  --wait --timeout 600s
```

Verify:
```bash
kubectl get pods -n monitoring
```

**Access Grafana:**
```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

Open `http://localhost:3000`. Login: `admin` / `admin123`.

**The AI-BankApp exposes Prometheus metrics natively.** The Spring Boot Actuator endpoint at `/actuator/prometheus` provides JVM metrics, HTTP request metrics, and more.

Create a ServiceMonitor to scrape the BankApp:
```yaml
# bankapp-servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: bankapp-monitor
  namespace: monitoring
  labels:
    release: monitoring
spec:
  namespaceSelector:
    matchNames:
      - bankapp
  selector:
    matchLabels:
      app: bankapp
  endpoints:
    - port: "8080"
      path: /actuator/prometheus
      interval: 15s
```

```bash
kubectl apply -f bankapp-servicemonitor.yaml
```

**Access Prometheus:**
```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
```

Query AI-BankApp metrics:
```promql
# JVM memory usage
jvm_memory_used_bytes{namespace="bankapp"}

# HTTP request rate
rate(http_server_requests_seconds_count{namespace="bankapp"}[5m])

# HTTP request latency (95th percentile)
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket{namespace="bankapp"}[5m]))
```

Explore the pre-built Grafana dashboards:
- **Kubernetes / Compute Resources / Namespace (Pods)** -- select the `bankapp` namespace
- **Kubernetes / Compute Resources / Pod** -- drill into individual pods
- **Node Exporter / Nodes** -- EKS worker node health

**Steps to follow:**

-->This task adds a full observability stack to your EKS cluster using Prometheus + Grafana + kube-state-metrics + node-exporter + Alertmanager via the kube-prometheus-stack Helm chart.

<img width="652" height="675" alt="image" src="https://github.com/user-attachments/assets/bcee80ff-f99d-45f4-8de0-8bddd549e32c" />

Step 1: Verify Cluster Capacity: 

-->Before installing monitoring, check available resources: kubectl top nodes

-->Also verify nodes: kubectl get nodes



Step 2: Add Helm Repository: helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

-->helm repo update

-->Verify: helm repo list



Step 3: Install kube-prometheus-stack: Deploy the monitoring stack: 

-->helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace --set grafana.adminPassword=admin123 --set prometheus.prometheusSpec.retention=3d --set prometheus.prometheusSpec.resources.requests.memory=256Mi --set prometheus.prometheusSpec.resources.requests.cpu=100m --wait --timeout 600s

Note: This may take: 5–10 minutes because many CRDs and pods are created.


Step 4: Verify Installation: 

-->Check Helm release: helm list -n monitoring



Step 5: Verify Monitoring Pods: kubectl get pods -n monitoring [Here all pods should be running]



Step 6: Verify CRDs: Prometheus Operator should install CRDs automatically: kubectl get crds | grep monitoring.coreos.com


Step 7: Access Grafana: 

-->Forward the Grafana service: kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 [Keep this terminal open]

-->Open: http://localhost:3000  [login with Username: admin Password: admin123]


Step 8: Verify Grafana Datasource: 

-->kubectl get secret monitoring-grafana -n monitoring   [and inspect Grafana logs]

<img width="581" height="431" alt="image" src="https://github.com/user-attachments/assets/20ee4826-bf69-4c85-a333-2528461945f8" />



Step 9: Verify BankApp Metrics Endpoint: Before creating a ServiceMonitor, ensure metrics are exposed:

-->Find the service: kubectl get svc -n bankapp

-->Then test: kubectl port-forward svc/bankapp-service -n bankapp 8080:8080

-->In another terminal: curl http://localhost:8080/actuator/prometheus

-->Verify by running following query: management.endpoints.web.exposure.include=*

-->management.endpoint.prometheus.enabled=true

Step 10: Create ServiceMonitor: 

-->Create: vi bankapp-servicemonitor.yaml   [Paste the above given code]

-->kubectl apply -f bankapp-servicemonitor.yaml

-->Verify: kubectl get servicemonitor -n monitoring   [Expected: bankapp-monitor]

Step 11: Verify Service Labels: The most common issue is label mismatch:

-->Check the BankApp service: kubectl get svc bankapp-service -n bankapp --show-labels








---

### Task 4: End-to-End Validation Checklist
Run through the complete validation:

**Application layer:**
```bash
# All pods running and ready
kubectl get pods -n bankapp
echo "---"

# App responds on health endpoint
curl -s http://$APP_URL/actuator/health
echo "---"

# HPA is active and monitoring CPU
kubectl get hpa -n bankapp
echo "---"

# Prometheus metrics endpoint works
curl -s http://$APP_URL/actuator/prometheus | head -10
```

**Data layer:**
```bash
# MySQL is healthy with persistent storage
kubectl exec -n bankapp deploy/mysql -- mysqladmin ping -h localhost -uroot -pTest@123
echo "---"

# PVCs are bound to EBS volumes
kubectl get pvc -n bankapp
echo "---"

# Ollama has the model loaded
kubectl exec -n bankapp deploy/ollama -- ollama list
```

**Infrastructure layer:**
```bash
# Nodes are healthy
kubectl get nodes
kubectl top nodes
echo "---"

# Gateway is serving traffic
kubectl get gateway -n bankapp
echo "---"

# Monitoring is running
kubectl get pods -n monitoring | head -5
```

**Security layer:**
```bash
# BankApp runs as non-root (devsecops user)
kubectl exec -n bankapp deploy/bankapp -- whoami

# Secrets are not exposed in environment
kubectl get secret bankapp-secret -n bankapp -o yaml | grep -c "MYSQL_ROOT_PASSWORD"
```

---

### Task 5: Reflect on the Full EKS Journey
Map each concept to the day you learned it:

| Day | What You Built | AI-BankApp Connection |
|-----|---------------|----------------------|
| 81 | EKS cluster via Terraform, kubectl connection, manual deploy | Used the project's `terraform/` configs to provision infra |
| 82 | Gateway API, Envoy, TLS, EBS storage, session persistence | Used `k8s/gateway.yml`, `k8s/cert-manager.yml`, `k8s/pv.yml` |
| 83 | Full production deployment, monitoring, validation | Complete stack: app + DB + AI + networking + observability |

**What the AI-BankApp's EKS setup includes that you have now seen:**
- Terraform-provisioned VPC with 3-AZ networking
- Managed node group with auto-scaling
- 6 EKS add-ons (CoreDNS, VPC CNI, kube-proxy, Pod Identity, EBS CSI, Metrics Server)
- ArgoCD pre-installed (used on Days 84-86)
- Gateway API with Envoy for traffic management
- cert-manager for automated HTTPS
- Cookie-based session persistence for stateful app
- EBS persistent storage for MySQL and Ollama
- HPA with scale-up/down policies
- Spring Boot Actuator metrics for Prometheus
- Init containers for dependency ordering
- PostStart lifecycle hooks for Ollama model pull

**What you would add for a real production deployment:**
- DNS with Route 53 and ExternalDNS
- Network Policies for pod-to-pod isolation
- Pod Disruption Budgets for safe node draining
- External Secrets Operator for AWS Secrets Manager integration
- Database backups (automated MySQL dumps to S3)
- Log aggregation with Loki (you built this on Day 75)
- Multi-environment clusters (dev + prod)

---

### Task 6: Complete Teardown
**This is critical -- do not leave resources running.**

Delete workloads first:
```bash
# Delete monitoring
helm uninstall monitoring -n monitoring

# Delete Gateway resources (releases the NLB)
kubectl delete -f k8s/gateway.yml 2>/dev/null

# Delete the BankApp stack
kubectl delete -f k8s/hpa.yml
kubectl delete -f k8s/bankapp-deployment.yml
kubectl delete -f k8s/ollama-deployment.yml
kubectl delete -f k8s/mysql-deployment.yml
kubectl delete -f k8s/service.yml
kubectl delete -f k8s/secrets.yml
kubectl delete -f k8s/configmap.yml
kubectl delete -f k8s/pvc.yml
kubectl delete -f k8s/pv.yml
kubectl delete -f k8s/namespace.yml

# Delete Envoy Gateway
helm uninstall envoy-gateway -n envoy-gateway-system 2>/dev/null

# Delete cert-manager
helm uninstall cert-manager -n cert-manager 2>/dev/null

# Delete namespaces
kubectl delete namespace monitoring envoy-gateway-system cert-manager 2>/dev/null
```

Wait for all LoadBalancers and EBS volumes to be released:
```bash
# Check for lingering load balancers
kubectl get svc -A | grep LoadBalancer

# Check for lingering PVCs
kubectl get pvc -A
```

**Destroy the infrastructure with Terraform:**
```bash
cd terraform
terraform destroy
```

This takes 10-15 minutes. It deletes:
- EKS cluster and control plane
- All node groups and EC2 instances
- ArgoCD Helm release
- VPC, subnets, NAT gateway, internet gateway
- IAM roles and policies

**Verify in the AWS Console:**
- EKS: no clusters
- EC2: no instances, no load balancers, no EBS volumes
- VPC: the `bankapp-eks` VPC is gone
- CloudFormation: no lingering stacks

**Check your AWS bill** in the Billing Dashboard. All charges should stop within the hour.

**Cost for this 3-day lab (approximate):** $15-25 depending on how long you kept the cluster running.

---

## Hints
- `kubectl wait --for=condition=ready` is your friend for scripted deployments -- no need to keep running `kubectl get pods -w`
- The kube-prometheus-stack chart creates a `ServiceMonitor` CRD -- use it to scrape custom metrics from any app that exposes a `/metrics` or `/actuator/prometheus` endpoint
- Spring Boot Actuator + Micrometer + Prometheus is the standard JVM monitoring stack -- the AI-BankApp has this built in
- `terraform destroy` cleans up most resources, but check for orphaned EBS volumes and load balancers that were created by Kubernetes (not Terraform)
- If `terraform destroy` fails, manually delete lingering resources in the AWS Console and retry
- 3 days of EKS with 3x t3.medium should cost $15-25 -- less if you tore down overnight
- Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`)

---

## Documentation
Create `day-83-eks-project.md` with:
- Full architecture diagram (VPC -> EKS -> Nodes -> Pods -> Gateway -> NLB -> Internet)
- Screenshot of the AI-BankApp running on EKS (dashboard and AI chatbot)
- Screenshot of `kubectl get all -n bankapp` showing the complete stack
- Screenshot of Grafana dashboard with AI-BankApp metrics
- PromQL queries for JVM and HTTP metrics
- The complete validation checklist with results
- The teardown procedure
- Key takeaways from the 3-day EKS block
- Cost report for the lab

---

## Submission
1. Add `day-83-eks-project.md` to `2026/day-83/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Completed the EKS block -- deployed the AI-BankApp as a production-grade application on Amazon EKS. Spring Boot + MySQL + Ollama AI chatbot, all running on managed Kubernetes with Gateway API for traffic routing, EBS persistent storage, HPA autoscaling, and Prometheus + Grafana monitoring. Three days from Terraform init to a fully observed, auto-scaling banking app with an AI chatbot. Tore it all down cleanly with terraform destroy."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
