import 'dart:async';

import 'auth.dart';
import 'database.dart';
import 'firestore.dart';
import 'functions.dart';
import 'interop/app_interop.dart';
import 'interop/firebase_interop.dart';
import 'js.dart';
import 'storage.dart';
import 'utils.dart';

export 'interop/firebase_interop.dart' show FirebaseError, FirebaseOptions;

/// A Firebase App holds the initialization information for a collection
/// of services.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.app>.
class App extends JsObjectWrapper<AppJsImpl> {
  static final _expando = Expando<App>();

  /// Name of the app.
  String get name => jsObject.name;

  /// Options used during [firebase.initializeApp()].
  FirebaseOptions get options => jsObject.options;

  /// Creates a new App from a [jsObject].
  static App getInstance(AppJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= App._fromJsObject(jsObject);
  }

  App._fromJsObject(AppJsImpl jsObject) : super.fromJsObject(jsObject);

  /// Returns [Auth] service.
  Auth auth() => Auth.getInstance(jsObject.auth());

  /// Returns [Database] service.
  Database database() => Database.getInstance(jsObject.database());

  /// Deletes the app and frees resources of all App's services.
  Future delete() => handleThenable(jsObject.delete());

  /// Returns [Storage] service optionally initialized with a custom storage bucket.
  Storage storage([String url]) {
    var jsObjectStorage =
        (url != null) ? jsObject.storage(url) : jsObject.storage();
    return Storage.getInstance(jsObjectStorage);
  }

  /// Returns [Firestore] service.
  Firestore firestore() => Firestore.getInstance(jsObject.firestore());

  /// Returns [Functions] service.
  Functions functions([String region]) {
    if (region == null) {
      return Functions.getInstance(jsObject.functions());
    }
    return Functions.getInstance(jsObject.functions(region));
  }
}
