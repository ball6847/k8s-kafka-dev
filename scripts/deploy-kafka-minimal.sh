#!/bin/bash

# deploy-kafka-minimal.sh
# Script to deploy minimal Kafka setup for development

set -e

NAMESPACE="kafka"
RELEASE_NAME="kafka"
VALUES_FILE="helm-values/minimal-dev.yaml"

echo "🚀 Deploying minimal Kafka setup..."

# Create namespace if it doesn't exist
echo "📁 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy Kafka using Helm
echo "⚡ Deploying Kafka with minimal configuration..."
helm upgrade --install $RELEASE_NAME bitnami/kafka \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait \
  --timeout 10m

echo ""
echo "✅ Kafka minimal deployment complete!"
echo ""
echo "📊 Deployment status:"
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=kafka

echo ""
echo "🔗 Service information:"
kubectl get svc -n $NAMESPACE -l app.kubernetes.io/name=kafka

echo ""
echo "📋 Useful commands:"
echo "  - Check pods: kubectl get pods -n $NAMESPACE"
echo "  - Check logs: kubectl logs -f -n $NAMESPACE deployment/$RELEASE_NAME"
echo "  - Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 9092:9092"
echo "  - Test: ./scripts/test-kafka.sh"
echo "  - Cleanup: ./scripts/cleanup.sh"
