#!/usr/bin/env bash
set -euo pipefail

: "${FLUTTER_DRIVE_TARGET:?FLUTTER_DRIVE_TARGET is required}"
: "${FLUTTER_DRIVE_DRIVER:?FLUTTER_DRIVE_DRIVER is required}"

FLUTTER_DRIVE_DEVICE="${FLUTTER_DRIVE_DEVICE:-chrome}"
FLUTTER_DRIVE_TIMEOUT_SECONDS="${FLUTTER_DRIVE_TIMEOUT_SECONDS:-180}"
FLUTTER_DRIVE_MAX_ATTEMPTS="${FLUTTER_DRIVE_MAX_ATTEMPTS:-4}"
FLUTTER_DRIVE_EXTRA_ARGS="${FLUTTER_DRIVE_EXTRA_ARGS:-}"

cleanup_web_processes() {
  pkill -f "Google Chrome" || true
  pkill -f chrome_crashpad || true
  pkill -x chromedriver || true
  pkill -x dartvm || true
  pkill -x dartaotruntime || true
}

run_tests() {
  rm -f output.log
  cleanup_web_processes

  chromedriver --port=4444 --trace-buffer-size=100000 &
  chromedriver_pid=$!
  sleep 2

  set +e
  python3 - <<'PY'
import os
import shlex
import subprocess
import sys


def normalize_output(output):
    if output is None:
        return ''
    if isinstance(output, bytes):
        return output.decode(errors='replace')
    return output


command = [
    'flutter',
    'drive',
    f"--target={os.environ['FLUTTER_DRIVE_TARGET']}",
    f"--driver={os.environ['FLUTTER_DRIVE_DRIVER']}",
    '-d',
    os.environ['FLUTTER_DRIVE_DEVICE'],
    *shlex.split(os.environ.get('FLUTTER_DRIVE_EXTRA_ARGS', '')),
]

try:
    completed = subprocess.run(
        command,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=int(os.environ['FLUTTER_DRIVE_TIMEOUT_SECONDS']),
    )
except subprocess.TimeoutExpired as error:
    output = normalize_output(error.stdout)
    print(output, end='')
    with open('output.log', 'w') as file:
        file.write(output)
    print('flutter drive timed out before tests completed.')
    sys.exit(124)

output = normalize_output(completed.stdout)
print(output, end='')
with open('output.log', 'w') as file:
    file.write(output)
sys.exit(completed.returncode)
PY
  exit_code=$?
  set -e

  kill "$chromedriver_pid" 2>/dev/null || true
  wait "$chromedriver_pid" 2>/dev/null || true
  cleanup_web_processes

  output=$(<output.log)
  if [[ "$output" =~ \[E\] ]]; then
    # You will see "All tests passed." in the logs even when tests failed.
    echo "All tests did not pass. Please check the logs for more information."
    return 2
  fi

  if [[ "$exit_code" == "124" ]] ||
     [[ "$output" == *"AppConnectionException"* ]] ||
     [[ "$output" == *"Failed to exit Chromium"* ]]; then
    return 3
  fi

  return "$exit_code"
}

for attempt in $(seq 1 "$FLUTTER_DRIVE_MAX_ATTEMPTS"); do
  if run_tests; then
    exit 0
  fi

  exit_code=$?
  if [[ "$exit_code" != "3" || "$attempt" == "$FLUTTER_DRIVE_MAX_ATTEMPTS" ]]; then
    exit "$exit_code"
  fi

  echo "Attempt $attempt failed before tests completed. Retrying with clean browser processes..."
done
