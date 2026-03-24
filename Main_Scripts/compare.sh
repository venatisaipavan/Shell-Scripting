#!/bin/bash

h=$HOSTNAME
latest_dir=$(ls -td /root/"$h"_patching_checks_* 2>/dev/null | head -1)

PRECHECK=$latest_dir/precheck.txt
POSTCHECK=$latest_dir/postcheck.txt

#PRECHECK="$latest_dir"/"precheck.txt"
#POSTCHECK="$latest_dir"/"postcheck.txt"
ignoreparameters="uptime|date|Mem|Swap|CPU Load"

echo "===== Lines removed in postcheck (pre only) ====="
grep -viE "$ignoreparameters" "$PRECHECK" \
            | grep -Fxv -f <(grep -viE "$ignoreparameters" "$POSTCHECK")

echo "===== Lines added in postcheck (post only) ====="
grep -viE "$ignoreparameters" "$POSTCHECK" \
            | grep -Fxv -f <(grep -viE "$ignoreparameters" "$PRECHECK")
