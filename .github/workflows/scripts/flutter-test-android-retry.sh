#!/usr/bin/env bash
# Android twin of the Apple wrapper embedded in reusable_e2e_ios/macos.yaml:
# `flutter test` against the AVD occasionally hangs after `assembleDebug`
# without printing a single line (the app never launches), which used to burn
# the whole step timeout and kill the job. Bound each attempt with an alarm,
# retry the zero-output shape once inside the same booted AVD, and trust only
# the runner's numeric tally for the verdict.
set -euo pipefail

: "${TEST_TARGET:?TEST_TARGET is required}"

run_flutter_test() {
  rm -f flutter_test_output.log
  # File redirect, never capture, so a stray child holding the pipe cannot
  # block us. The alarm bounds the known zero-output launch hang well below
  # the step timeout, leaving room for the retry.
  perl -e 'alarm shift; exec @ARGV' 900 \
    flutter test "$TEST_TARGET" --timeout 10x --dart-define=CI=true -d emulator-5554 \
    > flutter_test_output.log 2>&1
  FT_EXIT=$?
  cat flutter_test_output.log
}

set +e
run_flutter_test
# Retry once when no tally exists at all: the launch hang (alarm kill) and
# "Error connecting to the service protocol" both fail before any test runs.
if ! grep -Eq '[0-9]+ tests? passed' flutter_test_output.log \
   && ! grep -Eq '[0-9]+ failed' flutter_test_output.log; then
  echo "Infrastructure launch failure detected - retrying once."
  run_flutter_test
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
exit 0
