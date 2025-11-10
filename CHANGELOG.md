# Change History

All notable changes to this repository will be documented in this file following the [Keep a Changelog](https://keepachangelog.com/) principles and adhering to semantic versioning when version tags are published.

## [Unreleased]
### Added
- `/docs/` reorganized to include architecture, user, developer, troubleshooting, and visuals subdirectories with module and diagnostic references.
- Demo query script under `docs/developer/examples/demo_scripts/` to validate historian connectivity.

### Changed
- Root documentation refreshed (`README.md`, `ARCHITECTURE.md`, `ROADMAP.md`, `USER_MANUAL.md`, `DEVELOPER_REFERENCE.md`, `TROUBLESHOOTING.md`) to align with the new structure and link targets.
- Advanced usage, configuration, and recovery content redistributed across `/docs/user/` and `/docs/troubleshooting/`.

### Fixed
- Broken diagram paths resolved after restructuring documentation assets.

## [0.1.0] - 2024-04-01
### Added
- Initial import of Node-RED listen-only EtherNet/IP flows for PowerMonitor 500.
- InfluxDB Docker Compose stack with bootstrap instructions.
- AWS IoT Core provisioning assets (Terraform modules, CloudFormation snippet).

### Changed
- Documentation map established under `docs/` to guide early adopters.

### Fixed
- Clarified polling guidelines regarding connection ownership limits.
