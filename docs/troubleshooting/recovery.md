# Recovery Playbooks

Use these runbooks to restore data collection and integrations after faults. They are designed for shift operators and on-call engineers.

## Listen-Only Subscription Recovery
1. **Baseline the producer:** Identify the controller or gateway that owns the produced Class 1 connection using FactoryTalk Linx or Logix Designer diagnostics.
2. **Inspect subscriber status:** On the PM500 gateway, confirm the listen-only connection reports `Ownership: Listen-Only` and `Target State: Established`.
3. **Trigger validation:** Request a live tag sample from the diagnostics page and compare the timestamp against the producer. If more than one packet interval behind, capture a packet trace.
4. **Failover test:** During maintenance windows, restart the listen-only client and verify automatic resubscription without manual intervention.

## Heartbeat Monitoring Response
1. **Define the heartbeat source:** Select a fast toggling diagnostic tag produced by the PLC and record the expected frequency.
2. **Deploy monitoring rules:** Configure alerts to raise incidents when the heartbeat delta exceeds twice the expected interval and enable historical trending.
3. **Investigate alerts:** Validate PLC task execution, communication module health, and switch counters for congestion before escalating.
4. **Continuous improvement:** Review alert trends monthly and adjust thresholds or expand coverage where silent failures occurred.

## Coordinating Modbus and EtherNet/IP Access
1. **Identify overlap:** Map Modbus TCP clients and EtherNet/IP logging tasks touching the same registers.
2. **Schedule downtime:** Pause Modbus polling during logging windows and notify stakeholders at least 30 minutes before maintenance starts.
3. **Monitor runtime:** Confirm no active Modbus sessions remain by inspecting gateway session tables prior to logging and watch PLC CPU utilization during the capture.
4. **Post-maintenance:** Resume Modbus polling gradually and document any contention for future scheduling adjustments.

## Troubleshooting Node-RED Edge Deployments
- Confirm runtime version, palette compatibility, and credential files before rolling out new flows.
- Review debug log timestamps and match them against historian gaps to isolate outages quickly.
- Store sanitized flow exports with incident tickets so fixes can be reproduced in staging.

## PLC Impact Assessment Checklist
- Compare pre- and post-incident connection utilization metrics to ensure spare capacity remains.
- Track task scan times and communication load when flows are re-enabled; investigate increases above 10% of baseline.
- Trend critical process tags for deviations before closing the incident and obtain sign-off from operations and controls engineering.
