#!/bin/bash

PRECHECK="precheck.txt"
POSTCHECK="postcheck.txt"
ignoreparameters="uptime|date|Mem|Swap|CPU Load"

echo "===== Lines removed in postcheck (pre only) ====="
grep -viE "$ignoreparameters" "$PRECHECK" \
    | grep -Fxv -f <(grep -viE "$ignoreparameters" "$POSTCHECK")

echo "===== Lines added in postcheck (post only) ====="
grep -viE "$ignoreparameters" "$POSTCHECK" \
    | grep -Fxv -f <(grep -viE "$ignoreparameters" "$PRECHECK")