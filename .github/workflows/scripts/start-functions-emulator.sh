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

IS_CI="${CI}${CONTINUOUS_INTEGRATION}${BUILD_NUMBER}${RUN_ID}"
if [[ -n "${IS_CI}" ]]; then
  firebase emulators:start --only functions &
  until curl --output /dev/null --head --silent http://localhost:5001; do
    echo "Waiting for Functions emulator to come online..."
    sleep 2
  done
  echo "Functions emulator is online!"
else
  firebase emulators:start --only functions
fi
