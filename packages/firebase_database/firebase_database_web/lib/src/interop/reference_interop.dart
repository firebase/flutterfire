part of firebase.database_interop;

@JS('TransactionResult')
abstract class TransactionResultJsImpl {
  external dynamic toJSON();
  external bool get committed;
  external DataSnapshotJsImpl get snapshot;
}

@JS('Reference')
abstract class ReferenceJsImpl extends QueryJsImpl {
  external String? get key;

  external ReferenceJsImpl? get parent;

  external ReferenceJsImpl get root;
}
