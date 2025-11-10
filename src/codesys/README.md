# CODESYS Integration Assets

This directory captures exported configuration artifacts and operator guidance for connecting the PM500 to a CODESYS-based EtherNet/IP Scanner SL project.

## Prerequisites

Before importing the configurations or variable mappings provided here, ensure that the engineering workstation meets the following requirements:

- **CODESYS Control Win V3** installed and licensed for the target operating system.
- **CODESYS EtherNet/IP Scanner SL** package installed, with a valid runtime license activated on the target controller.
- Network access to the PM500 adapter with a static IP address that matches the configurations below (default `192.168.1.10`). Adjust the address inside the exported files if your network uses a different scheme.

## Provided Files

| Resource | Description |
| --- | --- |
| `exports/scanner-assembly-101-export.xml` | Example Scanner SL export with an exclusive owner connection for input assembly 101. |
| `exports/scanner-assembly-102-export.xml` | Example Scanner SL export with an exclusive owner connection for output assembly 102. |
| `exports/scanner-assembly-107-export.xml` | Example Scanner SL export combining input 101 and output 102 with configuration assembly 107. |
| `mapping/assembly-101-variable-mapping.csv` | IEC variable mapping for the 8-byte producer-consumer data coming from assembly 101. |
| `mapping/assembly-102-variable-mapping.csv` | IEC variable mapping for the 8-byte consumer data being written to assembly 102. |
| `mapping/assembly-107-variable-mapping.csv` | IEC variable mapping for the configuration/status data tied to assembly 107. |

Import the `.xml` exports via **Device Repository → Import** inside the CODESYS development environment. The `.csv` mappings can be copied into a spreadsheet or imported through the **Mapping** dialog of the EtherNet/IP I/O channels.

## Input-Only and Listen-Only Connections

If another PLC already owns the PM500 adapter, you can still create redundant read connections in CODESYS by switching the connection type to *Input-Only* or *Listen-Only*:

1. Import the desired assembly export from the `exports/` directory.
2. In the device tree, expand **EtherNet/IP Scanner → PM500 Adapter → Connections**.
3. Right-click the relevant connection (for example, *PM500_Input_101*) and choose **Edit Connection**.
4. Change **Connection Type** to **Input-Only** (for controllers allowed to establish a secondary input connection) or **Listen-Only** (for passive monitoring).
5. Ensure that the **Requested Packet Interval (RPI)** matches the owning PLC configuration—typical value is `50 ms` for the examples provided.
6. Rebuild the application and download it to the scanner runtime. CODESYS will subscribe to the adapter without interrupting the primary owner.
7. Map the connection variables using the templates in the `mapping/` directory to expose the data inside your IEC application.

> **Note:** Input-Only and Listen-Only connections expose read-only data. Do not deploy the `scanner-assembly-102-export.xml` file on a secondary scanner unless the owning PLC releases the output connection.

## Variable Mapping

Each `.csv` file lists friendly IEC variable names together with offsets and data types. You can paste these definitions into the **Variable Mapping** dialog to quickly bind process data:

1. Open the EtherNet/IP device, select the connection, and choose **I/O Mapping**.
2. For each channel, paste or type the IEC variable name provided in the mapping file.
3. Adjust data types if your project uses different scaling (for example, convert `WORD` values to `REAL` using scaling logic in your program).

After the variables are mapped, rebuild the project to validate that the symbol configuration is consistent with the PM500 profile.
