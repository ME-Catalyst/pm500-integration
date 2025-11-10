"""Structural validation for Node-RED flows."""
from __future__ import annotations

import json
from pathlib import Path

import pytest

FLOW_DIR = Path(__file__).resolve().parents[2] / "src" / "node-red" / "flows"


@pytest.mark.parametrize("flow_path", sorted(FLOW_DIR.glob("*.json")))
def test_flow_exports_have_required_structure(flow_path: Path) -> None:
    """Ensure exported flows use the expected Node-RED structure."""
    raw = json.loads(flow_path.read_text())

    assert isinstance(raw, list) and raw, "Node-RED exports must be non-empty arrays"

    tab_ids = {
        node["id"]
        for node in raw
        if isinstance(node, dict) and node.get("type") == "tab"
    }
    assert tab_ids, "At least one tab must be defined in the flow export"

    for node in raw:
        assert isinstance(node, dict), f"Flow entries must be objects: {flow_path.name}"
        assert "id" in node and isinstance(node["id"], str) and node["id"].strip(), (
            "Each node must include a non-empty string id"
        )
        assert "type" in node and isinstance(node["type"], str) and node["type"].strip(), (
            f"Node {node.get('id')} is missing a valid type"
        )

        if "z" in node:
            assert node["z"] in tab_ids, (
                f"Node {node['id']} references unknown tab {node['z']}"
            )

        if "wires" in node:
            assert isinstance(node["wires"], list), (
                f"Node {node['id']} wires must be a list"
            )
            for branch in node["wires"]:
                assert isinstance(branch, list), "Wire branches must be lists"
                for target in branch:
                    assert isinstance(target, str) and target.strip(), (
                        "Wire targets must be non-empty strings"
                    )


def test_flow_files_reference_existing_tabs() -> None:
    """Config nodes should not refer to undefined flows."""
    for flow_path in FLOW_DIR.glob("*.json"):
        raw = json.loads(flow_path.read_text())
        tab_ids = {
            node["id"]
            for node in raw
            if isinstance(node, dict) and node.get("type") == "tab"
        }
        referenced_tabs = {
            node["z"]
            for node in raw
            if isinstance(node, dict) and "z" in node
        }
        assert referenced_tabs.issubset(tab_ids), (
            f"Flow {flow_path.name} references undefined tabs: {referenced_tabs - tab_ids}"
        )
