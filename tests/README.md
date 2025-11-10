# Test Suites

This directory hosts automated validation entry points for the integration concept.

- `unit/` – Deterministic checks for utility helpers, payload transforms, or configuration schemas.
- `integration/` – End-to-end flow simulations for Node-RED, infrastructure stacks, or PLC exports.
- `flow/` – Replay harnesses for Node-RED or Sparkplug pipelines once they are available.

Current coverage focuses on structural validation for Node-RED flow exports and Docker Compose stacks. Run the entire suite with:

```bash
pytest
```

Each subdirectory includes its own README and test runner instructions as suites are implemented.
