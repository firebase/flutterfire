part of firebase.database_interop;

@JS('Reference')
abstract class ReferenceJsImpl extends QueryJsImpl {
  external String get key;

  external set key(String s);

  external ReferenceJsImpl get parent;

  external set parent(ReferenceJsImpl r);

  external ReferenceJsImpl get root;

  external set root(ReferenceJsImpl r);

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

  external PromiseJsImpl<TransactionJsImpl> transaction(
    void Function(dynamic) transactionUpdate, [
    dynamic Function(Object, bool, DataSnapshotJsImpl) onComplete,
    bool applyLocally,
  ]);

  external PromiseJsImpl<void> update(
    values, [
    void Function(dynamic) onComplete,
  ]);
}
