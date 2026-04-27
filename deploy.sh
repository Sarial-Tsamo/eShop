#!/bin/bash
# Quick Deployment Script for eShop on k3s

set -e

# --- Configuration ---
export KUBECONFIG="$HOME/.kube/config"
NAMESPACE="eshop"

MANIFEST_DIR="overlays/k3s"

echo "=========================================="
echo "🚀 Starting Automated eShop Deployment"
echo "=========================================="

# 1. Check prerequisites & connection
echo "Checking prerequisites..."
command -v kubectl &> /dev/null || { echo "kubectl is required but not installed"; exit 1; }

echo ""
echo "📦 Prerequisites Check"
echo "  ✓ kubectl is available"

echo ""
echo "🔗 Connecting to k3s cluster..."
kubectl get nodes > /dev/null 2>&1 || { echo "Cannot connect to k3s cluster. Ensure $KUBECONFIG is set correctly"; exit 1; }
echo "  ✓ Connected to cluster"

# 2. Show cluster info
echo ""
echo "📊 Cluster Nodes:"
echo "  Nodes:"
kubectl get nodes --no-headers | awk '{print "    - "$1" ("$5")"}'

# 3. Apply manifests
echo ""
echo "🚀 Deploying eShop Manifests..."
echo "  Stage 1: Creating namespace and infrastructure..."
kubectl apply -k ${MANIFEST_DIR} --load-restrictor LoadRestrictionsNone

echo "✅ Manifests applied successfully!"

# 4. Wait for pods to be ready
echo ""
echo "⏳ Waiting for deployments to become available..."
kubectl wait --for=condition=available deployment --all -n ${NAMESPACE} --timeout=2m || echo "⚠️ Some pods are still initializing (this is normal on first run)..."

# 5. Summary
echo ""
echo "📋 Current Pod Status:"
kubectl get pods -n ${NAMESPACE}
echo ""
echo "✨ Deployment Complete!"