#!/usr/bin/env bash
# Rebuild the .tgz archives that are stored here as .partNN pieces.
# Usage: ./reassemble.sh        (run from newly_trained_models/)
set -euo pipefail
cd "$(dirname "$0")"

fail=0
while read -r path size nparts sum; do
    case "$path" in '#'*|'') continue;; esac

    if [ -f "$path" ] && [ "$(stat -c%s "$path")" = "$size" ]; then
        echo "ok (already present)  $path"
        continue
    fi

    found=$(ls "$path".part?? 2>/dev/null | wc -l)
    if [ "$found" -ne "$nparts" ]; then
        echo "MISSING parts for $path ($found of $nparts found)" >&2
        fail=1
        continue
    fi

    cat "$path".part?? > "$path"
    got=$(sha256sum "$path" | cut -d' ' -f1)
    if [ "$got" != "$sum" ]; then
        echo "CHECKSUM MISMATCH  $path" >&2
        echo "  expected $sum" >&2
        echo "  got      $got" >&2
        fail=1
    else
        echo "ok  $path  ($nparts parts, $size bytes)"
    fi
done < PARTS.manifest

[ "$fail" = 0 ] || { echo "one or more archives failed" >&2; exit 1; }
echo "all archives rebuilt"
