#!/bin/bash
set -euo pipefail

AGP_VERSION="${AGP_VERSION:-9.0.1}"
GRADLE_VERSION="${GRADLE_VERSION:-9.1.0}"

TEST_ANDROID_DIR="tests/android"

perl -0pi -e "s/id \"com\.android\.application\" version \"[^\"]+\" apply false/id \"com.android.application\" version \"$AGP_VERSION\" apply false/" \
  "$TEST_ANDROID_DIR/settings.gradle"

perl -0pi -e "s#distributionUrl=https\\\\://services.gradle.org/distributions/gradle-[^-]+-all.zip#distributionUrl=https\\\\://services.gradle.org/distributions/gradle-$GRADLE_VERSION-all.zip#" \
  "$TEST_ANDROID_DIR/gradle/wrapper/gradle-wrapper.properties"

# Flutter's Gradle plugin does not fully support AGP 9's new DSL yet. Opt out in
# this CI-only checkout so the job validates FlutterFire plugin compatibility.
# https://docs.flutter.cn/release/breaking-changes/migrate-to-agp-9/
grep -q '^android.newDsl=false$' "$TEST_ANDROID_DIR/gradle.properties" || \
  printf '\nandroid.newDsl=false\n' >> "$TEST_ANDROID_DIR/gradle.properties"

# AGP 9 has built-in Kotlin support. Keep the compatibility check focused on
# FlutterFire plugins by applying the same migration to the test app at runtime.
perl -0pi -e 's/\n\s*id "kotlin-android"\n/\n/' "$TEST_ANDROID_DIR/app/build.gradle"
perl -0pi -e 's/\n\s*kotlinOptions \{\n\s*jvmTarget = JavaVersion\.VERSION_17\n\s*\}\n/\n/' "$TEST_ANDROID_DIR/app/build.gradle"

# AGP 9 rejects older Espresso artifacts that share the same namespace.
grep -q 'androidx.test.espresso:espresso-core:3.7.0' "$TEST_ANDROID_DIR/app/build.gradle" || cat <<'EOF' >> "$TEST_ANDROID_DIR/app/build.gradle"

dependencies {
    debugImplementation 'androidx.test.espresso:espresso-core:3.7.0'
    debugImplementation 'androidx.test.espresso:espresso-idling-resource:3.7.0'
}
EOF

grep -q "id \"com.android.application\" version \"$AGP_VERSION\" apply false" "$TEST_ANDROID_DIR/settings.gradle"
grep -q "gradle-$GRADLE_VERSION-all.zip" "$TEST_ANDROID_DIR/gradle/wrapper/gradle-wrapper.properties"
grep -q '^android.newDsl=false$' "$TEST_ANDROID_DIR/gradle.properties"
! grep -q 'id "kotlin-android"' "$TEST_ANDROID_DIR/app/build.gradle"
! grep -q 'kotlinOptions' "$TEST_ANDROID_DIR/app/build.gradle"
grep -q 'androidx.test.espresso:espresso-core:3.7.0' "$TEST_ANDROID_DIR/app/build.gradle"
grep -q 'androidx.test.espresso:espresso-idling-resource:3.7.0' "$TEST_ANDROID_DIR/app/build.gradle"

cd tests
flutter build apk --debug --dart-define=CI=true --no-android-gradle-daemon
