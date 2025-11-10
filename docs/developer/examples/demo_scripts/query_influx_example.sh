#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# File: docs/developer/examples/demo_scripts/query_influx_example.sh
# Summary: Demonstrates how to query the sample PowerMonitor 500 measurement
# Usage: ./docs/developer/examples/demo_scripts/query_influx_example.sh
# Depends: influx CLI with environment configured for the target InfluxDB v2 org
# -----------------------------------------------------------------------------
set -euo pipefail

if ! command -v influx >/dev/null 2>&1; then
  echo "The influx CLI must be installed and configured before running this script." >&2
  exit 1
fi

BUCKET="pm500_telemetry"
MEASUREMENT="powermonitor_500"

influx query "from(bucket: \"${BUCKET}\") |> range(start: -15m) |> filter(fn: (r) => r._measurement == \"${MEASUREMENT}\") |> limit(n: 5)"
