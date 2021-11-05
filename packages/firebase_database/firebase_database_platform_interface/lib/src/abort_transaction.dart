import 'package:firebase_core/firebase_core.dart';

class AbortTransactionException extends FirebaseException {
  AbortTransactionException()
      : super(
          plugin: 'firebase_database',
          code: 'abort-transaction',
          message: 'Transaction was aborted by user',
        );
}
