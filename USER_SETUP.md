# User Setup Guide

This guide walks site engineers and analysts through preparing a lab environment for the PowerMonitor 500 integration concept. 
Follow the steps sequentially to ensure a functional data path from the meter to analytics and cloud endpoints.

## 1. Prerequisites
- PowerMonitor 500 device with EtherNet/IP firmware enabled and reachable from the test network.
- Edge host (industrial PC or VM) running a Linux distribution with Docker Engine 24+ installed.
- Internet access for pulling Docker images and installing package dependencies.
- Corporate-approved credentials for accessing AWS resources if cloud integration is desired.

## 2. Clone the Repository
```bash
mkdir -p ~/workspace && cd ~/workspace
git clone https://github.com/<org>/pm500-integration.git
cd pm500-integration
```

## 3. Configure Environment Variables
Create `.env` files for the Docker compose stacks:
- `infra/influxdb/.env` – set `DOCKER_INFLUXDB_INIT_USERNAME`, `DOCKER_INFLUXDB_INIT_PASSWORD`, and `DOCKER_INFLUXDB_INIT_ORG`.
- `node-red/.env` – define `BROKER_URL`, `INFLUXDB_URL`, and secret tokens for downstream systems.
- (Optional) `cloud/aws-iot/terraform.tfvars` – populate AWS region, IoT thing group, and certificate S3 bucket.

## 4. Provision Edge Services
```bash
cd infra/influxdb
docker compose up -d
cd ../../node-red
docker compose up -d
```
Confirm services are reachable:
- InfluxDB UI at `https://<edge-host>:8086`
- Node-RED editor at `http://<edge-host>:1880`

## 5. Import Node-RED Flows
1. Open the Node-RED editor.
2. Use the *Import* dialog to load `node-red/flows/listen-only-mqtt-influx.json`.
3. Update flow credentials (InfluxDB token, MQTT username/password) via the credential sidebar.
4. Deploy the flows and verify data appears in debug nodes.

## 6. Validate Telemetry
- Use the PowerMonitor 500 LCD or Rockwell Studio 5000 to confirm CIP connections are in listen-only state.
- Run `docker compose logs -f` for Node-RED to ensure no connection timeouts occur.
- Query InfluxDB with the provided sample script:
  ```bash
  ./docs/scripts/query_influx_example.sh
  ```

## 7. Optional AWS IoT Integration
1. Authenticate to AWS CLI (`aws configure`).
2. Review `cloud/aws-iot/README.md` for prerequisites.
3. Apply Terraform modules:
   ```bash
   cd cloud/aws-iot/terraform
   terraform init
   terraform apply
   ```
4. Upload device certificates per the generated instructions.

## 8. Operational Handoff
- Document IP addresses, credentials, and flow revisions in the site change log.
- Schedule onboarding session with operations to walkthrough Grafana dashboards and alerts.
- File a ticket for inclusion into the enterprise monitoring system.

## 9. Maintenance Tips
- Pull repository updates monthly and redeploy Docker stacks when the release notes indicate changes.
- Backup Node-RED flows (`node-red/flows/*.json`) and InfluxDB volumes before performing upgrades.
- Review `TROUBLESHOOTING.md` for remediation steps if telemetry stops reporting.

