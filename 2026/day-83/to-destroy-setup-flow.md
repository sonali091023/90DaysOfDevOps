# AI-BankApp Deployment with EKS, Envoy Gateway & HTTPS

## Step 1: Create AWS Infrastructure

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### Verify EKS Cluster

```bash
aws eks update-kubeconfig --region ap-south-1 --name bankapp-eks

kubectl get nodes
```

Expected:

```bash
NAME                STATUS   ROLES    AGE
ip-xxx-xxx-xxx      Ready    <none>   xxm
```

---

## Step 2: Install Envoy Gateway

```bash
helm install envoy-gateway \
oci://docker.io/envoyproxy/gateway-helm \
--version v1.4.0 \
-n envoy-gateway-system \
--create-namespace \
--wait
```

### Verify

```bash
kubectl get pods -n envoy-gateway-system
```

All pods should be Running.

---

## Step 3: Verify Gateway API CRDs

```bash
kubectl get crd | grep gateway
```

Expected CRDs include:

```bash
gatewayclasses.gateway.networking.k8s.io
gateways.gateway.networking.k8s.io
httproutes.gateway.networking.k8s.io
```

---

## Step 4: Install cert-manager

Add repository:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

Install cert-manager:

```bash
helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--set crds.enabled=true \
--wait
```

### Enable Gateway API Support

Edit deployment:

```bash
kubectl edit deployment cert-manager -n cert-manager
```

Add:

```yaml
- --enable-gateway-api
```

Restart:

```bash
kubectl rollout restart deployment cert-manager -n cert-manager
kubectl rollout status deployment cert-manager -n cert-manager
```

### Verify

```bash
kubectl get pods -n cert-manager
kubectl get crd | grep cert-manager
```

---

## Step 5: Deploy AI-BankApp Resources

Create namespace:

```bash
kubectl apply -f k8s/namespace.yml
```

Storage:

```bash
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
```

Configuration:

```bash
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secrets.yml
```

Database:

```bash
kubectl apply -f k8s/mysql-deployment.yml
```

Services:

```bash
kubectl apply -f k8s/service.yml
```

Ollama:

```bash
kubectl apply -f k8s/ollama-deployment.yml
```

Application:

```bash
kubectl apply -f k8s/bankapp-deployment.yml
```

Autoscaling:

```bash
kubectl apply -f k8s/hpa.yml
```

Gateway:

```bash
kubectl apply -f k8s/gateway.yml
```

---

## Step 6: Create ClusterIssuer

```bash
kubectl apply -f k8s/cert-manager.yml
```

Verify:

```bash
kubectl get clusterissuer
```

Expected:

```bash
letsencrypt-prod   True
```

---

## Step 7: Verify Application Pods

```bash
kubectl get pods -n bankapp
```

Expected:

```bash
mysql
ollama
bankapp
```

All should be Running.

---

## Step 8: Verify Gateway

```bash
kubectl get gateway -n bankapp
```

Expected:

```bash
PROGRAMMED   True
```

Detailed status:

```bash
kubectl describe gateway bankapp-gateway -n bankapp
```

Verify:

```text
Accepted=True
Programmed=True
ResolvedRefs=True
```

---

## Step 9: Verify HTTPRoute

```bash
kubectl get httproute -n bankapp
```

```bash
kubectl describe httproute bankapp-route -n bankapp
```

Verify route is attached to the Gateway.

---

## Step 10: Verify TLS Certificate

Since Gateway Shim automatically creates the Certificate:

```bash
kubectl get certificate -n bankapp
```

Expected:

```bash
bankapp-tls   True
```

Check secret:

```bash
kubectl get secret bankapp-tls -n bankapp
```

---

## Step 11: Get Application URL

```bash
kubectl get gateway -n bankapp
```

Example:

```text
a952d00babff943608d08c0779ddb4ee-1493228670.ap-south-1.elb.amazonaws.com
```

Determine the public IP:

```bash
nslookup <elb-address>
```

Create hostname:

```text
<public-ip>.nip.io
```

Example:

```text
52.66.56.118.nip.io

-->Updatre the same in the /k8sgateway.yml file for http & https infront of hostname: 52.66.56.118.nip.io

-->& then reconfigure the file: kubectl apply -f k8s/gateway.yml Once it gets completed to confirm run command: kubectl get httproute -n bankapp
```

---

## Step 12: Access Application

HTTP:

```text
http://52.66.56.118.nip.io
```

HTTPS:

```text
https://52.66.56.118.nip.io
```

Verify:

```bash
curl -I http://52.66.56.118.nip.io
curl -k -I https://52.66.56.118.nip.io
```

```bash
Deploy Prometheus and Grafana to monitor the AI-BankApp on EKS:

-->helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

-->helm repo update

-->helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=3d \
  --set prometheus.prometheusSpec.resources.requests.memory=256Mi \
  --set prometheus.prometheusSpec.resources.requests.cpu=100m \
  --wait --timeout 600s

-->Verify: kubectl get pods -n monitoring

-->Access Grafana: In one terminal run: kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 & in Browser run: http://localhost:3000 [Login creds: admin/admin123]

-->Create a ServiceMonitor to scrape the BankApp:

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
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090 & in Browser run: http://localhost:9090

```
---

## Final Validation

```bash
kubectl get nodes
kubectl get pods -n bankapp
kubectl get svc -n bankapp
kubectl get gateway -n bankapp
kubectl get httproute -n bankapp
kubectl get certificate -n bankapp
kubectl get hpa -n bankapp
```

Everything should be Healthy, Running and Ready.

====================================================================================

# AI-BankApp Cleanup / Destroy Commands

## Step 1: Delete Application Resources

```bash
kubectl delete -f k8s/hpa.yml
kubectl delete -f k8s/gateway.yml
kubectl delete -f k8s/bankapp-deployment.yml
kubectl delete -f k8s/ollama-deployment.yml
kubectl delete -f k8s/mysql-deployment.yml
kubectl delete -f k8s/service.yml
kubectl delete -f k8s/configmap.yml
kubectl delete -f k8s/secrets.yml
kubectl delete -f k8s/pvc.yml
kubectl delete -f k8s/pv.yml
kubectl delete -f k8s/namespace.yml
```

Verify:

```bash
kubectl get all -n bankapp
```

Expected:

```text
No resources found
```

---

## Step 2: Delete ClusterIssuer

```bash
kubectl delete -f k8s/cert-manager.yml
```

Verify:

```bash
kubectl get clusterissuer
```

---

## Step 3: Uninstall cert-manager

```bash
helm uninstall cert-manager -n cert-manager
```

Verify:

```bash
kubectl get pods -n cert-manager
```

Expected:

```text
No resources found
```

Optionally remove the namespace:

```bash
kubectl delete namespace cert-manager
```

---

## Step 4: Uninstall Envoy Gateway

```bash
helm uninstall envoy-gateway -n envoy-gateway-system
```

Verify:

```bash
kubectl get pods -n envoy-gateway-system
```

Expected:

```text
No resources found
```

Optionally remove the namespace:

```bash
kubectl delete namespace envoy-gateway-system
```

---

## Step 5: Destroy AWS Infrastructure

Navigate to Terraform directory:

```bash
cd terraform
```

Review resources:

```bash
terraform plan -destroy
```

Destroy:

```bash
terraform destroy -auto-approve
```

---

## Step 6: Verify EKS Cluster Removal

Check EKS clusters:

```bash
aws eks list-clusters --region ap-south-1
```

Verify nodes are inaccessible:

```bash
kubectl get nodes
```

Expected:

```text
Unable to connect to the server
```

---

## Step 7: Verify AWS Resources

Ensure these are removed:

```bash
aws eks list-clusters --region ap-south-1
aws ec2 describe-instances --region ap-south-1
```

There should be no EKS worker nodes or EKS cluster remaining.

Quick Destroy Version

If you're tearing everything down and don't care about Kubernetes cleanup first:

cd terraform
terraform destroy -auto-approve

Since EKS is managed by Terraform, destroying the cluster will automatically remove all Kubernetes resources inside it.

Recommended for Day 83 Practice
1. Delete application resources
2. Delete ClusterIssuer
3. Uninstall cert-manager
4. Uninstall Envoy Gateway
5. terraform destroy -auto-approve

This teaches the full lifecycle and lets you verify each component is cleaned up properly before the cluster disappears.
