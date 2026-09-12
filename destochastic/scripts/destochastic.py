#!/usr/bin/env python3
"""Inventory and contract-check a skill during deterministic extraction."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import unquote


SCHEMA_VERSION = 1
HEADING_RE = re.compile(r"^(#{1,6})[ \t]+(.+?)(?:[ \t]+#+)?[ \t]*$")
FENCE_RE = re.compile(r"^[ \t]*(`{3,}|~{3,})[ \t]*([^ \t`]*)")
LINK_RE = re.compile(r"!?\[[^\]]*]\((<[^>]+>|[^)\s]+)(?:\s+['\"][^'\"]*['\"])?\)")
REFERENCE_LINK_RE = re.compile(r"^[ \t]*\[[^\]]+]:[ \t]*(<[^>]+>|[^ \t]+)")
FIELD_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*):(.*)$")
WORKFLOW_RE = re.compile(
    r"\b(workflow|process|procedure|steps?|runbook|pipeline)\b", re.I
)
CONTRACT_HEADING_RE = re.compile(
    r"^(objectives?|goals?|scope|deliverables?|outputs?|outcomes?|"
    r"output expectations?|success criteria|guarantees?|contract)$",
    re.I,
)
EXECUTABLE_LANGUAGES = {
    "bash",
    "console",
    "fish",
    "javascript",
    "js",
    "node",
    "perl",
    "php",
    "powershell",
    "ps1",
    "py",
    "python",
    "ruby",
    "rust",
    "sh",
    "shell",
    "sql",
    "typescript",
    "ts",
    "zsh",
}
SCRIPT_SUFFIXES = {
    ".bash",
    ".js",
    ".mjs",
    ".php",
    ".pl",
    ".ps1",
    ".py",
    ".rb",
    ".sh",
    ".ts",
}
TRANSIENT_DIRECTORIES = {
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    "__pycache__",
}
TRANSIENT_FILES = {".coverage"}
TRANSIENT_SUFFIXES = {".pyc", ".pyo"}


class SkillError(ValueError):
    """Report invalid skill input without a traceback."""


@dataclass(frozen=True)
class Heading:
    level: int
    title: str
    line: int
    end_line: int
    text: str
    occurrence: int


@dataclass(frozen=True)
class CodeBlock:
    language: str
    line: int
    end_line: int
    body: str
    closed: bool


@dataclass(frozen=True)
class SkillDocument:
    root: Path
    skill_file: Path
    text: str
    lines: list[str]
    frontmatter_fields: dict[str, str]
    frontmatter_end: int
    headings: list[Heading]
    code_blocks: list[CodeBlock]


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def normalized_title(title: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[`*_]", "", title)).strip()


def closes_fence(line: str, marker: str) -> bool:
    pattern = rf"^[ \t]*{re.escape(marker[0])}{{{len(marker)},}}[ \t]*$"
    return bool(re.match(pattern, line))


def parse_frontmatter(lines: list[str]) -> tuple[dict[str, str], int]:
    if not lines or lines[0].strip() != "---":
        raise SkillError("SKILL.md must start with YAML frontmatter")

    try:
        closing = next(
            index for index in range(1, len(lines)) if lines[index].strip() == "---"
        )
    except StopIteration as error:
        raise SkillError("SKILL.md frontmatter is not closed") from error

    entries: dict[str, list[str]] = {}
    current: str | None = None
    for line in lines[1:closing]:
        match = FIELD_RE.match(line)
        if match and not line.startswith((" ", "\t")):
            current = match.group(1)
            entries[current] = [line]
        elif current is not None:
            entries[current].append(line)

    return {key: "\n".join(value) for key, value in entries.items()}, closing


def parse_markdown(
    lines: list[str], frontmatter_end: int
) -> tuple[list[Heading], list[CodeBlock]]:
    raw_headings: list[tuple[int, str, int]] = []
    blocks: list[CodeBlock] = []
    fence_marker: str | None = None
    fence_language = ""
    fence_line = 0
    fence_body: list[str] = []

    for index in range(frontmatter_end + 1, len(lines)):
        line = lines[index]
        fence = FENCE_RE.match(line)
        if fence_marker is None and fence:
            fence_marker = fence.group(1)
            fence_language = fence.group(2).lower()
            fence_line = index + 1
            fence_body = []
            continue
        if fence_marker is not None:
            if closes_fence(line, fence_marker):
                blocks.append(
                    CodeBlock(
                        language=fence_language,
                        line=fence_line,
                        end_line=index + 1,
                        body="\n".join(fence_body),
                        closed=True,
                    )
                )
                fence_marker = None
                continue
            fence_body.append(line)
            continue

        heading = HEADING_RE.match(line)
        if heading:
            raw_headings.append(
                (len(heading.group(1)), normalized_title(heading.group(2)), index)
            )

    if fence_marker is not None:
        blocks.append(
            CodeBlock(
                language=fence_language,
                line=fence_line,
                end_line=len(lines),
                body="\n".join(fence_body),
                closed=False,
            )
        )

    occurrence_counts: dict[tuple[int, str], int] = {}
    headings: list[Heading] = []
    for position, (level, title, start) in enumerate(raw_headings):
        end = len(lines)
        for next_level, _, next_start in raw_headings[position + 1 :]:
            if next_level <= level:
                end = next_start
                break
        key = (level, title.casefold())
        occurrence = occurrence_counts.get(key, 0) + 1
        occurrence_counts[key] = occurrence
        headings.append(
            Heading(
                level=level,
                title=title,
                line=start + 1,
                end_line=end,
                text="\n".join(lines[start:end]),
                occurrence=occurrence,
            )
        )
    return headings, blocks


def load_skill(skill_dir: str | Path) -> SkillDocument:
    root = Path(skill_dir).expanduser().resolve()
    skill_file = root / "SKILL.md"
    if not root.is_dir():
        raise SkillError(f"skill directory does not exist: {root}")
    if not skill_file.is_file():
        raise SkillError(f"missing SKILL.md: {skill_file}")
    try:
        text = skill_file.read_text(encoding="utf-8")
    except UnicodeDecodeError as error:
        raise SkillError("SKILL.md must be UTF-8") from error
    lines = text.splitlines()
    fields, frontmatter_end = parse_frontmatter(lines)
    for required in ("name", "description"):
        if required not in fields:
            raise SkillError(f"SKILL.md frontmatter is missing {required}")
    headings, blocks = parse_markdown(lines, frontmatter_end)
    return SkillDocument(
        root,
        skill_file,
        text,
        lines,
        fields,
        frontmatter_end,
        headings,
        blocks,
    )


def display_frontmatter_value(raw_field: str) -> str:
    _, value = raw_field.split(":", 1)
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "'\"":
        value = value[1:-1]
    return value


def iter_files(root: Path) -> Iterable[Path]:
    for directory, names, files in os.walk(root):
        names[:] = sorted(name for name in names if name not in {".git", "__pycache__"})
        for filename in sorted(files):
            yield Path(directory) / filename


def script_inventory(root: Path) -> list[dict[str, Any]]:
    scripts_dir = root / "scripts"
    if not scripts_dir.is_dir():
        return []
    scripts = []
    for path in iter_files(scripts_dir):
        relative = path.relative_to(root).as_posix()
        first_line = ""
        try:
            with path.open("r", encoding="utf-8") as handle:
                first_line = handle.readline().rstrip("\n")
        except OSError, UnicodeDecodeError:
            pass
        scripts.append(
            {
                "path": relative,
                "executable": os.access(path, os.X_OK),
                "shebang": first_line.startswith("#!"),
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
            }
        )
    return scripts


def transient_artifacts(root: Path) -> list[str]:
    artifacts: list[str] = []
    for directory, names, files in os.walk(root):
        names[:] = sorted(name for name in names if name != ".git")
        for name in list(names):
            if name in TRANSIENT_DIRECTORIES:
                path = Path(directory) / name
                artifacts.append(path.relative_to(root).as_posix())
                names.remove(name)
        for filename in sorted(files):
            path = Path(directory) / filename
            if filename in TRANSIENT_FILES or path.suffix in TRANSIENT_SUFFIXES:
                artifacts.append(path.relative_to(root).as_posix())
    return sorted(artifacts)


def local_links(document: SkillDocument) -> list[dict[str, Any]]:
    links: list[dict[str, Any]] = []
    root = document.root
    fence_marker: str | None = None
    for index in range(document.frontmatter_end + 1, len(document.lines)):
        line = document.lines[index]
        fence = FENCE_RE.match(line)
        if fence_marker is None and fence:
            fence_marker = fence.group(1)
            continue
        if fence_marker is not None:
            if closes_fence(line, fence_marker):
                fence_marker = None
            continue

        line_without_code = re.sub(r"`[^`]*`", "", line)
        raw_targets = [match.group(1) for match in LINK_RE.finditer(line_without_code)]
        reference = REFERENCE_LINK_RE.match(line_without_code)
        if reference:
            raw_targets.append(reference.group(1))
        for raw in raw_targets:
            target = raw[1:-1] if raw.startswith("<") and raw.endswith(">") else raw
            target = unquote(target)
            if target.startswith(("#", "http://", "https://", "mailto:", "data:")):
                continue
            file_part = target.split("#", 1)[0]
            if not file_part:
                continue
            candidate = (root / file_part).resolve()
            try:
                relative = candidate.relative_to(root).as_posix()
                inside = True
            except ValueError:
                relative = file_part
                inside = False
            links.append(
                {
                    "line": index + 1,
                    "target": target,
                    "path": relative,
                    "inside_skill": inside,
                    "exists": inside and candidate.exists(),
                }
            )
    return links


def workflow_sections(document: SkillDocument) -> list[dict[str, Any]]:
    return [
        {
            "line": heading.line,
            "end_line": heading.end_line,
            "level": heading.level,
            "title": heading.title,
        }
        for heading in document.headings
        if WORKFLOW_RE.search(heading.title)
    ]


def extraction_candidates(document: SkillDocument) -> list[dict[str, Any]]:
    candidates: list[dict[str, Any]] = []
    for block in document.code_blocks:
        if block.language in EXECUTABLE_LANGUAGES or block.body.startswith("#!"):
            candidates.append(
                {
                    "kind": "executable-code-block",
                    "line": block.line,
                    "end_line": block.end_line,
                    "language": block.language or "unspecified",
                    "closed": block.closed,
                }
            )
    candidates.extend(
        {
            "kind": "workflow-section",
            "line": section["line"],
            "end_line": section["end_line"],
            "title": section["title"],
        }
        for section in workflow_sections(document)
    )
    return sorted(candidates, key=lambda item: (item["line"], item["kind"]))


def inspect_payload(document: SkillDocument) -> dict[str, Any]:
    return {
        "skill": {
            "path": str(document.root),
            "name": display_frontmatter_value(document.frontmatter_fields["name"]),
            "description_sha256": sha256_text(
                document.frontmatter_fields["description"]
            ),
        },
        "headings": [
            {
                "line": heading.line,
                "end_line": heading.end_line,
                "level": heading.level,
                "title": heading.title,
            }
            for heading in document.headings
        ],
        "candidates": extraction_candidates(document),
        "links": local_links(document),
        "scripts": script_inventory(document.root),
        "transient_artifacts": transient_artifacts(document.root),
    }


def print_inspection(payload: dict[str, Any]) -> None:
    skill = payload["skill"]
    print(f"Skill: {skill['name']} ({skill['path']})")
    print(f"Candidates: {len(payload['candidates'])}")
    for candidate in payload["candidates"]:
        label = candidate.get("title") or candidate.get("language")
        print(
            f"  L{candidate['line']}-{candidate['end_line']} {candidate['kind']}: {label}"
        )
    print(f"Scripts: {len(payload['scripts'])}")
    for script in payload["scripts"]:
        flags = ",".join(
            name
            for name, enabled in (
                ("executable", script["executable"]),
                ("shebang", script["shebang"]),
            )
            if enabled
        )
        print(f"  {script['path']} [{flags or 'no-exec-metadata'}]")
    broken = [
        link
        for link in payload["links"]
        if not link["inside_skill"] or not link["exists"]
    ]
    print(f"Local links: {len(payload['links'])} ({len(broken)} invalid)")
    print(f"Transient artifacts: {len(payload['transient_artifacts'])}")


def select_protected_sections(
    document: SkillDocument, requested: list[str]
) -> list[dict[str, Any]]:
    requested_titles = {normalized_title(value).casefold() for value in requested}
    selected: list[dict[str, Any]] = []
    matched_requested: set[str] = set()
    for heading in document.headings:
        folded = heading.title.casefold()
        automatic = bool(CONTRACT_HEADING_RE.fullmatch(heading.title))
        explicit = folded in requested_titles
        if not automatic and not explicit:
            continue
        if explicit:
            matched_requested.add(folded)
        selected.append(
            {
                "level": heading.level,
                "title": heading.title,
                "occurrence": heading.occurrence,
                "line": heading.line,
                "sha256": sha256_text(heading.text),
                "text": heading.text,
            }
        )
    missing = sorted(requested_titles - matched_requested)
    if missing:
        raise SkillError(f"protected headings not found: {', '.join(missing)}")
    return selected


def select_protected_texts(
    document: SkillDocument, requested_ranges: list[str]
) -> list[dict[str, Any]]:
    selected: list[dict[str, Any]] = []
    for requested in requested_ranges:
        match = re.fullmatch(r"([1-9][0-9]*)(?::([1-9][0-9]*))?", requested)
        if not match:
            raise SkillError(f"invalid protected line range: {requested}")
        start = int(match.group(1))
        end = int(match.group(2) or start)
        if end < start or end > len(document.lines):
            raise SkillError(f"protected line range is outside SKILL.md: {requested}")
        protected_text = "\n".join(document.lines[start - 1 : end])
        if not protected_text.strip():
            raise SkillError(f"protected line range is empty: {requested}")
        if document.text.count(protected_text) != 1:
            raise SkillError(
                f"protected line range must select unique text: {requested}"
            )
        selected.append(
            {
                "line_start": start,
                "line_end": end,
                "sha256": sha256_text(protected_text),
                "text": protected_text,
            }
        )
    return selected


def baseline_payload(
    document: SkillDocument,
    protected_headings: list[str],
    protected_lines: list[str],
) -> dict[str, Any]:
    return {
        "schema_version": SCHEMA_VERSION,
        "skill": {
            "source_path": str(document.root),
            "name_field": document.frontmatter_fields["name"],
            "description_field": document.frontmatter_fields["description"],
        },
        "protected_sections": select_protected_sections(document, protected_headings),
        "protected_texts": select_protected_texts(document, protected_lines),
        "initial_scripts": [
            script["path"] for script in script_inventory(document.root)
        ],
    }


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    serialized = json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=True) + "\n"
    path.write_text(serialized, encoding="utf-8")


def find_protected_section(
    document: SkillDocument, expected: dict[str, Any]
) -> Heading | None:
    for heading in document.headings:
        if (
            heading.level == expected["level"]
            and heading.title == expected["title"]
            and heading.occurrence == expected["occurrence"]
        ):
            return heading
    return None


def verify_payload(
    document: SkillDocument,
    baseline: dict[str, Any],
    require_new_executable: bool,
) -> tuple[dict[str, Any], bool]:
    errors: list[str] = []
    warnings: list[str] = []
    checks: list[dict[str, Any]] = []

    if baseline.get("schema_version") != SCHEMA_VERSION:
        raise SkillError(
            f"unsupported baseline schema: {baseline.get('schema_version')!r}"
        )
    skill_contract = baseline.get("skill")
    if not isinstance(skill_contract, dict):
        raise SkillError("baseline is missing the skill contract")

    for field in ("name", "description"):
        expected = skill_contract.get(f"{field}_field")
        actual = document.frontmatter_fields.get(field)
        passed = actual == expected
        checks.append({"check": f"frontmatter:{field}", "passed": passed})
        if not passed:
            errors.append(f"frontmatter field changed: {field}")

    protected = baseline.get("protected_sections", [])
    protected_texts = baseline.get("protected_texts", [])
    if not protected and not protected_texts:
        warnings.append("baseline has no protected objective or deliverable text")
    for expected in protected:
        section = find_protected_section(document, expected)
        label = f"section:{expected['title']}#{expected['occurrence']}"
        passed = section is not None and sha256_text(section.text) == expected["sha256"]
        checks.append({"check": label, "passed": passed})
        if section is None:
            errors.append(f"protected section missing: {expected['title']}")
        elif not passed:
            errors.append(f"protected section changed: {expected['title']}")

    for expected in protected_texts:
        expected_text = expected["text"]
        label = f"text:L{expected['line_start']}-L{expected['line_end']}"
        passed = document.text.count(expected_text) == 1
        checks.append({"check": label, "passed": passed})
        if not passed:
            errors.append(
                "protected text changed or is no longer unique: "
                f"L{expected['line_start']}-L{expected['line_end']}"
            )

    links = local_links(document)
    for link in links:
        if not link["inside_skill"]:
            errors.append(
                f"local link escapes skill at line {link['line']}: {link['target']}"
            )
        elif not link["exists"]:
            errors.append(f"broken local link at line {link['line']}: {link['target']}")

    scripts_by_path = {item["path"]: item for item in script_inventory(document.root)}
    for link in links:
        path = link["path"]
        if (
            not link["inside_skill"]
            or not path.startswith("scripts/")
            or path not in scripts_by_path
        ):
            continue
        script = scripts_by_path[path]
        if Path(path).suffix in SCRIPT_SUFFIXES or script["shebang"]:
            if not script["shebang"]:
                errors.append(f"linked script lacks a shebang: {path}")
            if not script["executable"]:
                errors.append(f"linked script is not executable: {path}")

    transient = transient_artifacts(document.root)
    for path in transient:
        errors.append(f"transient artifact remains in target skill: {path}")

    initial_scripts = set(baseline.get("initial_scripts", []))
    new_executables = sorted(
        path
        for path, metadata in scripts_by_path.items()
        if path not in initial_scripts
        and metadata["executable"]
        and metadata["shebang"]
    )
    if require_new_executable and not new_executables:
        errors.append("no new executable with a shebang was extracted")

    checks.extend(
        [
            {
                "check": "local-links",
                "passed": not any("link" in error for error in errors),
            },
            {
                "check": "new-executable",
                "passed": bool(new_executables),
                "required": require_new_executable,
            },
            {"check": "transient-artifacts", "passed": not transient},
        ]
    )
    payload = {
        "status": "failed" if errors else "passed",
        "checks": checks,
        "errors": errors,
        "warnings": warnings,
        "new_executables": new_executables,
        "remaining_candidates": extraction_candidates(document),
    }
    return payload, not errors


def print_verification(payload: dict[str, Any]) -> None:
    print(f"Verification: {payload['status']}")
    for error in payload["errors"]:
        print(f"ERROR: {error}")
    for warning in payload["warnings"]:
        print(f"WARNING: {warning}")
    print(f"New executables: {len(payload['new_executables'])}")
    for path in payload["new_executables"]:
        print(f"  {path}")
    print(
        f"Remaining candidates for agent review: {len(payload['remaining_candidates'])}"
    )


def load_baseline(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise SkillError(f"baseline does not exist: {path}") from error
    except json.JSONDecodeError as error:
        raise SkillError(f"baseline is not valid JSON: {error}") from error
    if not isinstance(payload, dict):
        raise SkillError("baseline root must be an object")
    return payload


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Inventory a skill and verify deterministic workflow extraction."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    inspect_parser = subparsers.add_parser(
        "inspect", help="inventory extraction candidates"
    )
    inspect_parser.add_argument("skill_dir")
    inspect_parser.add_argument("--json", action="store_true", help="emit stable JSON")

    baseline_parser = subparsers.add_parser(
        "baseline", help="capture the semantic contract"
    )
    baseline_parser.add_argument("skill_dir")
    baseline_parser.add_argument("--output", type=Path, required=True)
    baseline_parser.add_argument(
        "--protect-heading",
        action="append",
        default=[],
        metavar="TITLE",
        help="protect an additional heading and its complete section; repeat as needed",
    )
    baseline_parser.add_argument(
        "--protect-lines",
        action="append",
        default=[],
        metavar="START[:END]",
        help="protect an exact, unique line range; repeat as needed",
    )

    verify_parser = subparsers.add_parser("verify", help="verify a refactored skill")
    verify_parser.add_argument("skill_dir")
    verify_parser.add_argument("--baseline", type=Path, required=True)
    verify_parser.add_argument(
        "--require-new-executable",
        action="store_true",
        help="fail unless the refactor adds an executable with a shebang",
    )
    verify_parser.add_argument("--json", action="store_true", help="emit stable JSON")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        document = load_skill(args.skill_dir)
        if args.command == "inspect":
            payload = inspect_payload(document)
            if args.json:
                print(json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=True))
            else:
                print_inspection(payload)
            return 0
        if args.command == "baseline":
            payload = baseline_payload(
                document, args.protect_heading, args.protect_lines
            )
            write_json(args.output.resolve(), payload)
            print(f"Baseline: {args.output.resolve()}")
            protected_count = len(payload["protected_sections"]) + len(
                payload["protected_texts"]
            )
            print(f"Protected contract entries: {protected_count}")
            return 0
        if args.command == "verify":
            payload, passed = verify_payload(
                document,
                load_baseline(args.baseline.resolve()),
                args.require_new_executable,
            )
            if args.json:
                print(json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=True))
            else:
                print_verification(payload)
            return 0 if passed else 1
    except (OSError, SkillError) as error:
        print(f"destochastic: {error}", file=sys.stderr)
        return 2
    raise AssertionError(f"unhandled command: {args.command}")


if __name__ == "__main__":
    raise SystemExit(main())
