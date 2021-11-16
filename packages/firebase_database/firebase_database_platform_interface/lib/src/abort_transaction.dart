import 'package:firebase_core/firebase_core.dart';

class AbortTransactionException extends FirebaseException {
  AbortTransactionException([String? message])
      : super(
          plugin: 'firebase_database',
          code: 'abort-transaction',
          message: message ?? 'Transaction was aborted by user.',
        );
}
