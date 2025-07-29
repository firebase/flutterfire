#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cloud_functions_web.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cloud_functions_web'
  s.version          = '1.0.0'
  s.summary          = 'No-op implementation of cloud_functions_web plugin to avoid iOS build issues'
  s.description      = <<-DESC
Stub/fake cloud_functions_web plugin
                       DESC
  s.homepage         = 'https://github.com/firebase/flutterfire/tree/main/packages/cloud_functions/cloud_functions_web'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
