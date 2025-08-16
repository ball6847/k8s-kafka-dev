#!/bin/bash

# test-kafka.sh
# Script to test Kafka deployment

set -e

# Configuration
NAMESPACE="kafka"
RELEASE_NAME="kafka"
TEST_TOPIC="test-topic"

echo "🧪 Testing Kafka deployment..."

# Check if we can find the Kafka service
if ! kubectl get svc -n $NAMESPACE -l app.kubernetes.io/name=kafka >/dev/null 2>&1; then
    echo "❌ No Kafka service found in namespace $NAMESPACE"
    echo "Available namespaces with Kafka:"
    kubectl get svc --all-namespaces -l app.kubernetes.io/name=kafka 2>/dev/null || echo "No Kafka services found"
    exit 1
fi

# Get the Kafka service name
KAFKA_SVC=$(kubectl get svc -n $NAMESPACE -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')
echo "📡 Found Kafka service: $KAFKA_SVC"

# Create a test pod with Kafka tools
echo "🛠️ Creating test pod with Kafka tools..."
kubectl run kafka-test-client --rm -i --tty \
  --image=bitnami/kafka:latest \
  --namespace=$NAMESPACE \
  --restart=Never \
  --command -- bash -c "
    echo '📝 Creating test topic: $TEST_TOPIC'
    kafka-topics.sh --create --topic $TEST_TOPIC --bootstrap-server $KAFKA_SVC:9092 --partitions 1 --replication-factor 1

    echo '📋 Listing topics:'
    kafka-topics.sh --list --bootstrap-server $KAFKA_SVC:9092

    echo '📤 Producing test message...'
    echo 'Hello Kafka from Kubernetes!' | kafka-console-producer.sh --bootstrap-server $KAFKA_SVC:9092 --topic $TEST_TOPIC

    echo '📥 Consuming messages (will timeout after 10 seconds):'
    timeout 10s kafka-console-consumer.sh --bootstrap-server $KAFKA_SVC:9092 --topic $TEST_TOPIC --from-beginning || echo 'Consumer timeout (expected)'

    echo '✅ Kafka test completed successfully!'
"

echo ""
echo "🎉 Kafka deployment test completed!"
echo ""
echo "📋 Additional testing commands:"
echo "  - Port forward: kubectl port-forward -n $NAMESPACE svc/$KAFKA_SVC 9092:9092"
echo "  - Then test locally: kafka-console-producer.sh --broker-list localhost:9092 --topic $TEST_TOPIC"
