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

EMU_START_COMMAND="firebase emulators:start --only auth,firestore,functions --project react-native-firebase-testing"

IS_CI="${CI}${CONTINUOUS_INTEGRATION}${BUILD_NUMBER}${RUN_ID}"
if [[ -n "${IS_CI}" ]]; then
  $EMU_START_COMMAND &
  until curl --output /dev/null --silent --fail http://localhost:8080; do
    echo "Waiting for Firebase emulator to come online..."
    sleep 2
  done
  echo "Firebase emulator is online!"
else
  $EMU_START_COMMAND
fi
