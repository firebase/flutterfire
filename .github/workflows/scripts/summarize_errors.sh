#!/bin/bash

set -e

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <search_pattern> <logfile1> [<logfile2> ...]"
  exit 1
fi

search_pattern="$1"
shift

echo "Analyzing test logs for failures with pattern: '$search_pattern'"

for logfile in "$@"; do
  if [ ! -f "$logfile" ]; then
    echo "Log file not found: $logfile"
    continue
  fi

  echo "Checking $logfile..."

  # The awk script is now parameterized with the search_pattern variable.
  # We use a flag `failure_found` to indicate if a failure has been detected.
  # This is to prevent the script from exiting early if a failure is found.
  failure_found=0
  while IFS= read -r line; do
    if [[ "$line" == "melos exec"* ]]; then
      in_melos_block=true
      package_path=""
    fi

    if $in_melos_block && [[ "$line" == *"└> CWD:"* ]]; then
      package_path=$(echo "$line" | awk '{print $3}')
    fi

    if [[ "$line" =~ $search_pattern ]]; then
      if [ "$failure_found" -eq 0 ]; then
        echo ""
        echo "================================================================="
        echo "          Error Summary for $logfile"
        echo "================================================================="
        failure_found=1
      fi

      if [ -n "$package_path" ]; then
        echo "❌ Failure detected in package: $package_path"
      else
        echo "❌ Failure detected in $logfile"
      fi
      echo "  $line"
      echo ""
    fi

    if $in_melos_block && [[ "$line" == *"melos exec done"* ]]; then
      in_melos_block=false
      package_path=""
    fi
  done < "$logfile"
done

echo "Analysis complete."
