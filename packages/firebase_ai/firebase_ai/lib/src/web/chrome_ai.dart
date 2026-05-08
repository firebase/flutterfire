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

/// JS Interop for window.ai
@JS('window.ai')
external JSObject? get windowAI;

/// Extension on JSObject for window.ai
extension WindowAIExtension on JSObject {
  /// Access the language model API.
  @JS('languageModel')
  external JSObject get languageModel;
}

/// Extension on JSObject for languageModel
extension LanguageModelExtension on JSObject {
  /// Create a new model instance.
  @JS('create')
  external JSPromise<JSObject> create(JSObject? options);
}

/// Extension on JSObject for model instance
extension ModelInstanceExtension on JSObject {
  /// Prompt the model for a non-streaming response.
  @JS('prompt')
  external JSPromise<JSString> prompt(JSString input);

  /// Prompt the model for a streaming response.
  @JS('promptStreaming')
  external JSObject promptStreaming(JSString input);
}

/// Extension on JSObject for ReadableStream
extension ReadableStreamExtension on JSObject {
  /// Get a reader for the stream.
  @JS('getReader')
  external JSObject getReader();
}

/// Extension on JSObject for ReadableStreamDefaultReader
extension ReadableStreamDefaultReaderExtension on JSObject {
  /// Read a chunk from the stream.
  @JS('read')
  external JSPromise<JSObject> read();
}

/// Extension on JSObject for ReadableStreamDefaultReadResult
extension ReadableStreamDefaultReadResultExtension on JSObject {
  /// Indicates if the stream is done.
  @JS('done')
  external bool get done;

  /// The chunk value.
  @JS('value')
  external JSString get value;
}

/// Wrapper for Chrome's window.ai API.
class ChromeAI {
  JSObject? _model;

  /// Checks if window.ai is available.
  Future<bool> isAvailable() async {
    if (windowAI == null) return false;
    return true; 
  }

  /// Warms up the model (creates an instance).
  Future<void> warmup() async {
    if (windowAI == null) throw Exception('window.ai not available');
    final lm = windowAI!.languageModel;
    _model = await lm.create(null).toDart;
  }

  /// Generates content for a prompt.
  Future<String> generateContent(String prompt) async {
    if (_model == null) {
      await warmup();
    }
    final response = await _model!.prompt(prompt.toJS).toDart;
    return response.toDart;
  }

  /// Generates a stream of content for a prompt.
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
