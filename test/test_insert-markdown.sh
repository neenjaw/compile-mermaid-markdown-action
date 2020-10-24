#!/usr/bin/env bash

set -euo pipefail

BASENAME=$(basename "$0")
CANONICAL_SCRIPT=$(readlink -e "$0")
SCRIPT_DIR=$(dirname "${CANONICAL_SCRIPT}")
ROOT_DIR=$(dirname "${SCRIPT_DIR}")

function test_simple_awk_replace {
  insert_markdown_awk="${ROOT_DIR}/insert-markdown.awk"
  image_path="img/gray-flow.png"
  awk -v n="1" \
      -v path="${image_path}" \
      -v codeblock_action="replace" \
      -f "${insert_markdown_awk}" \
      "${SCRIPT_DIR}/simple.md" > "/tmp/simple.md.actual"
  diff "${SCRIPT_DIR}/simple.md.expected" "/tmp/simple.md.actual"
}

test_simple_awk_replace
