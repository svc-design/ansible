# Modern Container Application Reference Architectures

## Modern App Architectures

We define modern app architectures as those driven by four characteristics: scalability, portability, resiliency, and agility. While many different aspects of a modern architecture exist, these are fundamental.

- Scalability – Quickly and seamlessly scale up or down to accommodate spikes or reductions in demand, anywhere in the world.
- Portability – Easy to deploy on multiple types of devices and infrastructures, on public clouds, and on premises.
- Resiliency – Can fail over to newly spun‑up clusters or virtual environments in different availability regions, clouds, or data centers.
- Agility – Ability to update through automated CI/CD pipelines with higher code velocity and more frequent code pushes.

## Modern Container Application Reference Architectures

This repository provides a reference architecture for modern container applications. It focuses on the following key principles:

* Platform Agnosticism: The architecture is designed to be platform-agnostic, allowing you to deploy your application on different container orchestration platforms such as Kubernetes (k8s) or lightweight alternatives like k3s.
* Prioritization of OSS: Open-source software (OSS) is prioritized, ensuring that the architecture is built on robust and widely adopted tools and technologies.
* Everything Defined by Code: Infrastructure as Code (IaC) is used to define and provision all the necessary resources for your application. This ensures consistency, reproducibility, and scalability.
* CI/CD Automation: Continuous Integration and Continuous Deployment (CI/CD) pipelines are implemented using GitHub CI, enabling automated build, test, and deployment processes.
* Security-minded Development: Security is a top priority in the architecture, with best practices implemented at every stage, including containerized builds, secure container registries like Harbor, and secure communication between services.
* Distributed Storage: The architecture incorporates distributed storage solutions to ensure high availability and scalability for your application's data.

## Tools Chain

The following tools are used in this reference architecture:

- Pipeline: GitHub CI
- IaC Tool: Pulumi
- Code Repository: GitHub
- Container Registry: Harbor
- Monitoring:
  - Logs: Loki
  - Tracing: Deepflow
  - Metrics: Prometheus
  - Notification: Alertmanager
  - Datastore: Clickhouse
  - Visualization: Grafana
- Cluster Management:
  - Kubernetes (k8s)
  - Lightweight Kubernetes (k3s)
- Ingress: Nginx
- DNS

# Getting Started

To get started with this reference architecture, follow these steps:

1. Clone this repository to your local machine.
2. Set up the required tools mentioned above, ensuring they are properly configured.
3. Modify the code and configuration files as per your application's requirements.
4. Use Pulumi to provision the necessary infrastructure resources defined in the IaC files.
5. Configure the CI/CD pipeline in GitHub CI to trigger builds and deployments automatically.
6. Monitor your application using the provided monitoring stack.
7. Deploy your application to the target cluster using k8s or k3s.
8. Set up Nginx Ingress and DNS for routing traffic to your application.

For more detailed instructions and examples, please refer to the documentation provided in this repository.

# Contributing

We welcome contributions from the community to enhance this reference architecture. If you have any suggestions, improvements, or bug fixes, please feel free to submit a pull request.

# License

This reference architecture is released under the GPL V3 License.
