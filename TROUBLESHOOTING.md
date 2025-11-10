# Troubleshooting Guide

Use this guide as the entry point for diagnosing issues across device, edge, and cloud layers. Each section links to detailed runbooks stored under `/docs/troubleshooting/`.

## Quick Links
- [`docs/troubleshooting/known_issues.md`](docs/troubleshooting/known_issues.md) – Symptom/cause/resolution matrix covering device, edge, historian, cloud, and operations layers.
- [`docs/troubleshooting/logs_and_diagnostics.md`](docs/troubleshooting/logs_and_diagnostics.md) – Log capture, packet analysis, and evidence collection practices.
- [`docs/troubleshooting/recovery.md`](docs/troubleshooting/recovery.md) – Step-by-step recovery playbooks for listen-only subscriptions, heartbeat monitoring, and coordinated maintenance windows.

## When to Escalate
1. Attempt fixes from the relevant quick-start matrix. If the issue persists or impacts production telemetry, capture logs outlined in the diagnostics guide.
2. Escalate to edge engineering when Node-RED, Telegraf, or Docker services require configuration changes beyond standard credentials.
3. Engage cloud integration specialists when AWS IoT policies, Kinesis throughput, or enterprise messaging pipelines must be adjusted.
4. Notify the program architect once root cause is confirmed so documentation and release notes remain up to date.

## Preventive Maintenance
- Schedule monthly reviews of Docker service health, historian storage consumption, and MQTT broker metrics.
- Rotate credentials quarterly and update associated `.env` files with expiration details.
- Document configuration changes in the change log and link to the related roadmap milestone to preserve institutional knowledge.
