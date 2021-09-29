#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = library_version
  s.summary          = pubspec['description']
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']
  s.license          = { :file => '../LICENSE' }
  s.author           = 'The Chromium Authors'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Google-Mobile-Ads-SDK', '7.49.0'

  s.ios.deployment_target = '10.0'

  s.static_framework = true

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end
