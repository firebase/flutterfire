# https://firebase.google.com/support/release-notes/ios
# CocoaPods pin. Do not bump this past the last firebase-ios-sdk version
# published to CocoaPods. New releases stop publishing in October 2026.
# Swift Package Manager uses scripts/firebase_sdk_version_spm.dart.
def firebase_sdk_version!()
  '12.19.0'
end
