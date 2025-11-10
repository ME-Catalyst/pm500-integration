# PowerMonitor 500 IIoT Integration Concept

Industrial IoT reference architecture for collecting PowerMonitor 500 telemetry, normalizing it at the edge, and forwarding it to enterprise analytics platforms.

## Quickstart
1. Review the lab prerequisites in [`USER_MANUAL.md`](USER_MANUAL.md).
2. Deploy the edge services by following the installation steps in [`docs/user/install_guide.md`](docs/user/install_guide.md).
3. Import the Node-RED flows under [`src/node-red/flows/`](src/node-red/flows/) and validate historian writes with the demo scripts in [`docs/developer/examples/`](docs/developer/examples/).
4. Consult [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) if telemetry does not appear downstream.

## Documentation Map
- [`ARCHITECTURE.md`](ARCHITECTURE.md) – System structure, data flows, and dependencies.
- [`ROADMAP.md`](ROADMAP.md) – Milestones and upcoming releases.
- [`USER_MANUAL.md`](USER_MANUAL.md) – Installation, setup, and configuration entry points.
- [`DEVELOPER_REFERENCE.md`](DEVELOPER_REFERENCE.md) – Flow contracts, infrastructure APIs, and messaging conventions.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) – Quick links to recovery and diagnostics procedures.
- [`CHANGELOG.md`](CHANGELOG.md) – Versioned history of repository updates.

Supplemental materials live under [`docs/`](docs/) and are organized by architecture, user guidance, developer references, troubleshooting resources, and visuals.

## Visuals
- [System overview diagram](docs/architecture/diagrams/system_overview.svg)
- [Telemetry data flow](docs/visuals/diagrams/telemetry_data_flow.svg)
- [Integration sequence](docs/visuals/diagrams/integration_sequence.svg)

## License
This project is distributed under the [MIT License](LICENSE.md).

> **No Warranty or Liability** – Provided “as-is,” without warranty of any kind.
