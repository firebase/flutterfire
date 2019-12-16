import 'dart:async';

import 'package:flutter/services.dart';

typedef _MultiMethodChannelHandler(MethodCall call);

class MultiMethodChannel extends MethodChannel {
  MultiMethodChannel(name, [codec = const StandardMethodCodec(), BinaryMessenger binaryMessenger ])
      : super(name, codec, binaryMessenger) {
        // Register this as handler
        super.setMethodCallHandler(_methodCallHandler);
      }
  
  Map<String, _MultiMethodChannelHandler> _multiMethodChannelHandlers = <String, _MultiMethodChannelHandler>{};

  Future<dynamic> _methodCallHandler(MethodCall call) {
    _MultiMethodChannelHandler handler = _multiMethodChannelHandlers[call.method];
    return (handler != null) ? handler(call) : null;
  }

  void addMethodCallHandler(String method, _MultiMethodChannelHandler handler) {
    assert(!_multiMethodChannelHandlers.containsKey(method), 'A handler for method $method has already been registered!');
    _multiMethodChannelHandlers[method] = handler;
  }

  void removeMethodCallHandler(String method) {
    _multiMethodChannelHandlers.remove(method);
  }

  @override
  @Deprecated('MultiMethodChannel doesn\'t support setMethodCallHandler, and will throw at runtime. Use addMethodCallHandler (or a base MethodChannel instead).')
  void setMethodCallHandler(Future<dynamic> handler(MethodCall call)) {
    throw UnsupportedError('MultiMethodChannel doesn\'t support setMethodCallHandler. Use addMethodCallHandler (or use a normal MethodChannel instead).');
  }
}
