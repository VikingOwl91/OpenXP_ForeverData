#!/usr/bin/env bash
# Rebuild Data.lua from ForeverDB's current data and OpenXP's guides.
#   rebuild.sh OPENXP_CHECKOUT
# Run from the root of this repository. Prints "changed=true" when the quest
# data differs from what is committed, "changed=false" otherwise (the working
# tree is put back then).
set -euo pipefail

openxp=$1
here=$(pwd)
[ "$(basename "$here")" = OpenXP_ForeverData ] || { echo "the checkout has to be named OpenXP_ForeverData" >&2; exit 1; }

compiler="$openxp/tools/compile_foreverdb.py"
if [ ! -f "$compiler" ]; then
    echo "::warning::$openxp has no tools/compile_foreverdb.py yet, nothing rebuilt"
    echo "changed=false"
    exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
python3 "$here/.github/scripts/fetch_foreverdb.py" --out "$work"
python3 "$openxp/tests/test_compiler.py"

before=$(grep -c '^\[[0-9]*\]=' Data.lua || true)
python3 "$compiler" --foreverdb "$work/ForeverDB" --guides "$openxp/Guides" --out "$(dirname "$here")"
after=$(grep -c '^\[[0-9]*\]=' Data.lua || true)
if [ "$after" -lt $((before * 9 / 10)) ]; then
    echo "Data.lua went from $before to $after quests: not releasing that" >&2
    exit 1
fi

# a new data version alone, with the same quest data, is no reason for a release
if git diff --quiet -I'^version=' -I'^build=' -- Data.lua && git diff --quiet -- LICENSE.txt COPYING.txt; then
    git checkout -q -- .
    echo "changed=false"
else
    echo "changed=true"
fi
