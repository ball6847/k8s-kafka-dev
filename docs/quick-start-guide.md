# Quick Start Guide - Kafka on Kubernetes

This guide will get you up and running with Apache Kafka on Kubernetes in under 5 minutes.

## Prerequisites Checklist

- [ ] Kubernetes cluster running (minikube, kind, Docker Desktop, or cloud cluster)
- [ ] `kubectl` installed and configured
- [ ] `helm` version 3.x installed
- [ ] At least 4GB RAM available in your cluster

## Option 1: Minimal Setup (Fastest)

Perfect for learning, testing, and development where data persistence is not required.

```bash
# 1. Setup Helm repository
./scripts/setup-helm-repo.sh

# 2. Deploy minimal Kafka
./scripts/deploy-kafka-minimal.sh

# 3. Test the deployment
./scripts/test-kafka.sh
```

**Result**: Single Kafka broker, no persistence, ~1GB RAM usage

## Option 2: Persistent Setup (Recommended)

Best for development environments where you want to keep your data between restarts.

```bash
# 1. Setup Helm repository
./scripts/setup-helm-repo.sh

# 2. Deploy persistent Kafka
./scripts/deploy-kafka-persistent.sh

# 3. Test the deployment
./scripts/test-kafka.sh
```

**Result**: Single Kafka broker with persistence, external access, ~2GB RAM usage

## Option 3: Production-like Setup

For staging environments and production readiness testing.

```bash
# 1. Setup Helm repository
./scripts/setup-helm-repo.sh

# 2. Deploy production-like Kafka
./scripts/deploy-kafka-production.sh

# 3. Test the deployment
./scripts/test-kafka.sh
```

**Result**: 3 Kafka brokers, high availability, monitoring, ~6GB RAM usage

## Verification Steps

After deployment, verify everything is working:

### 1. Check Pod Status
```bash
kubectl get pods -n kafka-dev
```

You should see:
```
NAME               READY   STATUS    RESTARTS   AGE
kafka-minimal-0    1/1     Running   0          2m
```

### 2. Check Services
```bash
kubectl get svc -n kafka-dev
```

### 3. Test Kafka Functionality
```bash
# Run the test script
./scripts/test-kafka.sh

# Or manually test with port forwarding
kubectl port-forward -n kafka-dev svc/kafka-minimal 9092:9092 &

# Test with local Kafka tools (if installed)
echo "test message" | kafka-console-producer.sh --broker-list localhost:9092 --topic test
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

## Common Commands

### Port Forwarding for Local Access
```bash
# For minimal/persistent setup
kubectl port-forward -n kafka-dev svc/kafka-minimal 9092:9092

# For production setup
kubectl port-forward -n kafka-prod svc/kafka-production 9092:9092
```

### Viewing Logs
```bash
# For minimal setup
kubectl logs -f -n kafka-dev deployment/kafka-minimal

# For persistent/production setup
kubectl logs -f -n kafka-dev sts/kafka-persistent
```

### Scaling (Production setup only)
```bash
# Scale to 5 brokers
kubectl scale sts kafka-production -n kafka-prod --replicas=5
```

### Resource Monitoring
```bash
# Check resource usage
kubectl top pods -n kafka-dev
kubectl top nodes
```

## Accessing Kafka from Applications

### From Inside Kubernetes Cluster
```yaml
# Service endpoint for applications in the same cluster
bootstrap.servers: kafka-minimal.kafka-dev.svc.cluster.local:9092
```

### From Outside Kubernetes Cluster

**Minimal Setup**: Use port forwarding
```bash
kubectl port-forward -n kafka-dev svc/kafka-minimal 9092:9092
# Then connect to localhost:9092
```

**Persistent Setup**: Use NodePort
```bash
# Get NodePort
kubectl get svc -n kafka-dev kafka-persistent-external
# Connect to <node-ip>:<nodeport>
```

**Production Setup**: Use LoadBalancer
```bash
# Get LoadBalancer IP
kubectl get svc -n kafka-prod kafka-production-external
# Connect to <loadbalancer-ip>:9094
```

## Cleanup

When you're done testing:

```bash
./scripts/cleanup.sh
```

This will:
- Remove Helm deployments
- Optionally remove persistent volumes
- Optionally remove namespaces

## Troubleshooting

### Pod Won't Start
```bash
# Check pod events
kubectl describe pod -n kafka-dev <pod-name>

# Check resource availability
kubectl describe nodes
```

### Connection Issues
```bash
# Check service endpoints
kubectl get endpoints -n kafka-dev

# Test internal connectivity
kubectl run test-pod --rm -i --tty --image=busybox -- nslookup kafka-minimal.kafka-dev.svc.cluster.local
```

### Performance Issues
```bash
# Check resource usage
kubectl top pods -n kafka-dev
kubectl top nodes

# View detailed metrics (if monitoring enabled)
kubectl port-forward -n kafka-prod svc/kafka-production-metrics 9308:9308
```

## Next Steps

1. **Explore Kafka Topics**: Create topics with different configurations
2. **Test Producers/Consumers**: Write simple applications
3. **Monitor Performance**: Set up Prometheus and Grafana
4. **Security**: Configure SSL/SASL authentication
5. **Integration**: Connect with other services (databases, APIs, etc.)

## Need Help?

- Check the [Values Configuration Guide](./docs/values-configuration-guide.md)
- Review Kafka logs: `kubectl logs -f -n kafka-dev <pod-name>`
- Verify cluster resources: `kubectl describe nodes`
- Test network connectivity between pods

## Success Indicators

✅ **You're ready to go when you see**:
- All pods in `Running` state
- Services created and accessible
- Test script completes successfully
- Able to produce and consume messages

🎉 **Congratulations! You now have Kafka running on Kubernetes!**
