#!/bin/bash
set -euo pipefail

LOG_FILE="${TMPDIR:-/tmp}/flutterfire-fdc-emulators.log"
rm -f "$LOG_FILE"

print_emulator_logs() {
  cat "$LOG_FILE"

  if [ -f firebase-debug.log ]; then
    echo
    echo "firebase-debug.log:"
    cat firebase-debug.log
  fi

  if [ -f dataconnect-debug.log ]; then
    echo
    echo "dataconnect-debug.log:"
    cat dataconnect-debug.log
  fi
}

firebase emulators:start --project flutterfire-e2e-tests >"$LOG_FILE" 2>&1 &
FIREBASE_PID=$!

for _ in {1..90}; do
  if ! kill -0 "$FIREBASE_PID" 2>/dev/null; then
    echo "Firebase emulators exited before becoming ready."
    print_emulator_logs
    wait "$FIREBASE_PID"
    exit 1
  fi

  if grep -q "All emulators ready" "$LOG_FILE"; then
    print_emulator_logs
    exit 0
  fi

  sleep 1
done

echo "Timed out waiting for Firebase emulators to become ready."
print_emulator_logs
exit 1
