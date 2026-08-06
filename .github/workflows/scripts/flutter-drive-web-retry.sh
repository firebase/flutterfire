#!/usr/bin/env bash
set -euo pipefail

: "${FLUTTER_DRIVE_TARGET:?FLUTTER_DRIVE_TARGET is required}"
: "${FLUTTER_DRIVE_DRIVER:?FLUTTER_DRIVE_DRIVER is required}"

FLUTTER_DRIVE_DEVICE="${FLUTTER_DRIVE_DEVICE:-chrome}"
FLUTTER_DRIVE_TIMEOUT_SECONDS="${FLUTTER_DRIVE_TIMEOUT_SECONDS:-180}"
FLUTTER_DRIVE_MAX_ATTEMPTS="${FLUTTER_DRIVE_MAX_ATTEMPTS:-4}"
FLUTTER_DRIVE_EXTRA_ARGS="${FLUTTER_DRIVE_EXTRA_ARGS:-}"

# The embedded Python reads these from its environment; without the export a
# variable defaulted above is invisible to it, the KeyError kills the run
# before flutter drive starts, and on macOS (bash 3.2) that failure was
# silently swallowed — the job went green having run zero tests.
export FLUTTER_DRIVE_TARGET FLUTTER_DRIVE_DRIVER FLUTTER_DRIVE_DEVICE \
  FLUTTER_DRIVE_TIMEOUT_SECONDS FLUTTER_DRIVE_MAX_ATTEMPTS FLUTTER_DRIVE_EXTRA_ARGS

cleanup_web_processes() {
  # Chrome's process name differs per OS: "Google Chrome" on macOS,
  # "chrome"/"google-chrome" on Linux.
  pkill -f "Google Chrome" || true
  pkill -f "google-chrome" || true
  pkill -x chrome || true
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
  # Wait for chromedriver to accept connections instead of a fixed sleep.
  for _ in $(seq 1 30); do
    if curl --output /dev/null --silent --fail http://localhost:4444/status; then
      break
    fi
    if ! kill -0 "$chromedriver_pid" 2>/dev/null; then
      echo "chromedriver exited before becoming ready."
      return 3
    fi
    sleep 1
  done

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

  # output.log may not exist if the drive process died before writing it.
  output=$(cat output.log 2>/dev/null || true)
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
