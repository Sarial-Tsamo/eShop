# eShop Kubernetes Manifests for k3s Deployment

## Overview
This directory contains Kubernetes manifests for deploying the eShop microservices application in a k3s cluster.

## Directory Structure

```
manifest-output/
├── namespace.yaml                    # Creates eshop namespace
├── postgres-statefulset.yaml         # PostgreSQL database with pgvector
├── redis-deployment.yaml             # Redis cache
├── rabbitmq-statefulset.yaml         # RabbitMQ message broker
├── identity-api-deployment.yaml      # Identity service
├── basket-api-deployment.yaml        # Basket/Shopping cart service
├── catalog-api-deployment.yaml       # Product catalog service
├── ordering-api-deployment.yaml      # Order management service
├── order-processor-deployment.yaml   # Background order processor
├── payment-processor-deployment.yaml # Background payment processor
├── webhooks-api-deployment.yaml      # Webhooks service
├── webapp-deployment.yaml            # Frontend web application
├── webhooksclient-deployment.yaml    # Webhook client application
├── kustomization.yaml                # Kustomize base configuration
└── overlays/
    └── k3s/
        ├── kustomization.yaml        # k3s-specific overrides
        ├── webapp-patch.yaml         # Resource constraints for k3s
        └── traefik-ingress.yaml      # Traefik ingress routing

```

## Prerequisites

- k3s cluster running (1.26+)
- `kubectl` configured to access the k3s cluster
- `kustomize` installed (or use `kubectl apply -k`)
- Container images built and available in your registry:
  - `sarialbebeto/identity-api:latest`
  - `sarialbebeto/basket-api:latest`
  - `sarialbebeto/catalog-api:latest`
  - `sarialbebeto/ordering-api:latest`
  - `sarialbebeto/order-processor:latest`
  - `sarialbebeto/payment-processor:latest`
  - `sarialbebeto/webhooks-api:latest`
  - `sarialbebeto/webapp:latest`
  - `sarialbebeto/webhooksclient:latest`

## Deployment Instructions

### Step 1: Verify k3s Cluster Access
```bash
kubectl cluster-info
kubectl get nodes
```

### Step 2: Deploy Using Kustomize (Base Configuration)
To deploy the base configuration:
```bash
kubectl apply -k manifest-output/
```

### Step 3: Deploy Using k3s Overlay
For k3s-optimized deployment with Traefik ingress:
```bash
kubectl apply -k manifest-output/overlays/k3s/
```

### Step 4: Verify Deployment
```bash
# Check namespace
kubectl get ns

# Check all resources in eshop namespace
kubectl get all -n eshop

# Check pods status
kubectl get pods -n eshop -w

# Check services
kubectl get svc -n eshop

# Check ingress
kubectl get ingress -n eshop
```

### Step 5: Port Forwarding (for testing)
```bash
# Access WebApp
kubectl port-forward -n eshop svc/webapp 8080:80

# Access Identity API
kubectl port-forward -n eshop svc/identity-api 8081:80

# Access Basket API
kubectl port-forward -n eshop svc/basket-api 8082:80

# Access RabbitMQ Management
kubectl port-forward -n eshop svc/eventbus 15672:15672
```

## Service Access

### Internal (within cluster)
- **WebApp**: `http://webapp.eshop.svc.cluster.local`
- **Identity API**: `http://identity-api.eshop.svc.cluster.local`
- **Basket API**: `http://basket-api.eshop.svc.cluster.local`
- **Catalog API**: `http://catalog-api.eshop.svc.cluster.local`
- **Ordering API**: `http://ordering-api.eshop.svc.cluster.local`
- **Webhooks API**: `http://webhooks-api.eshop.svc.cluster.local`
- **RabbitMQ**: `eventbus:5672` (AMQP), `eventbus:15672` (Management UI)
- **Redis**: `redis:6379`
- **PostgreSQL**: `postgres:5432`

### External (via LoadBalancer)
- **WebApp**: `http://<k3s-node-ip>:<LoadBalancer-Port>`
- **WebhooksClient**: `http://<k3s-node-ip>:<LoadBalancer-Port>`
- **Identity API**: `http://<k3s-node-ip>:<LoadBalancer-Port>`

### Via Ingress (k3s overlay only)
With Traefik ingress configured:
- **WebApp**: `http://eshop.local`
- **API Gateway**: `http://api.eshop.local`

## Database Initialization

PostgreSQL automatically creates databases on StatefulSet startup. The services will perform EF Core migrations on startup.

Databases created:
- `identitydb` - Identity service
- `catalogdb` - Catalog service
- `orderingdb` - Ordering service
- `webhooksdb` - Webhooks service

## Environment Variables

Each service is configured with environment variables for:
- Database connection strings
- RabbitMQ broker connection
- Service URLs (for inter-service communication)
- Identity service URL
- Callback URLs

All services use these default credentials (change in production!):
- **PostgreSQL**: `postgres:postgres`
- **RabbitMQ**: `guest:guest`

## Storage

### Persistent Volumes
- **PostgreSQL**: 10Gi StatefulSet storage
- **RabbitMQ**: Uses StatefulSet volume

### Local Storage (k3s)
Default hostPath: `/mnt/data/postgres`

For production, replace with:
- NFS shares
- Cloud storage
- Local SSD mounts

## Resource Limits

Default resource allocation:
- **API Services**: 256Mi memory / 250m CPU (requests), 512Mi / 500m (limits)
- **Databases**: 256-512Mi memory / 250-500m CPU
- **Processors**: 256Mi memory / 250m CPU (requests), 512Mi / 500m (limits)
- **WebApp**: 512Mi memory / 500m CPU (requests), 1Gi / 1000m (limits) - doubled for k3s overlay

Adjust in `<service>-deployment.yaml` for your cluster capacity.

## Health Checks

All services include:
- **Liveness Probe**: Checks `/health` endpoint every 10s (30s initial delay)
- **Readiness Probe**: Checks `/health` endpoint every 5s (10s initial delay)

## Networking

### Service Communication
- All services communicate via Kubernetes service DNS
- RabbitMQ hostname: `eventbus:5672`
- PostgreSQL hostname: `postgres:5432`
- Redis hostname: `redis:6379`

### Load Balancing
- Services using `type: LoadBalancer` are accessible externally in k3s
- Use `type: ClusterIP` for internal-only services
- Traefik ingress provides advanced routing in k3s overlay

## Troubleshooting

### Check Pod Logs
```bash
kubectl logs -n eshop -l app=<service-name> -f
```

### Describe Pod for Events
```bash
kubectl describe pod -n eshop <pod-name>
```

### Check Service Connectivity
```bash
kubectl run -it --rm debug --image=busybox:latest --restart=Never -- sh
# Inside pod:
wget -O- http://identity-api:80
```

### Database Connection Issues
```bash
# Connect to PostgreSQL
kubectl exec -it -n eshop postgres-0 -- psql -U postgres
```

### RabbitMQ Issues
```bash
# Check RabbitMQ logs
kubectl logs -n eshop rabbitmq-0

# Access Management UI (port-forward to 15672)
kubectl port-forward -n eshop svc/eventbus 15672:15672
# Visit: http://localhost:15672 (guest:guest)
```

## Scaling

### Scale Services
```bash
# Scale webapp to 3 replicas
kubectl scale deployment -n eshop webapp --replicas=3

# Scale ordering-api
kubectl scale deployment -n eshop ordering-api --replicas=2
```

### Update Kustomization
Edit `kustomization.yaml` replicas section and reapply:
```bash
kubectl apply -k manifest-output/
```

## Cleanup

### Delete All Resources
```bash
kubectl delete -k manifest-output/
```

### Delete Specific Namespace
```bash
kubectl delete namespace eshop
```

## Updating Container Images

Edit the deployment files to update image versions:
```bash
kubectl set image deployment/webapp -n eshop \
  webapp=sarialbebeto/webapp:v2 --record
```

Or use `kubectl patch`:
```bash
kubectl patch deployment webapp -n eshop -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"webapp","image":"sarialbebeto/webapp:v2"}]}}}}'
```

## Monitoring

Monitor deployments:
```bash
# Watch pod creation
kubectl get pods -n eshop -w

# Check resource usage
kubectl top pods -n eshop

# Check node resources
kubectl top nodes
```

## Production Considerations

Before deploying to production:

1. **Use image tags**: Replace `latest` with specific version tags
2. **Configure private registry**: If using private Docker registry, create ImagePullSecret
3. **Update credentials**: Change PostgreSQL and RabbitMQ default passwords
4. **Use managed services**: Consider managed PostgreSQL, Redis for production
5. **Enable HTTPS**: Configure TLS certificates for ingress
6. **Set resource quotas**: Add namespace resource quotas
7. **Configure network policies**: Restrict inter-pod communication
8. **Enable audit logging**: For compliance and troubleshooting
9. **Set up monitoring**: Deploy Prometheus/Grafana for metrics
10. **Configure backups**: Regular database backups and disaster recovery

## License

See parent repository for license information.
