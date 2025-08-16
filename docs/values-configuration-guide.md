| PDB | No | No | Yes |
| Resource Requests | 250m CPU, 1Gi RAM | 500m CPU, 2Gi RAM | 1 CPU, 4Gi RAM |
| Heap Size | 1GB | 2GB | 4GB |

## Important Configuration Sections Explained

### KRaft Mode vs ZooKeeper

All configurations use **KRaft mode** (Kafka Raft) instead of ZooKeeper:
```yaml
zookeeper:
  enabled: false

kraft:
  enabled: true
```

**Benefits of KRaft**:
- Simpler architecture (no ZooKeeper dependency)
- Faster startup times
- Reduced operational complexity
- Better scalability

### Listeners Configuration

Each setup defines multiple listeners for different types of connections:
```yaml
listeners:
  client:      # For client applications
    containerPort: 9092
    protocol: PLAINTEXT
  controller:  # For KRaft controller communication
    containerPort: 9093
    protocol: PLAINTEXT
  interbroker: # For broker-to-broker communication
    containerPort: 9094
    protocol: PLAINTEXT
  external:    # For external access
    containerPort: 9095
    protocol: PLAINTEXT
```

### Persistence Configuration

For persistent setups, storage is configured as:
```yaml
persistence:
  enabled: true
  size: 10Gi                    # Adjust based on needs
  storageClass: ""              # Uses default storage class
  accessModes:
    - ReadWriteOnce
```

### Resource Management

Production-like setup includes proper resource management:
```yaml
resources:
  requests:
    cpu: 1
    memory: 4Gi
  limits:
    cpu: 2
    memory: 8Gi

heapOpts: "-Xmx4096m -Xms4096m"  # JVM heap settings
```

### High Availability Features (Production-like)

```yaml
# Multiple brokers
replicaCount: 3

# Anti-affinity to spread brokers across nodes
podAntiAffinity:
  type: hard
  topologyKey: kubernetes.io/hostname

# Pod Disruption Budget
pdb:
  create: true
  minAvailable: 2

# Replication settings
config: |
  default.replication.factor=3
  min.insync.replicas=2
  offsets.topic.replication.factor=3
```

## Customization Guidelines

### Adjusting Resource Requirements

To modify CPU and memory:
```yaml
kafka:
  resources:
    requests:
      cpu: "500m"      # 0.5 CPU cores
      memory: "2Gi"    # 2 GB RAM
    limits:
      cpu: "2"         # 2 CPU cores
      memory: "4Gi"    # 4 GB RAM
  
  heapOpts: "-Xmx2048m -Xms2048m"  # Should be ~50% of memory limit
```

### Storage Configuration

For different storage classes or sizes:
```yaml
persistence:
  enabled: true
  size: 50Gi                    # Increase for more data
  storageClass: "fast-ssd"      # Use specific storage class
  accessModes:
    - ReadWriteOnce
```

### External Access Options

**NodePort** (for local/on-premise):
```yaml
externalAccess:
  enabled: true
  service:
    type: NodePort
    ports:
      external: 9094
```

**LoadBalancer** (for cloud environments):
```yaml
externalAccess:
  enabled: true
  service:
    type: LoadBalancer
    ports:
      external: 9094
```

### Security Enhancements

For production environments, consider adding:
```yaml
# TLS encryption
listeners:
  client:
    protocol: SSL
    
# SASL authentication
config: |
  sasl.enabled.mechanisms=PLAIN
  sasl.mechanism.inter.broker.protocol=PLAIN
```

## Performance Tuning

### Kafka Configuration Tuning

Key performance settings to adjust in the `config` section:
```yaml
config: |
  # Network threads
  num.network.threads=8
  num.io.threads=16
  
  # Socket buffer sizes
  socket.send.buffer.bytes=102400
  socket.receive.buffer.bytes=102400
  
  # Log settings
  log.segment.bytes=1073741824      # 1GB segments
  log.retention.hours=168           # 7 days retention
  
  # Compression
  compression.type=lz4              # Fast compression
  
  # Batch settings
  batch.size=16384
  linger.ms=5
```

### JVM Tuning

```yaml
heapOpts: "-Xmx4g -Xms4g -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35"
```

## Monitoring and Observability

### Enabling Metrics

```yaml
metrics:
  kafka:
    enabled: true
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
  jmx:
    enabled: true

serviceMonitor:
  enabled: true    # Requires Prometheus Operator
  interval: 30s
```

### Log Configuration

For better debugging:
```yaml
config: |
  log4j.rootLogger=INFO, stdout
  log4j.appender.stdout.layout.ConversionPattern=[%d] %p %m (%c)%n
```

## Troubleshooting Common Issues

### Pod Startup Issues

1. **Resource constraints**: Increase CPU/memory requests
2. **Storage issues**: Check PVC creation and storage class availability
3. **Network policies**: Ensure pods can communicate

### Performance Issues

1. **Under-provisioned resources**: Monitor CPU/memory usage
2. **Disk I/O bottlenecks**: Use faster storage classes
3. **Network bottlenecks**: Tune socket buffer sizes

### Data Loss Prevention

1. **Enable persistence**: Always use persistent volumes for important data
2. **Set proper replication**: Use replication factor ≥ 3 for production
3. **Configure retention**: Set appropriate log retention policies

## Next Steps

1. **Start with minimal setup** for learning and development
2. **Move to persistent setup** when you need data retention
3. **Use production-like setup** for staging and performance testing
4. **Customize based on your specific requirements**

## Additional Resources

- [Bitnami Kafka Helm Chart Documentation](https://github.com/bitnami/charts/tree/main/bitnami/kafka)
- [Apache Kafka Configuration Reference](https://kafka.apache.org/documentation/#configuration)
- [Kubernetes Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Helm Values Files](https://helm.sh/docs/chart_template_guide/values_files/)
