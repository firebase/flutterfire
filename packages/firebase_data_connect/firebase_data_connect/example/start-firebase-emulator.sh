#!/bin/bash
set -euo pipefail

LOG_FILE="${TMPDIR:-/tmp}/flutterfire-fdc-emulators.log"
rm -f "$LOG_FILE"

firebase emulators:start --project flutterfire-e2e-tests >"$LOG_FILE" 2>&1 &
FIREBASE_PID=$!

for _ in {1..90}; do
  if ! kill -0 "$FIREBASE_PID" 2>/dev/null; then
    echo "Firebase emulators exited before becoming ready."
    cat "$LOG_FILE"
    wait "$FIREBASE_PID"
    exit 1
  fi

  if grep -q "All emulators ready" "$LOG_FILE"; then
    cat "$LOG_FILE"
    exit 0
  fi

  sleep 1
done

echo "Timed out waiting for Firebase emulators to become ready."
cat "$LOG_FILE"
exit 1
