#!/bin/bash
if ! [ -x "$(command -v firebase)" ]; then
  echo "❌ Firebase tools CLI is missing."
  exit 1
fi

if ! [ -x "$(command -v node)" ]; then
  echo "❌ Node.js is missing."
  exit 1
fi

if ! [ -x "$(command -v npm)" ]; then
  echo "❌ NPM is missing."
  exit 1
fi

# Run NPM install if node modules does not exist.
if [[ ! -d "functions/node_modules" ]]; then
  cd functions
  if npm i; then
    echo "✅ NPM install successful."
  else
    if [[ -z "${CI}" ]]; then
      echo "❌ NPM install failed."
      exit 1
    else
      # TODO temporary workaround for GitHub Actions CI issue:
      # npm ERR! Your cache folder contains root-owned files, due to a bug in
      # npm ERR! previous versions of npm which has since been addressed.
      # macOS runners only; on Linux the directory doesn't exist.
      if [[ -d "/Users/runner/.npm" ]]; then
        sudo chown -R 501:20 "/Users/runner/.npm" || exit 1
      fi
      npm i || exit 1
    fi
  fi
  cd ..
fi

export STORAGE_EMULATOR_DEBUG=true
EMU_START_COMMAND="firebase emulators:start --only auth,firestore,functions,storage,database --project flutterfire-e2e-tests"

if [[ -z "${CI}" ]]; then
  echo "Starting Firebase Emulator Suite in foreground."
  $EMU_START_COMMAND
  exit 0
fi

# Waiting on the "All emulators ready" log line covers every emulator in the
# suite; probing a single port (the old approach) let tests start while Auth,
# Storage, Database or Functions were still binding.
LOG_FILE="firebase-emulator.log"
MAX_CHECKATTEMPTS=120

echo "Starting Firebase Emulator Suite in background."
$EMU_START_COMMAND >"$LOG_FILE" 2>&1 &
EMU_PID=$!

CHECKATTEMPTS=1
while [ $CHECKATTEMPTS -le $MAX_CHECKATTEMPTS ]; do
  if ! kill -0 "$EMU_PID" 2>/dev/null; then
    echo "❌ Firebase Emulator process exited before becoming ready. Log output:"
    cat "$LOG_FILE"
    exit 1
  fi
  if grep -q "All emulators ready" "$LOG_FILE"; then
    echo "Firebase Emulator Suite is online!"
    exit 0
  fi
  echo "Waiting for Firebase Emulator Suite to come online, check $CHECKATTEMPTS of $MAX_CHECKATTEMPTS..."
  sleep 1
  ((CHECKATTEMPTS = CHECKATTEMPTS + 1))
done

echo "❌ Firebase Emulator Suite did not come online in $MAX_CHECKATTEMPTS seconds. Log output:"
cat "$LOG_FILE"
kill "$EMU_PID" 2>/dev/null
exit 1
