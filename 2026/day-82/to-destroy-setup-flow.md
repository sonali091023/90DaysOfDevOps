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
