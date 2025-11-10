# Logs and Diagnostics

Follow these practices to capture actionable telemetry when investigating faults or preparing change reviews.

## Routine Log Collection
- **Node-RED:** `docker compose logs -f node-red` exposes EtherNet/IP node status, MQTT publish results, and credential errors. Export relevant segments to the ticket system for audit trails.
- **InfluxDB:** Use `docker compose logs -f influxdb` and the `influx task list` CLI command to confirm retention tasks run as expected.
- **Gateway appliances:** Capture CIP statistics and connection inventories through vendor dashboards or `cipster` CLI utilities during every release candidate validation.

## Packet Capture Strategy
- Schedule packet captures during off-peak hours and coordinate with operations so listen-only consumers are known. Save captures under `/docs/troubleshooting/artifacts/` (not version-controlled) for future reference.
- Prefer span ports or TAPs when available; avoid inline captures that could introduce latency.

## Diagnostic Scripts
- Reuse scripts from [`docs/developer/examples/demo_scripts/`](../developer/examples/demo_scripts/) such as `query_influx_example.sh` to validate historian writes.
- Maintain per-environment `.env` files documenting target hosts so scripts can run unattended in CI.

## Evidence Checklist
Before closing a troubleshooting ticket, confirm the following artifacts are attached:
- Time-synchronized log excerpts from Node-RED, InfluxDB, and the cloud integration component under review.
- Screenshots or exports from Grafana or other visualization tools showing the recovered signal.
- Summary of configuration diffs applied during remediation (include commit hashes where relevant).
