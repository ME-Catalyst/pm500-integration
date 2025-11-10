# Advanced Usage and Polling Strategies

These guidelines help engineers scale data collection without exhausting PLC resources or interfering with production workloads.

## Connection Limits and Ownership
- CompactLogix and ControlLogix controllers typically support up to **nine Class 1 (real-time) CIP connections per communication module**.
- Track ownership of produced connections to prevent competing scanners. Assign a single system owner for each multicast stream and document the map in change management systems.
- Prefer **listen-only** subscribers for historians, analytics, and monitoring clients so control applications retain exclusive ownership when necessary.

## Polling Interval Recommendations
- **Status and health tags:** 2–5 seconds keeps heartbeat monitoring responsive without saturating bandwidth.
- **Process analogs and slow-moving discrete signals:** 5–10 seconds balances visibility with network load.
- **High-speed alarms:** Trigger flows on events when possible; if polling is required, limit to 1–2 second intervals scoped to the minimum viable tag set.
- **Engineering diagnostics:** Run on-demand reads at 15+ second intervals to avoid consuming real-time capacity.

## Minimizing PLC Disruption
- Audit active connections monthly and retire dormant sessions to reclaim bandwidth.
- Stagger polling windows so large tag groups do not refresh simultaneously.
- Group related tags into contiguous data blocks to reduce requests.
- Coordinate firmware updates and maintenance windows so connection owners reconnect promptly and listen-only clients resubscribe without manual intervention.

## Related References
- Interface details and assembly constraints: [`configuration.md`](configuration.md)
- Telemetry data flow and processing stages: [`../architecture/data_flow.md`](../architecture/data_flow.md)
- Recovery runbooks for listen-only subscriptions and Modbus coordination: [`../troubleshooting/recovery.md`](../troubleshooting/recovery.md)
