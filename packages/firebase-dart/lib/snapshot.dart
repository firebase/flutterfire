part of Firebase;

/**
 * A DataSnapshot contains data from a Firebase location. Any time you read
 * Firebase data, you receive data as a DataSnapshot.
 *
 * DataSnapshots are passed to event handlers such as onValue or onceValue.
 * You can extract the contents of the snapshot by calling val(), or you
 * can traverse into the snapshot by calling child() to return child
 * snapshots (which you could in turn call val() on).
 */
class DataSnapshot {
  /**
   * Holds a reference to the JavaScript 'DataSnapshot' object.
   */
  JsObject _ds;

  /**
   * Construct a new DataSnapshot from a JsObject.
   */
  DataSnapshot.fromJsObject(JsObject obj) {
    this._ds = obj;
  }

  /**
   * Get the Dart Primitive, Map or List representation of the DataSnapshot.
   * The value may be null, indicating that the snapshot is empty and contains
   * no data.
   */
  val() {
    var obj = this._ds.callMethod('val');
    var json = context['JSON'].callMethod('stringify', [obj]);
    return JSON.decode(json);
  }

  /**
   * Get a DataSnapshot for the location at the specified relative path. The
   * relative path can either bve a simple child name or a deeper slash
   * seperated path.
   */
  DataSnapshot child(String path) {
    return new DataSnapshot.fromJsObject(this._ds.callMethod('child', [path]));
  }

  /**
   * Enumerate through the DataSnapshot's children (in priority order). The
   * provided callback will be called synchronously with a DataSnapshot for
   * each child.
   */
  forEach(cb(DataSnapshot snapshot)) {
    this._ds.callMethod('forEach', [(obj) {
      cb(new DataSnapshot.fromJsObject(obj));
    }]);
  }

  /**
   * Returns true if the specified child exists.
   */
  bool hasChild(String path) {
    return this._ds.callMethod('hasChild', [path]);
  }

  /**
   * Returns true if the DataSnapshot has any children. If it does, you can
   * enumerate them with forEach. If it does not, then the snapshot either
   * contains a primitive value or it is empty.
   */
  bool hasChildren() {
    return this._ds.callMethod('hasChildren');
  }

  /**
   * Get the name of the location that generated this DataSnapshot.
   */
  String name() {
    return this._ds.callMethod('name');
  }

  /**
   * Get the number of children for this DataSnapshot. If it has children,
   * you can enumerate them with forEach().
   */
  num numChildren() {
    return this._ds.callMethod('numChildren');
  }

  /**
   * Get the Firebsae reference for the location that generated this
   * DataSnapshot.
   */
  Firebase ref() {
    return new Firebase.fromJsObject(this._ds.callMethod('ref'));
  }

  /**
   * Get the priority of the data in this DataSnapshot.
   */
  getPriority() {
    return this._ds.callMethod('getPriority');
  }

  /**
   * Exports the entire contents of the DataSnapshot as a Dart Map. This is
   * similar to val(), except priority information is included, making it
   * suitable for backing up your data.
   */
  exportVal() {
    var obj = this._ds.callMethod('exportVal');
    var json = context['JSON'].callMethod('stringify', [obj]);
    return JSON.decode(json);
  }
}
