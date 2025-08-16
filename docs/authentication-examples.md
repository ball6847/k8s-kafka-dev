# Bitnami Kafka Helm Chart - Authentication Examples
# Different approaches to managing Kafka users

## Example 1: Minimal with NO Authentication (Development Only)
# This completely disables authentication - use only for testing

listeners:
  client:
    containerPort: 9092
    protocol: PLAINTEXT       # No authentication
    name: CLIENT
  controller:
    name: CONTROLLER
    containerPort: 9093
    protocol: PLAINTEXT       # No authentication
  interbroker:
    containerPort: 9094
    protocol: PLAINTEXT       # No authentication
    name: INTERNAL

sasl:
  client:
    users: []                 # No users
    passwords: []             # No passwords

---

## Example 2: Simple SASL with Inline Users (Development)
# Basic authentication with users defined in values file

listeners:
  client:
    containerPort: 9092
    protocol: SASL_PLAINTEXT  # SASL authentication
    name: CLIENT
  controller:
    name: CONTROLLER
    containerPort: 9093
    protocol: PLAINTEXT       # Controller can stay plain
  interbroker:
    containerPort: 9094
    protocol: PLAINTEXT       # Inter-broker can stay plain
    name: INTERNAL

sasl:
  client:
    users:
      - "kafka-user"          # Application user
      - "admin-user"          # Admin user
      - "dev-user"            # Developer user
    passwords:
      - "kafka-password"
      - "admin-password"
      - "dev-password"
  mechanisms:
    - PLAIN                   # Simple mechanism
  enabledMechanisms: PLAIN

---

## Example 3: Secure SASL with SCRAM (Recommended)
# More secure authentication using SCRAM-SHA-256

listeners:
  client:
    containerPort: 9092
    protocol: SASL_PLAINTEXT  # SASL authentication
    name: CLIENT
  controller:
    name: CONTROLLER
    containerPort: 9093
    protocol: SASL_PLAINTEXT  # Controller also with SASL
  interbroker:
    containerPort: 9094
    protocol: SASL_PLAINTEXT  # Inter-broker with SASL
    name: INTERNAL

sasl:
  client:
    users:
      - "app-producer"        # Producer application
      - "app-consumer"        # Consumer application
      - "kafka-admin"         # Admin user
    passwords:
      - "producer-secret-123"
      - "consumer-secret-456"
      - "admin-secret-789"
  interBroker:
    user: "kafka-admin"       # User for inter-broker communication
    password: "admin-secret-789"
  controller:
    user: "kafka-admin"       # User for controller communication
    password: "admin-secret-789"
  mechanisms:
    - SCRAM-SHA-256           # Secure mechanism
  enabledMechanisms: SCRAM-SHA-256

---

## Example 4: External Secret (Production Recommended)
# Uses Kubernetes secrets to store credentials securely

# First create the secret:
# kubectl create secret generic kafka-user-passwords \
#   --from-literal=client-passwords="app-user:app-pass,admin-user:admin-pass" \
#   --from-literal=inter-broker-password="broker-secret" \
#   --from-literal=controller-password="controller-secret"

listeners:
  client:
    containerPort: 9092
    protocol: SASL_PLAINTEXT
    name: CLIENT
  controller:
    name: CONTROLLER
    containerPort: 9093
    protocol: SASL_PLAINTEXT
  interbroker:
    containerPort: 9094
    protocol: SASL_PLAINTEXT
    name: INTERNAL

sasl:
  client:
    users:
      - "app-user"
      - "admin-user"
    existingSecret: "kafka-user-passwords"  # Reference to external secret
  interBroker:
    user: "admin-user"
    existingSecret: "kafka-user-passwords"
  controller:
    user: "admin-user"
    existingSecret: "kafka-user-passwords"
  mechanisms:
    - SCRAM-SHA-256
  enabledMechanisms: SCRAM-SHA-256

---

## Example 5: Mixed Security (Client SASL, Internal Plain)
# Secure client connections but plain internal communication

listeners:
  client:
    containerPort: 9092
    protocol: SASL_PLAINTEXT  # Clients must authenticate
    name: CLIENT
  controller:
    name: CONTROLLER
    containerPort: 9093
    protocol: PLAINTEXT       # Internal - no auth needed
  interbroker:
    containerPort: 9094
    protocol: PLAINTEXT       # Internal - no auth needed
    name: INTERNAL

sasl:
  client:
    users:
      - "external-app"
      - "monitoring-tool"
    passwords:
      - "external-app-secret"
      - "monitoring-secret"
  mechanisms:
    - SCRAM-SHA-256
  enabledMechanisms: SCRAM-SHA-256

# Note: Only client listener requires authentication
# Inter-broker and controller communication remains unencrypted (faster)
