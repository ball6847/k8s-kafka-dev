#!/bin/bash

# deploy-kafka-minimal-auth.sh
# Script to deploy minimal Kafka setup WITH persistence AND authentication

set -e

NAMESPACE="kafka"
RELEASE_NAME="kafka"
VALUES_FILE="helm-values/minimal-persistent-auth.yaml"

echo "🚀 Deploying minimal Kafka setup with authentication..."

# Create namespace if it doesn't exist
echo "📁 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy Kafka using Helm
echo "⚡🔐 Deploying Kafka with minimal resources + persistence + authentication..."
helm upgrade --install $RELEASE_NAME bitnami/kafka \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --wait \
  --timeout 12m

echo ""
echo "✅ Kafka minimal + persistent + auth deployment complete!"
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
echo "🔐 Authentication Information:"
echo "   Users created: kafka-user, admin-user, dev-user"
echo "   Passwords: Check the secret or use values from config"

echo ""
echo "🔑 Get user passwords:"
echo "   kubectl get secret $RELEASE_NAME-user-passwords -n $NAMESPACE -o jsonpath='{.data.client-passwords}' | base64 -d"

echo ""
echo "📋 Configuration Summary:"
echo "  - Brokers: 1"
echo "  - CPU: 250m-1 core"
echo "  - Memory: 1-2Gi"
echo "  - Data Storage: 8Gi (persistent) ✅"
echo "  - Authentication: SASL PLAIN ✅"
echo "  - External Access: Disabled (use port-forward for external access)"

echo ""
echo "🧪 Testing with authentication:"
echo "  1. Get credentials:"
echo "     kubectl get secret $RELEASE_NAME-user-passwords -n $NAMESPACE -o yaml"
echo "  2. Create client.properties:"
echo "     echo 'security.protocol=SASL_PLAINTEXT' > client.properties"
echo "     echo 'sasl.mechanism=PLAIN' >> client.properties"
echo "     echo 'sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"kafka-user\" password=\"kafka-password\";' >> client.properties"
echo "  3. Test with: ./scripts/test-kafka-auth.sh"

echo ""
echo "📋 Useful commands:"
echo "  - Check pods: kubectl get pods -n $NAMESPACE"
echo "  - Check logs: kubectl logs -f -n $NAMESPACE sts/$RELEASE_NAME"
echo "  - Port forward: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 9092:9092"
echo "  - Test auth: ./scripts/test-kafka-auth.sh"
echo "  - Cleanup: ./scripts/cleanup.sh"
