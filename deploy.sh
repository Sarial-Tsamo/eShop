#!/bin/bash
# Quick Deployment Script for eShop on k3s

set -e

echo "=========================================="
echo "eShop k3s Deployment Script"
echo "=========================================="

# Check prerequisites
echo "Checking prerequisites..."
command -v kubectl &> /dev/null || { echo "kubectl is required but not installed"; exit 1; }

NAMESPACE="eshop"
MANIFEST_DIR="manifest-output"

echo ""
echo "📦 Prerequisites Check"
echo "  ✓ kubectl is available"

# Check cluster connection
echo ""
echo "🔗 Connecting to k3s cluster..."
kubectl cluster-info > /dev/null 2>&1 || { echo "Cannot connect to k3s cluster"; exit 1; }
echo "  ✓ Connected to cluster"

# Show cluster info
echo ""
echo "📊 Cluster Info:"
kubectl cluster-info | grep -E "Kubernetes master|Server"
echo "  Nodes:"
kubectl get nodes --no-headers | awk '{print "    - "$1" ("$5")"}'

# Deploy base manifests
echo ""
echo "🚀 Deploying eShop Manifests..."
echo "  Stage 1: Creating namespace and infrastructure..."
kubectl apply -k ${MANIFEST_DIR}/ --dry-run=client -o yaml | head -10

echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  Applying manifests..."
    kubectl apply -k ${MANIFEST_DIR}/
    
    echo ""
    echo "✅ Manifests applied successfully!"
    
    # Wait for pods to be ready
    echo ""
    echo "⏳ Waiting for pods to be ready (this may take a few minutes)..."
    kubectl rollout status deployment -n ${NAMESPACE} --all --timeout=5m 2>/dev/null || echo "  (Some pods may still be starting...)"
    
    # Show deployment status
    echo ""
    echo "📋 Deployment Status:"
    echo ""
    echo "Namespace: ${NAMESPACE}"
    kubectl get ns | grep ${NAMESPACE}
    
    echo ""
    echo "Pods:"
    kubectl get pods -n ${NAMESPACE} --no-headers || echo "  (No pods yet)"
    
    echo ""
    echo "Services:"
    kubectl get svc -n ${NAMESPACE} --no-headers || echo "  (No services yet)"
    
    echo ""
    echo "✨ Deployment Complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Wait for all pods to reach 'Running' status:"
    echo "     kubectl get pods -n ${NAMESPACE} -w"
    echo ""
    echo "  2. Access services via port-forwarding:"
    echo "     kubectl port-forward -n ${NAMESPACE} svc/webapp 8080:80"
    echo ""
    echo "  3. View logs:"
    echo "     kubectl logs -n ${NAMESPACE} -l app=webapp -f"
    echo ""
    echo "  4. For more information, see: ${MANIFEST_DIR}/README.md"
else
    echo "Deployment cancelled."
    exit 0
fi
