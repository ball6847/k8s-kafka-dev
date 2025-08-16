#!/bin/bash

# cleanup.sh
# Script to cleanup Kafka deployments

set -e

echo "🧹 Cleaning up Kafka deployments..."

# Function to cleanup a namespace
cleanup_namespace() {
    local namespace=$1
    echo "🗑️ Cleaning up namespace: $namespace"
    
    # Get all Helm releases in the namespace
    releases=$(helm list -n $namespace -q 2>/dev/null || echo "")
    
    if [ -n "$releases" ]; then
        echo "📦 Found Helm releases in $namespace: $releases"
        for release in $releases; do
            echo "⏳ Uninstalling Helm release: $release"
            helm uninstall $release -n $namespace
        done
    else
        echo "ℹ️ No Helm releases found in $namespace"
    fi
    
    # Check for persistent volumes
    pvcs=$(kubectl get pvc -n $namespace -o name 2>/dev/null || echo "")
    if [ -n "$pvcs" ]; then
        echo "💾 Found persistent volume claims in $namespace:"
        kubectl get pvc -n $namespace
        read -p "Do you want to delete PVCs? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete pvc --all -n $namespace
            echo "✅ PVCs deleted"
        else
            echo "ℹ️ PVCs preserved"
        fi
    fi
    
    # Ask if user wants to delete the namespace
    read -p "Do you want to delete the namespace $namespace? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace $namespace
        echo "✅ Namespace $namespace deleted"
    else
        echo "ℹ️ Namespace $namespace preserved"
    fi
}

# Check for common Kafka namespaces
namespaces=("kafka" "kafka-prod")

for ns in "${namespaces[@]}"; do
    if kubectl get namespace $ns >/dev/null 2>&1; then
        cleanup_namespace $ns
        echo ""
    fi
done

# List any remaining Kafka-related resources
echo "🔍 Checking for remaining Kafka resources..."
kubectl get all --all-namespaces -l app.kubernetes.io/name=kafka 2>/dev/null || echo "No remaining Kafka resources found"

echo ""
echo "✅ Cleanup completed!"
