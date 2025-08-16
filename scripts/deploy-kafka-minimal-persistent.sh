#!/bin/bash

# deploy-kafka-minimal-persistent.sh
# Script to deploy minimal Kafka setup WITH persistence

set -e

NAMESPACE="kafka"
RELEASE_NAME="kafka"
VALUES_FILE="helm-values/minimal-persistent.yaml"

echo "🚀 Deploying minimal Kafka setup WITH persistence..."

# Create namespace if it doesn't exist
echo "📁 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy Kafka using Helm
echo "⚡💾 Deploying Kafka with minimal resources + persistence..."
helm upgrade --install $RELEASE_NAME bitnami/kafka \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait \
  --timeout 12m

echo ""
echo "✅ Kafka minimal + persistent deployment complete!"
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
echo "📋 Configuration Summary:"
echo "  - Brokers: 1"
echo "  - CPU: 250m-1 core"
echo "  - Memory: 1-2Gi"
echo "  - Data Storage: 8Gi (persistent) ✅"
echo "  - Log Storage: Disabled (access via kubectl logs)"
echo "  - External Access: Disabled (can enable if needed)"

echo ""
echo "📋 Useful commands:"
echo "  - Check pods: kubectl get pods -n $NAMESPACE"
echo "  - Check logs: kubectl logs -f -n $NAMESPACE sts/$RELEASE_NAME"
echo "  - Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 9092:9092"
echo "  - Test: ./scripts/test-kafka.sh"
echo "  - Cleanup: ./scripts/cleanup.sh"

echo ""
echo "🎉 Your topics and messages will now persist across restarts!"
