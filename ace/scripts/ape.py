#!/usr/bin/env python3
"""Run the APE CLI via its Docker image.

This wrapper mirrors the container entrypoint CLI by forwarding all
arguments and I/O to `docker run` with sane defaults. It also provides
local `-help` output that matches the APE help text.

Environment variables:
- APE_DOCKER_IMAGE: Docker image tag to run (default: grace:latest).
- APE_DOCKER_ARGS: Extra arguments to pass to `docker run`.
- APE_DOCKER_WORKDIR: Container working directory (default: /work).
- APE_DOCKER_MOUNT: Set to "0" or "false" to disable mounting $PWD.
- APE_DOCKER_USER: Override the user passed to `docker run --user`.
"""

from __future__ import annotations

import os
import shlex
import shutil
import subprocess
import sys
from typing import List


HELP_TEXT = """Attempto Parsing Engine for ACE 6.7, version 6.7.180715
Copyright 2008-2013, Attempto Group, University of Zurich
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain conditions.
Please visit http://attempto.ifi.uzh.ch for details.

Command-line arguments:
-text \"TEXT\"        The input ACE text. If neither -text nor -file is present then the ACE text is read from stdin.
-file FILENAME      The name or URL of the input file containing the ACE text.
-ulextext \"TEXT\"    The user lexicon (taken from a string).
-ulexfile FILENAME  The user lexicon (taken from a file or URL).
-solo OUTPUT        Output just one output component. OUTPUT has to be one of {paraphrase,paraphrase1,paraphrase2,owlfss,owlfsspp,owlrdf,owlxml,ruleml,fol,pnf,tptp,tokens,syntax,syntaxpp,syntaxd,syntaxdpp,drs,drsxml,drspp,drshtml}.
-cdrs               Output the DRS as a Prolog term.
-cdrsxml            Output the DRS in XML.
-cdrspp             Output the DRS in pretty-printed form in plain text.
-cdrshtml           Output the DRS in pretty-printed form in HTML.
-cparaphrase        Output a paraphrase which is a \"best-effort\" combination of paraphrase1 and paraphrase2.
-cparaphrase1       Output a paraphrase which uses full sentences instead of relative clauses.
-cparaphrase2       Output a paraphrase which uses relative clauses instead of full sentences.
-ctokens            Output tokens as a Prolog list of lists.
-csentences         Output sentences as a Prolog list.
-csyntax            Output simplified syntax trees as a Prolog list.
-csyntaxpp          Output simplified syntax trees in pretty-printed form.
-csyntaxd           Output plain syntax trees as a Prolog list (for debugging).
-csyntaxdpp         Output plain syntax trees in pretty-printed form (for debugging).
-cowlfss            Output OWL/SWRL in the Functional-Style Syntax representation (as Prolog term).
-cowlfsspp          Output OWL/SWRL in the Functional-Style Syntax representation (pretty-printed).
-cowlxml            Output OWL/SWRL in the XML representation.
-cowlrdf            Output OWL/SWRL in the RDF/XML representation. DEPRECATED
-cruleml            Output RuleML representation of the DRS.
-cfol               Output standard first-order logic representations (default form) of the DRS as a Prolog term.
-cpnf               Output standard first-order logic representations (prenex normal form) of the DRS as a Prolog term.
-ctptp              Output TPTP representation of the DRS.
-uri URI            URI for the OWL outputs.
-noclex             Ignore the lexicon entries that are compiled into the executable.
-guess              Guess the word-class of unknown words.
-server             Launch a socket interface to APE at port 2766 (0xACE).
-httpserver         Launch an HTTP interface to APE at port 8000.
-port NUMBER        Override the default port of either the socket or the HTTP interface.
-version            Shows version information.
-help               Shows this help page.
"""


def _truthy(value: str | None) -> bool:
    if value is None:
        return True
    return value.strip().lower() not in {"0", "false", "no", "off"}


def _docker_available() -> bool:
    return shutil.which("docker") is not None


def _tty_flags() -> List[str]:
    stdin_tty = sys.stdin.isatty()
    stdout_tty = sys.stdout.isatty()
    stderr_tty = sys.stderr.isatty()

    flags = ["-i"]
    if stdin_tty and stdout_tty and stderr_tty:
        flags.append("-t")
    return flags


def _default_user() -> str | None:
    try:
        uid = os.getuid()
        gid = os.getgid()
    except AttributeError:
        return None
    return f"{uid}:{gid}"


def _normalize_args(args: List[str]) -> List[str]:
    normalized = []
    for arg in args:
        if arg == "--help":
            normalized.append("-help")
        elif arg == "--version":
            normalized.append("-version")
        else:
            normalized.append(arg)
    return normalized


def build_docker_command(argv: List[str]) -> List[str]:
    image = os.environ.get("APE_DOCKER_IMAGE", "grace:latest")
    workdir = os.environ.get("APE_DOCKER_WORKDIR", "/work")
    mount_enabled = _truthy(os.environ.get("APE_DOCKER_MOUNT"))
    extra_args = shlex.split(os.environ.get("APE_DOCKER_ARGS", ""))

    command: List[str] = ["docker", "run", "--rm"]
    command.extend(_tty_flags())

    user_override = os.environ.get("APE_DOCKER_USER")
    user_value = user_override if user_override else _default_user()
    if user_value:
        command.extend(["--user", user_value])

    if mount_enabled:
        cwd = os.getcwd()
        command.extend(["-v", f"{cwd}:{workdir}", "-w", workdir])

    if extra_args:
        command.extend(extra_args)

    command.append(image)
    command.extend(argv)
    return command


def main() -> int:
    args = _normalize_args(sys.argv[1:])
    if "-help" in args:
        sys.stdout.write(HELP_TEXT)
        return 0

    if not _docker_available():
        sys.stderr.write("docker is not available on PATH.\n")
        return 127

    command = build_docker_command(args)
    try:
        return subprocess.call(command)
    except FileNotFoundError:
        sys.stderr.write("Failed to execute docker. Is it installed?\n")
        return 127


if __name__ == "__main__":
    raise SystemExit(main())
