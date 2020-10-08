/// Firebase is a global namespace from which all the Firebase
/// services are accessed.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase>.
library firebase_interop;

export 'src/analytics.dart';
export 'src/app.dart';
export 'src/auth.dart';
// export 'src/database.dart';
// TODO(ehesp): fix naming conflicts
export 'src/firestore.dart' hide jsifyFieldValue;
export 'src/functions.dart';
export 'src/messaging.dart';
export 'src/performance.dart';
export 'src/remote_config.dart';
export 'src/storage.dart';
export 'src/top_level.dart';
