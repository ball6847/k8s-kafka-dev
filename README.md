# Kafka on Kubernetes Development Setup

This project contains Helm values and scripts for deploying Apache Kafka on Kubernetes for development purposes using the Bitnami Kafka Helm chart.

## Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or any k8s cluster)
- Helm 3.x installed
- kubectl configured to access your cluster

### Installation

1. **Add Bitnami Helm Repository**
   ```bash
   ./scripts/setup-helm-repo.sh
   ```

2. **Deploy Kafka (Minimal Development Setup)**
   ```bash
   ./scripts/deploy-kafka-minimal.sh
   ```

3. **Deploy Kafka (Minimal + Persistent - RECOMMENDED)**
   ```bash
   ./scripts/deploy-kafka-minimal-persistent.sh
   ```

4. **Deploy Kafka (Minimal + Persistent + Authentication)**
   ```bash
   ./scripts/deploy-kafka-minimal-auth.sh
   ```

5. **Deploy Kafka (Persistent Development Setup)**
   ```bash
   ./scripts/deploy-kafka-persistent.sh
   ```

6. **Deploy Kafka (Production-like Setup)**
   ```bash
   ./scripts/deploy-kafka-production.sh
   ```

### Helm Values Files

- `helm-values/minimal-dev.yaml` - Minimal setup for development (single broker, no persistence)
- `helm-values/minimal-persistent.yaml` - Minimal setup WITH persistence (single broker, persistent storage) **RECOMMENDED**
- `helm-values/minimal-persistent-auth.yaml` - Minimal setup + persistence + SASL authentication
- `helm-values/persistent-dev.yaml` - Development setup with persistence (more resources)
- `helm-values/production-like.yaml` - Production-like setup (3 brokers, persistence, monitoring)

### Testing

After deployment, test your Kafka installation:
```bash
./scripts/test-kafka.sh
```

### Cleanup

To remove the Kafka deployment:
```bash
./scripts/cleanup.sh
```

## Configuration Options

### Resource Requirements

- **Minimal**: ~1 CPU, 2Gi RAM (no persistence)
- **Minimal + Persistent**: ~1 CPU, 2Gi RAM + 8Gi storage (RECOMMENDED)
- **Development**: ~2 CPU, 4Gi RAM + 18Gi storage
- **Production-like**: ~6 CPU, 12Gi RAM + 90Gi storage

### External Access

The charts include options for:
- NodePort services (for local development)
- LoadBalancer services (for cloud environments)
- Ingress controllers

See the values files for specific configurations.

## Useful Commands

```bash
# Get Kafka pods
kubectl get pods -l app.kubernetes.io/name=kafka -n kafka

# Get Kafka services
kubectl get svc -l app.kubernetes.io/name=kafka -n kafka

# Port forward to access Kafka locally
kubectl port-forward -n kafka svc/kafka 9092:9092

# Access kafka logs
kubectl logs -f -n kafka sts/kafka-controller
```
