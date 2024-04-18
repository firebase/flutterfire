#!/bin/bash

# Define the version of the document
read -p 'BoM Version number: ' VERSION
DATE=$(date +"%Y-%m-%d")

# Define package directory and native version file paths
PACKAGES_DIR="packages"
VERSIONS_FILE="versions.mdx"
ANDROID_VERSION_FILE="${PACKAGES_DIR}/firebase_core/firebase_core/android/gradle.properties"
IOS_VERSION_FILE="${PACKAGES_DIR}/firebase_core/firebase_core/ios/firebase_sdk_version.rb"
WEB_VERSION_FILE="${PACKAGES_DIR}/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart"
WINDOWS_VERSION_FILE="${PACKAGES_DIR}/firebase_core/firebase_core/windows/CMakeLists.txt"

# Fetch native versions
ANDROID_SDK_VERSION=$(awk -F '=' '/FirebaseSDKVersion/{print $2}' $ANDROID_VERSION_FILE)
IOS_SDK_VERSION=$(awk -F "'" '/def firebase_sdk_version!()/ {getline; print $2}' $IOS_VERSION_FILE)
WEB_SDK_VERSION=$(awk -F "'" '/const String supportedFirebaseJsSdkVersion =/ {print $2}' $WEB_VERSION_FILE)
WINDOWS_SDK_VERSION=$(awk -F '"' '/set\(FIREBASE_SDK_VERSION/ {print $2}' $WINDOWS_VERSION_FILE)

# Remove top mdx part
awk '/^--- *$/{ if (!seen["---"]++) next } /^{ *$/{ if (!seen["{"]++) next } 1' $VERSIONS_FILE > temp_file && mv temp_file $VERSIONS_FILE


# List of packages
declare -a packages=("firebase_core" "firebase_auth" "cloud_firestore" "firebase_database" "firebase_storage" "firebase_messaging" "firebase_crashlytics" "firebase_performance" "firebase_remote_config" "firebase_analytics" "firebase_in_app_messaging" "firebase_app_check" "firebase_ml_model_downloader")

# Write new content to a temporary file
TEMP_FILE="temp_versions_file"

{
    echo "---"
    echo "{"
    echo "    \"$VERSION\": {"
    for package in "${packages[@]}"; do
        VERSION_FILE="${PACKAGES_DIR}/${package}/${package}/pubspec.yaml"
        PACKAGE_VERSION=$(grep "version:" $VERSION_FILE | cut -d' ' -f2)
        echo "        \"$package\": \"$PACKAGE_VERSION\","
    done
    echo "        \"native_sdk\": {"
    echo "            \"android\": \"$ANDROID_SDK_VERSION\","
    echo "            \"ios\": \"$IOS_SDK_VERSION\","
    echo "            \"web\": \"$WEB_SDK_VERSION\","
    echo "            \"windows\": \"$WINDOWS_SDK_VERSION\""
    echo "        },"
    echo "    },"
} > "$TEMP_FILE"

cat "$VERSIONS_FILE" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$VERSIONS_FILE"

# Clean up
sed -i '' '/# FlutterFire Compatible Versions/,/released./{/# FlutterFire Compatible Versions/,/released./d;}' "$VERSIONS_FILE"

# Append static text part to end the document
NEW_VERSION_SECTION=$(cat <<EOF
# FlutterFire Compatible Versions

This document is listing all the compatible versions of the FlutterFire plugins. This document is updated whenever a new version of the FlutterFire plugins is released.

# Versions

## [Flutter BoM $VERSION ($DATE)](https://github.com/firebase/flutterfire/blob/master/CHANGELOG.md#$DATE)

{/* When ready can be included
Install this version using FlutterFire CLI

\`\`\`bash
flutterfire install $VERSION
\`\`\`
*/}

### Included Native Firebase SDK Versions

| Firebase SDK | Version | Link |
|------------|---------|------|
| Android SDK | $ANDROID_SDK_VERSION | [Release Notes](https://firebase.google.com/support/release-notes/android) |
| iOS SDK | $IOS_SDK_VERSION | [Release Notes](https://firebase.google.com/support/release-notes/ios) |
| Web SDK | $WEB_SDK_VERSION | [Release Notes](https://firebase.google.com/support/release-notes/js) |
| Windows SDK | $WINDOWS_SDK_VERSION | [Release Notes](https://firebase.google.com/support/release-notes/cpp-relnotes) |

### FlutterFire Plugin Versions
| Plugin | Version |
|--------|---------|\n
EOF
)

# Add table rows for each package version
for package in "${packages[@]}"; do
    VERSION_FILE="${PACKAGES_DIR}/${package}/${package}/pubspec.yaml"
    PACKAGE_VERSION=$(grep "version:" $VERSION_FILE | cut -d' ' -f2)
    NEW_VERSION_SECTION+="| [$package](https://pub.dev/packages/${package}/versions/${PACKAGE_VERSION}) | $PACKAGE_VERSION |\n"
done

# Prepare the multiline replacement content in a temporary file
temp_new_version="temp_new_version.txt"
echo "$NEW_VERSION_SECTION" > "$temp_new_version"

# Use awk to replace the line
awk -v replacement="$temp_new_version" '
    BEGIN { while((getline line < replacement) > 0) { new_content = new_content line "\n" } }
    /# Versions/ { print new_content; next }
    { print }
' "$VERSIONS_FILE" > "temp_file" && mv "temp_file" "$VERSIONS_FILE"

# Clean up the temporary file for the new version content
rm "$temp_new_version"

# Turn \n into new lines in VERSIONS_FILE
sed -i '' 's/\\n/\
/g' $VERSIONS_FILE

echo "Version $VERSION has been generated successfully!"