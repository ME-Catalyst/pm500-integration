# PowerMonitor 500 IIoT Integration Concept

## Concept Summary
This repository explores an industrial IoT integration pattern for the Allen-Bradley PowerMonitor 500 energy meter. The integration concept envisions collecting power and energy data from the device over industrial communication protocols, translating it into IT-friendly payloads, and orchestrating analytics and visualization flows using modern automation tools.

## Current Repository State
- **Edge application samples:** Reference Node-RED flows for listen-only EtherNet/IP polling with hand-offs to InfluxDB and MQTT live under [`node-red/flows/`](node-red/flows/).
- **Data services foundation:** [`infra/influxdb/`](infra/influxdb/) contains a Docker Compose stack for InfluxDB OSS v2 plus bootstrap guidance.
- **Cloud integration starter kit:** [`cloud/aws-iot/`](cloud/aws-iot/) provides Terraform, CloudFormation, and CLI snippets for provisioning AWS IoT Core, along with TLS client checklists.
- **Operations and architecture documentation:** The `docs/` tree captures device interface details, telemetry pipeline design, polling guidelines, and Sparkplug B conventions for downstream consumers.
- **Implementation status:** No production firmware or PLC project files are stored in this repository—artifacts focus on lab validation, planning, and infrastructure templates.

## Roadmap Snapshot
The program roadmap is tracked in [`docs/roadmap.md`](docs/roadmap.md). Highlights as of this update:

| Phase | Status | Evidence |
| --- | --- | --- |
| Foundational documentation and patterns | ✅ Complete | Core reference guides covering device interfaces, polling limits, and telemetry topology are published under `docs/`. |
| Edge data acquisition prototypes | ✅ Complete | Node-RED sample flows demonstrate listen-only polling and export patterns. |
| Data persistence and visualization enablement | 🟡 In progress | InfluxDB stack is provisioned; Grafana wiring and alert definitions remain open work. |
| Cloud and enterprise integration | 🟡 In progress | AWS IoT provisioning assets are ready; data modeling and CI/CD automation still pending. |
| Production hardening and runbooks | 🔜 Planned | Operational readiness reviews and change-management workflows still need to be authored after pilot validation. |

## High-Level Objectives
- Validate communication paths for the PowerMonitor 500 across EtherNet/IP listen-only sessions and Modbus TCP diagnostics.
- Prototype data acquisition, transformation, and visualization pipelines using Node-RED, Telegraf, and InfluxDB, with optional Sparkplug B emission for MQTT consumers.
- Evaluate PLC-side orchestration options, such as CODESYS, for coordinating control logic and data exchange without disrupting existing programs.
- Document deployment considerations, connectivity prerequisites, and security assumptions for future implementation across both OT and IT environments.
- Prepare cloud readiness assets (AWS IoT Core provisioning, certificate handling) to streamline enterprise integration once edge telemetry is proven.

## Documentation Map
- [`docs/roadmap.md`](docs/roadmap.md) – Program phases, status indicators, and immediate next steps.
- [`docs/device-interface.md`](docs/device-interface.md) – PowerMonitor 500 assemblies, heartbeat behavior, and configuration constraints.
- [`docs/polling-guidelines.md`](docs/polling-guidelines.md) – Recommended connection strategies to avoid exhausting PLC CIP resources.
- [`docs/telemetry-pipeline.md`](docs/telemetry-pipeline.md) – Edge-to-historian data flow patterns for Node-RED, CODESYS, Telegraf, and InfluxDB.
- [`docs/sparkplug-b.md`](docs/sparkplug-b.md) – Sparkplug B topic, template, and encoding expectations for MQTT consumers.
- [`docs/operations/playbooks.md`](docs/operations/playbooks.md) – Runbooks for subscription validation, heartbeat monitoring, and troubleshooting.

## Reference Resources
- PowerMonitor 500 product information: [Rockwell Automation PowerMonitor 500](https://www.rockwellautomation.com/en-us/products/details.powermonitor-500.html)
- EtherNet/IP protocol overview: [ODVA EtherNet/IP](https://www.odva.org/technology-standards/ethernet-ip/)
- Modbus TCP protocol specification: [Modbus Organization Resources](https://modbus.org/specs.php)
- Node-RED automation platform: [Node-RED](https://nodered.org/)
- CODESYS engineering platform: [CODESYS](https://www.codesys.com/)

## Status Note
The integration concept remains exploratory and will evolve as hardware validation, stakeholder feedback, and security reviews identify additional requirements. Documentation updates accompany each roadmap checkpoint to keep the repository aligned with the latest lab findings.

## Documentation Language
- All repository content follows **U.S. English** spelling conventions (for example, "color" rather than "colour") to keep terminology consistent across engineering and operations teams.

## License
- This project is distributed under the [MIT License](LICENSE.md).

## Recent Updates
- [`docs/roadmap.md`](docs/roadmap.md) consolidates the phase breakdown, status indicators, and immediate next actions.
- [`node-red/flows/`](node-red/flows/) now includes paired MQTT and InfluxDB export examples with listen-only polling defaults.
- [`infra/influxdb/`](infra/influxdb/) documents the Docker Compose stack and credential bootstrap steps for InfluxDB OSS v2.
