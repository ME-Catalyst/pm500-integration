"""Smoke tests for repository scaffolding."""

from pathlib import Path


def test_src_hierarchy_exists() -> None:
    root = Path(__file__).resolve().parents[2]
    expected = {
        root / "src" / "node-red",
        root / "src" / "infrastructure",
        root / "src" / "cloud",
        root / "src" / "codesys",
    }
    missing = [path for path in expected if not path.exists()]
    assert not missing, f"Missing expected implementation directories: {missing}"


def test_examples_directory_has_samples() -> None:
    root = Path(__file__).resolve().parents[2]
    examples_dir = root / "examples"
    assert examples_dir.is_dir(), "examples directory should exist"
    sample_files = list(examples_dir.glob("*"))
    assert sample_files, "examples directory should contain sample assets"
