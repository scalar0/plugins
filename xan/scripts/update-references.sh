#!/usr/bin/env bash
set -euo pipefail

DIR=$(git rev-parse --show-toplevel)/xan/references

xan help > $DIR/help.md && \
xan help cheatsheet --md > $DIR/cheatsheet.md && \
xan help functions --md > $DIR/functions.md