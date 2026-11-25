#!/usr/bin/env bash
# iOS twin of flutter-test-android-retry.sh, matching the wrapper embedded in
# reusable_e2e_ios.yaml. `flutter test` against an Apple simulator can fail
# before any test runs ("Unable to start the app on the device", empty
# xcodebuild settings, or a zero-output hang). Bound each attempt with an
# alarm, retry that launch-failure shape, recycle the simulator on the last
# try, and trust only the runner's numeric tally for the verdict.
set -euo pipefail

: "${TEST_TARGET:?TEST_TARGET is required}"
: "${SIMULATOR:?SIMULATOR is required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_flutter_test() {
  rm -f flutter_test_output.log
  # File redirect, never capture: iOS spawns log streamers that hold a
  # captured pipe open forever. The alarm ($1) bounds the known zero-output
  # hang well below the step timeout.
  perl -e 'alarm shift; exec @ARGV' "$1" \
    flutter test "$TEST_TARGET" -d "$SIMULATOR" --timeout 10x --dart-define=CI=true \
    > flutter_test_output.log 2>&1
  FT_EXIT=$?
  cat flutter_test_output.log
}

attempt_failed() {
  { ! grep -Eq '[0-9]+ tests? passed' flutter_test_output.log && ! grep -Eq '[0-9]+ failed' flutter_test_output.log; } \
    || grep -q "Unable to start the app on the device" flutter_test_output.log
}

set +e
run_flutter_test 900
if attempt_failed; then
  echo "Launch failure - retrying (attempt 2/3)."
  echo "::group::Simulator log around the hang (Runner)"
  perl -e 'alarm shift; exec @ARGV' 90 \
    xcrun simctl spawn "$SIMULATOR" log show --last 16m --style compact \
    --predicate 'process == "Runner" OR eventMessage CONTAINS "Runner"' 2>/dev/null | tail -80 || true
  echo "::endgroup::"
  run_flutter_test 600
fi
if attempt_failed; then
  echo "Launch failure - recycling the simulator and retrying (attempt 3/3)."
  xcrun simctl shutdown "$SIMULATOR" 2>/dev/null || true
  xcrun simctl erase "$SIMULATOR" 2>/dev/null || true
  xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
  "${SCRIPT_DIR}/ensure-simulator-ready.sh" || true
  run_flutter_test 600
fi

# Trust only the runner's own tally, parsed numerically. Substring checks are
# how '0 tests passed, 1 failed' once laundered into a green job.
PASSED=$(grep -Eo '[0-9]+ tests? passed' flutter_test_output.log | tail -1 | grep -Eo '^[0-9]+')
FAILED=$(grep -Eo '[0-9]+ failed' flutter_test_output.log | tail -1 | grep -Eo '^[0-9]+')
: "${PASSED:=0}"; : "${FAILED:=0}"
echo "Result tally: passed=$PASSED failed=$FAILED (flutter test exit $FT_EXIT)"
if [ "$FAILED" -gt 0 ] || [ "$PASSED" -eq 0 ]; then
  exit 1
fi
if [ "$FT_EXIT" -ne 0 ]; then
  echo "All $PASSED tests passed; tolerating flutter test exit $FT_EXIT (simulator foreground quirk)."
fi
exit 0
