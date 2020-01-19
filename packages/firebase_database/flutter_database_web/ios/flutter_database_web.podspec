#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_database_web.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_database_web'
    s.version          = '0.1.0'
  s.summary          = 'No-op implementation of firebase_database_web web plugin to avoid build issues on iOS'
  s.description      = <<-DESC
temp fake firebase_database_web plugin
                        DESC
  s.homepage         = 'https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_database/flutter_database_web'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.ios.deployment_target = '8.0'
end
