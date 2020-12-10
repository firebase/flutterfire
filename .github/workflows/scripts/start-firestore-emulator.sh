#!/bin/bash
if ! [ -x "$(command -v firebase)" ]; then
  echo "❌ Firebase tools CLI is missing."
  exit 1
fi

IS_CI="${CI}${CONTINUOUS_INTEGRATION}${BUILD_NUMBER}${RUN_ID}"
if [[ -n "${IS_CI}" ]]; then
  firebase emulators:start --only firestore &
  until curl --output /dev/null --silent --fail http://localhost:8080; do
    echo "Waiting for Firestore emulator to come online..."
    sleep 2
  done
  echo "Firestore emulator is online!"
else
  firebase emulators:start --only firestore
fi
