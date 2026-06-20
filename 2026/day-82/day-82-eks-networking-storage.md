# Day 82 -- EKS Networking with Gateway API and Persistent Storage

## Task
Your EKS cluster is running and the AI-BankApp deployed with raw manifests. But production needs proper ingress, HTTPS, session persistence, and reliable storage. The AI-BankApp project uses the Kubernetes Gateway API with Envoy Gateway instead of traditional Ingress -- the next generation of Kubernetes traffic management.

Today you set up the Gateway API, configure TLS with cert-manager, understand EBS storage in action, and explore the AI-BankApp's production networking setup.

Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch `feat/gitops`) -- `k8s/gateway.yml`, `k8s/cert-manager.yml`, `k8s/pv.yml`, `k8s/pvc.yml`

---

## Expected Output
- Envoy Gateway installed on EKS
- Gateway API resources (GatewayClass, Gateway, HTTPRoute) configured
- cert-manager installed with Let's Encrypt ClusterIssuer
- EBS persistent storage working for MySQL and Ollama
- Understanding of session persistence for stateful web apps
- A markdown file: `day-82-eks-networking-storage.md`

---

## Challenge Tasks

### Task 1: Understand Gateway API vs Ingress
The AI-BankApp uses the Gateway API instead of the traditional Ingress resource. Research the differences:

| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| API maturity | Stable but limited | GA since Kubernetes 1.26 |
| Traffic splitting | Not supported | Built-in (weighted backends) |
| Header matching | Annotation-dependent | Native HTTPRoute rules |
| Role separation | Single resource | GatewayClass (infra) -> Gateway (ops) -> HTTPRoute (dev) |
| TLS management | Annotation-based | Native TLS config in Gateway listeners |
| Session affinity | Not standardized | BackendTrafficPolicy (with Envoy) |

**The AI-BankApp's Gateway architecture:**
```
[Internet]
    |
[AWS NLB] (created by Envoy Gateway)
    |
[Gateway: bankapp-gateway]
  |-- Listener: HTTP (port 80)
  |-- Listener: HTTPS (port 443, TLS terminated)
    |
[HTTPRoute: bankapp-route]
    |
[Service: bankapp-service:8080]
    |
[Pods: bankapp x2-4] (with session affinity via cookie)
```

**Steps to follow:**

Task 1: Understand Gateway API vs Ingress:

**Q. What is Ingress?**

-->Ingress is the traditional Kubernetes resource used to expose HTTP and HTTPS services outside the cluster.

<img width="867" height="456" alt="image" src="https://github.com/user-attachments/assets/fc01fa73-95a0-4cd2-a2bb-14b17c45b5a4" />

**Q. What is Gateway API?**

-->Gateway API is the next-generation Kubernetes traffic management API designed to overcome Ingress limitations.

<img width="911" height="530" alt="image" src="https://github.com/user-attachments/assets/133ffb7e-9bed-4a89-b4dd-0e4ae92b2bfb" />

<img width="872" height="576" alt="image" src="https://github.com/user-attachments/assets/15e56bf9-73a1-4ac9-8f67-3b0e57ca2552" />

**Role Separation in Gateway API: One of the biggest improvements is separation of concerns.**

<img width="730" height="777" alt="image" src="https://github.com/user-attachments/assets/7d98f0fd-c60b-4775-97f3-7e1728df6ce2" />

<img width="750" height="480" alt="image" src="https://github.com/user-attachments/assets/7ad30830-de2a-4176-bf3f-04d2521ad498" />

<img width="797" height="420" alt="image" src="https://github.com/user-attachments/assets/f479c4d2-d0a8-4eeb-8738-a663b293f123" />

**Request Flow:**

Step 1: User Accesses Application: https://bank.example.com [Expected: Request arrives from the internet.]

Step 2: AWS NLB Receives Traffic: The Envoy Gateway controller automatically provisions an AWS Network Load Balancer.

**Flow:** Internet --> NLB

**Benefits:** High availability, Layer-4 load balancing, Static endpoint etc.

Step 3: Gateway Handles Listeners: The Gateway listens on:

<img width="490" height="217" alt="image" src="https://github.com/user-attachments/assets/79cd1375-3af7-4eb4-9685-7521d9a5e942" />

-->Functions: Accept connections, TLS termination, Forward traffic to routes etc.

Step 4: HTTPRoute Matches Requests: 

<img width="710" height="426" alt="image" src="https://github.com/user-attachments/assets/d7e714d1-f530-4dc8-9f46-fd69cd35a3e0" />

Step 5: Service Load Balances Traffic: 

<img width="716" height="817" alt="image" src="https://github.com/user-attachments/assets/05b9d4e4-36f3-4c61-ab35-db934b763033" />

**Session Affinity in AI-BankApp:** Banking applications often require users to remain connected to the same backend instance.

-->Gateway API with Envoy supports: kind: BackendTrafficPolicy

<img width="605" height="277" alt="image" src="https://github.com/user-attachments/assets/27ee702a-495f-4c98-93fd-baa043907401" />

-->Benefits: Consistent user sessions, Better user experience, Reduced re-authentication etc.

<img width="720" height="266" alt="image" src="https://github.com/user-attachments/assets/aaad2033-e991-4753-bc30-6ae221b3b55c" />

-->**Key Takeaway:** Ingress is suitable for simple applications and legacy Kubernetes environments.

**Note:** Gateway API is the modern Kubernetes networking standard, offering advanced routing, traffic management, session persistence, TLS handling, and team-based ownership. The AI-BankApp adopts Gateway API because it provides enterprise-grade traffic control and integrates cleanly with Envoy Gateway on AWS.

---

### Task 2: Install Envoy Gateway
Envoy Gateway is the Gateway API implementation the AI-BankApp uses.

Install via Helm:
```bash
helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version v1.4.0 \
  -n envoy-gateway-system --create-namespace \
  --wait
```

Verify:
```bash
kubectl get pods -n envoy-gateway-system
kubectl get gatewayclass
```

You should see the `envoy-gateway` GatewayClass registered.

Now install the Gateway API CRDs if not already present:
```bash
kubectl get crd gateways.gateway.networking.k8s.io 2>/dev/null || \
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

**Steps to follow:**

-->**Note:** Before installing Envoy Gateway, make sure your cluster is running and reachable:

-->**Objective:** Install Envoy Gateway, verify that it is running correctly, and ensure the Gateway API CRDs are available in your Kubernetes cluster.

Step 1: Check Your Kubernetes Cluster: Before installing Envoy Gateway, verify that your cluster is healthy.

-->kubectl cluster-info

**Issue Faced:**

<img width="1912" height="440" alt="image" src="https://github.com/user-attachments/assets/3ebf5eac-dfa0-4114-9910-3840fbf30ff6" />

-->So Earlier, your kubeconfig contained an old EKS endpoint: 971ACC79F2FCE0E88742C203EACE9B38.gr7.ap-south-1.eks.amazonaws.com

-->But the current active cluster endpoint is: D4F866F4406116FB00BFB3515BD61E7C.gr7.ap-south-1.eks.amazonaws.com

-->So the issue was a stale kubeconfig that pointed to a previous EKS endpoint. Running: To fix this run command: 

-->aws eks update-kubeconfig --region ap-south-1 --name bankapp-eks [updated your kubeconfig with the correct endpoint]

-->verify the created nodes: kubectl get nodes

-->So then current status is EKS cluster exists, Cluster status is ACTIVE, kubeconfig is fixed, Worker nodes are Ready, kubectl connectivity is working etc.

-->kubectl get nodes

<img width="1885" height="262" alt="image" src="https://github.com/user-attachments/assets/00c0d742-446c-40fd-b4c5-46fafb59a502" />

Step 2: Verify Helm Installation: 

-->Check Helm version: helm version

<img width="1781" height="82" alt="image" src="https://github.com/user-attachments/assets/b6e1a41c-4e7f-4ac4-a7a7-e7a47d62a820" />

**Note:** If helm is not installed: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

Step 3: Install Envoy Gateway: 

-->helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm --version v1.4.0 -n envoy-gateway-system --create-namespace --wait

<img width="722" height="466" alt="image" src="https://github.com/user-attachments/assets/2a3b8fca-d166-4134-a0eb-e5e337a62ae1" />

<img width="1917" height="747" alt="image" src="https://github.com/user-attachments/assets/e001ff9f-7c5f-4318-b1d0-ab00bb7cf452" />

Step 4: Verify Pods: Check that Envoy Gateway components are running:

-->kubectl get pods -n envoy-gateway-system

<img width="1757" height="96" alt="image" src="https://github.com/user-attachments/assets/11db1049-b0bb-44a7-a8d7-2798eea6baa1" />

**And If pods are not running then use below commands to verify:**

-->kubectl describe pod -n envoy-gateway-system <pod-name>

-->kubectl logs -n envoy-gateway-system <pod-name>

Step 5: Verify GatewayClass: Check whether Envoy Gateway registered itself:

-->kubectl get gatewayclass

Note: This confirms Envoy Gateway is now the Gateway API controller for your cluster.

Issue faced: 

<img width="1830" height="45" alt="image" src="https://github.com/user-attachments/assets/39002559-8cf0-4c7a-92b9-20f8f172c6fa" />

-->This means Envoy Gateway is running correctly, Gateway API CRDs are installed, But there is no GatewayClass resource for Envoy Gateway to manage. 

-->To fix this use Option 1: To create file **vi gatewayclass.yaml**

<img width="626" height="256" alt="image" src="https://github.com/user-attachments/assets/27c38d04-7c37-401e-820f-f077f8ac1ba8" />

-->Then automate: kubectl apply -f gatewayclass.yaml

-->Option 2: Is directly create it from the terminal for that use below command:

cat <<EOF | kubectl apply -f -

apiVersion: gateway.networking.k8s.io/v1

kind: GatewayClass

metadata:

  name: envoy-gateway

spec:

  controllerName: gateway.envoyproxy.io/gatewayclass-controller

EOF

-->This creates the resource directly in Kubernetes.

-->Again run the command to check if the envoy gateway registerd itself: kubectl get gatewayclass

<img width="1607" height="87" alt="image" src="https://github.com/user-attachments/assets/eab09e30-9435-4f64-911d-9a1b82199ed6" />

-->This confirms Envoy Gateway is now the Gateway API controller for your cluster.

Step 6: Check Whether Gateway API CRDs Exist: 

-->kubectl get crd gateways.gateway.networking.k8s.io

<img width="1611" height="102" alt="image" src="https://github.com/user-attachments/assets/46d2784a-f63c-4771-88e3-228cd92f0f25" />

Step 7: Verify Gateway API Resources: 

-->Check the installed Gateway API resources: kubectl api-resources | grep gateway

<img width="1707" height="417" alt="image" src="https://github.com/user-attachments/assets/d382716c-daf2-4ba6-a260-f76e93b87775" />

Step 9: Final Verification: 

-->kubectl get pods -n envoy-gateway-system

-->kubectl get gatewayclass

-->kubectl get crd gateways.gateway.networking.k8s.io

-->kubectl api-resources | grep gateway

<img width="1681" height="575" alt="image" src="https://github.com/user-attachments/assets/c4d52905-da9a-4149-9013-ba91a7f84fe9" />

-->So Envoy Gateway pod is Running, envoy-gateway GatewayClass exists, Gateway API CRDs are installed, Gateway resources appear in kubectl api-resources etc.

**Common Issues:**

1. helm: command not found: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

2. Kubernetes cluster unreachable:

-->Check cubeconfig: kubectl config current-context

-->kubectl get nodes

-->For kind: kind get clusters

3. GatewayClass Not Found: Sometimes the CRDs were installed after Envoy Gateway.

Restart the deployment: kubectl rollout restart deployment -n envoy-gateway-system Then verify again: kubectl get gatewayclass

-->Still if gatewayClass not found manually creare that as mentioned above.

4. OCI Pull Errors: Authenticate with Docker Hub if rate-limited: docker login OR pull again after a few minutes.

---

### Task 3: Deploy the AI-BankApp with Gateway API
Make sure the app is deployed (from Day 81):
```bash
kubectl get pods -n bankapp
```

If not running, redeploy the core manifests:
```bash
cd AI-BankApp-DevOps
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/mysql-deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/ollama-deployment.yml
kubectl apply -f k8s/bankapp-deployment.yml
kubectl apply -f k8s/hpa.yml
```

**Now study and apply the Gateway configuration.**

Open `k8s/gateway.yml` and understand each resource:

**1. GatewayClass** -- defines which controller handles Gateways:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy-gateway
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

**2. Gateway** -- creates the actual load balancer with listeners:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: bankapp-gateway
  namespace: bankapp
spec:
  gatewayClassName: envoy-gateway
  listeners:
    - name: http
      protocol: HTTP
      port: 80
    - name: https
      protocol: HTTPS
      port: 443
      hostname: <your-ip>.nip.io
      tls:
        mode: Terminate
        certificateRefs:
          - name: bankapp-tls
```

When this is applied, Envoy Gateway creates an AWS NLB (Network Load Balancer) automatically.

**3. HTTPRoute** -- routes traffic to the BankApp service:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: bankapp-route
  namespace: bankapp
spec:
  parentRefs:
    - name: bankapp-gateway
      sectionName: https
    - name: bankapp-gateway
      sectionName: http
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: bankapp-service
          port: 8080
```
**4. BackendTrafficPolicy** -- session persistence via cookies:
```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: bankapp-session
  namespace: bankapp
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: bankapp-route
  loadBalancer:
    type: ConsistentHash
    consistentHash:
      type: Cookie
      cookie:
        name: BANKAPP_AFFINITY
        ttl: 3600s
```

**Why cookie-based session affinity?** The AI-BankApp uses Spring Security with form-based login. Without session affinity, a user's requests could hit different pods, and they would be logged out. The `BANKAPP_AFFINITY` cookie ensures all requests from a user go to the same pod.

Apply the Gateway configuration:
```bash
kubectl apply -f k8s/gateway.yml
```

Wait for the NLB to be provisioned:
```bash
kubectl get gateway -n bankapp -w
```

Get the external IP:
```bash
export GATEWAY_IP=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}')
echo "App URL: http://$GATEWAY_IP"
```

Test access:
```bash
curl http://$GATEWAY_IP
```

**Steps to floow:**

-->Great! Before applying the Gateway resources, let's verify the prerequisites and understand what each resource is doing.

Step 1: Verify AI-BankApp is Running: kubectl get pods -n bankapp

-->Also verify services: kubectl get svc -n bankapp

-->So AI-BankApp is not deployed yet to this EKS cluster yet, Thats why we cant see any resource yet

<img width="1297" height="287" alt="image" src="https://github.com/user-attachments/assets/34fbbde2-18b0-48c2-bb1f-21e4019b42ee" />

-->Command used: cd AI-BankApp-DevOps && kubectl apply -f k8s/namespace.yml && kubectl apply -f k8s/pv.yml && kubectl apply -f k8s/pvc.yml && kubectl apply -f k8s/configmap.yml && kubectl apply -f k8s/secrets.yml && kubectl apply -f k8s/mysql-deployment.yml && kubectl apply -f k8s/service.yml && kubectl apply -f k8s/ollama-deployment.yml && kubectl apply -f k8s/bankapp-deployment.yml && kubectl apply -f k8s/hpa.yml  && kubectl apply -f cert-manager.yml 

<img width="1895" height="337" alt="image" src="https://github.com/user-attachments/assets/d7ced32c-2dd4-4524-9cd7-ef871cd67a62" />

<img width="1397" height="277" alt="image" src="https://github.com/user-attachments/assets/d4331e90-cf12-4cf3-9cb0-1742af748504" />

Step 2: Check the Gateway Manifest: 

<img width="892" height="520" alt="image" src="https://github.com/user-attachments/assets/c8ae9484-fa54-443f-9ed5-9e7c3a910296" />

Step 3: Apply Gateway Resources: kubectl apply -f k8s/gateway.yml

Now: Verify Resources

Step 4: Verify GatewayClass Exists: kubectl get gatewayclass

<img width="1395" height="92" alt="image" src="https://github.com/user-attachments/assets/d919e3e0-9426-4f57-b977-3f3c8d340015" />

Step 5: Examine the Gateway Resource: The Gateway acts like an Ingress Controller entry point.

<img width="422" height="690" alt="image" src="https://github.com/user-attachments/assets/b51daa51-3458-403a-b82a-2a1670ef2aaf" />

<img width="632" height="460" alt="image" src="https://github.com/user-attachments/assets/dab9a7ef-b3ce-4cf8-85d0-b2889bd81cd4" />

Step 6: About hostname: <your-ip>.nip.io: You'll need the Load Balancer IP/hostname later.

<img width="776" height="405" alt="image" src="https://github.com/user-attachments/assets/89db4102-5559-4350-abcb-4dd150ec590c" />

Step 7: Understand HTTPRoute: The HTTPRoute replaces traditional Ingress rules.

<img width="570" height="546" alt="image" src="https://github.com/user-attachments/assets/3b970818-4e04-4c69-b683-b9fd86582378" />

-->sends traffic to: kubectl get svc bankapp-service -n bankapp

-->Verify that the service really exposes port 8080: kubectl describe svc bankapp-service -n bankapp

<img width="1350" height="486" alt="image" src="https://github.com/user-attachments/assets/9e37d50b-ec71-4d00-8841-578e36b8920f" />

-->kubectl get backendtrafficpolicy -n bankapp

<img width="1512" height="87" alt="image" src="https://github.com/user-attachments/assets/c2a7c6d2-228a-4c50-8b41-9b970e4df521" />

Step 8: Apply the Gateway Resources: 

-->First inspect the file: cat k8s/gateway.yml

<img width="705" height="486" alt="image" src="https://github.com/user-attachments/assets/87ef541f-f191-4292-aee9-eb9e4ece286e" />

<img width="1427" height="981" alt="image" src="https://github.com/user-attachments/assets/f3b2a9a7-556a-45e6-a649-2aa23af91531" />

<img width="1372" height="890" alt="image" src="https://github.com/user-attachments/assets/90e498b9-4fa7-49b1-a7ee-7e672c103a98" />

Step 9: Verify Resources: kubectl get gateway -n bankapp

-->Check routes: kubectl get httproute -n bankapp

<img width="1521" height="141" alt="image" src="https://github.com/user-attachments/assets/2280fedf-6b59-4e34-9523-27b28e0c17a0" />

Step 10: Watch Envoy Create AWS NLB: After applying the Gateway:

<img width="690" height="467" alt="image" src="https://github.com/user-attachments/assets/3b781e87-1878-481d-9deb-677f7bf94bc2" />

Step 11: Verify Route Acceptance: kubectl describe httproute bankapp-route -n bankapp

<img width="1667" height="977" alt="image" src="https://github.com/user-attachments/assets/f37ad7a7-03aa-4326-a429-3a764fac859c" />

<img width="1607" height="536" alt="image" src="https://github.com/user-attachments/assets/c40a267e-2b74-49ef-8631-7608484bb5de" />

-->Also check: kubectl describe gateway bankapp-gateway -n bankapp

<img width="1612" height="960" alt="image" src="https://github.com/user-attachments/assets/f7e3d03b-086b-4a08-bbae-1f8766a9531a" />

<img width="1477" height="971" alt="image" src="https://github.com/user-attachments/assets/00dcd48e-52cb-4cb1-b647-b68b542bf1d5" />

Step 12: Get the External Address: Run below any of the commands in terminal:

--> kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}'

-->export GATEWAY_IP=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}') echo $GATEWAY_IP

<img width="1697" height="192" alt="image" src="https://github.com/user-attachments/assets/69fb80a0-65dd-4be2-ae24-12fc35e16669" />

Step 13: Test Connectivity: In terminal run command: curl http://$GATEWAY_IP OR curl -I http://$GATEWAY_IP

**If the Gateway Stays Unprogrammed:**

-->kubectl describe gateway bankapp-gateway -n bankapp

<img width="1585" height="975" alt="image" src="https://github.com/user-attachments/assets/e29e40f7-cebb-41e9-b8f6-6d3053296854" />

-->kubectl logs -n envoy-gateway-system deployment/envoy-gateway --tail=100

<img width="1917" height="977" alt="image" src="https://github.com/user-attachments/assets/d3e9d938-632e-4969-9e77-ac2c99a27ed2" />

-->kubectl get pods -n bankapp

<img width="1552" height="137" alt="image" src="https://github.com/user-attachments/assets/634e75c8-b306-41f8-8980-2ab4d57dc3a1" />

---

### Task 4: Set Up TLS with cert-manager
The AI-BankApp uses cert-manager with Let's Encrypt for automatic HTTPS certificates.

Install cert-manager:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  -n cert-manager --create-namespace \
  --set crds.enabled=true \
  --wait
```

Verify:
```bash
kubectl get pods -n cert-manager
```

Study and apply the ClusterIssuer from `k8s/cert-manager.yml`:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
      - http01:
          gatewayHTTPRoute:
            parentRefs:
              - group: gateway.networking.k8s.io
                kind: Gateway
                name: bankapp-gateway
                namespace: bankapp
```

**How it works:**
1. cert-manager requests a certificate from Let's Encrypt
2. Let's Encrypt sends an HTTP-01 challenge
3. cert-manager creates a temporary HTTPRoute to respond to the challenge
4. Let's Encrypt verifies and issues the certificate
5. cert-manager stores the certificate in the `bankapp-tls` Secret
6. The Gateway uses this Secret for HTTPS termination

To use this, you need a hostname that points to your NLB IP. The AI-BankApp uses `nip.io` for quick DNS:
```bash
export HOSTNAME="${GATEWAY_IP}.nip.io"
echo "HTTPS URL: https://$HOSTNAME"
```

Update the Gateway hostname and apply:
```bash
# For learning: you can skip TLS and just use HTTP
# For production: update gateway.yml with your hostname and apply cert-manager.yml
```

**Steps to follow:**

-->Great, you've already completed the hard parts (EKS, Envoy Gateway, Gateway API, NLB). Now let's set up cert-manager + Let's Encrypt TLS for the AI-BankApp.

Step 1: Install cert-manager: Add the Helm repository:

-->helm repo add jetstack https://charts.jetstack.io

-->helm repo update

**Install cert-manager and its CRDs:**

-->helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set crds.enabled=true --wait

-->As cert-manager is already installed due to that we are facing above issue

<img width="1662" height="487" alt="image" src="https://github.com/user-attachments/assets/bd59820c-7ea5-4718-8d8f-ebbff72a8cb6" />

Step 2: Verify Installation: 

-->Check the pods: kubectl get pods -n cert-manager

-->Verify CRDs: kubectl get crd | grep cert-manager

<img width="1492" height="277" alt="image" src="https://github.com/user-attachments/assets/a2839f23-fd18-4fc5-9f60-5b0af965bf86" />

Step 3: Determine Your Hostname: 

-->We already have gateway created: kubectl get gateway -n bankapp

-->Export it: export GATEWAY_IP=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}')

-->then to check: echo $GATEWAY_IP

-->Create the nip.io hostname: export HOSTNAME="${GATEWAY_IP}.nip.io"

-->then check: echo $HOSTNAME

<img width="1462" height="501" alt="image" src="https://github.com/user-attachments/assets/50c8989e-155c-470c-ad21-238bb2b8446a" />

Step 4: Create the ClusterIssuer: 

-->Open the cert-manager manifest: vi k8s/cert-manager.yml In this file Replace: email: your-email@example.com with your actual email address.

<img width="592" height="237" alt="image" src="https://github.com/user-attachments/assets/8d661965-4d58-4cad-8292-bf9f060dacfc" />

<img width="1296" height="142" alt="image" src="https://github.com/user-attachments/assets/bb3a0aed-2d17-4a6b-885c-26937973b478" />

Step 5: Create a Certificate Resource: The ClusterIssuer only defines how certificates are obtained. You also need a Certificate resource.

-->vi k8s/certificate.yml

<img width="472" height="712" alt="image" src="https://github.com/user-attachments/assets/bd4ce696-b163-4785-9250-0fe9753a969a" />

-->kubectl apply -f k8s/certificate.yml

<img width="1401" height="125" alt="image" src="https://github.com/user-attachments/assets/9636917f-ce64-47e8-8ccc-3974bcbe254d" />

Step 6: Update the Gateway: Your current Gateway probably contains:

-->Open file: vi k8s/gateway.yml In this file Look for the HTTPS listener section. It will look similar to:

-->First get the Gateway address: export GATEWAY_IP=$(kubectl get gateway bankapp-gateway -n bankapp -o jsonpath='{.status.addresses[0].value}')

-->echo $GATEWAY_IP

<img width="660" height="666" alt="image" src="https://github.com/user-attachments/assets/710f487d-e643-46a3-9fd5-52d63740e54b" />

-->kubectl apply -f k8s/gateway.yml

<img width="710" height="712" alt="image" src="https://github.com/user-attachments/assets/e828c1d9-de8b-4008-bf5e-b50c935364fc" />

<img width="1351" height="147" alt="image" src="https://github.com/user-attachments/assets/d81ea90c-5bff-4653-ae0f-92f9a8c81525" />

Step 7: Watch Certificate Issuance: kubectl get certificate -n bankapp

Issue faced: Used following steps mentioned in the file,

[steps-to-fix-issue-steps](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-82/steps-to-fix-issue.md)

-->Check certificate: kubectl get certificate -n bankapp

-->watch: kubectl get certificate -n bankapp -w

-->Check challenge: kubectl get challenges -A

-->Check order: kubectl get orders -A

<img width="1542" height="235" alt="image" src="https://github.com/user-attachments/assets/450f11e9-ec31-4e91-97f9-d425718a3eeb" />

Step 8: Verify Secret Creation: kubectl get secret bankapp-tls -n bankapp

<img width="1347" height="102" alt="image" src="https://github.com/user-attachments/assets/2bce30cd-c981-4157-b5d7-745a0d465a61" />

Step 9: Test HTTPS: 

-->curl -I https://$HOSTNAME

<img width="1200" height="62" alt="image" src="https://github.com/user-attachments/assets/99d9f11d-d7e4-4edd-a97c-269390a5a86e" />

-->OR open in the browser: https://15.207.9.148.nip.io

<img width="1917" height="956" alt="image" src="https://github.com/user-attachments/assets/36a3ca99-d1ea-4f0b-bb77-25d136fc5389" />

---

### Task 5: Understand EBS Persistent Storage in Action
The AI-BankApp uses EBS volumes for MySQL (5Gi) and Ollama (10Gi). Study how they work on EKS.

Check the storage setup:
```bash
# StorageClass
kubectl get storageclass gp3

# PVCs
kubectl get pvc -n bankapp

# PVs (dynamically provisioned)
kubectl get pv
```

Output should look like:
```
NAME                      STATUS   VOLUME         CAPACITY   STORAGECLASS
mysql-pvc                 Bound    pvc-abc123...  5Gi        gp3
ollama-pvc                Bound    pvc-def456...  10Gi       gp3
```

**Find the actual EBS volumes in AWS:**
```bash
aws ec2 describe-volumes \
  --filters "Name=tag:kubernetes.io/created-by,Values=ebs.csi.aws.com" \
  --query "Volumes[*].{ID:VolumeId,Size:Size,AZ:AvailabilityZone,State:State}" \
  --output table \
  --region us-west-2
```

**Key EBS concepts on EKS:**
- `WaitForFirstConsumer` -- the volume is created in the same AZ as the pod that claims it
- `ReadWriteOnce` -- EBS can only attach to one node at a time (MySQL and Ollama use Recreate strategy because of this)
- `gp3` -- latest generation SSD, 3000 IOPS baseline, cheaper than gp2
- `allowVolumeExpansion: true` -- you can grow volumes without recreating them

**Test persistence** -- delete the MySQL pod and watch it come back with data intact:
```bash
# Check current MySQL data
kubectl exec -n bankapp deploy/mysql -- mysql -uroot -pTest@123 -e "SHOW DATABASES;"

# Delete the pod
kubectl delete pod -n bankapp -l app=mysql

# Watch it recreate
kubectl get pods -n bankapp -l app=mysql -w

# Verify data survived
kubectl exec -n bankapp deploy/mysql -- mysql -uroot -pTest@123 -e "SHOW DATABASES;"
```

The database is intact because the EBS volume persists independently of the pod.

**Steps to follow:**

-->This task is designed to help you understand how Kubernetes Persistent Volumes (PVs), Persistent Volume Claims (PVCs), AWS EBS, and the EBS CSI Driver work together in EKS. Since you're working on the AI-BankApp project, here's a detailed walkthrough.

<img width="640" height="780" alt="image" src="https://github.com/user-attachments/assets/87c9b05d-4d95-464c-9767-faba1357468a" />

Step 1: Check StorageClass: kubectl get storageclass gp3

-->To see complete details: kubectl describe storageclass gp3

<img width="662" height="797" alt="image" src="https://github.com/user-attachments/assets/11b03cab-d484-4abc-9d0c-11efb0a5cb39" />

<img width="660" height="557" alt="image" src="https://github.com/user-attachments/assets/0924c1ea-b010-4263-93c5-c45553e06ed4" />

<img width="1917" height="442" alt="image" src="https://github.com/user-attachments/assets/57f48db7-4b67-4d9e-ab94-f8a4139bb6ae" />

Step 2: Check PVCs: kubectl get pvc -n bankapp

-->Detailed view: kubectl describe pvc mysql-pvc -n bankapp

<img width="620" height="442" alt="image" src="https://github.com/user-attachments/assets/e05a03ae-5a77-427c-b36f-e685d1dd226a" />

<img width="1877" height="551" alt="image" src="https://github.com/user-attachments/assets/88450e7e-e1a3-4b70-b52a-573573bd962b" />

Step 3: Check PVs: kubectl get pv

-->Detailed: kubectl describe pv pvc-654bbb3b-6c1e-44af-a7a4-4397bc8f8b90

<img width="826" height="246" alt="image" src="https://github.com/user-attachments/assets/fcbf3117-1d77-46d7-b9b4-111c8d99517a" />

<img width="1887" height="611" alt="image" src="https://github.com/user-attachments/assets/5df67d88-9615-4e19-ba60-648e7f079b70" />

Step 4: Find Actual EBS Volumes: 

-->aws ec2 describe-volumes --query "Volumes[*].[VolumeId,Size,AvailabilityZone,State]" --output table --region ap-south-1

<img width="1217" height="247" alt="image" src="https://github.com/user-attachments/assets/c2fa6215-ff6d-4ac6-b896-88b54e1d71fa" />

-->To see Kubernetes-created volumes only: aws ec2 describe-volumes --filters "Name=tag:kubernetes.io/created-for/pvc/name,Values=*" --region ap-south-1

<img width="1562" height="892" alt="image" src="https://github.com/user-attachments/assets/dbd5dc75-fd61-4c7d-aa63-e98ca0af8ce7" />

Step 5: Match PV with AWS EBS: 

-->Get PV details: kubectl describe pv pvc-654bbb3b-6c1e-44af-a7a4-4397bc8f8b90

<img width="1825" height="606" alt="image" src="https://github.com/user-attachments/assets/4995feb6-e458-4543-9b28-6cfa7a048b49" />

-->aws ec2 describe-volumes --volume-ids vol-01abcd --region ap-south-1

<img width="1917" height="962" alt="image" src="https://github.com/user-attachments/assets/b2248a65-112d-4a8f-a588-9a4ae0445017" />

<img width="627" height="205" alt="image" src="https://github.com/user-attachments/assets/c83983f4-78bc-486d-85b5-2dd17d417310" />

**Understanding ReadWriteOnce (RWO):**

-->kubectl describe pvc mysql-pvc -n bankapp

<img width="1457" height="511" alt="image" src="https://github.com/user-attachments/assets/0fa842fd-b487-45a4-9545-83d4536b798e" />

<img width="755" height="707" alt="image" src="https://github.com/user-attachments/assets/193920bc-fbf3-423a-90df-ff175336c1c0" />

**Why MySQL Uses Recreate Strategy Because of RWO:**

<img width="705" height="767" alt="image" src="https://github.com/user-attachments/assets/6ccc7617-4cea-4b77-8a00-eeca8bb961c0" />

**Understanding Volume Expansion:**

<img width="660" height="582" alt="image" src="https://github.com/user-attachments/assets/3e34065a-5443-4028-94e9-14908f9fca17" />

<img width="660" height="582" alt="image" src="https://github.com/user-attachments/assets/bd4a7153-33fe-434e-847e-14b1fc2ad3d8" />

Step 6: Test Persistence: 

-->Check databases: kubectl exec -n bankapp deploy/mysql -- mysql -uroot -pTest@123 -e "SHOW DATABASES;"

-->Delete MySQL Pod: kubectl delete pod -n bankapp -l app=mysql

-->Watch recreation: kubectl get pods -n bankapp -l app=mysql -w

<img width="707" height="611" alt="image" src="https://github.com/user-attachments/assets/e2cfcdca-6b29-4604-8fee-4877a2b6cf39" />

<img width="687" height="671" alt="image" src="https://github.com/user-attachments/assets/3923863f-f468-47c9-9de9-55ffe8282f15" />

<img width="1917" height="887" alt="image" src="https://github.com/user-attachments/assets/441db292-5924-4cc9-92da-a1db236a9ae8" />

**What Actually Happened?**

<img width="647" height="451" alt="image" src="https://github.com/user-attachments/assets/dfe83d82-40ad-4b3c-b482-1300e57b5b3c" />

**Commands Summary:**

# StorageClass

-->kubectl get storageclass gp3

-->kubectl describe storageclass gp3

# PVCs

-->kubectl get pvc -n bankapp

-->kubectl describe pvc mysql-pvc -n bankapp

# PVs

-->kubectl get pv

-->kubectl describe pv <pv-name>

# AWS Volumes

-->aws ec2 describe-volumes --region ap-south-1

# MySQL Data Check

-->kubectl exec -n bankapp deploy/mysql -- \

-->mysql -uroot -pTest@123 -e "SHOW DATABASES;"

# Delete MySQL Pod

-->kubectl delete pod -n bankapp -l app=mysql

# Watch Recreate

-->kubectl get pods -n bankapp -l app=mysql -w

# Verify Persistence

-->kubectl exec -n bankapp deploy/mysql -- \

-->mysql -uroot -pTest@123 -e "SHOW DATABASES;"

**Key Learning Outcome:**

**By completing this task, you'll understand:**

-->PVC = request for storage.

-->PV = Kubernetes storage object.

-->EBS Volume = actual AWS disk.

-->WaitForFirstConsumer = creates volume in the correct AZ.

-->ReadWriteOnce = one node can attach the volume at a time.

-->gp3 = modern AWS SSD storage.

-->Data survives pod deletion because EBS exists independently of the pod.

---

### Task 6: Explore HPA and Node Capacity
The AI-BankApp's HPA scales pods between 2 and 4 based on CPU.

```bash
kubectl get hpa -n bankapp
```

Check resource usage across nodes:
```bash
kubectl top nodes
kubectl top pods -n bankapp
```

**Resource budget for the AI-BankApp on 3x t3.medium nodes:**

| Component | CPU Request | Memory Request | Instances |
|-----------|-----------|---------------|-----------|
| BankApp | 250m | 256Mi | 2-4 pods |
| MySQL | 250m | 256Mi | 1 pod |
| Ollama | 900m | 2Gi | 1 pod |
| Init containers | 50m | 32Mi | temporary |
| System pods | ~500m | ~500Mi | per node |
| **Total available** | **6000m (3 nodes)** | **12Gi (3 nodes)** | |

Ollama is the heaviest consumer. If you scale BankApp to 4 pods, total CPU requests reach ~2.9 cores + system overhead.

**Clean up the workload (keep the cluster for Day 83):**
```bash
kubectl delete -f k8s/gateway.yml 2>/dev/null
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
```

**Steps to follow:**

Task 6 is about understanding how Kubernetes Horizontal Pod Autoscaler (HPA) works, how much capacity your EKS nodes have, and whether your AI-BankApp can fit within the available resources.

Step 1: Check HPA

---

## Hints
- Gateway API is the future of Kubernetes ingress -- it is officially supported and will eventually replace the Ingress resource
- Envoy Gateway creates an AWS NLB automatically when a Gateway resource is applied -- check the AWS EC2 console under Load Balancers
- `BackendTrafficPolicy` is Envoy-specific -- other Gateway implementations (like Istio) have their own session affinity mechanisms
- EBS volumes are AZ-locked. If a pod moves to a node in a different AZ, the volume cannot follow. `WaitForFirstConsumer` prevents this by delaying volume creation until the pod is scheduled
- The `Recreate` deployment strategy for MySQL and Ollama is intentional -- EBS cannot attach to two nodes simultaneously, so the old pod must terminate before the new one starts
- cert-manager with Gateway API requires the `gateway-api` feature gate -- make sure you installed cert-manager with CRDs enabled
- `nip.io` is a wildcard DNS service: `1.2.3.4.nip.io` resolves to `1.2.3.4` -- useful for quick TLS testing without buying a domain
- Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`)

---

## Documentation
Create `day-82-eks-networking-storage.md` with:
- Gateway API architecture diagram: NLB -> Gateway -> HTTPRoute -> Service -> Pods
- Comparison table: Gateway API vs Ingress
- Each Gateway API resource explained (GatewayClass, Gateway, HTTPRoute, BackendTrafficPolicy)
- Why cookie-based session affinity is needed for the AI-BankApp
- Screenshot of `kubectl get gateway` showing the NLB address
- How cert-manager automates TLS certificates
- EBS storage flow: StorageClass -> PVC -> PV -> EBS Volume -> Pod
- Screenshot of `kubectl get pvc` showing bound volumes
- Resource budget table for the AI-BankApp on EKS

---

## Submission
1. Add `day-82-eks-networking-storage.md` to `2026/day-82/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Deep dive into EKS production networking today -- set up the Kubernetes Gateway API with Envoy Gateway for the AI-BankApp, configured cookie-based session persistence for Spring Security, explored cert-manager for automated HTTPS, and verified EBS persistent storage survives pod restarts. Gateway API is the future of Kubernetes traffic management."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
