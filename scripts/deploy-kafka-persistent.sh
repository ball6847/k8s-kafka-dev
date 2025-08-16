#!/bin/bash

# deploy-kafka-persistent.sh
# Script to deploy persistent Kafka setup for development

set -e

NAMESPACE="kafka"
RELEASE_NAME="kafka"
VALUES_FILE="helm-values/persistent-dev.yaml"

echo "🚀 Deploying persistent Kafka setup..."

# Create namespace if it doesn't exist
echo "📁 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy Kafka using Helm
echo "💾 Deploying Kafka with persistent storage..."
helm upgrade --install $RELEASE_NAME bitnami/kafka \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait \
  --timeout 15m

echo ""
echo "✅ Kafka persistent deployment complete!"
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
echo "📋 Useful commands:"
echo "  - Check pods: kubectl get pods -n $NAMESPACE"
echo "  - Check logs: kubectl logs -f -n $NAMESPACE sts/$RELEASE_NAME"
echo "  - Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 9092:9092"
echo "  - External access: kubectl get svc -n $NAMESPACE $RELEASE_NAME-external"
echo "  - Test: ./scripts/test-kafka.sh"
echo "  - Cleanup: ./scripts/cleanup.sh"
