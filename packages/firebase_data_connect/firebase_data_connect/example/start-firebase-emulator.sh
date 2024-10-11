#!/bin/bash
firebase emulators:start --project flutterfire-e2e-tests &
# Added below to fix the e2e tests
# npx "firebase/firebase-tools#mtewani/dart-bugbash" emulators:start --project flutterfire-e2e-tests &
sleep 30