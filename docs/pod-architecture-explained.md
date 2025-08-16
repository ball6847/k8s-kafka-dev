# Understanding Bitnami Kafka Chart Pod Architecture

The newer versions of the Bitnami Kafka Helm chart have a **new architecture** that uses separate StatefulSets for different node types.

## **🏗️ New Architecture (Kafka Chart v26+)**

The chart now has two statefulsets, one for controller-eligible nodes (controller or controller+broker) and another one for broker-only nodes.

### **Two StatefulSets Created:**

| StatefulSet | Purpose | Default Replicas | Our Setting |
|-------------|---------|------------------|-------------|
| **Controller** | KRaft controller nodes | `3` | `1` (minimal) |
| **Broker** | Broker-only nodes | `3` | `0` (disabled) |

### **Operating Modes:**

| Mode | Controller Pods | Broker Pods | Total Pods | Use Case |
|------|----------------|-------------|------------|----------|
| **Separated** | 3 controllers | 3 brokers | 6 pods | Production HA |
| **Combined** | 3 controller+broker | 0 brokers | 3 pods | Standard setup |
| **Minimal** | 1 controller+broker | 0 brokers | **1 pod** | Development |

## **🔧 Configuration Explained**

### **Why You Saw 3 Pods Initially:**

The default configuration creates 3 controller pods:
```yaml
controller:
  replicaCount: 3           # ← DEFAULT: 3 controller pods
  controllerOnly: false     # ← Each pod is controller+broker
```

### **Our Minimal Configuration:**

We changed it to create only 1 pod:
```yaml
controller:
  replicaCount: 1           # ← MINIMAL: Only 1 pod
  controllerOnly: false     # ← Pod serves as both controller AND broker

broker:
  replicaCount: 0           # ← DISABLED: No separate broker pods
```

## **📊 Resource Comparison**

| Configuration | Pods | CPU | RAM | Use Case |
|---------------|------|-----|-----|----------|
| **Default** | 3 pods | ~3 cores | ~6GB | Standard development |
| **Our Minimal** | 1 pod | ~1 core | ~2GB | Minimal development |
| **Production** | 6+ pods | ~12+ cores | ~24GB+ | Production HA |

## **🎯 Understanding the Settings**

### **Controller Settings:**
```yaml
controller:
  replicaCount: 1           # Number of controller pods
  controllerOnly: false     # If true: controller-only (needs separate brokers)
                           # If false: controller+broker combined
```

### **Broker Settings:**
```yaml
broker:
  replicaCount: 0           # Number of broker-only pods
                           # Set to 0 when using combined mode
```

### **Why This Architecture?**

This major version is a refactor of the Kafka chart and its architecture, to better adapt to Kraft features.

**Benefits:**
- **Flexibility**: Can separate controllers from brokers for large clusters
- **Scalability**: Scale controllers and brokers independently
- **KRaft Compliance**: Proper KRaft quorum management

**For Development:**
- **Combined mode** (`controllerOnly: false`) is simpler
- **Single pod** reduces resource usage
- **Still gets all Kafka functionality**

## **🚀 Deployment Patterns**

### **Minimal Development (1 pod):**
```yaml
controller:
  replicaCount: 1
  controllerOnly: false
broker:
  replicaCount: 0
```

### **Standard Development (3 pods):**
```yaml
controller:
  replicaCount: 3
  controllerOnly: false
broker:
  replicaCount: 0
```

### **Production HA (6 pods):**
```yaml
controller:
  replicaCount: 3
  controllerOnly: true      # Dedicated controllers
broker:
  replicaCount: 3           # Dedicated brokers
```

## **⚠️ Important Notes**

1. **Controller Quorum**: For production, always use odd numbers (1, 3, 5) for controller replicas
2. **Combined Mode**: `controllerOnly: false` means each pod serves as both controller AND broker
3. **Resource Allocation**: Controller settings under `controller:` section, not `kafka:` section
4. **Migration**: Existing deployments may need adjustment for the new architecture

## **🔍 Checking Your Deployment**

```bash
# Check all pods
kubectl get pods -n kafka-dev

# Check StatefulSets
kubectl get sts -n kafka-dev

# You should see:
# kafka-minimal-auth-controller-0  (1 pod in controller StatefulSet)
# No broker StatefulSet (because broker.replicaCount=0)
```

## **📝 Summary**

The "3 pods" you initially saw was the **default controller configuration**. Our updated minimal configuration now creates **only 1 pod** that serves as both controller and broker - perfect for development! 🎯
