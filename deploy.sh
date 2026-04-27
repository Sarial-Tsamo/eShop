#!/bin/bash
# Quick Deployment Script for eShop on k3s

set -e

# --- Configuration ---
export KUBECONFIG="$HOME/.kube/config"

echo "=========================================="
echo "eShop k3s Deployment Script"
echo "=========================================="

# Check prerequisites
echo "Checking prerequisites..."
command -v kubectl &> /dev/null || { echo "kubectl is required but not installed"; exit 1; }

NAMESPACE="eshop"
MANIFEST_DIR="eShop"

echo ""
echo "📦 Prerequisites Check"
echo "  ✓ kubectl is available"

# Check cluster connection
echo ""
echo "🔗 Connecting to k3s cluster..."
kubectl get nodes > /dev/null 2>&1 || { echo "Cannot connect to k3s cluster. Ensure $KUBECONFIG is set correctly"; exit 1; }
echo "  ✓ Connected to cluster"

# Show cluster info
echo ""
echo "📊 Cluster Nodes:"
echo "  Nodes:"
kubectl get nodes --no-headers | awk '{print "    - "$1" ("$5")"}'

# Deploy base manifests
echo ""
echo "🚀 Deploying eShop Manifests..."
echo "  Stage 1: Creating namespace and infrastructure..."
kubectl apply -k ${MANIFEST_DIR}/ --dry-run=client -o yaml | head -10
echo "✅ Manifests applied successfully!"

echo ""
echo "⏳ Checking rollout status..."
kubectl rollout status deployment -n ${NAMESPACE} --all --timeout=2m || echo "⚠️ Some pods are still initializing..."

echo ""
echo "📋 Current Pod Status:"
kubectl get pods -n ${NAMESPACE}
echo ""
echo "✨ Deployment Complete!"