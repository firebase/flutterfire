#!/bin/bash
# Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

curl -v -X DELETE "http://localhost:8080/emulator/v1/projects/react-native-firebase-testing/databases/(default)/documents"