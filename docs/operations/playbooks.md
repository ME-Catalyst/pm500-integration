# Operations Playbooks for PM500 Integration

This playbook consolidates runbook procedures for monitoring EtherNet/IP listener configurations, coordinating Modbus diagnostics, and troubleshooting both the CODESYS and Node-RED integration paths. Each section is designed for shift operators and on-call engineers who need concise, repeatable steps during routine validation or incident response.

## Repository Integration Points

- Review the roadmap in [../roadmap.md](../roadmap.md) before runbook updates to confirm which phases are production supported.
- Node-RED flows in [../../node-red/flows/](../../node-red/flows/) provide the polling topologies referenced by the listen-only validation steps below.
- InfluxDB deployment notes under [../../infra/influxdb/](../../infra/influxdb/) describe the telemetry targets used in heartbeat monitoring procedures.

## Validating Listen-Only Subscriptions

1. **Baseline the producer**
   - Confirm which controller or gateway owns the producing Class 1 connection by reviewing the connection inventory in FactoryTalk Linx or the Logix designer project notes.
   - Check that the producing device remains in a `Run` or `Established` state and note the multicast group or connection ID assigned to the tag set.
2. **Inspect subscriber status**
   - On the PM500 gateway, open the EtherNet/IP session dashboard and verify that the Listen-Only connection shows `Ownership: Listen-Only` and `Target State: Established`.
   - Review gateway logs for recent `Connection Timeout` or `Transition to Listen-Only` events. A clean log for the previous hour indicates stable ownership.
3. **Trigger data validation**
   - Use the gateway diagnostics page to request a live tag sample. Compare the timestamp and value against the producer’s data table to ensure the multicast stream is current.
   - If the timestamp deviates by more than one requested packet interval, capture a packet trace to confirm whether the producer is still transmitting.
4. **Failover and recovery checks**
   - Disconnect and reconnect the Listen-Only client during a maintenance window to confirm automatic re-subscription. The connection should re-establish within the configured timeout without manual intervention.
   - Document the results and update the subscription matrix so future clients can share the same produced connection slot.

## Heartbeat Monitoring Procedures

1. **Define the heartbeat source**
   - Select a fast-changing diagnostic tag (e.g., a toggle bit or incrementing counter) produced by the PLC for health monitoring.
   - Configure the gateway to store the expected toggle or increment frequency (typically 1–2 seconds for heartbeat tags).
2. **Deploy monitoring rules**
   - Create an alert rule that calculates the delta between successive heartbeat timestamps. Flag any interval exceeding 2× the configured rate.
   - Enable trend logging so missed heartbeats are visible in historical charts and correlate with network or controller events.
3. **Operational response**
   - When a heartbeat alert fires, validate that the PLC task is still executing and that the producing communication module is not faulted.
   - If the PLC is healthy, inspect network switches for congestion or multicast filtering that could delay packets. Record findings in the incident ticket.
4. **Continuous improvement**
   - Review heartbeat alert frequency monthly. Adjust thresholds if nuisance alarms occur, or expand monitoring to additional segments if silent failures are discovered.

## Ensuring Modbus Sessions are Idle During EtherNet/IP Logging

1. **Identify overlapping resources**
   - Map Modbus TCP client sessions and EtherNet/IP logging tasks to the same PLC data tables. Note any shared registers or function codes.
   - Determine the typical schedule for Modbus read/write jobs and the logging windows used for packet capture or analytics.
2. **Schedule coordination**
   - Configure the Modbus client to pause polling during planned EtherNet/IP logging windows using either a scheduler or maintenance mode flag.
   - Broadcast a maintenance notification to stakeholders at least 30 minutes in advance so external Modbus consumers can acknowledge the downtime.
3. **Runtime validation**
   - Prior to starting logging, verify no active Modbus sessions exist by reviewing the gateway Modbus session table and ensuring all states read `Idle`.
   - During logging, monitor PLC CPU utilization and communication buffer metrics. Any unexpected increase suggests a Modbus session reconnected and should be halted.
4. **Post-logging checks**
   - Resume Modbus polling gradually and confirm that EtherNet/IP logging buffers flush without errors.
   - Document the coordination timeline and adjust schedules if conflicts recur.

## Troubleshooting Checklist: CODESYS Integration Path

- [ ] Confirm the CODESYS runtime version on the PM500 matches the validated release in the deployment notes.
- [ ] Verify that the PLC library mappings for EtherNet/IP and Modbus function blocks are loaded without compilation warnings.
- [ ] Check the task configuration for scan time overruns; ensure the communication task has sufficient priority.
- [ ] Inspect the gateway-to-PLC network VLAN for packet drops or misconfigured QoS rules.
- [ ] Review recent application downloads to make sure Listen-Only subscriptions were not overwritten by an older project file.
- [ ] Examine the CODESYS log for `CommDriver` faults or heartbeat timeout messages and correlate with system alerts.
- [ ] If issues persist, switch the runtime to simulation mode, replay the failing scenario, and capture trace data for escalation.

## Troubleshooting Checklist: Node-RED Integration Path

- [ ] Confirm that the Node-RED container or service is running and the EtherNet/IP nodes are `Connected`.
- [ ] Validate environment variables for PLC addresses, session ownership, and Modbus pause controls.
- [ ] Review Node-RED debug logs for `connection refused`, `listen-only timeout`, or Modbus transaction errors.
- [ ] Ensure the flow includes heartbeat validation and error handling nodes that re-subscribe after faults.
- [ ] Check that MQTT/Sparkplug brokers reflect current session status and that retained messages are updated after restarts.
- [ ] Run the automated flow test suite (if available) to reproduce failures and capture packet traces.
- [ ] If the flow interacts with external APIs, confirm network ACLs permit outbound connections during the logging window.

## PLC Impact Assessment Methods

1. **Connection utilization review**
   - Pull the PLC communication diagnostics to quantify active Class 1 and Class 3 sessions. Compare against hardware limits to ensure additional monitoring will not exhaust resources.
2. **Scan time and CPU load analysis**
   - Record average and peak task scan times before and during the integration activity. An increase of more than 10% warrants investigation into task priorities or data block sizes.
3. **Network load sampling**
   - Capture Ethernet switch statistics (multicast/broadcast rates, port utilization) to confirm monitoring activities do not introduce excessive traffic.
4. **Process impact verification**
   - Trend critical process tags to verify that Listen-Only validation, heartbeat rules, or paused Modbus sessions do not affect control loops.
5. **Stakeholder sign-off**
   - Summarize findings in an impact report and obtain acknowledgment from operations, controls engineering, and OT security before closing the change ticket.
