# Developer Reference

This guide summarizes the primary integration points for extending or consuming the PowerMonitor 500 edge stack. Use it alongside the examples in [`docs/developer/`](docs/developer/) when building new automation or validating changes.

## Node-RED Flow Contracts

### MQTT Sparkplug B Publisher
- **Flow file:** `src/node-red/flows/assembly-to-mqtt.json`
- **Trigger:** Periodic CIP polling (default 1s) from the EtherNet/IP input assembly.
- **Payload schema:**
  ```json
  {
    "metrics": [
      {"name": "voltageAN", "alias": "PM500/voltage/AN", "value": 480.2, "properties": {"unit": "V"}},
      {"name": "currentA", "value": 12.1, "properties": {"unit": "A"}},
      {"name": "realPower", "value": 4.2, "properties": {"unit": "kW"}}
    ],
    "timestamp": 1713897600000,
    "seq": 1024,
    "uuid": "<asset-uuid>"
  }
  ```
- **Extension guidance:** Add or remove metrics by editing the `function` node labeled *Format Sparkplug Payload*.
- **Authentication:** MQTT broker credentials defined in `src/node-red/.env` under `BROKER_USERNAME` and `BROKER_PASSWORD`.
- **Specification reference:** [`docs/developer/internal_apis.md`](docs/developer/internal_apis.md)

### InfluxDB Line Protocol Writer
- **Flow file:** `src/node-red/flows/assembly-to-influx.json`
- **Node:** *Format Influx Body*
- **Output:** Writes measurement `powermonitor_500` with tags `site`, `asset`, `phase`, `breaker`, and numeric fields for energy metrics (kWh, kW, kVAR, kVA, voltage, current, power factor).
- **Extension guidance:** Modify the measurement or tag sets within the function node; ensure new fields exist in Grafana dashboards before deploying to production.
- **Authentication:** Uses InfluxDB token stored in `src/node-red/.env` as `INFLUXDB_TOKEN`.

## Infrastructure-as-Code Interfaces

### InfluxDB Stack (Docker Compose)
- **File:** `src/infrastructure/influxdb/docker-compose.yml`
- **Services:** `influxdb`, `telegraf` (optional), and persistent volume definitions.
- **Customization hooks:**
  - Extend environment variables in `src/infrastructure/influxdb/.env` for backup targets or custom bucket names.
  - Add additional services (Grafana, Kapacitor) by extending the compose file and referencing shared networks.

### AWS IoT Provisioning (Terraform)
- **Directory:** `src/cloud/aws-iot/terraform`
- **Primary modules:**
  - `iot_core`: Creates IoT thing type, thing group, and provisioning templates.
  - `data_routes`: Defines IoT rules, Kinesis streams, and IAM roles.
- **Inputs:** Configured via `terraform.tfvars` (region, environment name, certificate bucket, downstream stream names).
- **Outputs:** Device certificate ARNs, IoT endpoint, rule ARNs, and IAM role names for referencing in downstream automation.
- **Extensibility:**
  - Add modules for DynamoDB or Lambda integration following the same naming conventions.
  - Use workspaces (`terraform workspace select`) to isolate staging and production parameters.

## Cloud Data Access APIs

### MQTT Consumer Pattern
- Subscribe to `spBv1.0/pm500/#` to receive all assets.
- Parse payloads using the Sparkplug B schema; the `metrics` array includes each measurement with metadata.
- Use the `uuid` and topic segments to associate metrics with site/asset identifiers.
- Recommended client libraries: Eclipse Paho (Python/Java), AWS IoT Device SDK (Node.js/Python), or gmqtt (async Python).

### AWS IoT Rule Outputs
- **Kinesis Data Streams:** Records contain the JSON payload from the Node-RED transformation stage. Consumer apps can use AWS Kinesis SDKs or Managed Service for Apache Flink.
- **S3 Archive:** Optional delivery collects gzip-compressed JSON objects partitioned by `site/year/month/day`.
- **EventBridge:** Extend Terraform to route events into EventBridge bus for integration with ticketing or automation workflows.

## Examples and Diagnostics
- Sample configuration comparisons: [`docs/developer/examples/sample_configs/listener_comparison.md`](docs/developer/examples/sample_configs/listener_comparison.md)
- Demo scripts (e.g., Influx queries): [`docs/developer/examples/demo_scripts/`](docs/developer/examples/demo_scripts/)
- Style and contribution guidelines: [`docs/developer/conventions.md`](docs/developer/conventions.md)

## Contribution Expectations
- Update this reference whenever new flow nodes, Terraform modules, or cloud delivery targets are introduced.
- Include example payloads or CLI snippets to accelerate downstream integration.
- Keep authentication and secret handling guidance high-level; never commit real credentials.
