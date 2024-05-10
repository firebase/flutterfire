// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library firebase_vertexai;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:google_generative_ai/google_generative_ai.dart' as google_ai;
// ignore: implementation_imports, tightly coupled packages
import 'package:google_generative_ai/src/vertex_hooks.dart';

import 'src/vertex_version.dart';

part 'src/firebase_vertexai.dart';
part 'src/vertex_api.dart';
part 'src/vertex_chat.dart';
part 'src/vertex_content.dart';
part 'src/vertex_function_calling.dart';
part 'src/vertex_model.dart';
