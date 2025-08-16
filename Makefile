# Makefile for Kafka on Kubernetes project
# Provides convenient shortcuts for common operations

.PHONY: help setup deploy-minimal deploy-persistent deploy-production test clean status logs port-forward

# Default target
help: ## Show this help message
	@echo "Kafka on Kubernetes - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick Start:"
	@echo "  make setup && make deploy-minimal-persistent && make test"

setup: ## Setup Helm repository
	@echo "🚀 Setting up Helm repository..."
	@./scripts/setup-helm-repo.sh

deploy-minimal: ## Deploy minimal Kafka setup (1 broker, no persistence)
	@echo "⚡ Deploying minimal Kafka..."
	@./scripts/deploy-kafka-minimal.sh

deploy-minimal-persistent: ## Deploy minimal Kafka WITH persistence (best of both worlds)
	@echo "⚡💾 Deploying minimal + persistent Kafka..."
	@./scripts/deploy-kafka-minimal-persistent.sh

deploy-minimal-auth: ## Deploy minimal Kafka WITH persistence AND authentication
	@echo "⚡🔐 Deploying minimal + persistent + auth Kafka..."
	@./scripts/deploy-kafka-minimal-auth.sh

deploy-persistent: ## Deploy persistent Kafka setup (1 broker, with persistence)
	@echo "💾 Deploying persistent Kafka..."
	@./scripts/deploy-kafka-persistent.sh

deploy-production: ## Deploy production-like setup (3 brokers, HA)
	@echo "🏭 Deploying production-like Kafka..."
	@./scripts/deploy-kafka-production.sh

test: ## Test Kafka deployment
	@echo "🧪 Testing Kafka..."
	@./scripts/test-kafka.sh

test-auth: ## Test authenticated Kafka deployment
	@echo "🧪🔐 Testing authenticated Kafka..."
	@./scripts/test-kafka-auth.sh

status: ## Show status of Kafka deployments
	@echo "📊 Kafka Deployment Status:"
	@echo ""
	@echo "=== kafka namespace ==="
	@kubectl get all -n kafka 2>/dev/null || echo "No resources in kafka"
	@echo ""
	@echo "=== kafka-prod namespace ==="
	@kubectl get all -n kafka-prod 2>/dev/null || echo "No resources in kafka-prod"

logs: ## Show logs from Kafka pods
	@echo "📋 Recent Kafka logs:"
	@kubectl logs -n kafka -l app.kubernetes.io/name=kafka --tail=50 2>/dev/null || \
	 kubectl logs -n kafka-prod -l app.kubernetes.io/name=kafka --tail=50 2>/dev/null || \
	 echo "No Kafka pods found"

logs-follow: ## Follow logs from Kafka pods
	@echo "📋 Following Kafka logs (Ctrl+C to stop):"
	@kubectl logs -n kafka -l app.kubernetes.io/name=kafka -f 2>/dev/null || \
	 kubectl logs -n kafka-prod -l app.kubernetes.io/name=kafka -f 2>/dev/null || \
	 echo "No Kafka pods found"

port-forward: ## Port forward Kafka service to localhost:9092
	@echo "🔌 Port forwarding Kafka to localhost:9092..."
	@echo "Press Ctrl+C to stop"
	@kubectl port-forward -n kafka svc/kafka 9092:9092 2>/dev/null || \
	 kubectl port-forward -n kafka-prod svc/kafka 9092:9092 2>/dev/null || \
	 echo "No Kafka service found for port forwarding"

shell: ## Open shell in Kafka pod for debugging
	@echo "🐚 Opening shell in Kafka pod..."
	@kubectl run kafka-debug-shell --rm -i --tty --image=bitnami/kafka:latest --namespace=kafka --restart=Never -- bash || \
	 kubectl run kafka-debug-shell --rm -i --tty --image=bitnami/kafka:latest --namespace=kafka-prod --restart=Never -- bash

topics: ## List Kafka topics
	@echo "📋 Kafka Topics:"
	@kubectl run kafka-topics --rm -i --tty --image=bitnami/kafka:latest --namespace=kafka --restart=Never -- \
	 kafka-topics.sh --list --bootstrap-server kafka:9092 2>/dev/null || \
	 kubectl run kafka-topics --rm -i --tty --image=bitnami/kafka:latest --namespace=kafka-prod --restart=Never -- \
	 kafka-topics.sh --list --bootstrap-server kafka:9092 2>/dev/null || \
	 echo "Could not connect to Kafka"

clean: ## Clean up all Kafka deployments
	@echo "🧹 Cleaning up Kafka deployments..."
	@./scripts/cleanup.sh

# Development shortcuts
dev: deploy-minimal ## Alias for deploy-minimal
dev-persistent: deploy-minimal-persistent ## Alias for deploy-minimal-persistent
dev-auth: deploy-minimal-auth ## Alias for deploy-minimal-auth (with authentication)
prod: deploy-production ## Alias for deploy-production

# Validation targets
check-kubectl: ## Check if kubectl is installed and configured
	@kubectl version --client >/dev/null 2>&1 || (echo "❌ kubectl not found or not configured" && exit 1)
	@echo "✅ kubectl is available"

check-helm: ## Check if Helm is installed
	@helm version >/dev/null 2>&1 || (echo "❌ Helm not found" && exit 1)
	@echo "✅ Helm is available"

check-cluster: check-kubectl ## Check if Kubernetes cluster is accessible
	@kubectl cluster-info >/dev/null 2>&1 || (echo "❌ Cannot connect to Kubernetes cluster" && exit 1)
	@echo "✅ Kubernetes cluster is accessible"

validate: check-helm check-cluster ## Validate all prerequisites
	@echo "✅ All prerequisites are met!"

# Resource monitoring
resources: ## Show resource usage
	@echo "📊 Resource Usage:"
	@echo ""
	@echo "=== Nodes ==="
	@kubectl top nodes 2>/dev/null || echo "Metrics server not available"
	@echo ""
	@echo "=== Kafka Pods ==="
	@kubectl top pods -n kafka -l app.kubernetes.io/name=kafka 2>/dev/null || \
	 kubectl top pods -n kafka-prod -l app.kubernetes.io/name=kafka 2>/dev/null || \
	 echo "No Kafka pods found or metrics server not available"

# Backup and restore (for persistent setups)
backup-list: ## List available persistent volumes
	@echo "💾 Persistent Volumes:"
	@kubectl get pv
	@echo ""
	@echo "💾 Persistent Volume Claims:"
	@kubectl get pvc --all-namespaces

# Documentation
docs: ## Open documentation in browser (if available)
	@echo "📚 Documentation available in:"
	@echo "  - README.md"
	@echo "  - docs/quick-start-guide.md" 
	@echo "  - docs/values-configuration-guide.md"

# Advanced targets
upgrade-minimal: ## Upgrade minimal deployment with latest values
	@helm upgrade kafka bitnami/kafka -n kafka --values helm-values/minimal-dev.yaml

upgrade-minimal-persistent: ## Upgrade minimal-persistent deployment with latest values
	@helm upgrade kafka bitnami/kafka -n kafka --values helm-values/minimal-persistent.yaml

upgrade-persistent: ## Upgrade persistent deployment with latest values
	@helm upgrade kafka bitnami/kafka -n kafka --values helm-values/persistent-dev.yaml

upgrade-production: ## Upgrade production deployment with latest values
	@helm upgrade kafka bitnami/kafka -n kafka-prod --values helm-values/production-like.yaml
