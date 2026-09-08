# Native Storage listener tests

The example's checked-in `RunnerTests` target exercises the actual Storage
plugin and Firebase SDK on an iOS simulator. It uses the example's normal
`Runner` scheme and links against the host app's plugin code.

First run `melos bootstrap` at the repository root, enable Flutter Swift Package
Manager support, and start the local Storage emulator:

```sh
cd .github/workflows/scripts
firebase emulators:start --only storage --project flutterfire-e2e-tests
```

From the Firebase Storage package directory, run:

```sh
./tool/test_engine_lifecycle.sh <simulator-udid>
```

The runner requires Xcode, Flutter, a booted iOS simulator, and the Storage
emulator on `127.0.0.1:9199`. It builds a minimal Dart entrypoint and runs the
checked-in Xcode test target. It does not create or edit test targets or schemes.
Flutter may perform its normal generated-project migrations during the build.

The tests cover callbacks queued before cancellation, relistening, background
callback delivery, immediate sink release, terminal success and cancellation,
iOS engine disposal, and cleanup through Firebase Core's reinitialization
registry followed by a new successful upload. Fixtures use a real paused upload
and an event-counting sink. No Firebase credentials or production bucket are
required.

Listener cleanup removes observers and stale plugin task handles. It does not
explicitly cancel native transfers, and it preserves emulator configuration
across Firebase Core reinitialization.

Engine disposal invokes `detachFromEngine(for:)` on iOS. Calling `destroyContext()`
while retaining the engine does not invoke that hook and remains outside this
fix. macOS has no corresponding plugin-detach callback; cancellation and Firebase
Core reinitialization cleanup use the shared Swift implementation there.
