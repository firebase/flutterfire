#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cloud_functions_web.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cloud_functions_web'
  s.version          = '0.0.1'
  s.summary          = 'cloud_functions for web.'
  s.description      = <<-DESC
This is the cloud_functions implementation for web. Thus, the iOS implementation does
nothing, and won't ever be used.
                       DESC
  s.homepage         = 'https://github.com/FirebaseExtended/flutterfire'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'The Chromium Authors' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
