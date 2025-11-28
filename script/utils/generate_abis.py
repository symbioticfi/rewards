#!/usr/bin/env python3
"""Generate ABI artifacts for deployable contracts and public interfaces."""

from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "out"
ABIS_DIR = ROOT / "abis"
SRC_ROOT = Path("src")
INTERFACES_ROOT = SRC_ROOT / "interfaces"


def is_abi_artifact(source_path: str) -> bool:
    """Return True if the source path should produce an ABI artifact."""
    if not source_path.startswith(f"{SRC_ROOT}/"):
        return False

    if source_path.startswith(f"{INTERFACES_ROOT}/"):
        return True

    return False


def run_forge_build() -> None:
    """Run forge build to ensure artifacts are up to date."""
    subprocess.run(
        ["forge", "build", "--extra-output-files", "abi"],
        cwd=ROOT,
        check=True,
    )


def load_source_path(artifact_data: dict) -> str | None:
    """Extract the contract source path from the artifact metadata."""
    metadata_raw = artifact_data.get("metadata")
    if not metadata_raw:
        return None

    if isinstance(metadata_raw, str):
        try:
            metadata = json.loads(metadata_raw)
        except json.JSONDecodeError:
            return None
    elif isinstance(metadata_raw, dict):
        metadata = metadata_raw
    else:
        return None

    compilation_target = metadata.get("settings", {}).get("compilationTarget") or {}
    if not compilation_target:
        return None

    # compilationTarget maps source path -> contract name; we need the path.
    return next(iter(compilation_target.keys()), None)


def main() -> None:
    run_forge_build()

    if ABIS_DIR.exists():
        shutil.rmtree(ABIS_DIR)
    ABIS_DIR.mkdir(parents=True, exist_ok=True)

    for artifact_json in sorted(OUT_DIR.rglob("*.json")):
        # Skip ABI-only JSON artifacts.
        if artifact_json.name.endswith(".abi.json"):
            continue

        with artifact_json.open() as fh:
            artifact_data = json.load(fh)

        source_path = load_source_path(artifact_data)
        if not source_path or not is_abi_artifact(source_path):
            continue

        abi_file = artifact_json.with_suffix(".abi.json")
        if not abi_file.exists():
            continue

        contract_name = Path(abi_file).name
        if contract_name.endswith(".abi.json"):
            contract_name = contract_name[: -len(".abi.json")]
        dest_path = ABIS_DIR / f"{contract_name}.abi.json"
        shutil.copy2(abi_file, dest_path)


if __name__ == "__main__":
    main()
