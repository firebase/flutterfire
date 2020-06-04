#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_in_app_messaging'
  s.version          = '0.0.1'
  s.summary          = 'In-App Messaging Plugin for Firebase'
  s.description      = <<-DESC
Flutter plugin for Firebase In-App Messaging.
                       DESC
  s.homepage         = 'https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_in_app_messaging'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase'
  s.dependency 'Firebase/InAppMessaging'
  s.static_framework = true

  s.ios.deployment_target = '8.0'
end

