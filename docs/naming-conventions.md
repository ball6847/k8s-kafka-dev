# Resource Naming Conventions

## **🏷️ What Changed**

We've simplified the naming to be cleaner and more conventional:

### **Before (Verbose):**
```
Namespace: kafka-dev
Release: kafka-minimal-auth
Pod: kafka-minimal-auth-controller-0
Service: kafka-minimal-auth
```

### **After (Clean):**
```
Namespace: kafka
Release: kafka
Pod: kafka-controller-0
Service: kafka
```

## **📋 Current Naming Structure**

| Resource Type | Name Pattern | Example |
|---------------|--------------|---------|
| **Namespace** | `kafka` | `kafka` |
| **Release Name** | `kafka` | `kafka` |
| **Controller Pod** | `{release}-controller-{id}` | `kafka-controller-0` |
| **Service** | `{release}` | `kafka` |
| **Secret** | `{release}-user-passwords` | `kafka-user-passwords` |
| **PVC** | `data-{release}-controller-{id}` | `data-kafka-controller-0` |

## **🎯 Benefits of Clean Naming**

### **1. Simpler Commands:**
```bash
# Port forward
kubectl port-forward -n kafka svc/kafka 9092:9092

# Check pods  
kubectl get pods -n kafka

# View logs
kubectl logs -n kafka kafka-controller-0
```

### **2. Cleaner URLs:**
```
# Internal service
kafka.kafka.svc.cluster.local:9092

# Instead of:
kafka-minimal-auth.kafka-dev.svc.cluster.local:9092
```

### **3. Environment Consistency:**
```bash
# Development
kubectl get pods -n kafka

# Production  
kubectl get pods -n kafka-prod
```

## **🔧 Configuration Impact**

### **Deployment Scripts:**
All deployment scripts now use:
- **Namespace**: `kafka` (for dev) / `kafka-prod` (for production)
- **Release Name**: `kafka`

### **Application Connections:**
Update your application configs to use:
```properties
# Kubernetes internal
bootstrap.servers=kafka.kafka.svc.cluster.local:9092

# Port-forwarded local
bootstrap.servers=localhost:9092
```

### **Monitoring/Alerting:**
Update any monitoring to look for:
- **Pod name pattern**: `kafka-controller-*`
- **Namespace**: `kafka`
- **Service**: `kafka`

## **🚀 Quick Migration**

If you have existing deployments with old names:

```bash
# Clean up old deployment
make clean

# Deploy with new clean names
make deploy-minimal-auth

# Verify new naming
kubectl get all -n kafka
```

## **📝 Summary**

The new naming convention provides:
- ✅ **Shorter, cleaner resource names**
- ✅ **Standard namespace conventions**
- ✅ **Easier command-line usage**
- ✅ **More professional naming for production**
- ✅ **Consistent across all configurations**

Perfect for both development and production environments! 🎯
