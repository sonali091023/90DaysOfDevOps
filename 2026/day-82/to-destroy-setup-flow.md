
Build Everything Again:

Step 1: Create Infrastructure: terraform apply -auto-approve

Step 2: Configure kubectl: aws eks update-kubeconfig --region ap-south-1 --name bankapp-eks & To verify: kubectl get nodes

Step 3: Install Envoy Gateway: helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm --version v1.4.0 -n envoy-gateway-system --create-namespace --wait & then to verify: kubectl get 
pods -n envoy-gateway-system

Step 4: Install Gateway API CRDs: kubectl get crd | grep gateway

Step 5: Install cert-manager: helm repo add jetstack https://charts.jetstack.io & To update: helm repo update

-->Then install: helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set crds.enabled=true --wait

-->then verify: kubectl get pods -n cert-manager

Step 6: Deploy AI-BankApp: kubectl apply -f k8s/namespace.yml && kubectl apply -f k8s/pv.yml && kubectl apply -f k8s/pvc.yml && kubectl apply -f k8s/configmap.yml && kubectl apply -f k8s/secrets.yml && kubectl apply -f k8s/mysql-deployment.yml && kubectl apply -f k8s/service.yml && kubectl apply -f k8s/ollama-deployment.yml && kubectl apply -f k8s/bankapp-deployment.yml && kubectl apply -f k8s/hpa.yml && kubectl apply -f k8s/gateway.yml

Step 7: Verify Pods: kubectl get pods -n bankapp

Step 8: Verify Gateway: kubectl get gateway -n bankapp

Step 9: Verify Certificate: kubectl get certificate -n bankapp -w

Step 10: Access Application: 

-->Get LoadBalancer address: kubectl get gateway -n bankapp

-->Open in browser: https://<your-domain-or-nip.io-hostname> 

===========================
Cleanup the setup:

-->This removes the BankApp workload but keeps the EKS cluster.

-->kubectl delete -f k8s/gateway.yml 2>/dev/null && kubectl delete -f k8s/hpa.yml && kubectl delete -f k8s/bankapp-deployment.yml &&kubectl delete -f k8s/ollama-deployment.yml && kubectl delete -f k8s/mysql-deployment.yml && kubectl delete -f k8s/service.yml && kubectl delete -f k8s/secrets.yml && kubectl delete -f k8s/configmap.yml && kubectl delete -f k8s/pvc.yml && kubectl delete -f k8s/pv.yml && kubectl delete -f k8s/namespace.yml

-->kubectl get all -A

-->kubectl get ns

-->kubectl delete ns argocd

-->kubectl delete ns bankapp

-->kubectl delete ns cert-manager

-->kubectl delete ns envoy-gateway-system

-->Once again verify: kubectl get ns

-->kubectl get pods -A

-->kubectl get svc -A

-->Then go inside terraform dir: cd terraform & terraform state list: You should see resources such as: VPC, Subnets, Internet Gateway, NAT Gateway, Route Tables, EKS Cluster, Node Groups etc.

-->run: terraform destroy: So Terraform will delete: EKS Cluster, Managed Node Groups, VPC, Public/Private Subnets,NAT Gateway, Internet Gateway, Security Groups, IAM Roles, Route Tables etc.

-->aws eks list-clusters

-->aws eks delete-cluster --name bankapp-eks --region ap-south-1

-->aws eks describe-cluster --name bankapp-eks --region ap-south-1

======================================
If you want to completely destroy the Day-82 AI-BankApp setup on EKS, do it in the reverse order of creation.

1. Delete Application Resources

Delete BankApp resources first:

kubectl delete -f k8s/certificate.yml
kubectl delete -f k8s/cert-manager.yml
kubectl delete -f k8s/gateway.yml
kubectl delete -f k8s/

Or delete the namespace:

kubectl delete namespace bankapp

Verify:

kubectl get ns
2. Delete Envoy Gateway

Check release:

helm list -A

Remove Envoy Gateway:

helm uninstall envoy-gateway -n envoy-gateway-system

Delete namespace:

kubectl delete namespace envoy-gateway-system

Wait until the AWS NLB disappears:

kubectl get svc -A

or

aws elbv2 describe-load-balancers

Make sure the NLB created by Envoy is gone before destroying EKS.

3. Delete cert-manager (Optional)

If you're done with TLS experiments:

helm uninstall cert-manager -n cert-manager

Delete namespace:

kubectl delete namespace cert-manager

Delete CRDs:

kubectl delete crd certificates.cert-manager.io
kubectl delete crd certificaterequests.cert-manager.io
kubectl delete crd challenges.acme.cert-manager.io
kubectl delete crd clusterissuers.cert-manager.io
kubectl delete crd issuers.cert-manager.io
kubectl delete crd orders.acme.cert-manager.io

Verify:

kubectl get crd | grep cert-manager

Should return nothing.

4. Delete ArgoCD (if no longer needed)
helm uninstall argocd -n argocd
kubectl delete namespace argocd
5. Verify Cluster Is Clean
kubectl get all -A

You should only see system namespaces:

kube-system
default
kube-public
kube-node-lease
6. Destroy EKS Using Terraform

Go to your Terraform directory:

cd terraform

Review what will be removed:

terraform plan -destroy

Destroy everything:

terraform destroy

Or skip approval:

terraform destroy -auto-approve

Terraform will remove:

EKS Cluster
Managed Node Groups
VPC
Subnets
Internet Gateway
NAT Gateway
Security Groups
IAM Roles
Route Tables
7. Verify EKS Is Gone
aws eks list-clusters

Expected:

{
  "clusters": []
}

Check EC2 instances:

aws ec2 describe-instances \
--filters "Name=instance-state-name,Values=running"

Check load balancers:

aws elbv2 describe-load-balancers

Check VPCs:

aws ec2 describe-vpcs

The BankApp VPC should no longer exist.

Quick Cleanup Sequence
kubectl delete namespace bankapp

helm uninstall envoy-gateway -n envoy-gateway-system
kubectl delete namespace envoy-gateway-system

helm uninstall cert-manager -n cert-manager
kubectl delete namespace cert-manager

helm uninstall argocd -n argocd
kubectl delete namespace argocd

cd terraform
terraform destroy -auto-approve

After terraform destroy, always verify in AWS Console (EKS, EC2, VPC, ELB) that no resources remain, because orphaned NLBs, NAT Gateways, and EIPs are common sources of unexpected AWS charges.
