#!/bin/bash

# deploy-kafka-production.sh
# Script to deploy production-like Kafka setup

set -e

NAMESPACE="kafka-prod"
RELEASE_NAME="kafka"
VALUES_FILE="helm-values/production-like.yaml"

echo "🚀 Deploying production-like Kafka setup..."

# Create namespace if it doesn't exist
echo "📁 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy Kafka using Helm
echo "🏭 Deploying Kafka with production-like configuration..."
helm upgrade --install $RELEASE_NAME bitnami/kafka \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait \
  --timeout 20m

echo ""
echo "✅ Kafka production-like deployment complete!"
echo ""
echo "📊 Deployment status:"
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=kafka

echo ""
echo "🔗 Service information:"
kubectl get svc -n $NAMESPACE -l app.kubernetes.io/name=kafka

echo ""
echo "💾 Persistent volumes:"
kubectl get pvc -n $NAMESPACE

echo ""
echo "📈 Monitoring (if enabled):"
kubectl get servicemonitor -n $NAMESPACE 2>/dev/null || echo "ServiceMonitor not found (Prometheus operator may not be installed)"

echo ""
echo "📋 Useful commands:"
echo "  - Check pods: kubectl get pods -n $NAMESPACE"
echo "  - Check StatefulSet: kubectl get sts -n $NAMESPACE"
echo "  - Check logs: kubectl logs -f -n $NAMESPACE sts/$RELEASE_NAME"
echo "  - Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 9092:9092"
echo "  - External access: kubectl get svc -n $NAMESPACE $RELEASE_NAME-external"
echo "  - Test: ./scripts/test-kafka.sh"
echo "  - Cleanup: ./scripts/cleanup.sh"
