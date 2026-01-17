# Mariner Documentation

Technical documentation for the Mariner development environment and architecture.

## Getting Started

- [Quick Start Guide](setup/quickstart.md) - Fastest path to a running development environment
- Setup scripts:
  - WSL2/Linux: `./scripts/host/setup-k8s-linux.sh`
  - macOS: `./scripts/host/setup-k8s-macos.sh`

## Development

- [Kubernetes Development](development/kubernetes.md) - Working with the K8s development environment
  - Services overview
  - Development workflow
  - Hot reload configuration
  - Debugging
  - Troubleshooting

## Architecture

- [Networking Architecture](architecture/networking.md) - DevContainer + k3d networking design
  - Architecture overview and topology
  - Design justification and alternatives evaluated
  - Implementation details
  - Troubleshooting

## Additional Resources

- [Project README](../README.md) - Repository overview
- [Product & UX Narrative](../ANCHOR.md) - System narrative
- [Work Planning](../WORK.md) - Project backlog
- [Development Directives](../DIRECTIVES.md) - Long-lived working rules
