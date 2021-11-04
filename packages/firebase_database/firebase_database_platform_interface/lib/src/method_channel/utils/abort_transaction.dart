import 'package:firebase_core/firebase_core.dart';

class AbortTransaction extends FirebaseException {
  AbortTransaction()
      : super(
          plugin: 'firebase_database',
          code: 'abort-transaction',
          message: 'Transaction was aborted by user',
        );
}
