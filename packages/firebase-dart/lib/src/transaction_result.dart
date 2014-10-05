library firebase.transaction_result;

import 'data_snapshot.dart';

class TransactionResult {
  final Object error;
  final bool committed;
  final DataSnapshot snapshot;

  TransactionResult(this.error, this.committed, this.snapshot);
}
