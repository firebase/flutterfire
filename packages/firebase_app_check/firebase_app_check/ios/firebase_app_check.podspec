require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

if defined?($FirebaseSDKVersion)
  Pod::UI.puts "#{pubspec['name']}: Using user specified Firebase SDK version '#{$FirebaseSDKVersion}'"
  firebase_sdk_version = $FirebaseSDKVersion
else
  firebase_core_script = File.join(File.expand_path('..', File.expand_path('..', File.dirname(__FILE__))), 'firebase_core/ios/firebase_sdk_version.rb')
  if File.exist?(firebase_core_script)
    require firebase_core_script
    firebase_sdk_version = firebase_sdk_version!
    Pod::UI.puts "#{pubspec['name']}: Using Firebase SDK version '#{firebase_sdk_version}' defined in 'firebase_core'"
  end
end

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = library_version
  s.summary          = pubspec['description']
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']

  s.license          = { :file => '../LICENSE' }
  s.authors           = 'The Chromium Authors'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/*.h'
  s.ios.deployment_target = '11.0'

  # Flutter dependencies
  s.dependency 'Flutter'

  # Firebase dependencies
  s.dependency 'firebase_core'
  s.dependency 'Firebase/CoreOnly', "~> #{firebase_sdk_version}"
  # TODO(salakar): Directly depend on AppCheck podspec to avoid issues with subspec:
  # https://github.com/firebase/firebase-ios-sdk/pull/9187 (pending acceptance & merge)
  s.dependency 'FirebaseAppCheck', "~> #{firebase_sdk_version}-beta"

  s.static_framework = true
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => "LIBRARY_VERSION=\\@\\\"#{library_version}\\\" LIBRARY_NAME=\\@\\\"flutter-fire-appcheck\\\"",
    'DEFINES_MODULE' => 'YES',
    # Flutter.framework does not contain a i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end

