#!/bin/bash
# Deployment Validation Script for eShop on k3s

set -e

NAMESPACE="eshop"
EXPECTED_DEPLOYMENTS=11  # All services except StatefulSets
EXPECTED_STATEFULSETS=2  # postgres, rabbitmq
EXPECTED_SERVICES=13     # All services

echo "=========================================="
echo "eShop Deployment Validation"
echo "=========================================="
echo ""

# Check if namespace exists
echo "🔍 Checking namespace..."
if kubectl get namespace ${NAMESPACE} &>/dev/null; then
    echo "  ✅ Namespace '${NAMESPACE}' exists"
else
    echo "  ❌ Namespace '${NAMESPACE}' not found"
    exit 1
fi

# Count deployments
DEPLOYMENT_COUNT=$(kubectl get deployments -n ${NAMESPACE} --no-headers | wc -l)
echo ""
echo "🚀 Checking Deployments (Expected: ${EXPECTED_DEPLOYMENTS}, Found: ${DEPLOYMENT_COUNT}):"
kubectl get deployments -n ${NAMESPACE} -o wide 2>/dev/null | awk 'NR>1 {status="✅"; if ($2!=$3) status="⚠️"; print "  " status " " $1 " (" $2 "/" $3 " ready)"}'

# Count StatefulSets
STATEFULSET_COUNT=$(kubectl get statefulsets -n ${NAMESPACE} --no-headers | wc -l)
echo ""
echo "📊 Checking StatefulSets (Expected: ${EXPECTED_STATEFULSETS}, Found: ${STATEFULSET_COUNT}):"
kubectl get statefulsets -n ${NAMESPACE} -o wide 2>/dev/null | awk 'NR>1 {status="✅"; if ($2!=$3) status="⚠️"; print "  " status " " $1 " (" $2 "/" $3 " ready)"}'

# Count services
SERVICE_COUNT=$(kubectl get services -n ${NAMESPACE} --no-headers | wc -l)
echo ""
echo "🌐 Checking Services (Expected: ${EXPECTED_SERVICES}, Found: ${SERVICE_COUNT}):"
kubectl get services -n ${NAMESPACE} --no-headers | awk '{status="✅"; print "  " status " " $1}'

# Check pods
echo ""
echo "📦 Pod Status:"
READY_PODS=$(kubectl get pods -n ${NAMESPACE} --field-selector=status.phase=Running --no-headers | wc -l)
TOTAL_PODS=$(kubectl get pods -n ${NAMESPACE} --no-headers | wc -l)
echo "  Running: ${READY_PODS}/${TOTAL_PODS}"

# Check for failed pods
FAILED_PODS=$(kubectl get pods -n ${NAMESPACE} --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
if [ ${FAILED_PODS} -gt 0 ]; then
    echo "  ⚠️  Failed/Pending Pods: ${FAILED_PODS}"
    echo ""
    kubectl get pods -n ${NAMESPACE} --field-selector=status.phase!=Running --no-headers | \
        awk '{print "    - " $1 " (" $3 ")"}'
else
    echo "  ✅ No failed pods"
fi

# Check ingress
echo ""
echo "🔗 Checking Ingress Resources:"
INGRESS_COUNT=$(kubectl get ingress -n ${NAMESPACE} --no-headers 2>/dev/null | wc -l)
if [ ${INGRESS_COUNT} -gt 0 ]; then
    kubectl get ingress -n ${NAMESPACE} -o wide | awk 'NR>1 {print "  ✅ " $1}'
else
    echo "  ℹ️  No ingress configured (deploy k3s overlay to enable)"
fi

# Check persistent volumes
echo ""
echo "💾 Checking Persistent Volumes:"
PVC_COUNT=$(kubectl get pvc -n ${NAMESPACE} --no-headers 2>/dev/null | wc -l)
if [ ${PVC_COUNT} -gt 0 ]; then
    kubectl get pvc -n ${NAMESPACE} --no-headers | awk '{status="✅"; if ($2!="Bound") status="⚠️"; print "  " status " " $1 " (" $2 ")"}'
else
    echo "  ℹ️  No PVC created yet"
fi

# Health check
echo ""
echo "🏥 Health Summary:"

# Calculate percentages
if [ ${TOTAL_PODS} -gt 0 ]; then
    READY_PERCENTAGE=$((READY_PODS * 100 / TOTAL_PODS))
else
    READY_PERCENTAGE=0
fi

case $READY_PERCENTAGE in
    100)
        STATUS_ICON="✅"
        STATUS_TEXT="All systems operational"
        ;;
    [5-9][0-9])
        STATUS_ICON="✅"
        STATUS_TEXT="Deployment in progress"
        ;;
    [1-4][0-9])
        STATUS_ICON="⚠️"
        STATUS_TEXT="Partial deployment"
        ;;
    0)
        STATUS_ICON="❌"
        STATUS_TEXT="Deployment failed or not started"
        ;;
esac

echo "  ${STATUS_ICON} Overall Status: ${STATUS_TEXT} (${READY_PERCENTAGE}%)"
echo "  Pods Ready: ${READY_PODS}/${TOTAL_PODS}"

# Print next steps
echo ""
echo "📋 Next Steps:"
if [ ${READY_PERCENTAGE} -eq 100 ]; then
    echo "  1. All services are running! 🎉"
    echo "  2. Access services via port-forwarding:"
    echo "     kubectl port-forward -n ${NAMESPACE} svc/webapp 8080:80"
    echo "  3. Or, if using k3s overlay with Traefik:"
    echo "     Add to /etc/hosts: 127.0.0.1 eshop.local"
    echo "     Then visit: http://eshop.local"
else
    echo "  1. Wait for pods to become ready:"
    echo "     kubectl get pods -n ${NAMESPACE} -w"
    echo "  2. Check pod logs if any are failing:"
    echo "     kubectl logs -n ${NAMESPACE} <pod-name>"
    echo "  3. Describe failing pod for more details:"
    echo "     kubectl describe pod -n ${NAMESPACE} <pod-name>"
fi

echo ""
echo "=========================================="

# Exit with appropriate code
if [ ${READY_PERCENTAGE} -eq 100 ]; then
    exit 0
else
    exit 1
fi
