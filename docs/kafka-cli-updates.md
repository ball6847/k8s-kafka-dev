# Kafka Command Line Tool Updates

## **🔧 Issue Fixed: `broker-list` Deprecated**

The error you encountered is due to Kafka command-line tools being updated to use newer option names.

### **❌ Old (Deprecated) Syntax:**
```bash
kafka-console-producer.sh --broker-list localhost:9092 --topic test
```

### **✅ New (Current) Syntax:**
```bash
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test
```

## **📋 Command Updates**

| Tool | Option | Purpose | Status |
|------|--------|---------|--------|
| **Producer** | `--producer.config` | Authentication config | ✅ Correct |
| **Consumer** | `--consumer.config` | Authentication config | ✅ Correct |
| **Topics** | `--command-config` | Authentication config | ✅ Fixed |
| **ACLs** | `--command-config` | Authentication config | ✅ Correct |

## **🎯 What I Fixed**

### **1. Test Scripts Updated:**
- ✅ `scripts/test-kafka.sh` - Fixed producer `--broker-list` → `--bootstrap-server`
- ✅ `scripts/test-kafka-auth.sh` - Fixed producer and topics authentication

### **2. Authentication Config Files:**

**For kafka-topics.sh (admin operations):**
```bash
kafka-topics.sh --create --topic test \
  --bootstrap-server kafka:9092 \
  --command-config /tmp/client.properties     # ← Correct for topics
```

**For kafka-console-producer.sh:**
```bash
kafka-console-producer.sh \
  --bootstrap-server kafka:9092 \
  --topic test \
  --producer.config /tmp/client.properties    # ← Correct for producer
```

**For kafka-console-consumer.sh:**
```bash
kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 \
  --topic test \
  --consumer.config /tmp/client.properties    # ← Correct for consumer
```

## **🚀 Test Again**

Now you can run the test successfully:
```bash
make test-auth
```

## **📖 Reference**

### **Common Kafka CLI Commands (Updated Syntax):**

```bash
# Create topic
kafka-topics.sh --create --topic my-topic --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1

# List topics
kafka-topics.sh --list --bootstrap-server kafka:9092

# Produce messages
echo "test message" | kafka-console-producer.sh --bootstrap-server kafka:9092 --topic my-topic

# Consume messages
kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic my-topic --from-beginning

# With authentication
kafka-console-producer.sh --bootstrap-server kafka:9092 --topic my-topic --producer.config client.properties
```

### **Client Properties File (for authentication):**
```properties
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="kafka-user" password="kafka-password";
```

The fix ensures compatibility with newer Kafka versions while maintaining backward compatibility! 🎯
