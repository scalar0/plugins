from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "destochastic.py"
BASE_SKILL = """\
---
name: example-skill
description: Preserve this exact capability and trigger.
---

# Example Skill

## Objectives

Produce a checked artifact.

## Workflow

1. Inspect the input.
2. Run the repeated transformation.

```bash
python3 -c "print('work')"
```

## Deliverables

- Return the checked artifact.
"""


class DestochasticCliTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.skill = self.root / "example-skill"
        self.skill.mkdir()
        (self.skill / "SKILL.md").write_text(BASE_SKILL, encoding="utf-8")
        self.baseline = self.root / "baseline.json"

    def run_cli(
        self, *arguments: str, expected: int = 0
    ) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(
            [sys.executable, str(SCRIPT), *arguments],
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(expected, result.returncode, result.stderr + result.stdout)
        return result

    def capture_baseline(self) -> dict[str, object]:
        self.run_cli("baseline", str(self.skill), "--output", str(self.baseline))
        return json.loads(self.baseline.read_text(encoding="utf-8"))

    def add_executable(self) -> None:
        scripts = self.skill / "scripts"
        scripts.mkdir()
        executable = scripts / "transform.py"
        executable.write_text(
            "#!/usr/bin/env python3\nprint('work')\n", encoding="utf-8"
        )
        executable.chmod(0o755)
        skill_text = (self.skill / "SKILL.md").read_text(encoding="utf-8")
        skill_text = skill_text.replace(
            "1. Inspect the input.\n2. Run the repeated transformation.\n\n"
            "```bash\npython3 -c \"print('work')\"\n```",
            "Choose the input that needs transformation.\n\n"
            "Run [the deterministic transformer](scripts/transform.py).",
        )
        (self.skill / "SKILL.md").write_text(skill_text, encoding="utf-8")

    def test_inspect_reports_workflow_and_code_candidates(self) -> None:
        result = self.run_cli("inspect", str(self.skill), "--json")
        payload = json.loads(result.stdout)
        kinds = {candidate["kind"] for candidate in payload["candidates"]}
        self.assertEqual({"workflow-section", "executable-code-block"}, kinds)

    def test_inspect_ignores_links_in_code_and_checks_reference_links(self) -> None:
        path = self.skill / "SKILL.md"
        path.write_text(
            path.read_text(encoding="utf-8")
            + "\n`[inline](missing-inline.txt)`\n"
            + "\n```text\n[example](missing-code.txt)\n```\n"
            + "\n[contract]: missing-reference.txt\n",
            encoding="utf-8",
        )
        result = self.run_cli("inspect", str(self.skill), "--json")
        payload = json.loads(result.stdout)
        self.assertEqual(
            ["missing-reference.txt"],
            [link["target"] for link in payload["links"]],
        )

    def test_baseline_auto_protects_contract_sections(self) -> None:
        payload = self.capture_baseline()
        titles = [section["title"] for section in payload["protected_sections"]]
        self.assertEqual(["Objectives", "Deliverables"], titles)

    def test_line_range_can_protect_contract_text_in_a_mixed_section(self) -> None:
        mixed = BASE_SKILL.replace("## Objectives", "## Overview")
        (self.skill / "SKILL.md").write_text(mixed, encoding="utf-8")
        self.run_cli(
            "baseline",
            str(self.skill),
            "--output",
            str(self.baseline),
            "--protect-lines",
            "10",
        )
        payload = json.loads(self.baseline.read_text(encoding="utf-8"))
        self.assertEqual(
            "Produce a checked artifact.", payload["protected_texts"][0]["text"]
        )

        path = self.skill / "SKILL.md"
        path.write_text(
            path.read_text(encoding="utf-8").replace(
                "Produce a checked artifact.",
                "Produce an unchecked artifact.",
            ),
            encoding="utf-8",
        )
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            expected=1,
        )
        self.assertIn("protected text changed", result.stdout)

    def test_verify_accepts_extraction_and_reports_new_executable(self) -> None:
        self.capture_baseline()
        self.add_executable()
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            "--require-new-executable",
            "--json",
        )
        payload = json.loads(result.stdout)
        self.assertEqual("passed", payload["status"])
        self.assertEqual(["scripts/transform.py"], payload["new_executables"])

    def test_verify_rejects_changed_description(self) -> None:
        self.capture_baseline()
        path = self.skill / "SKILL.md"
        path.write_text(
            path.read_text(encoding="utf-8").replace(
                "Preserve this exact capability and trigger.",
                "Changed capability.",
            ),
            encoding="utf-8",
        )
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            "--json",
            expected=1,
        )
        self.assertIn("frontmatter field changed: description", result.stdout)

    def test_verify_rejects_changed_deliverable(self) -> None:
        self.capture_baseline()
        path = self.skill / "SKILL.md"
        path.write_text(
            path.read_text(encoding="utf-8").replace(
                "Return the checked artifact.",
                "Return something else.",
            ),
            encoding="utf-8",
        )
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            expected=1,
        )
        self.assertIn("protected section changed: Deliverables", result.stdout)

    def test_verify_rejects_non_executable_linked_script(self) -> None:
        self.capture_baseline()
        self.add_executable()
        script = self.skill / "scripts" / "transform.py"
        script.chmod(0o644)
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            expected=1,
        )
        self.assertIn("linked script is not executable", result.stdout)

    def test_verify_rejects_broken_local_link(self) -> None:
        self.capture_baseline()
        path = self.skill / "SKILL.md"
        path.write_text(
            path.read_text(encoding="utf-8")
            + "\nRun [the missing tool](scripts/missing.py).\n",
            encoding="utf-8",
        )
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            expected=1,
        )
        self.assertIn("broken local link", result.stdout)

    def test_verify_can_require_an_actual_extraction(self) -> None:
        self.capture_baseline()
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            "--require-new-executable",
            expected=1,
        )
        self.assertIn("no new executable", result.stdout)

    def test_verify_rejects_transient_cache_artifacts(self) -> None:
        self.capture_baseline()
        cache = self.skill / "scripts" / "__pycache__"
        cache.mkdir(parents=True)
        (cache / "tool.cpython-314.pyc").write_bytes(b"cache")
        result = self.run_cli(
            "verify",
            str(self.skill),
            "--baseline",
            str(self.baseline),
            expected=1,
        )
        self.assertIn("transient artifact remains", result.stdout)
        self.assertIn("scripts/__pycache__", result.stdout)

    def test_explicit_protected_heading_must_exist(self) -> None:
        result = self.run_cli(
            "baseline",
            str(self.skill),
            "--output",
            str(self.baseline),
            "--protect-heading",
            "Missing Contract",
            expected=2,
        )
        self.assertIn("protected headings not found", result.stderr)


if __name__ == "__main__":
    unittest.main()
