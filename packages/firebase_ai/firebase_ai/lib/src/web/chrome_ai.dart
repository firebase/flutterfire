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

import 'dart:async';
import 'dart:js_interop';

@JS('window.ai')
external JSObject? get windowAI;

extension WindowAIExtension on JSObject {
  @JS('languageModel')
  external JSObject get languageModel;
}

extension LanguageModelExtension on JSObject {
  @JS('create')
  external JSPromise<JSObject> create(JSObject? options);
}

extension ModelInstanceExtension on JSObject {
  @JS('prompt')
  external JSPromise<JSString> prompt(JSString input);

  @JS('promptStreaming')
  external JSObject promptStreaming(JSString input);
}

extension ReadableStreamExtension on JSObject {
  @JS('getReader')
  external JSObject getReader();
}

extension ReadableStreamDefaultReaderExtension on JSObject {
  @JS('read')
  external JSPromise<JSObject> read();
}

extension ReadableStreamDefaultReadResultExtension on JSObject {
  @JS('done')
  external bool get done;

  @JS('value')
  external JSString get value;
}

class ChromeAI {
  JSObject? _model;

  Future<bool> isAvailable() async {
    if (windowAI == null) return false;
    return true; 
  }

  Future<void> warmup() async {
    if (windowAI == null) throw Exception('window.ai not available');
    final lm = windowAI!.languageModel;
    _model = await lm.create(null).toDart;
  }

  Future<String> generateContent(String prompt) async {
    if (_model == null) {
      await warmup();
    }
    final response = await _model!.prompt(prompt.toJS).toDart;
    return response.toDart;
  }

  Stream<String> generateContentStream(String prompt) {
    final controller = StreamController<String>();
    
    warmup().then((_) {
      final stream = _model!.promptStreaming(prompt.toJS);
      final reader = stream.getReader();
      
      void readNext() {
        reader.read().toDart.then((result) {
          if (result.done) {
            controller.close();
            return;
          }
          controller.add(result.value.toDart);
          readNext();
        }).catchError((e) {
          controller.addError(e);
          controller.close();
        });
      }
      
      readNext();
    }).catchError((e) {
      controller.addError(e);
      controller.close();
    });
    
    return controller.stream;
  }
}
