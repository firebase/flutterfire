{# This content gets published to the following location:                                  #}
{#   https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports?platform=flutter #}

By default, {{firebase_crashlytics}} automatically instruments your Flutter
project to upload the necessary symbol files that ensure crash reports are
deobfuscated and human readable.

Unfortunately, there are cases that can result in the project not being fully
configured. This guide outlines what the automation does and provides first
steps to debug your project setup.

## Apple platforms {: #apple}

Adding the {{crashlytics}} Flutter plugin and running the
`flutterfire configure` command will attempt to add a run script to your
project’s Xcode workspace that finds and uploads the necessary dSYM symbol files
to {{crashlytics}}. Without these files, you’ll see a "Missing dSYM" alert in
the {{crashlytics}} dashboard and exceptions will be held by the backend until
the missing files are uploaded.

If you have this issue, first make sure that you have the run script installed:

1.  Locate and open the Xcode workspace file in your project’s iOS directory
    (<code><var>FLUTTER_PROJECT_NAME</var>/ios/Runner.xcworkspace</code>).

1.  Identify whether a run script titled
    `[firebase_crashlytics] Crashlytics Upload Symbols` has been added to the
    Runner target’s Build Phases.

**If this run script does _not_ exist**, you can add it manually:

1.  Locate the Firebase App ID for your Apple app. Here are two different places
    where you can find this ID:

    * In the {{name_appmanager}}, go to your
      <nobr><span class="material-icons">settings</span> > _Project settings_</nobr>.
      Scroll down to the _Your apps_ card, then click on your
      Firebase Apple App to view the app's information, including its _App ID_.

    * In your Flutter project's top-level directory, find your
      `firebase_options.dart` file. The Firebase App ID for your Apple app is
      labeled as `GOOGLE_APP_ID`.

1.  Click <span class="material-icons">add</span> >
    **New Run Script Phase**.

    Make sure this new _Run Script_ phase is your project's last build
    phase. Otherwise, {{crashlytics}} can't properly process dSYMs.

1.  Expand the new _Run Script_ section.

    Note: For the remaining substeps, copy-and-paste the paths exactly as
    specified, and Xcode will resolve them. However, if you have issues with
    Xcode resolving these paths or a unique project structure, you can
    manually specify the paths instead.

1.  In the script field (located under the _Shell_ label), add the
    following run scripts.

    These scripts process your project's dSYM files and upload the files to
    {{crashlytics}}.

    <pre class="devsite-click-to-copy">$PODS_ROOT/FirebaseCrashlytics/upload-symbols --build-phase --validate -ai <var>FIREBASE_APPLE_APP_ID</var></pre>

    <pre class="devsite-click-to-copy">$PODS_ROOT/FirebaseCrashlytics/upload-symbols --build-phase -ai <var>FIREBASE_APPLE_APP_ID</var></pre>

1.  In the _Input Files_ section, add the paths for the locations of the
    following files:

    * The location of your project's **dSYM files**:

      <pre class="devsite-click-to-copy">${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}</pre>

      Providing the location of your project's dSYM files enables
      {{crashlytics}} to process dSYMs for large apps more quickly.

    * The location of your project's built **`Info.plist` file**:

      <pre class="devsite-click-to-copy">$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)</pre>

      Providing the location of your project's built `Info.plist` file
      enables {{crashlytics}} to associate an app version with the dSYMs.

**If the run script does exist**, refer to the
[Apple-specific guide for troubleshooting dSYM issues](/docs/crashlytics/get-deobfuscated-reports?platform=ios).
You’ll need to take the following additional steps if you choose to upload your
dSYM files via the described process:

1.  Locate the Firebase App ID for your Apple app. Here are two different places
    where you can find this ID:

    * In the {{name_appmanager}}, go to your
      <nobr><span class="material-icons">settings</span> > _Project settings_</nobr>.
      Scroll down to the _Your apps_ card, then click on your
      Firebase Apple App to view the app's information, including its _App ID_.

    * In your Flutter project's top-level directory, find your
      `firebase_options.dart` file. The Firebase App ID for your Apple app is
      labeled as `GOOGLE_APP_ID`.

1.  When running the `upload-symbols` script, use
    <code><nobr>-ai <var>FIREBASE_APPLE_APP_ID</var></nobr></code> instead of
    <nobr><code>-gsp /path/to/GoogleService-Info.plist</code></nobr>.


## Android {: #android}

The `flutterfire configure` command attempts to add necessary dependencies to
your project’s Gradle build files. Without these dependencies, crash reports in
the {{name_appmanager}} may end up obfuscated if obfuscation is turned on.

Make sure the following lines are present in the project-level `build.gradle`
and in the app-level `build.gradle`:

* In the **project-level** build file (`android/build.gradle`), check for the
  following line:

  <pre class="prettyprint">
  dependencies {
    // ... other dependencies

    classpath 'com.google.gms:google-services:4.3.5'
    <strong>classpath 'com.google.firebase:firebase-crashlytics-gradle:2.7.1'</strong>
  }
  </pre>

* In the **app-level** build file (`android/app/build.gradle`), check for the
  following line:

  <pre class="prettyprint">
  // ... other imports

  android {
    // ... your android config
  }

  dependencies {
    // ... your dependencies
  }

  // This section must appear at the bottom of the file
  apply plugin: 'com.google.gms.google-services'
  <strong>apply plugin: 'com.google.firebase.crashlytics'</strong>
  </pre>

*1.  If your Flutter project uses the
    [`--split-debug-info` flag](https://docs.flutter.dev/perf/app-size#reducing-app-size){: .external}
    (and the
    [`--obfuscate` flag](https://docs.flutter.dev/deployment/obfuscate){: .external}),
    you need to use the [{{firebase_cli}}](/docs/cli) (v.11.9.0+) to upload
    Android symbols.

    You need to upload the debug symbols before reporting a crash from an obfuscated code build (i.e using the above noted flags
    `--split-debug-info` & `--obfuscate`). From the root directory of your Flutter project, run the following command:

    <pre class="devsite-terminal" data-terminal-prefix="your-flutter-proj$ ">firebase crashlytics:symbols:upload --app=<var class="readonly">APP_ID</var> <var class="readonly">PATH/TO</var>/symbols</pre>

    The <code><var>PATH/TO</var>/symbols</code> directory is the same directory
    that you pass to the `--split-debug-info` flag when building the application.

If problems persist, refer to the
[Android-specific guide for troubleshooting obfuscated reports](/docs/crashlytics/get-deobfuscated-reports?platform=android).
