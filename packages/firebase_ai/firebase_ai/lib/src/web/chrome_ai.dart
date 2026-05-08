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
}
