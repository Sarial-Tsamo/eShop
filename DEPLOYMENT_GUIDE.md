# eShop Kubernetes Deployment Guide - Quick Start

## 🚀 Quick Deployment (2 minutes)

### Option 1: Automated Deployment (Recommended)
```bash
cd /home/ubuntu/eShop/manifest-output
./deploy.sh
```

### Option 2: Manual Deployment
```bash
# Deploy to k3s cluster
kubectl apply -k /home/ubuntu/eShop/manifest-output/

# Monitor deployment
kubectl get pods -n eshop -w
```

### Option 3: k3s-Optimized Deployment
```bash
# Deploy with k3s overlays (Traefik ingress, optimized resources)
kubectl apply -k /home/ubuntu/eShop/manifest-output/overlays/k3s/
```

## 📋 What Gets Deployed

### Infrastructure Services
- ✅ **PostgreSQL** (StatefulSet) - Database with pgvector extension
- ✅ **Redis** (Deployment) - In-memory cache
- ✅ **RabbitMQ** (StatefulSet) - Message broker

### Microservices
- ✅ **Identity API** - Authentication and authorization
- ✅ **Basket API** - Shopping cart management
- ✅ **Catalog API** - Product catalog
- ✅ **Ordering API** - Order management
- ✅ **Webhooks API** - Webhook management
- ✅ **WebApp** - Frontend application
- ✅ **WebhooksClient** - Webhook client application
- ✅ **Order Processor** - Background task
- ✅ **Payment Processor** - Background task

### Total: 13 services + infrastructure

## 🔍 Verify Deployment

```bash
# Check if all pods are running
kubectl get pods -n eshop

# Expected output (all should be Running):
# identity-api-xxxxx                    1/1     Running
# basket-api-xxxxx                      1/1     Running
# catalog-api-xxxxx                     1/1     Running
# ordering-api-xxxxx                    1/1     Running
# order-processor-xxxxx                 1/1     Running
# payment-processor-xxxxx               1/1     Running
# webhooks-api-xxxxx                    1/1     Running
# webapp-xxxxx                          1/1     Running
# webhooksclient-xxxxx                  1/1     Running
# postgres-0                            1/1     Running
# redis-xxxxx                           1/1     Running
# rabbitmq-0                            1/1     Running

# Check services
kubectl get svc -n eshop

# Check ingress (if using k3s overlay)
kubectl get ingress -n eshop
```

## 🌐 Access Applications

### Via Port Forwarding (Quick Testing)
```bash
# WebApp (Frontend)
kubectl port-forward -n eshop svc/webapp 8080:80
# Access: http://localhost:8080

# Identity API
kubectl port-forward -n eshop svc/identity-api 8081:80
# Access: http://localhost:8081

# RabbitMQ Management UI
kubectl port-forward -n eshop svc/eventbus 15672:15672
# Access: http://localhost:15672 (guest/guest)

# PostgreSQL (for debugging)
kubectl port-forward -n eshop svc/postgres 5432:5432
# Connect: psql -h localhost -U postgres
```

### Via Ingress (k3s overlay only)
```bash
# Update /etc/hosts:
echo "127.0.0.1 eshop.local api.eshop.local" >> /etc/hosts

# Access:
# http://eshop.local                    # WebApp
# http://api.eshop.local/identity      # Identity API
# http://api.eshop.local/catalog       # Catalog API
# http://api.eshop.local/ordering      # Ordering API
# http://api.eshop.local/basket        # Basket API
```

## 📊 Monitor Deployment

```bash
# Watch pods in real-time
watch kubectl get pods -n eshop

# View pod logs
kubectl logs -n eshop pod/webapp-xxxxx -f

# Check pod events
kubectl describe pod -n eshop webapp-xxxxx

# Resource usage
kubectl top pods -n eshop
kubectl top nodes
```

## 🛠️ Common Operations

### Scale a Service
```bash
# Scale webapp to 3 replicas
kubectl scale deployment webapp -n eshop --replicas=3
```

### Update Container Image
```bash
kubectl set image deployment/webapp \
  -n eshop \
  webapp=sarialbebeto/webapp:v2 \
  --record
```

### Execute Command in Pod
```bash
kubectl exec -it -n eshop pod/webapp-xxxxx -- /bin/bash
```

### View Logs
```bash
# Last 50 lines
kubectl logs -n eshop deployment/webapp --tail=50

# Streaming logs
kubectl logs -n eshop deployment/webapp -f

# Previous pod logs (if restarted)
kubectl logs -n eshop deployment/webapp --previous
```

### Get Pod Information
```bash
# YAML output
kubectl get pod -n eshop pod/webapp-xxxxx -o yaml

# Detailed description
kubectl describe pod -n eshop pod/webapp-xxxxx

# Events
kubectl get events -n eshop
```

## ❌ Troubleshooting

### Pods Not Starting
```bash
# Check pod status
kubectl describe pod -n eshop pod/webapp-xxxxx

# Common issues:
# - ImagePullBackOff: Docker image not found
# - CrashLoopBackOff: Application crash
# - Pending: Not enough resources

# View logs to see crash reason
kubectl logs -n eshop pod/webapp-xxxxx
```

### Database Connection Issues
```bash
# Check PostgreSQL pod
kubectl get pod -n eshop postgres-0

# Connect to database pod
kubectl exec -it -n eshop postgres-0 -- psql -U postgres

# Check databases
\l

# Exit
\q
```

### Service Not Accessible
```bash
# Check service exists
kubectl get svc -n eshop

# Test connectivity from another pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod:
wget -O- http://webapp:80
```

### Event Bus Issues
```bash
# Check RabbitMQ logs
kubectl logs -n eshop rabbitmq-0

# Access RabbitMQ management UI
kubectl port-forward -n eshop svc/eventbus 15672:15672
# Visit: http://localhost:15672 (guest/guest)
```

## 🧹 Cleanup

### Delete All Resources
```bash
kubectl delete -k /home/ubuntu/eShop/manifest-output/
```

### Delete Specific Service
```bash
kubectl delete deployment -n eshop webapp
```

### Delete Namespace (Deletes Everything)
```bash
kubectl delete namespace eshop
```

## 📁 Manifest Structure

```
manifest-output/
├── README.md                     # Comprehensive documentation
├── DEPLOYMENT_GUIDE.md           # This file
├── deploy.sh                     # Automated deployment script
├── kustomization.yaml            # Base Kustomize config
├── namespace.yaml                # Kubernetes namespace
├── postgres-statefulset.yaml     # Database
├── redis-deployment.yaml         # Cache
├── rabbitmq-statefulset.yaml     # Message broker
├── identity-api-deployment.yaml  # Auth service
├── basket-api-deployment.yaml    # Cart service
├── catalog-api-deployment.yaml   # Catalog service
├── ordering-api-deployment.yaml  # Orders service
├── order-processor-deployment.yaml
├── payment-processor-deployment.yaml
├── webhooks-api-deployment.yaml
├── webapp-deployment.yaml        # Frontend
├── webhooksclient-deployment.yaml
└── overlays/
    └── k3s/                      # k3s-specific configurations
        ├── kustomization.yaml    # Overlay Kustomize config
        ├── traefik-ingress.yaml  # Ingress configuration
        └── webapp-patch.yaml     # Resource optimization
```

## 🔐 Security Notes

### Default Credentials (⚠️ Change in Production!)
- **PostgreSQL**: `postgres:postgres`
- **RabbitMQ**: `guest:guest`

### Before Production Deployment
1. ✅ Use specific image tags (not `latest`)
2. ✅ Update all default passwords
3. ✅ Configure HTTPS/TLS
4. ✅ Set up proper resource limits
5. ✅ Enable network policies
6. ✅ Implement RBAC
7. ✅ Configure backup strategy
8. ✅ Set up monitoring

## 📞 Support

For detailed information:
- See [README.md](README.md) for comprehensive documentation
- Check logs: `kubectl logs -n eshop <pod-name>`
- Describe resources: `kubectl describe <resource-type> -n eshop <name>`

## ✨ Next Steps

1. **Verify all pods are running**
   ```bash
   kubectl get pods -n eshop
   ```

2. **Test the application**
   ```bash
   kubectl port-forward -n eshop svc/webapp 8080:80
   # Open http://localhost:8080 in browser
   ```

3. **Monitor performance**
   ```bash
   kubectl top pods -n eshop
   ```

4. **Scale services as needed**
   ```bash
   kubectl scale deployment <service> -n eshop --replicas=3
   ```

---

**Happy Deploying! 🎉**

For more details, see [README.md](README.md)
