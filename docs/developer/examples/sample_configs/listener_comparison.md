# Listener Platform Comparison: CODESYS vs. Node-RED

## Overview
This decision record summarizes the trade-offs between building the PM500 listener on CODESYS and Node-RED. It highlights operational factors that influence maintenance costs, risk exposure, and the ability to scale the solution beyond a single pilot cell.

## Evaluation Criteria

### Setup Effort
- **CODESYS:** Requires installing and licensing the CODESYS runtime on the PLC, provisioning development workstations with the engineering environment, and coordinating downloads that interrupt PLC execution. Initial setup typically needs OT involvement and scheduled downtime.
- **Node-RED:** Can be deployed as a lightweight service on an edge gateway, VM, or container host without touching the PLC runtime. Flows are edited through a browser, and updates can be rolled out with standard CI/CD practices, minimizing production interruptions.

### Diagnostics and Monitoring
- **CODESYS:** Provides native PLC debugging (breakpoints, watch lists, trace) and direct visibility into task execution. However, log export and integration with enterprise observability tools is limited, and troubleshooting usually requires engineering software access on the control network.
- **Node-RED:** Offers built-in debug nodes, message tracing, and integration with logging stacks such as MQTT, InfluxDB, or ELK. Flow diagnostics are accessible remotely through secure tunnels, enabling IT support teams to triage issues without direct PLC access.

### Licensing and Cost Structure
- **CODESYS:** Engineering seats and PLC runtimes often require per-device or per-feature licenses. Scaling to additional controllers increases recurring costs and procurement overhead.
- **Node-RED:** Open-source under the Apache 2.0 license. Enterprise support is optional, and runtime instances can be cloned without incremental licensing fees, reducing the financial barrier to scaling.

### Scalability and Deployment Flexibility
- **CODESYS:** Listener logic runs on the PLC and is limited by controller CPU, memory, and task scheduling. Scaling beyond a few additional data points may require upgrading hardware or distributing logic across multiple PLCs.
- **Node-RED:** Runs on general-purpose compute and supports container orchestration, clustering, and external storage. Scaling throughput is primarily a matter of allocating more compute resources or load-balancing flows across gateways.

### PLC Operational Risk
- **CODESYS:** Changes to the listener share runtime resources with control logic. Misconfigurations can impact scan times or inadvertently modify control variables, increasing downtime risk.
- **Node-RED:** Operates off-controller, isolating data acquisition from deterministic control tasks. PLC interaction is limited to well-defined protocols (e.g., OPC UA, Modbus), reducing the chance of destabilizing the automation program.

## Recommendation
Select **Node-RED** when rapid deployment, remote diagnostics, and cost-effective scaling are priorities, especially for multi-site rollouts or when IT teams will maintain the integration.

Choose **CODESYS** when tight coupling with existing PLC code is required, on-controller execution is mandated by policy, or when the team already standardizes on CODESYS engineering workflows and tooling.

Stakeholders should weigh licensing budgets, tolerance for PLC downtime, and long-term maintainability when deciding between the two platforms.
