part of firebase.database_interop;

@JS('TransactionResult')
abstract class TransactionResultJsImpl {
  external dynamic toJson();
}

@JS('Reference')
abstract class ReferenceJsImpl extends QueryJsImpl {
  external String? get key;

  external ReferenceJsImpl? get parent;

  external ReferenceJsImpl get root;

  external ReferenceJsImpl child(String path);

  external OnDisconnectJsImpl onDisconnect();

  external ThenableReferenceJsImpl push([
    value,
    void Function(dynamic) onComplete,
  ]);

  external PromiseJsImpl<void> remove([void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> set(value, [void Function(dynamic) onComplete]);

  external PromiseJsImpl<void> setPriority(
    priority, [
    void Function(dynamic) onComplete,
  ]);

  external PromiseJsImpl<void> setWithPriority(
    newVal,
    newPriority, [
    void Function(dynamic) onComplete,
  ]);

  external PromiseJsImpl<TransactionResultJsImpl> transaction(
    void Function(dynamic) transactionUpdate, [
    void Function(dynamic, bool, DataSnapshotJsImpl) onComplete,
    bool applyLocally,
  ]);

  external PromiseJsImpl<void> update(
    values, [
    void Function(dynamic) onComplete,
  ]);
}
