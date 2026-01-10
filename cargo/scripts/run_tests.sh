#!/usr/bin/env bash
set -euo pipefail

# Enforce repo test contract using nextest + coverage per AGENTS.md.

export NO_COLOR=1
export NEXTEST_SHOW_PROGRESS=none
export CARGO_TERM_COLOR=never

cargo llvm-cov nextest --profile=agent --workspace --all-targets --all-features > /dev/null 2>&1 || true

# Pretty print summary like test.sh
root=$(git rev-parse --show-toplevel)
cat "$root/target/nextest/agent/junit-agent.xml" \
| yq -px -oj --xml-attribute-prefix="" \
| jq -M '.testsuites |{fail_ratio: .failures + "/" + .tests,fail_tests:[(.testsuite[]| select((.failures | tonumber != 0) or (.errors | tonumber != 0))| .testcase[] | select(.failure != null)) |{class:.classname,name:.name,failure: {type:.failure.type, "system-out":."system-out","system-err":."system-err"}}]}'
