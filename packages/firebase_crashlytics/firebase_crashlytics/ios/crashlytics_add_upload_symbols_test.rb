#!/usr/bin/env ruby
# Exercises crashlytics_add_upload_symbols against a temporary Runner project.

require 'fileutils'
require 'tmpdir'
require 'xcodeproj'

SCRIPT = File.expand_path('crashlytics_add_upload_symbols', __dir__)
PHASE_NAME = '[firebase_crashlytics] Crashlytics Upload Symbols'
STOCK_SCRIPT = '"$PODS_ROOT/FirebaseCrashlytics/upload-symbols" --flutter-project "$PROJECT_DIR/firebase_app_id_file.json" '

def fail(message)
  abort("FAIL: #{message}")
end

def assert(condition, message)
  fail(message) unless condition
end

def upload_phase(project_path)
  project = Xcodeproj::Project.open(project_path)
  runner = project.targets.find { |target| target.name == 'Runner' }
  runner.shell_script_build_phases.find { |phase|
    phase.name == PHASE_NAME || phase.shell_script.include?('FirebaseCrashlytics/upload-symbols')
  }
end

def run_script(project_dir)
  success = system('ruby', SCRIPT, '-f', '-p', project_dir, '-n', 'Runner.xcodeproj')
  assert(success, 'crashlytics_add_upload_symbols exited non-zero')
end

Dir.mktmpdir('crashlytics_upload_symbols') do |dir|
  project_path = File.join(dir, 'Runner.xcodeproj')
  project = Xcodeproj::Project.new(project_path)
  project.new_target(:application, 'Runner', :ios, '15.0')
  project.save
  File.write(File.join(dir, 'firebase_app_id_file.json'), "{}\n")

  run_script(dir)
  phase = upload_phase(project_path)
  assert(phase, 'expected a Crashlytics upload phase to be created')
  script = phase.shell_script
  assert(script.include?('Debug*'), 'created script does not skip Debug* configurations')
  assert(script.include?('*simulator'), 'created script does not skip simulator builds')
  assert(script.include?('No dSYM'), 'created script does not skip a missing dSYM')
  assert(script.include?('FirebaseCrashlytics/upload-symbols'), 'created script does not call upload-symbols')
  sh_check = system('/bin/sh', '-n', '-c', script)
  assert(sh_check, 'created script is not valid shell')

  # Re-running leaves an up-to-date script in place.
  run_script(dir)
  assert(upload_phase(project_path).shell_script == script, 're-run changed an up-to-date script')

  # A previously generated one-line phase is upgraded.
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = STOCK_SCRIPT
  project.save
  run_script(dir)
  upgraded = upload_phase(project_path).shell_script
  assert(upgraded.include?('Debug*'), 'stock one-line script was not upgraded')
  assert(upgraded != STOCK_SCRIPT, 'stock one-line script was left unchanged')

  # A hand-edited phase is preserved.
  custom = "if [ \"$CONFIGURATION\" = \"Debug\" ]; then\n  exit 0\nfi\n\"$PODS_ROOT/FirebaseCrashlytics/upload-symbols\"\n"
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = custom
  project.save
  run_script(dir)
  assert(upload_phase(project_path).shell_script == custom, 'custom upload script was overwritten')

  # A manual Crashlytics/run phase is preserved and not duplicated.
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = '"$PODS_ROOT/FirebaseCrashlytics/run"'
  project.save
  run_script(dir)
  phases = Xcodeproj::Project.open(project_path).targets.first.shell_script_build_phases
  assert(phases.length == 1, 'manual run phase was duplicated')
  assert(phases.first.shell_script.include?('FirebaseCrashlytics/run'), 'manual run phase was overwritten')
end

puts('ok')
