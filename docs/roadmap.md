# PM500 Integration Roadmap

## Overview
This roadmap tracks the lab-to-production journey for the PowerMonitor 500 integration concept. Each phase lists the scope, current completion status, tangible deliverables present in this repository, and the immediate follow-up actions required to advance to the next milestone.

Status legend: ✅ Complete · 🟡 In progress · 🔜 Planned

## Phase 1 – Foundation Documentation (Status: ✅ Complete)
- **Scope:** Capture device capabilities, safe polling limits, and architectural building blocks so stakeholders share a common baseline.
- **Delivered Assets:**
  - [`docs/device-interface.md`](device-interface.md) for assemblies, heartbeat behavior, and configuration restrictions.
  - [`docs/polling-guidelines.md`](polling-guidelines.md) and [`docs/operations/playbooks.md`](operations/playbooks.md) covering connection hygiene and runbook procedures.
  - [`docs/sparkplug-b.md`](sparkplug-b.md) describing the expected MQTT/Sparkplug namespace and templates.
- **Next Actions:** Keep the guides synchronized with hardware validation notes as field trials uncover additional constraints.

## Phase 2 – Edge Data Acquisition Prototypes (Status: ✅ Complete)
- **Scope:** Demonstrate listen-only telemetry extraction from the PM500 and publish to multiple downstream targets without disrupting PLC ownership.
- **Delivered Assets:**
  - Node-RED reference flows in [`src/node-red/flows/`](../src/node-red/flows/) for InfluxDB and MQTT export paths.
  - Telemetry pipeline patterns in [`docs/telemetry-pipeline.md`](telemetry-pipeline.md) referencing Node-RED, Telegraf, and CODESYS options.
- **Next Actions:** Validate flows against hardware, confirm polling intervals meet production limits, and capture performance metrics for sustained load.

## Phase 3 – Data Persistence & Visualization Enablement (Status: 🟡 In Progress)
- **Scope:** Provide a repeatable data services stack and document how to land, query, and visualize telemetry.
- **Delivered Assets:**
  - InfluxDB OSS v2 Docker Compose stack under [`src/infrastructure/influxdb/`](../src/infrastructure/influxdb/) with bootstrap instructions.
  - Telemetry normalization examples that produce Influx line protocol in [`docs/telemetry-pipeline.md`](telemetry-pipeline.md).
- **Outstanding Work:**
  - Add Grafana or Chronograf dashboards illustrating core KPIs.
  - Define alerting thresholds and retention policies aligned with operations requirements.
  - Publish sample Telegraf configuration files tailored to the PM500 metrics catalog.

## Phase 4 – Cloud & Enterprise Integration (Status: 🟡 In Progress)
- **Scope:** Bridge edge telemetry into enterprise analytics platforms with secure provisioning and deployment automation.
- **Delivered Assets:**
  - AWS IoT Core infrastructure snippets and TLS client guidance in [`src/cloud/aws-iot/`](../src/cloud/aws-iot/).
  - Sparkplug B messaging guide for MQTT brokers in [`docs/sparkplug-b.md`](sparkplug-b.md).
- **Outstanding Work:**
  - Define cloud-side data models (e.g., AWS IoT Rules, Kinesis/Firehose mappings) and CI/CD pipelines for infrastructure code.
  - Document certificate rotation runbooks integrated with enterprise PKI or Secrets Manager.
  - Prototype data forwarding from the edge stack to cloud endpoints using staged credentials.

## Phase 5 – Production Hardening & Operations (Status: 🔜 Planned)
- **Scope:** Institutionalize change management, monitoring, and support processes prior to broad deployment.
- **Planned Deliverables:**
  - Operational readiness checklist covering failover, backup, and security controls.
  - Incident response workflows with on-call roles and escalation paths.
  - KPI dashboards and reporting cadence to share with leadership.
- **Prerequisites:** Completion of pilot testing with documented lessons learned from Phases 2–4.

## Reporting Cadence
- Roadmap updates accompany every significant repository change that affects phase scope or status.
- Each phase owner logs progress notes directly in the associated documentation to keep cross-functional teams aligned.
