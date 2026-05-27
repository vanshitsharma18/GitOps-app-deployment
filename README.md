# Todo Application - GKE Deployment

**Version:** 1.0.0 | **Platform:** Google Kubernetes Engine (GKE) | **Last Updated:** 2026-05-27

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [GKE Cluster Setup](#gke-cluster-setup)
5. [Deploy Application](#deploy-application)
6. [Access Application](#access-application)
7. [Manage Deployments](#manage-deployments)
8. [Troubleshooting](#troubleshooting)
9. [Contributing](#contributing)
10. [License](#license)

---

## Overview

This is a full-stack Todo application built with Node.js and Express, deployed on Google Kubernetes Engine (GKE).

**What's Included:**
- Node.js backend with Express API
- HTML/CSS/JavaScript frontend
- Docker containerization
- Kubernetes manifest files
- Helm charts for easy deployment
- GitHub Actions CI/CD pipeline

**Key Features:**
- Create, read, update, delete todos
- Persistent data storage
- Containerized deployment
- Cloud-native architecture
- Automatic scaling capability

---

## Prerequisites

### Required Software

```bash
# Install Google Cloud SDK
# Visit: https://cloud.google.com/sdk/docs/install

# Install kubectl
gcloud components install kubectl

# Install Helm
# Visit: https://helm.sh/docs/intro/install/

# Install Docker (for local testing)
# Visit: https://www.docker.com/products/docker-desktop

# Verify installations
gcloud --version
kubectl version --client
helm version
docker --version
```

### Google Cloud Account

1. Create a GCP account at [cloud.google.com](https://cloud.google.com)
2. Create a new project
3. Enable billing on the project
4. Keep your Project ID handy

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/vanshitsharma18/todo-app-deployment.git
cd todo-app-deployment
```

### 2. Run Locally

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Application runs at http://localhost:3000
```

### 3. Deploy to GKE (5 minutes)

```bash
# Set your GCP project ID
export PROJECT_ID="your-project-id"

# Create GKE cluster (will take 3-5 minutes)
gcloud container clusters create todo-app-cluster \
  --project=$PROJECT_ID \
  --region=us-central1 \
  --num-nodes=3

# Get cluster credentials
gcloud container clusters get-credentials todo-app-cluster \
  --region=us-central1 \
  --project=$PROJECT_ID

# Deploy application
kubectl apply -f k8s-manifest.yaml

# Check deployment
kubectl get pods
kubectl get svc
```

---

## GKE Cluster Setup

### Step 1: Set Up Google Cloud

```bash
# Login to Google Cloud
gcloud auth login

# Set default project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

### Step 2: Create GKE Cluster

```bash
# Create a standard GKE cluster
gcloud container clusters create todo-app-cluster \
  --project=$PROJECT_ID \
  --region=us-central1 \
  --num-nodes=3 \
  --machine-type=e2-medium

# Wait for cluster to be created (3-5 minutes)
# You'll see: "Creating cluster..." message

# Get cluster credentials (connect kubectl to cluster)
gcloud container clusters get-credentials todo-app-cluster \
  --region=us-central1 \
  --project=$PROJECT_ID
```

### Step 3: Verify Cluster

```bash
# Check if cluster is ready
kubectl get nodes

# You should see 3 nodes listed

# Check cluster info
kubectl cluster-info
```

---

## Deploy Application

### Method 1: Using kubectl (Simplest)

```bash
# Deploy using manifest file
kubectl apply -f k8s-manifest.yaml

# Check deployment status
kubectl get pods
kubectl get svc

# Wait for pods to be Running (about 30 seconds)
```

### Method 2: Using Helm (Recommended)

```bash
# Install using Helm chart
helm install todo-app ./helm/fullstack-todo-app-charts

# Verify installation
helm list
kubectl get all
```

### Method 3: Build and Push Your Own Image

```bash
# 1. Set up Container Registry
gcloud auth configure-docker

# 2. Build Docker image
docker build -t gcr.io/$PROJECT_ID/todo-app:v1 .

# 3. Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/todo-app:v1

# 4. Update manifest with your image
# Edit k8s-manifest.yaml and change image to:
# gcr.io/$PROJECT_ID/todo-app:v1

# 5. Deploy
kubectl apply -f k8s-manifest.yaml
```

---

## Access Application

### Get the External IP

```bash
# Check service status
kubectl get svc

# Wait for EXTERNAL-IP to be assigned (may take 1-2 minutes)
# Copy the external IP address

# Access application
# Open browser: http://<EXTERNAL-IP>:3000
```

### Alternative: Port Forward (Testing)

```bash
# Port forward service to localhost
kubectl port-forward svc/fullstack-todo-service 3000:3000

# Access at: http://localhost:3000
```

### Using Ingress (Advanced)

```bash
# Create Ingress for external access
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todo-app-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: fullstack-todo-service
            port:
              number: 3000
EOF

# Get Ingress IP
kubectl get ingress

# Wait for IP to be assigned (2-3 minutes)
# Access at: http://<INGRESS-IP>
```

---

## Manage Deployments

### View Status

```bash
# See all running pods
kubectl get pods

# See detailed pod info
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Stream live logs
kubectl logs -f <pod-name>
```

### Update Application

```bash
# Scale to more replicas
kubectl scale deployment fullstack-todo-app --replicas=5

# Check scaling status
kubectl get pods

# Update image
kubectl set image deployment/fullstack-todo-app \
  app=gcr.io/$PROJECT_ID/todo-app:v2

# Check rollout status
kubectl rollout status deployment/fullstack-todo-app

# Rollback if needed
kubectl rollout undo deployment/fullstack-todo-app
```

### Delete Resources

```bash
# Remove deployment
kubectl delete deployment fullstack-todo-app

# Remove service
kubectl delete svc fullstack-todo-service

# Delete all resources
kubectl delete -f k8s-manifest.yaml
```

### Clean Up Cluster

```bash
# Delete entire GKE cluster (be careful!)
gcloud container clusters delete todo-app-cluster \
  --region=us-central1 \
  --project=$PROJECT_ID

# Confirm deletion when prompted
```

---

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Check recent events
kubectl get events

# Common issues:
# - Image not found: Check image name in manifest
# - Insufficient resources: Scale down replicas
# - Port already in use: Change port in manifest
```

### Cannot Connect to Application

```bash
# Verify service is running
kubectl get svc fullstack-todo-service

# Check if EXTERNAL-IP is assigned
# If pending: wait 1-2 minutes and try again

# Verify pod is running
kubectl get pods

# Test connectivity from pod
kubectl exec -it <pod-name> -- curl localhost:3000
```

### Application Crashes

```bash
# Check pod logs for errors
kubectl logs <pod-name>

# Check if previous logs exist
kubectl logs <pod-name> --previous

# Describe pod for error details
kubectl describe pod <pod-name>

# Check resource usage
kubectl top pods
```

### Cluster Issues

```bash
# Check cluster status
kubectl get nodes

# Describe node for issues
kubectl describe node <node-name>

# Check cluster info
kubectl cluster-info dump

# Restart pod
kubectl delete pod <pod-name>
```

---

## Configuration

### Environment Variables

Edit `k8s-manifest.yaml` to set environment variables:

```yaml
env:
  - name: NODE_ENV
    value: "production"
  - name: PORT
    value: "3000"
```

### Resource Limits

Edit manifest to control CPU and memory:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Replicas

Change number of running pods:

```yaml
spec:
  replicas: 3
```

---

## Useful Commands

### Cluster Commands

```bash
# List all clusters
gcloud container clusters list --project=$PROJECT_ID

# Get cluster info
kubectl cluster-info

# Scale cluster nodes
gcloud container clusters resize todo-app-cluster --num-nodes=5 \
  --region=us-central1 \
  --project=$PROJECT_ID
```

### Pod Commands

```bash
# List all pods
kubectl get pods

# Get pod details
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward
kubectl port-forward pod/<pod-name> 3000:3000
```

### Deployment Commands

```bash
# List deployments
kubectl get deployments

# Describe deployment
kubectl describe deployment fullstack-todo-app

# Scale deployment
kubectl scale deployment fullstack-todo-app --replicas=5

# Update deployment
kubectl set image deployment/fullstack-todo-app app=<new-image>

# View rollout history
kubectl rollout history deployment/fullstack-todo-app

# Rollback to previous version
kubectl rollout undo deployment/fullstack-todo-app
```

### Service Commands

```bash
# List services
kubectl get svc

# Get service details
kubectl describe svc fullstack-todo-service

# Port forward service
kubectl port-forward svc/fullstack-todo-service 3000:3000
```

---

## CI/CD Pipeline

The repository includes GitHub Actions workflow for automatic deployment.

### What Happens on Push

1. Code is tested
2. Docker image is built
3. Image is pushed to Google Container Registry
4. Application is deployed to GKE

### Set Up CI/CD

1. Add GitHub secrets to your repository:
   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_SA_KEY`: Service account key (JSON)

2. Workflow file: `.github/workflows/ci.yaml`

3. On every push to `master`:
   - Image builds and uploads
   - Deployment updates automatically

---

## File Structure

```
.
├── server.js                 # Node.js application
├── package.json             # Dependencies
├── Dockerfile               # Container configuration
├── k8s-manifest.yaml        # Kubernetes manifest
├── kind-cluster-config.yaml # Cluster config (optional)
├── docker-compose.yml       # Local deployment
├── helm/                    # Helm charts
│   └── fullstack-todo-app-charts/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── .github/workflows/       # CI/CD pipelines
│   └── ci.yaml
└── README.md               # This file
```

---

## Next Steps

### Monitor Your Application

```bash
# Watch pod creation
kubectl get pods --watch

# Monitor resource usage
kubectl top pods
kubectl top nodes

# View real-time logs
kubectl logs -f deployment/fullstack-todo-app
```

### Scale Your Application

```bash
# Increase replicas for high availability
kubectl scale deployment fullstack-todo-app --replicas=5

# Create auto-scaler
kubectl autoscale deployment fullstack-todo-app \
  --min=2 --max=10 --cpu-percent=70
```

### Add Persistent Storage

```bash
# Create persistent volume
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: todo-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

# Mount in deployment
# Add to spec.volumes in k8s-manifest.yaml
```

### Enable HTTPS

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Create certificate
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: gce
EOF
```

---

## Common Issues

### Q: Cluster creation fails
**A:** Check if APIs are enabled:
```bash
gcloud services list --enabled
```

### Q: Pod stays in pending state
**A:** Check resource availability:
```bash
kubectl describe pod <pod-name>
kubectl top nodes
```

### Q: Cannot access application
**A:** Wait for LoadBalancer IP:
```bash
kubectl get svc --watch
```

### Q: High costs on GCP
**A:** Scale down cluster:
```bash
gcloud container clusters resize todo-app-cluster --num-nodes=1
```

### Q: How to backup data
**A:** Use persistent volumes:
```bash
kubectl get pvc
gcloud compute disks list
```

---

## Performance Tips

1. **Use appropriate resource limits** - Set requests and limits
2. **Enable auto-scaling** - Handle traffic spikes
3. **Use Ingress** - More efficient than LoadBalancer
4. **Implement health checks** - Ensure pod quality
5. **Monitor resources** - Use kubectl top commands

---

## Security Best Practices

1. **Use private images** - Store in private registry
2. **Enable Network Policies** - Control pod communication
3. **Use Workload Identity** - Secure pod authentication
4. **Regular updates** - Keep images and Kubernetes updated
5. **RBAC** - Control user access

---

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Open Pull Request

---

## Support

- **Issues**: [GitHub Issues](https://github.com/vanshitsharma18/todo-app-deployment/issues)
- **Discussions**: [GitHub Discussions](https://github.com/vanshitsharma18/todo-app-deployment/discussions)
- **Author**: Vanshit Sharma
  - GitHub: [@vanshitsharma18](https://github.com/vanshitsharma18)
  - Docker Hub: [vanshitsharma07](https://hub.docker.com/u/vanshitsharma07)

---

## License

This project is licensed under the ISC License. See LICENSE file for details.

---

## Useful Links

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

## Quick Reference

### Create & Deploy
```bash
gcloud container clusters create todo-app-cluster --region=us-central1 --num-nodes=3
gcloud container clusters get-credentials todo-app-cluster --region=us-central1
kubectl apply -f k8s-manifest.yaml
```

### Check Status
```bash
kubectl get pods
kubectl get svc
kubectl logs -f deployment/fullstack-todo-app
```

### Scale & Update
```bash
kubectl scale deployment fullstack-todo-app --replicas=5
kubectl set image deployment/fullstack-todo-app app=gcr.io/$PROJECT_ID/todo-app:v2
```

### Cleanup
```bash
kubectl delete -f k8s-manifest.yaml
gcloud container clusters delete todo-app-cluster --region=us-central1
```

---

**Last Updated**: 2026-05-27  
**Version**: 1.0.0  

⭐ **If this guide was helpful, please star the [repository](https://github.com/vanshitsharma18/todo-app-deployment)!**
