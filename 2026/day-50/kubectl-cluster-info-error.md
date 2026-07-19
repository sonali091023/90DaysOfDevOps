<img width="1917" height="302" alt="image" src="https://github.com/user-attachments/assets/1a969bfd-04b7-43ed-9f1f-142510bfcf03" />

This error is very common when starting with Kubernetes. It means kubectl is installed, but it doesn't know how to connect to a Kubernetes cluster (or there isn't one running).

Let's analyze your error.

Error
The connection to the server localhost:8080 was refused

Notice this part:

http://localhost:8080

This is the key clue.

Normally, a Kind cluster does not use localhost:8080. It uses an API Server endpoint like:

https://127.0.0.1:39415

or

https://127.0.0.1:45673

The fact that kubectl is trying to reach localhost:8080 means it is not reading a valid kubeconfig.

Possible Causes
Cause 1 (Most Likely): No Cluster Exists

Check whether your Kind cluster exists:

kind get clusters

If you get:

No kind clusters found.

Then simply create one:

kind create cluster --name devops-cluster

After that:

kubectl cluster-info

should work.

Cause 2: kubeconfig is Missing

Run:

kubectl config view

If the output looks like:

apiVersion: v1
clusters: []
contexts: []
current-context: ""
users: []

then your kubeconfig is empty.

Also check:

ls -la ~/.kube

You should have:

config

If the config file doesn't exist, kubectl falls back to trying http://localhost:8080.

Cause 3: Current Context is Missing

Run:

kubectl config current-context

If you see:

error: current-context is not set

or nothing at all,

then kubectl has no cluster selected.

Cause 4: Docker Isn't Running

Kind requires Docker.

Check:

docker ps

If Docker isn't running, start it:

sudo systemctl start docker

Verify:

docker ps
Let's Troubleshoot Step by Step

Please run these commands one by one and share the output.

1. Is Kind installed?
kind version
2. Does the cluster exist?
kind get clusters
3. Is Docker running?
docker ps
4. Does kubectl have a current context?
kubectl config current-context
5. Show your kubeconfig
kubectl config view
6. Check whether the config file exists
ls -la ~/.kube
What I Suspect

Based on your error:

The connection to the server localhost:8080 was refused

I suspect one of these is true:

✅ Your Kind cluster has been deleted.
✅ You haven't created the cluster yet.
✅ Your ~/.kube/config is empty or missing.
✅ There is no current context configured.

Once you share the outputs of the six commands above, I can pinpoint the exact issue and guide you through the fix.
