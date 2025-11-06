# Node-RED Integration Notes

This directory provides reference Node-RED flows for polling an Allen-Bradley PowerMonitor 500 via EtherNet/IP and forwarding the resulting data to InfluxDB and MQTT. The flows assume the use of [`node-red-contrib-cip`](https://flows.nodered.org/node/node-red-contrib-cip) for communicating with the device, and the core InfluxDB and MQTT nodes supplied with Node-RED.

## Required nodes

Install the following palettes before importing the flows:

| Purpose | Node-RED module | Notes |
| --- | --- | --- |
| EtherNet/IP communication | `node-red-contrib-cip` | Provides the `cip in` and `cip out` nodes used to issue Assembly reads and writes. |
| InfluxDB output | `node-red-contrib-influxdb` (bundled with the InfluxDB node) | Supplies the `influxdb out` node to publish measurements. |
| MQTT publish | `@node-red/nodes` (core MQTT nodes) | Supplies the `mqtt out` node for telemetry. |

After installing the palettes, restart Node-RED to ensure the node types are registered.

## Provided flows

Two example flows are supplied under [`flows/`](./flows/):

1. **`assembly-to-influx.json`** – Polls Assembly Instance 100, Attribute 3 every 250 ms and writes the data to an InfluxDB measurement.
2. **`assembly-to-mqtt.json`** – Polls the same attribute every 500 ms and publishes the result to an MQTT topic.

Import each JSON file into Node-RED via the menu: **Import → Clipboard → Paste flow JSON**.

### Configuration placeholders

Replace the placeholder values in the configuration nodes with your environment-specific settings:

- **CIP Connection** (`cip-config`): Update the controller IP address and slot. Adjust the `instance` if your Assembly instance differs from 100.
- **InfluxDB** (`influxdb`): Set the URL, database/bucket, organization, and authentication.
- **MQTT Broker** (`mqtt-broker`): Set the broker URI and credentials.

## Safe polling guidance with shared PLC access

When a PowerMonitor is owned by a PLC, treat all third-party connections as "listen-only" consumers to avoid disrupting the PLC’s control ownership. Follow these practices:

1. **Respect ownership state** – Do not attempt to establish an exclusive or redundant owner connection if a PLC already owns the device. Use `Listen Only` in the `node-red-contrib-cip` configuration so the PLC retains control.
2. **Limit polling rate** – Keep the poll interval ≥200 ms (5 Hz) to avoid oversubscribing the device’s implicit messaging resources. Coordinate with the PLC team if you need faster rates.
3. **Stagger reads** – When monitoring multiple assemblies or attributes, offset the poll intervals (e.g., 250 ms, 350 ms, 450 ms) to distribute the load evenly.
4. **Monitor connection health** – Use the CIP node status and diagnostic outputs. If the PLC reconfigures the device, your listen-only connection may drop; implement reconnection logic rather than forcing a new ownership claim.
5. **Document changes** – Communicate the polling configuration (intervals, assemblies, consumers) with the PLC owner so they can factor the additional connections into their scan-time and network loading assessments.

By keeping the flows in listen-only mode with conservative polling intervals, you can observe the PowerMonitor without interrupting the PLC’s control ownership.
