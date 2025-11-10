# Flow Replay Tests

Use this directory for replay harnesses that validate telemetry pipelines using recorded payloads or Node-RED project exports.

## Automated Checks

The `pytest` suite in this directory validates the structural integrity of every Node-RED flow stored under `src/node-red/flows/`.
It confirms that:

- Each export is a non-empty array of Node-RED nodes.
- Flow tabs exist and all nodes reference a known tab identifier.
- Wire definitions reference valid downstream node identifiers.

Run the checks with:

```bash
pytest tests/flow
```
