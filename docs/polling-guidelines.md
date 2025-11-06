# Polling Guidelines for Rockwell PLC Connectivity

## Rockwell CIP Connection Limits
- CompactLogix and ControlLogix controllers typically support up to **nine Class 1 (real-time) CIP connections per communication module**.
- Each class 1 connection follows a **producer/consumer model**. The PLC produces data across multicast groups while subscribed devices consume the data.
- Every HMI, historian, or gateway that consumes data counts against the connection limit unless it shares an existing produced connection.
- Connections can be reserved for application use; once the limit is reached, additional connection attempts are rejected until an existing session is released.

## Recommended Polling Intervals
- **Status and health tags**: poll every 2–5 seconds to detect device faults quickly.
- **Process analogs and slow-moving discrete signals**: poll every 5–10 seconds; longer intervals reduce traffic during normal operation.
- **High-speed or critical alarms**: use event-based subscriptions or, if polling is required, limit to 1–2 second intervals and scope to the smallest required tag set.
- **Engineering or ad hoc diagnostics**: prefer on-demand reads with generous intervals (15+ seconds) to avoid consuming real-time connection bandwidth.

## Connection Ownership Rules
- Assign a **single system owner** (e.g., primary SCADA or gateway) for each produced tag set to avoid conflicting requests.
- Avoid opening redundant connections from multiple clients when a single produced connection can be **multicast to multiple consumers**.
- Ensure any client taking an exclusive ownership connection releases it after maintenance activities to free capacity.
- Document the connection map so new integrations can join existing producer streams instead of consuming additional connections.

## Listen-Only Strategies
- Use **Listen-Only connections** when clients only need to receive data and another device already owns the producer connection.
- Verify that the producing connection remains online; Listen-Only connections drop if the owner disconnects.
- Configure Listen-Only devices to **failover gracefully**, either by retrying when the owner returns or by switching to a backup producer.
- Prioritize Listen-Only mode for historian, analytics, and monitoring applications that do not need to control the PLC, preserving connection slots for control clients.

## Minimizing PLC Disruption
- Audit connection usage regularly and remove dormant sessions.
- Stagger polling intervals so large tag groups do not request updates simultaneously.
- Combine related tags into **efficient data blocks** to reduce the number of separate requests.
- Coordinate firmware updates or maintenance windows to ensure connection owners reconnect promptly and Listen-Only clients resubscribe without manual intervention.
