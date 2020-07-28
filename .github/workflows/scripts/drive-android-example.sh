#!/bin/bash

melos exec -c 1 --fail-fast --scope="$FLUTTERFIRE_PLUGIN_SCOPE_EXAMPLE" --dir-exists=test_driver -- \
  flutter drive --no-pub --no-build --target=./test_driver/MELOS_PARENT_PACKAGE_NAME_e2e.dart