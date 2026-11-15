#!/usr/bin/env bash
# Rebuild Data.lua from ForeverDB's current data and OpenXP's guides.
#   rebuild.sh OPENXP_CHECKOUT
# Run from the root of this repository. Prints "changed=true" when the result
# is worth a release, "changed=false" otherwise (the working tree is put back
# then).
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

# What makes a release: a rule, level, giver, licence or toc change. Players keep
# reporting the same spot a fraction of a percent apart, so positions alone
# only make one when the last data commit is a week old.
rules() { sed -E -e '/^(version|build)=/d' -e 's/,[0-9.]+,[0-9.]+\}/}/g' "$@"; }
age=$(( ($(date +%s) - $(git log -1 --format=%ct -- Data.lua)) / 86400 ))
if ! git diff --quiet -- LICENSE.txt COPYING.txt; then
    echo "changed=true"
elif ! git diff --quiet -I'^## Version:' -- OpenXP_ForeverData.toc; then
    echo "changed=true"
elif ! cmp -s <(git show HEAD:Data.lua | rules) <(rules Data.lua); then
    echo "changed=true"
elif [ "$age" -ge 7 ] && ! git diff --quiet -I'^version=' -I'^build=' -- Data.lua; then
    echo "changed=true"
else
    git checkout -q -- .
    echo "changed=false"
fi
