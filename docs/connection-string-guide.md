# Kafka Connection String Generator

The `get-kafka-connection.sh` script automatically generates the correct Kafka connection strings for different access scenarios.

## **🚀 Quick Usage**

### **Via Makefile (Recommended):**
```bash
# Internal cluster access
make connection

# Local access (port-forward)
make connection-local

# External access  
make connection-external

# With authentication
make connection-auth
```

### **Direct Script Usage:**
```bash
# Basic usage
./scripts/get-kafka-connection.sh --type internal

# With authentication
./scripts/get-kafka-connection.sh --type internal --auth

# Specific namespace
./scripts/get-kafka-connection.sh --namespace kafka --type external

# Full example
./scripts/get-kafka-connection.sh --namespace kafka --release kafka --type local --auth
```

## **📋 Connection Types**

| Type | Use Case | Output |
|------|----------|--------|
| **`internal`** | Apps inside K8s cluster | `kafka.kafka.svc.cluster.local:9092` |
| **`external`** | Apps outside K8s cluster | NodePort/LoadBalancer endpoints |
| **`local`** | Local development | `localhost:9092` + port-forward command |

## **🔍 Auto-Detection**

The script automatically detects:
- ✅ **Namespace** (searches: kafka, kafka-dev, kafka-prod, default)
- ✅ **Release name** (finds Helm releases with "kafka" in name)
- ✅ **Service type** (NodePort, LoadBalancer, ClusterIP)
- ✅ **Authentication setup** (checks for SASL configuration)

## **📤 Example Outputs**

### **Internal Access:**
```bash
$ make connection
🔗 Kafka Connection String:
# Kafka connection for applications INSIDE Kubernetes cluster
# Namespace: kafka, Release: kafka

bootstrap.servers=kafka.kafka.svc.cluster.local:9092
```

### **Local Access with Auth:**
```bash
$ make connection-auth
🔗 Kafka Connection String (With Auth):
# Kafka connection for applications INSIDE Kubernetes cluster
# Namespace: kafka, Release: kafka

bootstrap.servers=kafka.kafka.svc.cluster.local:9092

# Authentication properties (SASL PLAIN)
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="kafka-user" password="kafka-password";

# Available users: kafka-user, admin-user, dev-user
# Get actual passwords with:
# kubectl get secret kafka-user-passwords -n kafka -o jsonpath='{.data.client-passwords}' | base64 -d
```

### **External Access:**
```bash
$ make connection-external
🔗 Kafka Connection String (External):
# Kafka connection for applications OUTSIDE Kubernetes cluster
# Namespace: kafka, Release: kafka

# NodePort access - use any node IP
bootstrap.servers=<NODE_IP>:31234
# Get node IPs with: kubectl get nodes -o wide
```

### **Port-Forward Setup:**
```bash
$ make connection-local
🔗 Kafka Connection String (Local):
# Kafka connection via port-forward (localhost)
# Namespace: kafka, Release: kafka

# Use port-forward command:
# kubectl port-forward -n kafka svc/kafka 9092:9092
bootstrap.servers=localhost:9092
```

## **🔧 Advanced Options**

```bash
# Manual namespace/release
./scripts/get-kafka-connection.sh --namespace my-kafka --release my-release --type internal

# Help
./scripts/get-kafka-connection.sh --help
```

## **💡 Use Cases**

### **1. Application Configuration**
Copy the output directly into your application's configuration:

**Spring Boot (application.properties):**
```properties
spring.kafka.bootstrap-servers=kafka.kafka.svc.cluster.local:9092
spring.kafka.security.protocol=SASL_PLAINTEXT
spring.kafka.sasl.mechanism=PLAIN
spring.kafka.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="kafka-user" password="kafka-password";
```

**Node.js (KafkaJS):**
```javascript
const kafka = require('kafkajs')

const client = kafka({
  clientId: 'my-app',
  brokers: ['kafka.kafka.svc.cluster.local:9092'],
  sasl: {
    mechanism: 'plain',
    username: 'kafka-user',
    password: 'kafka-password'
  }
})
```

### **2. Testing/Debugging**
```bash
# Get connection string
./scripts/get-kafka-connection.sh --type local --auth > kafka-config.properties

# Use for testing
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test --producer.config kafka-config.properties
```

### **3. CI/CD Pipelines**
```bash
# In your pipeline
KAFKA_BROKERS=$(./scripts/get-kafka-connection.sh --type internal | grep bootstrap.servers | cut -d'=' -f2)
echo "Using Kafka brokers: $KAFKA_BROKERS"
```

## **🎯 Benefits**

- ✅ **Auto-detection** - No need to remember service names
- ✅ **Multiple formats** - Works for different access patterns
- ✅ **Authentication ready** - Includes SASL configuration  
- ✅ **Copy-paste ready** - Direct use in application configs
- ✅ **Documentation included** - Shows how to use the connection string

Perfect for development, testing, and production application configuration! 🚀
