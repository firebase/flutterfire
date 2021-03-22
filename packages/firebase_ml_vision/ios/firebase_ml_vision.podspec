#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
libraryVersion = pubspec['version'].gsub('+', '-')

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
  s.name             = 'firebase_ml_vision'
  s.version          = '0.1.1'
  s.summary          = 'Flutter plugin for Google ML Vision for Firebase.'
  s.description      = <<-DESC
An SDK that brings Google's machine learning expertise to Android and iOS apps in a powerful yet
 easy-to-use package.
                       DESC
  s.homepage         = 'https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_ml_vision'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'firebase_core'
  s.dependency 'Firebase/MLVision', firebase_sdk_version
  s.ios.deployment_target = '10.0'
  s.static_framework = true

  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => "LIBRARY_VERSION=\\@\\\"#{libraryVersion}\\\" LIBRARY_NAME=\\@\\\"flutter-fire-ml-vis\\\"" }
end
