"""Test the Git hook in disposable repositories."""

import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest


HOOK = Path(__file__).resolve().parents[1] / ".githooks" / "pre-commit"


class PreCommitTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="skills-hook-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "events"
        self.env = {
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "LC_ALL": "C",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
            "HOOK_LOG": str(self.log),
        }
        self.git("init", "--quiet")
        self.git("config", "core.hooksPath", str(HOOK.parent))
        prettier = self.bin / "prettier"
        prettier.write_text(
            "#!/usr/bin/env bash\n"
            'printf \'prettier:%s:%s\\n\' "$1" "$2" >> "$HOOK_LOG"\n'
            'exit "${FORMAT_STATUS:-0}"\n'
        )
        prettier.chmod(0o755)

    def git(self, *args, cwd=None, check=True):
        return subprocess.run(
            ["git", *args],
            cwd=cwd or self.repo,
            env=self.env,
            check=check,
            capture_output=True,
            text=True,
        )

    def update(self, path, event, extra=""):
        script = self.repo / path
        script.parent.mkdir(parents=True, exist_ok=True)
        script.write_text(
            "#!/usr/bin/env bash\nset -eu\n"
            f'test "$PWD" = {shlex.quote(str(self.repo))}\n'
            f"printf '%s\\n' {shlex.quote(event)} >> \"$HOOK_LOG\"\n" + extra
        )

    def events(self):
        return self.log.read_text().splitlines() if self.log.exists() else []

    def test_runs_all_updates_before_prettier_from_a_subdirectory(self):
        paths = [
            (".hidden/scripts/update.sh", "hidden"),
            ("a skill/scripts/update.sh", "space"),
            ("nested/new\nline/scripts/update.sh", "newline"),
            ("scripts/update.sh", "root"),
        ]
        for path, event in paths:
            self.update(path, event)
        self.update(".git/scripts/update.sh", "git-internal")
        nested = self.repo / "nested"
        self.git("hook", "run", "pre-commit", cwd=nested)
        self.assertEqual(
            self.events(), ["hidden", "space", "newline", "root", "prettier:--write:."]
        )

    def test_no_updates_still_runs_prettier(self):
        self.git("hook", "run", "pre-commit")
        self.assertEqual(self.events(), ["prettier:--write:."])

    def test_update_failure_stops_later_updates_and_prettier(self):
        self.update("a/scripts/update.sh", "failed", "exit 17\n")
        self.update("b/scripts/update.sh", "later")
        result = self.git("hook", "run", "pre-commit", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.events(), ["failed"])

    def test_prettier_failure_fails_the_hook(self):
        self.env["FORMAT_STATUS"] = "19"
        result = self.git("hook", "run", "pre-commit", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.events(), ["prettier:--write:."])

    def test_generated_changes_do_not_change_the_index(self):
        source = self.repo / "source.txt"
        source.write_text("staged\n")
        self.git("add", "source.txt")
        index = self.repo / ".git" / "index"
        before = index.read_bytes()
        self.update(
            "skill/scripts/update.sh", "updated", "printf 'updated\\n' > source.txt\n"
        )
        self.git("hook", "run", "pre-commit")
        self.assertEqual(index.read_bytes(), before)
        self.assertEqual(source.read_text(), "updated\n")
        self.assertEqual(self.git("show", ":source.txt").stdout, "staged\n")

    @unittest.skipUnless(shutil.which("prettier"), "Prettier is not installed.")
    def test_real_prettier_formats_generated_output(self):
        (self.bin / "prettier").unlink()
        self.update(
            "skill/scripts/update.sh",
            "generated",
            "printf '{\"value\":1}' > generated.json\n",
        )
        self.git("hook", "run", "pre-commit")
        self.assertEqual((self.repo / "generated.json").read_text(), '{ "value": 1 }\n')


if __name__ == "__main__":
    unittest.main()
