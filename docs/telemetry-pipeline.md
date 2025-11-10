# Telemetry Pipeline Integration

This guide describes how the PM500 edge stack can forward measurements from PLC assets through Node-RED and CODESYS into InfluxDB OSS v2 via Telegraf.

## Repository Assets

- Node-RED reference flows in [../node-red/flows/](../node-red/flows/) implement the polling, normalization, and export patterns described in this guide.
- The InfluxDB OSS v2 stack under [../infra/influxdb/](../infra/influxdb/) provides the target data store for the examples below and can be paired with Telegraf.
- AWS IoT Core provisioning snippets in [../cloud/aws-iot/](../cloud/aws-iot/) supply MQTT endpoints for the Sparkplug B publishing options discussed in later sections.

## Node-RED write configuration

1. **Install the InfluxDB output node** (`node-red-contrib-influxdb`) on the Node-RED runtime co-located with Telegraf.
2. **Create a flow** that ingests PM500 tag updates (MQTT, OPC UA, or Modbus nodes).
3. **Normalize payloads** using a `function` node:
   ```javascript
   msg.measurement = "pm500_metrics";
   msg.tags = {
     asset: msg.payload.assetId,
     line: msg.payload.lineId,
     unit: msg.payload.unit
   };
   msg.fields = {
     voltage: Number(msg.payload.voltage),
     current: Number(msg.payload.current),
     temperature: Number(msg.payload.temperature)
   };
   return msg;
   ```
4. **Configure the InfluxDB Out node** to use the `http` protocol pointed at Telegraf's InfluxDB v2 listener (default `http://telegraf:8086`). Supply the scoped write token generated in InfluxDB and select the telemetry bucket.
5. **Batch writes** by enabling the Influx node's `precision` and `max batch size` options or by buffering data with a `delay` node. This improves throughput and reduces HTTP overhead.

When Telegraf is preferred as the ingestion proxy, replace the InfluxDB Out node with an `http request` node aimed at Telegraf's `/write` endpoint. Set headers:

- `Authorization: Token <TELEGRAF_WRITE_TOKEN>`
- `Content-Type: text/plain; charset=utf-8`

Use a `template` node to render Influx line protocol, e.g.:

```
pm500_metrics,asset={{payload.assetId}},line={{payload.lineId}} voltage={{payload.voltage}},current={{payload.current}},temperature={{payload.temperature}}
```

Send the rendered string as the HTTP body and configure Telegraf's `influxdb_v2` input to listen for writes.

## CODESYS relay via MQTT or OPC UA

CODESYS-based PLCs can forward PM500 data points into Telegraf by leveraging two common field protocols:

### MQTT path

1. Install the CODESYS MQTT library and publish telemetry to a broker topic (e.g., `factory/pm500/<machine>/measurements`).
2. Deploy Telegraf with the `inputs.mqtt_consumer` plugin subscribed to the same topic. Configure JSON parsing to map payload keys to measurement fields.
3. Optionally, run Node-RED as an intermediary: use the MQTT-in node to consume PLC messages, enrich them with additional context (shift, operator, line), and publish the enriched payload to Telegraf's HTTP listener or MQTT topic dedicated to Telegraf.

### OPC UA path

1. Expose PM500 variables via the CODESYS OPC UA server with appropriate browse names and data types.
2. Configure Node-RED's OPC UA client to poll or subscribe to those variables.
3. Transform the data with the same normalization function shown above, then emit to Telegraf via HTTP or MQTT.
4. Alternatively, use Telegraf's `inputs.opcua` plugin directly if the deployment supports it, pointing to the CODESYS endpoint and mapping nodes to fields.

## Advantages of the architecture

- **Bandwidth reduction:** Telegraf performs local aggregation, downsampling, and deadband filtering before forwarding data to the historian, minimizing the load on backhaul links.
- **Local analytics:** Node-RED and Telegraf processors (starlark, processors.*) enable edge-level KPIs, alarms, and anomaly detection without cloud dependencies, keeping production insights available during WAN outages.
- **VLAN isolation:** Segmenting PLCs, Node-RED, Telegraf, and InfluxDB into dedicated VLANs limits east-west traffic exposure and creates clear trust boundaries between OT and IT networks.

Combining these components yields a resilient pipeline that scales from lab environments to brownfield retrofits while honoring industrial security practices.

## Next Steps

- Pair the InfluxDB stack with Grafana or Chronograf dashboards that highlight power factor, phase current balance, and heartbeat integrity.
- Document Telegraf processor and aggregator chains once KPIs are finalized to ensure edge-side filtering is reproducible.
- Capture export samples for both Sparkplug B and AWS IoT Core to validate schema alignment before production rollout.
