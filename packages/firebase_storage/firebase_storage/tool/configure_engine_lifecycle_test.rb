# Copyright 2026 The Chromium Authors.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

require 'xcodeproj'
path = File.join(ARGV.fetch(0), 'Runner.xcodeproj')
project = Xcodeproj::Project.open(path)
runner = project.targets.find { |t| t.name == 'Runner' }
test = project.new_target(:unit_test_bundle, 'StorageLifecycleTests', :ios, '15.0')
test.add_dependency(runner)
group = project.main_group.new_group('RunnerTests', 'RunnerTests')
test.add_file_references([group.new_file('StorageEngineLifecycleTests.swift')])
test.build_configurations.each do |config|
  config.build_settings.merge!({
    'SWIFT_VERSION' => '5.0',
    'PRODUCT_NAME' => '$(TARGET_NAME)',
    'PRODUCT_BUNDLE_IDENTIFIER' => 'io.flutter.plugins.firebase.storage.lifecycle-tests',
    'GENERATE_INFOPLIST_FILE' => 'YES',
    'TEST_HOST' => '$(BUILT_PRODUCTS_DIR)/Runner.app/Runner',
    'BUNDLE_LOADER' => '$(TEST_HOST)',
    'FRAMEWORK_SEARCH_PATHS' => ['$(inherited)', '$(BUILT_PRODUCTS_DIR)'],
    'SWIFT_INCLUDE_PATHS' => ['$(inherited)', '$(BUILT_PRODUCTS_DIR)'],
    'LD_RUNPATH_SEARCH_PATHS' => ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks'],
    'CODE_SIGNING_ALLOWED' => 'NO',
  })
end
runner.package_product_dependencies.each do |dep|
  added = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  added.product_name = dep.product_name
  added.package = dep.package
  test.package_product_dependencies << added
  buildfile = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  buildfile.product_ref = added
  test.frameworks_build_phase.files << buildfile
end
scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(runner, test)
scheme.save_as(path, 'StorageLifecycleTests', true)
project.save
