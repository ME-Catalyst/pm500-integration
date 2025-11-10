# Integration Tests

This folder hosts end-to-end simulations that exercise Node-RED flows, historian stacks, and cloud bridges together.

## Automated Checks

An initial pytest guard validates the InfluxDB Docker Compose stack under `src/infrastructure/influxdb/`.
It ensures the expected image, restart policy, environment variables, and persistent volumes remain in place.

Run the check with:

```bash
pytest tests/integration
```
