# Troubleshooting Guide

Use this guide to diagnose and resolve common issues encountered while running the PowerMonitor 500 integration concept. Issues 
are grouped by system layer for faster triage.

## 1. Device and Network

| Symptom | Probable Cause | Resolution |
| --- | --- | --- |
| EtherNet/IP connection faults | Scanner attempting exclusive ownership | Reconfigure Node-RED flow to use listen-only assemblies; confirm no competing PLCs hold the connection. |
| No response from device | Incorrect IP or network VLAN mismatch | Verify meter IP via front panel, confirm VLAN routing, and test connectivity with `ping` and `cipster` tools. |
| Erratic power readings | CT/PT ratio misconfiguration | Reapply correct scaling in the PowerMonitor configuration utility and redeploy. |

## 2. Node-RED Flows

| Symptom | Probable Cause | Resolution |
| --- | --- | --- |
| Red status indicator on EtherNet/IP nodes | CIP session timed out or authentication mismatch | Ensure assemblies exist, verify slot addressing, and restart the Node-RED container to reset sessions. |
| MQTT publish failures | Broker unreachable or TLS handshake failure | Check broker URL in `node-red/.env`, confirm certificates, and test connectivity with `mosquitto_pub`. |
| InfluxDB write errors | Token revoked or bucket missing | Generate a new token in InfluxDB UI and update Node-RED credentials; confirm bucket creation via `influx bucket list`. |

## 3. Historian and Visualization

| Symptom | Probable Cause | Resolution |
| --- | --- | --- |
| Empty Grafana panels | Query uses wrong measurement or tags | Align dashboards with measurement `powermonitor_500` and ensure tag filters match site/asset values. |
| Slow dashboard loads | High query cardinality | Add retention policies, drop unused tags, or aggregate metrics before visualization. |
| InfluxDB high disk usage | Retention policy disabled | Apply retention settings via `influx bucket update --retention 30d`. |

## 4. Cloud Integration

| Symptom | Probable Cause | Resolution |
| --- | --- | --- |
| Devices cannot connect to AWS IoT | Certificates missing or policy too restrictive | Attach IoT policy allowing `iot:Connect` and `iot:Publish`; confirm certificates uploaded to correct thing. |
| Rule delivery failures | IAM role lacks target permission | Review Terraform outputs for IAM role names and attach required service permissions. |
| Kinesis consumers lagging | Insufficient shard capacity | Increase shard count or adopt enhanced fan-out for high throughput scenarios. |

## 5. Operations and Maintenance

| Symptom | Probable Cause | Resolution |
| --- | --- | --- |
| Containers restart repeatedly | Insufficient resources or misconfigured environment variables | Inspect `docker compose logs`, adjust CPU/memory reservations, and confirm `.env` files contain valid values. |
| Release checklist fails documentation step | Roadmap or architecture docs outdated | Update `ROADMAP.md`, `ARCHITECTURE.md`, and related files; rerun release workflow (see `.github/workflows/release-docs.yml`). |
| Alerts missing from notification channels | Webhook credentials expired | Renew webhook tokens and update Grafana notification channels; test with manual alert trigger. |

## Escalation Path
- **Level 1:** Site operations handles hardware and connectivity checks.
- **Level 2:** Edge engineering reviews Node-RED flows and Docker stack health.
- **Level 3:** Cloud integration team investigates AWS IoT, Kinesis, and downstream pipelines.
- **Level 4:** Program architect coordinates cross-team remediation and updates documentation.

## Preventive Actions
- Schedule monthly reviews of `docker compose` service logs and Grafana alert histories.
- Rotate secrets quarterly and verify automation scripts still authenticate successfully.
- Update documentation after every verified fix so the troubleshooting matrix remains accurate.

