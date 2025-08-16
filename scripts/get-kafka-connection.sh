#!/bin/bash

# get-kafka-connection.sh
# Script to return Kafka connection string for different scenarios

set -e

# Default values
NAMESPACE=""
RELEASE_NAME=""
ACCESS_TYPE=""
INCLUDE_AUTH=""

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Get Kafka connection string for different access scenarios"
    echo ""
    echo "Options:"
    echo "  -n, --namespace NAMESPACE    Kubernetes namespace (default: auto-detect)"
    echo "  -r, --release RELEASE        Helm release name (default: auto-detect)"
    echo "  -t, --type TYPE             Connection type: internal|external|local"
    echo "                              internal: From inside Kubernetes cluster"
    echo "                              external: From outside cluster (NodePort/LoadBalancer)"
    echo "                              local: Via port-forward to localhost"
    echo "  -a, --auth                  Include authentication properties"
    echo "  -h, --help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --type internal          # Internal cluster connection"
    echo "  $0 --type local --auth      # Port-forward with authentication"
    echo "  $0 --type external -n kafka # External access in kafka namespace"
}

# Function to auto-detect Kafka deployment
auto_detect_kafka() {
    echo "🔍 Auto-detecting Kafka deployment..." >&2
    
    # Common namespaces to check
    local namespaces=("kafka" "kafka-dev" "kafka-prod" "default")
    
    for ns in "${namespaces[@]}"; do
        if kubectl get namespace "$ns" >/dev/null 2>&1; then
            local releases=$(helm list -n "$ns" -q 2>/dev/null | grep -E "(kafka|confluent)" || echo "")
            if [ -n "$releases" ]; then
                NAMESPACE="$ns"
                RELEASE_NAME=$(echo "$releases" | head -1)
                echo "✅ Found Kafka: release='$RELEASE_NAME' namespace='$NAMESPACE'" >&2
                return 0
            fi
        fi
    done
    
    echo "❌ No Kafka deployment found in common namespaces" >&2
    return 1
}

# Function to get service information
get_service_info() {
    local ns="$1"
    local service_name="$2"
    
    if ! kubectl get svc "$service_name" -n "$ns" >/dev/null 2>&1; then
        echo "❌ Service '$service_name' not found in namespace '$ns'" >&2
        return 1
    fi
    
    kubectl get svc "$service_name" -n "$ns" -o json
}

# Function to generate internal connection string
get_internal_connection() {
    local ns="$1"
    local release="$2"
    
    echo "bootstrap.servers=${release}.${ns}.svc.cluster.local:9092"
}

# Function to generate external connection string  
get_external_connection() {
    local ns="$1"
    local release="$2"
    
    # Check for external service
    local external_svc="${release}-external"
    if kubectl get svc "$external_svc" -n "$ns" >/dev/null 2>&1; then
        local svc_info=$(get_service_info "$ns" "$external_svc")
        local svc_type=$(echo "$svc_info" | jq -r '.spec.type')
        
        case "$svc_type" in
            "NodePort")
                local nodeport=$(echo "$svc_info" | jq -r '.spec.ports[0].nodePort')
                echo "# NodePort access - use any node IP"
                echo "bootstrap.servers=<NODE_IP>:${nodeport}"
                echo "# Get node IPs with: kubectl get nodes -o wide"
                ;;
            "LoadBalancer")
                local lb_ip=$(echo "$svc_info" | jq -r '.status.loadBalancer.ingress[0].ip // .status.loadBalancer.ingress[0].hostname // "PENDING"')
                if [ "$lb_ip" = "PENDING" ]; then
                    echo "# LoadBalancer IP is pending..."
                    echo "bootstrap.servers=<PENDING_LOADBALANCER_IP>:9092"
                    echo "# Check status with: kubectl get svc $external_svc -n $ns"
                else
                    echo "bootstrap.servers=${lb_ip}:9092"
                fi
                ;;
            *)
                echo "# Unsupported external service type: $svc_type"
                return 1
                ;;
        esac
    else
        echo "# No external service found. Use port-forward instead:"
        echo "# kubectl port-forward -n $ns svc/$release 9092:9092"
        echo "bootstrap.servers=localhost:9092"
    fi
}

# Function to generate local (port-forward) connection string
get_local_connection() {
    local ns="$1"
    local release="$2"
    
    echo "# Use port-forward command:"
    echo "# kubectl port-forward -n $ns svc/$release 9092:9092"
    echo "bootstrap.servers=localhost:9092"
}

# Function to add authentication properties
add_auth_properties() {
    echo ""
    echo "# Authentication properties (SASL PLAIN)"
    echo "security.protocol=SASL_PLAINTEXT"
    echo "sasl.mechanism=PLAIN"
    echo "sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"kafka-user\" password=\"kafka-password\";"
    echo ""
    echo "# Available users: kafka-user, admin-user, dev-user"
    echo "# Get actual passwords with:"
    echo "# kubectl get secret $RELEASE_NAME-user-passwords -n $NAMESPACE -o jsonpath='{.data.client-passwords}' | base64 -d"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -t|--type)
            ACCESS_TYPE="$2"
            shift 2
            ;;
        -a|--auth)
            INCLUDE_AUTH="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_usage >&2
            exit 1
            ;;
    esac
done

# Auto-detect if not provided
if [ -z "$NAMESPACE" ] || [ -z "$RELEASE_NAME" ]; then
    if ! auto_detect_kafka; then
        echo ""
        echo "Please specify namespace and release name manually:"
        echo "  $0 --namespace kafka --release kafka --type internal"
        exit 1
    fi
fi

# Validate access type
if [ -z "$ACCESS_TYPE" ]; then
    echo "❌ Access type is required. Use --type internal|external|local" >&2
    show_usage >&2
    exit 1
fi

case "$ACCESS_TYPE" in
    "internal")
        echo "# Kafka connection for applications INSIDE Kubernetes cluster"
        echo "# Namespace: $NAMESPACE, Release: $RELEASE_NAME"
        echo ""
        get_internal_connection "$NAMESPACE" "$RELEASE_NAME"
        ;;
    "external")
        echo "# Kafka connection for applications OUTSIDE Kubernetes cluster"
        echo "# Namespace: $NAMESPACE, Release: $RELEASE_NAME"
        echo ""
        get_external_connection "$NAMESPACE" "$RELEASE_NAME"
        ;;
    "local")
        echo "# Kafka connection via port-forward (localhost)"
        echo "# Namespace: $NAMESPACE, Release: $RELEASE_NAME"
        echo ""
        get_local_connection "$NAMESPACE" "$RELEASE_NAME"
        ;;
    *)
        echo "❌ Invalid access type: $ACCESS_TYPE" >&2
        echo "Valid types: internal, external, local" >&2
        exit 1
        ;;
esac

# Add authentication if requested
if [ "$INCLUDE_AUTH" = "true" ]; then
    add_auth_properties
fi

echo ""
echo "# Generated on: $(date)"
echo "# Cluster context: $(kubectl config current-context)"
