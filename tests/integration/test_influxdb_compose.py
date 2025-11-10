"""Integration checks for infrastructure configuration files."""
from __future__ import annotations

from pathlib import Path
from typing import Any, Dict

COMPOSE_PATH = Path(__file__).resolve().parents[2] / "src" / "infrastructure" / "influxdb" / "docker-compose.yml"


def _load_compose() -> Dict[str, Any]:
    compose: Dict[str, Any] = {"services": {}}
    section: str | None = None
    current_service: str | None = None
    sub_section: str | None = None

    for raw_line in COMPOSE_PATH.read_text().splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue

        if not line.startswith(" "):
            section = None
            if stripped.startswith("version:"):
                compose["version"] = stripped.split(":", 1)[1].strip().strip('"')
            elif stripped == "services:":
                section = "services"
            continue

        if section != "services":
            continue

        if line.startswith("  ") and not line.startswith("    "):
            current_service = stripped.rstrip(":")
            compose["services"][current_service] = {}
            sub_section = None
            continue

        if current_service is None:
            continue

        service = compose["services"][current_service]

        if line.startswith("    ") and not line.startswith("      "):
            key = stripped.rstrip(":")
            if key in {"environment", "volumes"}:
                sub_section = key
                service[key] = {} if key == "environment" else []
            else:
                sub_section = None
                if ":" in stripped:
                    name, value = stripped.split(":", 1)
                    service[name] = value.strip().strip('"')
            continue

        if sub_section == "environment" and ":" in stripped:
            name, value = stripped.split(":", 1)
            service[sub_section][name.strip()] = value.strip()
        elif sub_section == "volumes":
            service[sub_section].append(stripped.lstrip("- "))

    return compose


def test_influxdb_compose_defines_required_service() -> None:
    """Validate the InfluxDB docker-compose configuration."""
    compose = _load_compose()

    assert compose.get("version") == "3.8", "docker-compose file must target version 3.8"

    services = compose.get("services", {})
    assert "influxdb" in services, "InfluxDB service must be declared"

    influxdb = services["influxdb"]
    assert influxdb.get("image") == "influxdb:2.7"
    assert influxdb.get("restart") == "unless-stopped"

    environment = influxdb.get("environment", {})
    required_env = {
        "DOCKER_INFLUXDB_INIT_MODE",
        "DOCKER_INFLUXDB_INIT_USERNAME",
        "DOCKER_INFLUXDB_INIT_PASSWORD",
        "DOCKER_INFLUXDB_INIT_ORG",
        "DOCKER_INFLUXDB_INIT_BUCKET",
        "DOCKER_INFLUXDB_INIT_RETENTION",
        "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN",
    }
    missing_env = required_env - set(environment)
    assert not missing_env, f"Missing required environment variables: {sorted(missing_env)}"

    volumes = influxdb.get("volumes", [])
    assert any(volume.startswith("influxdb-data") for volume in volumes), (
        "InfluxDB service must persist data using the influxdb-data volume"
    )
