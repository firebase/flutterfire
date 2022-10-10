#!/bin/bash
# Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


BRANCH=$1
git clone https://github.com/flutter/flutter.git --depth 1 -b $BRANCH "$GITHUB_WORKSPACE/_flutter"
echo "$GITHUB_WORKSPACE/_flutter/bin" >> $GITHUB_PATH
