# Program Roadmap

The roadmap establishes the incremental milestones required to transform the PowerMonitor 500 integration concept into a production-ready telemetry solution. Milestones are grouped into phases to help stakeholders understand what is complete, in progres
s, or scheduled for later delivery.

## Milestone Summary

| Milestone | Target Window | Owner | Status | Exit Criteria |
| --- | --- | --- | --- | --- |
| M1 – Instrument baseline documentation | Q2 FY24 | Documentation lead | ✅ Complete | Device interface guides, polling guidance, and Sparkplug B profile published and peer-reviewed. |
| M2 – Edge acquisition prototypes | Q2 FY24 | Edge engineering | ✅ Complete | Listen-only Node-RED flows exporting to MQTT and InfluxDB validated against lab hardware. |
| M3 – Historian & visualization enablement | Q3 FY24 | Data platform | 🟡 In progress | InfluxDB stack hardened with retention policy, Grafana dashboards templated, alert thresholds defined. |
| M4 – Enterprise integration | Q3 FY24 | Cloud integration | 🟡 In progress | AWS IoT Core provisioning automated, data contracts formalized, CI/CD pipeline scaffolding merged. |
| M5 – Operational readiness | Q4 FY24 | Site operations | 🔜 Planned | Runbooks approved, support rotations defined, rollback and disaster recovery tests complete. |
| M6 – Production rollout | Q1 FY25 | Program management | 🔜 Planned | Pilot site acceptance signed off, security review closed, and release notes distributed to stakeholders. |

## Phase Narrative

### Foundation (M1-M2)
- Solidify all device-facing documentation and validate reference implementations.
- Build confidence with lab-grade prototypes for data acquisition and export flows.

### Platform Hardening (M3-M4)
- Move from prototypes to managed services with observability, alerting, and automated configuration.
- Integrate with enterprise security, identity, and data distribution patterns via AWS IoT Core.

### Operationalization (M5-M6)
- Prepare the support organization with playbooks, monitoring baselines, and rollback procedures.
- Execute pilot, obtain approvals, and release the production build backed by signed change records.

## Dependencies
- **Hardware availability:** Pilot hardware must remain reserved through M5 for regression testing.
- **Security review:** Corporate security must complete the threat model before production release.
- **Licensing:** Ensure Node-RED runtime licensing and any CODESYS runtime costs are budgeted.

## Decision Log
- Continue leveraging Sparkplug B as the MQTT profile of record to simplify downstream subscriber handling.
- Standardize on InfluxDB OSS v2 for historian proof-of-concept to reuse existing Grafana expertise.
- Adopt Terraform for long-term cloud resource lifecycle management.

## Review Cadence
- The roadmap is reviewed during the bi-weekly program sync.
- Updates are applied within two business days of milestone adjustments and reflected in release notes.

