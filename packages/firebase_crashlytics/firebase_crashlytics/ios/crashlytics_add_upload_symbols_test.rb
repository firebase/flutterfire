#!/usr/bin/env ruby
# Exercises crashlytics_add_upload_symbols against a temporary Runner project.

require 'fileutils'
require 'tmpdir'
require 'xcodeproj'

SCRIPT = File.expand_path('crashlytics_add_upload_symbols', __dir__)
PHASE_NAME = '[firebase_crashlytics] Crashlytics Upload Symbols'
STOCK_SCRIPT = '"$PODS_ROOT/FirebaseCrashlytics/upload-symbols" --flutter-project "$PROJECT_DIR/firebase_app_id_file.json" '
DWARF_INPUT = '${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}'
DEBUG_DYLIB_INPUT = "#{DWARF_INPUT}.debug.dylib"
OLD_INPUTS = [
  "\"${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}\"",
  "\"${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/\"",
  "\"${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist\"",
  "\"$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)\"",
  "\"$(PROJECT_DIR)/firebase_app_id_file.json\"",
]

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

def normalize_input_path(path)
  path.to_s.strip.delete('"')
end

def assert_dwarf_input(phase, message)
  raw = phase.input_paths || []
  assert(raw.include?(DWARF_INPUT), message)
  assert(!raw.include?("\"#{DWARF_INPUT}\""), message)
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
  assert_dwarf_input(phase, 'created phase has no DWARF input')
  sh_check = system('/bin/sh', '-n', '-c', script)
  assert(sh_check, 'created script is not valid shell')

  # Re-running leaves an up-to-date script in place.
  run_script(dir)
  rerun = upload_phase(project_path)
  assert(rerun.shell_script == script, 're-run changed an up-to-date script')
  assert_dwarf_input(rerun, 're-run dropped the DWARF input')

  # A previously generated one-line phase is upgraded, including its inputs.
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = STOCK_SCRIPT
  phase.input_paths = OLD_INPUTS + ['CUSTOM_DEP']
  project.save
  run_script(dir)
  upgraded = upload_phase(project_path)
  assert(upgraded.shell_script.include?('Debug*'), 'stock one-line script was not upgraded')
  assert(upgraded.shell_script != STOCK_SCRIPT, 'stock one-line script was left unchanged')
  assert_dwarf_input(upgraded, 'stock upgrade did not add the DWARF input')
  assert(upgraded.input_paths.include?('CUSTOM_DEP'), 'stock upgrade dropped an existing input')
  assert(
    (upgraded.input_paths || []).map { |path| normalize_input_path(path) }.include?(normalize_input_path(OLD_INPUTS.first)),
    'stock upgrade dropped an existing dSYM input'
  )

  # A 6.0.x phase already has the generated script and the old input list.
  generated_script = upgraded.shell_script
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = generated_script
  phase.input_paths = OLD_INPUTS + ['CUSTOM_DEP']
  project.save
  run_script(dir)
  repaired = upload_phase(project_path)
  assert(repaired.shell_script == generated_script, 'generated script was rewritten while adding the DWARF input')
  assert_dwarf_input(repaired, '6.0.x phase did not gain the DWARF input')
  assert(repaired.input_paths.include?('CUSTOM_DEP'), '6.0.x repair dropped an existing input')

  # A .debug.dylib input is not the Mach-O DWARF file.
  dylib = "\"#{DEBUG_DYLIB_INPUT}\""
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = generated_script
  phase.input_paths = [dylib]
  project.save
  run_script(dir)
  with_dylib = upload_phase(project_path)
  assert_dwarf_input(with_dylib, 'debug.dylib input hid the missing DWARF file')
  assert(
    (with_dylib.input_paths || []).map { |path| normalize_input_path(path) }.include?(DEBUG_DYLIB_INPUT),
    'debug.dylib input was removed'
  )

  # The historical command under another phase name is user-owned.
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.name = 'Custom Upload'
  phase.shell_script = STOCK_SCRIPT
  phase.input_paths = ['CUSTOM_INPUT']
  project.save
  run_script(dir)
  renamed = upload_phase(project_path)
  assert(renamed.name == 'Custom Upload', 'renamed historical phase was renamed')
  assert(renamed.shell_script == STOCK_SCRIPT, 'renamed historical phase script was overwritten')
  assert(renamed.input_paths == ['CUSTOM_INPUT'], 'renamed historical phase inputs were overwritten')
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == 'Custom Upload' }
  phase.name = PHASE_NAME
  project.save

  # A custom one-line upload-symbols command is left alone.
  custom_line = '"$PODS_ROOT/FirebaseCrashlytics/upload-symbols" --extra'
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = custom_line
  phase.input_paths = ['CUSTOM_INPUT']
  project.save
  run_script(dir)
  kept_line = upload_phase(project_path)
  assert(kept_line.shell_script == custom_line, 'custom one-line upload script was overwritten')
  assert(kept_line.input_paths == ['CUSTOM_INPUT'], 'custom one-line upload inputs were overwritten')

  # A hand-edited phase is preserved.
  custom = "if [ \"$CONFIGURATION\" = \"Debug\" ]; then\n  exit 0\nfi\n\"$PODS_ROOT/FirebaseCrashlytics/upload-symbols\"\n"
  project = Xcodeproj::Project.open(project_path)
  phase = project.targets.first.shell_script_build_phases.find { |item| item.name == PHASE_NAME }
  phase.shell_script = custom
  phase.input_paths = ['CUSTOM_INPUT']
  project.save
  run_script(dir)
  kept = upload_phase(project_path)
  assert(kept.shell_script == custom, 'custom upload script was overwritten')
  assert(kept.input_paths == ['CUSTOM_INPUT'], 'custom upload inputs were overwritten')

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
