package dev.flutter.plugins.firebaseperformance;

import android.util.SparseArray;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FirebasePerformancePluginHandler implements MethodChannel.MethodCallHandler {
  private final SparseArray<MethodChannel.MethodCallHandler> handlers = new SparseArray<>();

  void addHandler(final int handle, final MethodChannel.MethodCallHandler handler) {
    if (handlers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    handlers.put(handle, handler);
  }

  void removeHandler(final int handle) {
    handlers.remove(handle);
  }

  private MethodChannel.MethodCallHandler getHandler(final MethodCall call) {
    final Integer handle = call.argument("handle");

    if (handle == null) return null;
    return handlers.get(handle);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("FirebasePerformance#instance")) {
      handlers.clear();
      final Integer handle = call.argument("handle");
      addHandler(handle, new FlutterFirebasePerformance(this));
      result.success(null);
    } else {
      final MethodChannel.MethodCallHandler handler = getHandler(call);

      if (handler != null) {
        handler.onMethodCall(call, result);
      } else {
        result.notImplemented();
      }
    }
  }
}
