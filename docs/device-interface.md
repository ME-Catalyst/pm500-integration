# Device Interface Overview

## Available Data Points
- **Assemblies**
  - Input Assembly 101
  - Output Assembly 102
  - Configuration Assembly 107
- **Heartbeat**
  - Producer heartbeat instance 98
  - Consumer heartbeat instance 99
- **Attributes**
  - Attribute 3 is exposed for read/write access where supported

## Supported Transport Modes
- **Implicit Messaging** for real-time cyclic data exchange.
- **UCMM Explicit Messaging** for on-demand parameter access and configuration.

## Configuration Restrictions
- All write operations must be performed via **Modbus TCP**.
- Only a single Modbus TCP socket may be open at any given time.
- Modbus connectivity is mutually exclusive with EtherNet/IP operation; enable only one protocol at a time.
- When operating in EtherNet/IP Listen-Only mode, periodic keep-alive traffic is required to maintain the connection.
