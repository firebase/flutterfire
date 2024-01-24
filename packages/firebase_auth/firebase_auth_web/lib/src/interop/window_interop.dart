// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library window_interop;

import 'dart:js_interop';

@JS('Error')
@staticInterop
external Object get errorConstructor;
