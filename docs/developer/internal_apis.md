# Sparkplug B Messaging Guide

## Overview
Sparkplug B defines a structured MQTT topic and payload format for industrial telemetry. Payloads are binary-encoded using Google Protocol Buffers and carry a primary timestamp, sequence number, metrics list, and optional template references. This guide documents the templates and conventions expected by Eclipse Sparkplug compliant consumers and the Ignition MQTT Engine when integrating the PM500 platform.

## Core Topic Namespace
- **Group ID**: `pm500`
- **Edge Node ID**: `edge/<cell-id>` (alphanumeric cell identifier)
- **Device ID**: `device/<asset-tag>` (matches PM500 asset tag)
- **Namespace**: `spBv1.0`

Topics follow the pattern `spBv1.0/<Group ID>/<Message Type>/<Edge Node ID>[/<Device ID>]`.
- Birth and death certificates use message types `NBIRTH`/`NDEATH` for edge nodes and `DBIRTH`/`DDEATH` for devices.
- Data updates use `NDATA` or `DDATA` depending on whether the payload originates from the edge node or device scope.

## Payload Header Requirements
Each payload must populate the Sparkplug `Payload` fields as follows:
- `timestamp`: Epoch milliseconds when the message was generated.
- `seq`: Monotonic sequence number per Edge Node and message type. Reset to `0` on every birth.
- `uuid`: Leave unset unless explicitly coordinating with store-and-forward clients.
- `metrics`: Ordered list of metric objects as defined below.

Payloads must not include metrics with duplicate names within the same template instance. All metrics must carry a data type that matches the Sparkplug spec (e.g., `Int32`, `Float`, `Boolean`, `String`).

## Base Metric Templates
The Ignition MQTT Engine expects the PM500 Edge Node to use consistent template definitions. Template identifiers appear in `Metric.templateRef` and the birth payload must publish the full template definition. Templates may be reused by device instances.

### Edge Node Health Template `tpl_edge_health`
- **Template Metrics**
  - `online` (`Boolean`, `is_null = false`): Edge application connectivity status.
  - `uptimeSeconds` (`UInt64`): Seconds since last edge node restart.
  - `fwVersion` (`String`): Firmware semantic version.
  - `lastConfigSync` (`DateTime`): Epoch milliseconds of the last configuration pull.
- **Implementation Notes**
  - Publish the template definition in the `NBIRTH` payload.
  - Include a metric instance using `templateRef = tpl_edge_health` with `isHistorical = false` and `isNull = false`.

### Device Process Template `tpl_device_process`
- **Template Metrics**
  - `phaseCurrentA` (`Float`): RMS current on phase A.
  - `phaseCurrentB` (`Float`): RMS current on phase B.
  - `phaseCurrentC` (`Float`): RMS current on phase C.
  - `voltageL1L2` (`Float`): Line-to-line voltage between L1 and L2.
  - `voltageL2L3` (`Float`): Line-to-line voltage between L2 and L3.
  - `voltageL3L1` (`Float`): Line-to-line voltage between L3 and L1.
  - `powerFactor` (`Double`): Aggregate power factor.
  - `frequencyHz` (`Float`): Line frequency.
- **Implementation Notes**
  - Publish the template definition in `DBIRTH` for each device.
  - Reference the template in `DDATA` payloads with `templateRef = tpl_device_process`.

### Alarm Template `tpl_alarm_state`
- **Template Metrics**
  - `id` (`String`): Alarm identifier matching PM500 catalog.
  - `active` (`Boolean`): Alarm state.
  - `severity` (`UInt16`): ISA severity code.
  - `latched` (`Boolean`): Latch status.
  - `message` (`String`, optional, `isNull = true` when absent): Operator message.
- **Implementation Notes**
  - Template definition emitted in `NBIRTH` to register alarm schema once per Edge Node.
  - Instances may be included in both `NDATA` (edge-wide alarms) and `DDATA` (device alarms).

## Birth Certificate Payload Templates
Birth messages must enumerate both static metrics and template definitions. The following tables summarize the expected contents.

### Node Birth (`NBIRTH`)
| Metric Name | Type | Value | Notes |
|-------------|------|-------|-------|
| `Node Control/Next Server` | Boolean | `false` | Required control metric. |
| `Node Control/Rebirth` | Boolean | `false` | Accept command to trigger rebirth. |
| `Node Control/Reboot` | Boolean | `false` | Accept command to reboot edge runtime. |
| `Node Control/Scan Rate` | UInt32 | `1000` | Milliseconds. |
| `bdSeq` | UInt64 | `0` | Birth/death sequence counter. |
| Template definition `tpl_edge_health` | Template | n/a | Present in `metrics` with `template.isDefinition = true`. |
| Template definition `tpl_alarm_state` | Template | n/a | Present in `metrics` with `template.isDefinition = true`. |
| `edgeHealth` | Template Instance | `templateRef = tpl_edge_health` | Populated with health metrics. |

### Device Birth (`DBIRTH`)
| Metric Name | Type | Value | Notes |
|-------------|------|-------|-------|
| `bdSeq` | UInt64 | `0` | Device birth/death sequence counter. |
| Template definition `tpl_device_process` | Template | n/a | `template.isDefinition = true`. |
| `process` | Template Instance | `templateRef = tpl_device_process` | Real-time electrical metrics. |
| `alarms` | Dataset | Row per active device alarm | Column schema: `id`, `severity`, `message`, `timestamp`. |

## Data Update Payload Patterns
- **Edge Data (`NDATA`)**
  - Include incremental updates for health metrics, alarm datasets, or any non-device scoped data.
  - Maintain the same metric names as published in birth.
  - Only include changed metrics when possible to conserve bandwidth.

- **Device Data (`DDATA`)**
  - Publish the `process` template instance on configured scan rate (default 1 second).
  - Send alarm dataset updates whenever the alarm list changes.

## Encoding Guidance for Node-RED
1. Install the `node-red-contrib-sparkplug` palette to gain the `sparkplug in/out` nodes.
2. Configure the Sparkplug Out node with namespace `spBv1.0`, group `pm500`, edge node `edge/<cell-id>`, and device `device/<asset-tag>`.
3. Use a `function` node to construct metric objects matching the template schema. Example snippet:
   ```javascript
   msg.payload.metrics = [
     {
       name: 'process',
       templateRef: 'tpl_device_process',
       value: {
         phaseCurrentA: 42.5,
         phaseCurrentB: 41.8,
         phaseCurrentC: 42.1,
         voltageL1L2: 480.0,
         voltageL2L3: 479.5,
         voltageL3L1: 481.2,
         powerFactor: 0.97,
         frequencyHz: 59.98
       }
     }
   ];
   return msg;
   ```
4. Ensure timestamps (`msg.payload.timestamp`) are set with `Date.now()` and maintain the sequence number in flow context (increment per publish).
5. Trigger an `NBIRTH` by deploying the flow or toggling the `Node Control/Rebirth` metric to `true` and republishing the birth payload.

## Encoding Guidance for CODESYS Edge Gateways
1. Import the Sparkplug B client library and map application variables to Sparkplug metrics.
2. Define STRUCTs matching the templates:
   ```iecst
   TYPE TPL_DeviceProcess :
   STRUCT
     phaseCurrentA : LREAL;
     phaseCurrentB : LREAL;
     phaseCurrentC : LREAL;
     voltageL1L2   : LREAL;
     voltageL2L3   : LREAL;
     voltageL3L1   : LREAL;
     powerFactor   : LREAL;
     frequencyHz   : LREAL;
   END_STRUCT
   END_TYPE
   ```
3. Populate a `SparkplugMetricList` in the `NBIRTH` routine, adding template definitions with `IsDefinition := TRUE` and template instances with references to the STRUCT data.
4. Maintain a global `udint` sequence counter that resets to zero on every birth and increments before each publish.
5. Use the library`s encode function to serialize the payload, then publish to topic `spBv1.0/pm500/DDATA/edge/<cell-id>/device/<asset-tag>`.
6. Implement watchdog logic that publishes a `DDEATH` with the same `bdSeq` value if communication fails or the device shuts down.

## Testing With Ignition MQTT Engine
- Use Ignition 8.1.27 or newer with the MQTT Engine module configured to subscribe to `spBv1.0/pm500/#`.
- After deploying the edge application, verify receipt of `NBIRTH` and `DBIRTH` messages, ensuring template definitions appear under `Tags/Edge Nodes/<edge>/<device>`.
- Confirm that metrics display with correct data types and that alarm dataset columns map to Ignition UDT members.
- Issue a `Node Control/Rebirth` command from Ignition and ensure the edge republish birth certificates with sequence numbers reset.

## Additional Resources
- Eclipse Sparkplug Specification Version 3.0.
- Ignition MQTT Transmission and Engine user manuals.
- Node-RED Sparkplug palette documentation.
