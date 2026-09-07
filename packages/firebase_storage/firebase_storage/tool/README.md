# Native lifecycle tests

Run the deterministic Foundation-only dispatcher tests with:

```sh
./tool/test_native_lifecycle.sh
```

To test real iOS engine disposal, first run `melos bootstrap` at the repository
root, start the Storage emulator, and boot an iOS simulator:

```sh
cd .github/workflows/scripts
firebase emulators:start --only storage --project flutterfire-e2e-tests
```

From the Firebase Storage package directory, run:

```sh
./tool/test_engine_lifecycle.sh <simulator-udid>
```

This requires Xcode, Flutter with Swift Package Manager enabled, CocoaPods'
`xcodeproj` Ruby gem, and the Storage emulator on `127.0.0.1:9199`. The runner builds a minimal Dart entrypoint, creates
a temporary XCTest target in the example project, and restores the project
files afterward. Do not edit or build that example concurrently with the runner.

The XCTest starts a real headless Flutter engine, registers the actual Storage
plugin, and pauses a real Firebase upload. It queues a real Firebase observer
callback before disposing the engine and verifies that Flutter invokes plugin
cleanup and the queued callback does not reach its old event sink.

This covers iOS engine disposal, which invokes `detachFromEngine(for:)`.
`destroyContext()` alone while retaining the engine is a different lifecycle
and is not covered by this hook. macOS does not expose the corresponding plugin
detach callback; shared dispatcher tests and the macOS emulator suite cover
cancellation and terminal delivery there.
