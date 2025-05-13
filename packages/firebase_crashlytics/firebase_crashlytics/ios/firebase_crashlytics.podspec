require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

# Add upload-symbols script to the Flutter target.
current_dir = Dir.pwd
calling_dir = File.dirname(__FILE__)
project_dir = calling_dir.slice(0..(calling_dir.index('/.symlinks')))
system("ruby #{current_dir}/crashlytics_add_upload_symbols -f -p #{project_dir} -n Runner.xcodeproj")

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
  s.authors          = 'The Chromium Authors'
  s.source           = { :path => '.' }

  s.source_files     = 'firebase_crashlytics/Sources/firebase_crashlytics/**/*.{h,m}'
  s.public_header_files = 'firebase_crashlytics/Sources/firebase_crashlytics/include/*.h'

  s.ios.deployment_target = '13.0'

  s.dependency 'Flutter'
  s.dependency 'firebase_core'
  s.dependency 'Firebase/Crashlytics', firebase_sdk_version

  s.static_framework = true
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => "LIBRARY_VERSION=\\\"#{library_version}\\\" LIBRARY_NAME=\\\"flutter-fire-cls\\\"",
    'DEFINES_MODULE' => 'YES'
  }
  s.user_target_xcconfig = { 'DEBUG_INFORMATION_FORMAT' => 'dwarf-with-dsym' }
end
