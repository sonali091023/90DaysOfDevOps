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

**Steps to follow:**

Step 1: Verify the cluster is still accessible: Before deleting anything, make sure you're connected to the cluster: kubectl get nodes

Step 2: Delete the Monitoring Stack: If you installed Prometheus and Grafana using Helm: helm uninstall monitoring -n monitoring

-->& then verify: helm list -A  [Expected: monitoring should no longer appear.]

Step 3: Delete the Gateway Resources: Delete the Gateway first so AWS can start removing the Network Load Balancer:

-->kubectl delete -f k8s/gateway.yml

-->& if If you have a separate HTTPRoute file, delete it as well: kubectl delete -f k8s/httproute.yml

-->& then verify: kubectl get gateway -A

kubectl get httproute -A

<img width="1917" height="792" alt="image" src="https://github.com/user-attachments/assets/5e421e27-00d5-4e56-9a82-6944809f9787" />

Step 4: Delete the AI-BankApp Resources: Delete resources in the following order: kubectl delete -f k8s/hpa.yml

-->kubectl delete -f k8s/bankapp-deployment.yml

-->kubectl delete -f k8s/ollama-deployment.yml

-->kubectl delete -f k8s/mysql-deployment.yml

-->kubectl delete -f k8s/service.yml

-->kubectl delete -f k8s/secrets.yml

-->kubectl delete -f k8s/configmap.yml

-->kubectl delete -f k8s/pvc.yml

-->kubectl delete -f k8s/pv.yml

-->kubectl delete -f k8s/namespace.yml

-->& then verify: kubectl get all -A    [Expected: You should only see system components.]

Step 5: Remove Envoy Gateway: helm uninstall envoy-gateway -n envoy-gateway-system

-->& then verify: helm list -A

Step 6: Remove cert-manager: helm uninstall cert-manager -n cert-manager

-->& then verify: helm list -A

Step 7: Delete the Namespaces: kubectl delete namespace monitoring

-->kubectl delete namespace envoy-gateway-system

-->& then to verify: kubectl get ns

Step 8: Ensure AWS Resources Are Released: Check for LoadBalancer Services: kubectl get svc -A

-->There should be no services with: TYPE = LoadBalancer & If any remain, wait a few minutes for AWS to delete them.

-->Check Persistent Volume Claims: kubectl get pvc -A

-->Check Persistent Volumes: kubectl get pv

Step 9: Destroy the Infrastructure: Navigate to your Terraform directory: cd terraform && terraform destroy --auto-destroy

<img width="717" height="480" alt="image" src="https://github.com/user-attachments/assets/c5bed215-a2d4-4312-8ff4-ef52e54363f3" />

Step 10: Verify Terraform Finished: The final output should look similar to: 

<img width="717" height="480" alt="image" src="https://github.com/user-attachments/assets/ab08a0e7-bdd0-41aa-a548-f6b3e3fdd99d" />

Step 11: Verify in AWS: 

<img width="857" height="597" alt="image" src="https://github.com/user-attachments/assets/06d84eed-d88d-4009-9af5-61e4457a13d7" />

Step 12: Check AWS Billing: Within an hour, the resources should no longer generate charges. Review the Billing Dashboard to confirm there are no unexpected running resources.

<img width="1086" height="292" alt="image" src="https://github.com/user-attachments/assets/7e134d35-3a2a-4a61-b404-73b0f395a94f" />

Final Validation Checklist: Run these commands before leaving the lab: kubectl get nodes:

-->So above command should fail after the cluster is destroyed because the Kubernetes API is no longer available: terraform destroy

<img width="952" height="377" alt="image" src="https://github.com/user-attachments/assets/909fa5cc-3509-497b-921e-1afc91bec5ce" />

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
