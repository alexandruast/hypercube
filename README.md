# hypercube

## CentOS Microservices Platform Built on Kubernetes

### Success criteria
  - Have a fully configured Kubernetes cluster
  - Code is environment agnostic (same code runs on vagrant and in production)
  - Code is cloud agnostic (runs on premises, AWS, GCE, Azure etc...)
  - Pick a git repository, and the platform does the rest

#### Phase 1 - Basic Kubernetes Cluster
  - Code the initial cluster (RBAC, Helm, Istio)
  - Logging dashboards
  - Monitoring dashboards
  - Alerting
  - Service auto scaling

#### Phase 2 - CI, Applications
  - Sample apps for Java, Go, Python
  - Continuous integration
  - 12-factor app checklist

#### Phase 3 - Security and Availability
  - GitHub OAuth for Jenkins
  - Security and encryption
  - Authority certificates
  - Chaos engineering

#### Phase 4 - Cloud
  - AWS provisioning (terraform/packer)
  - Cluster auto scaling

#### Phase 5 - Marketing
  - Web UI

