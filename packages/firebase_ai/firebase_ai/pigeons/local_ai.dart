// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/local_ai.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/src/main/kotlin/io/flutter/plugins/firebase/ai/GeneratedLocalAI.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/Classes/GeneratedLocalAI.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'firebase_ai',
  copyrightHeader: 'pigeons/copyright.txt',
))

@HostApi()
abstract class LocalAIApi {
  @async
  bool isAvailable();
  
  @async
  String generateContent(String prompt);
  
  @async
  void warmup();
}
