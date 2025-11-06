# InfluxDB OSS v2 Deployment

This directory contains a ready-to-run Docker Compose definition for standing up InfluxDB OSS v2 for the PM500 telemetry pipeline. The stack enables quick local prototyping, PoC deployments on an industrial PC, or a small virtual machine on the plant network.

## Prerequisites

- Docker Engine 20.10 or newer
- Docker Compose plugin 2.0 or newer (or `docker-compose` binary)
- Persistent storage available for InfluxDB data and configuration volumes

## Quick start

1. Copy the provided environment file template and adjust credentials:
   ```bash
   cp .env.example .env
   ```
2. Update the values inside `.env` with secure credentials and organization details.
3. Launch the stack:
   ```bash
   docker compose up -d
   ```
4. Verify the health check and confirm the service is reachable at `http://localhost:8086` (or the host's IP if deployed remotely).
5. Log into the UI using the configured username and password, then create any additional buckets, retention policies, and API tokens required by Telegraf or downstream clients.

## Environment variables

`docker-compose.yml` reads the following variables (default values are shown for reference):

| Variable | Description | Default |
| --- | --- | --- |
| `INFLUXDB_USERNAME` | Initial admin username | `admin` |
| `INFLUXDB_PASSWORD` | Initial admin password | `changeme` |
| `INFLUXDB_ORG` | Organization name | `pm500` |
| `INFLUXDB_BUCKET` | Primary telemetry bucket | `telemetry` |
| `INFLUXDB_RETENTION` | Retention duration for the bucket | `30d` |
| `INFLUXDB_TOKEN` | Admin API token | `pm500-token` |

Set these values in `.env` before running `docker compose`. For production, rotate the admin token and create read/write scoped tokens for Telegraf and visualization tools.

## Data directories

The Compose file defines two managed volumes:

- `influxdb-data` – stores database files
- `influxdb-config` – persists configuration (users, orgs, dashboards)

To relocate data to a specific host directory, replace the volume entries in `docker-compose.yml` with bind mounts, for example:

```yaml
    volumes:
      - ./data:/var/lib/influxdb2
      - ./config:/etc/influxdb2
```

Ensure the host directories have the correct permissions (UID/GID 472 by default).

## Upgrading

1. Stop the stack: `docker compose down`
2. Pull the latest image: `docker compose pull`
3. Start the stack again: `docker compose up -d`

InfluxDB automatically performs minor schema migrations on startup. Always back up the data volume before major upgrades.

## Backup and restore

- **Backup:** `docker compose exec influxdb influx backup /var/lib/influxdb2/backups/<timestamp>`
- **Restore:** Copy the backup archive into the container and run `influx restore /path/to/backup`

Regular backups are recommended before applying application changes or firmware updates to upstream devices.

## Telegraf connectivity

Once InfluxDB is up, configure Telegraf with an `influxdb_v2` output plugin pointed at `http://influxdb:8086` (if running on the same Docker network) or the host IP. Use a scoped API token with write permissions to the telemetry bucket.

## Security considerations

- Change default credentials immediately after bootstrap.
- Restrict access to port 8086 via firewall rules or VPN.
- Use HTTPS by placing InfluxDB behind a reverse proxy (e.g., Traefik or Nginx) with TLS termination if remote access is required.
- Regularly rotate tokens and audit access logs.

## Cleanup

To remove the stack and associated volumes:

```bash
docker compose down -v
```

This deletes all stored data—ensure backups are captured before running the command.
