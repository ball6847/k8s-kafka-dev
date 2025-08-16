#!/bin/bash

# setup-helm-repo.sh
# Script to setup Bitnami Helm repository

set -e

echo "🚀 Setting up Bitnami Helm repository..."

# Add Bitnami Helm repository
echo "📦 Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update Helm repositories
echo "🔄 Updating Helm repositories..."
helm repo update

# List repositories to verify
echo "✅ Helm repositories:"
helm repo list

# Show available Kafka chart versions
echo ""
echo "📋 Available Kafka chart versions:"
helm search repo bitnami/kafka --versions | head -10

echo ""
echo "✅ Bitnami Helm repository setup complete!"
echo ""
echo "Next steps:"
echo "  - Run './scripts/deploy-kafka-minimal.sh' for minimal setup"
echo "  - Run './scripts/deploy-kafka-persistent.sh' for persistent setup"
echo "  - Run './scripts/deploy-kafka-production.sh' for production-like setup"
