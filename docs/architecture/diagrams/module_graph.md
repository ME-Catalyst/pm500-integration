# Module Graph Overview

The integration concept is organized into the following logical modules:

| Layer | Location | Description |
| --- | --- | --- |
| Field | PowerMonitor 500, plant PLCs | Produces electrical metrics and exposes EtherNet/IP assemblies consumed by the edge stack. |
| Edge Applications | `src/node-red/flows/`, `src/codesys/` | Polls assemblies, normalizes data, and publishes Sparkplug B or InfluxDB line protocol. |
| Data Services | `src/infrastructure/influxdb/` | Provides historian storage, Telegraf processing, and optional visualization endpoints. |
| Cloud Integration | `src/cloud/aws-iot/` | Provisions MQTT ingestion, routing rules, and archival destinations for enterprise consumers. |
| Tooling and Tests | `tests/`, `docs/developer/examples/` | Validates flows, enforces schema conformance, and offers reusable scripts for diagnostics. |

Use this table with the system overview diagram (`system_overview.svg`) to quickly identify the files that implement each capability.
