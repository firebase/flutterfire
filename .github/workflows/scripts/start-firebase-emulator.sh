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
  cd functions && npm i && cd ..
fi

export STORAGE_EMULATOR_DEBUG=true
EMU_START_COMMAND="firebase emulators:start --only auth,firestore,functions,storage --project react-native-firebase-testing"

MAX_RETRIES=3
MAX_CHECKATTEMPTS=60
CHECKATTEMPTS_WAIT=1

RETRIES=1
while [ $RETRIES -le $MAX_RETRIES ]; do

  if [[ -n "${IS_CI}" ]]; then
    echo "Starting Firebase Emulator Suite in foreground."
    $EMU_START_COMMAND
    exit 0
  else
    echo "Starting Firebase Emulator Suite in background."
    $EMU_START_COMMAND &
    CHECKATTEMPTS=1
    while [ $CHECKATTEMPTS -le $MAX_CHECKATTEMPTS ]; do
      sleep $CHECKATTEMPTS_WAIT
      if curl --output /dev/null --silent --fail http://localhost:8080; then
        echo "Firebase Emulator Suite is online!"
        exit 0;
      fi
      echo "Waiting for Firebase Emulator Suite to come online, check $CHECKATTEMPTS of $MAX_CHECKATTEMPTS..."
      ((CHECKATTEMPTS = CHECKATTEMPTS + 1))
    done
  fi

  echo "Firebase Emulator Suite did not come online in $MAX_CHECKATTEMPTS checks. Try $RETRIES of $MAX_RETRIES."
  ((RETRIES = RETRIES + 1))

done
echo "Firebase Emulator Suite did not come online after $MAX_RETRIES attempts."
exit 1