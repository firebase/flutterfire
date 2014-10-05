library firebase.snapshot;

import 'dart:convert';
import 'dart:js';

import 'firebase.dart';

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
  final JsObject _ds;

  /**
   * Construct a new DataSnapshot from a JsObject.
   */
  DataSnapshot.fromJsObject(JsObject obj): _ds = obj;

  /**
   * Get the Dart Primitive, Map or List representation of the DataSnapshot.
   * The value may be null, indicating that the snapshot is empty and contains
   * no data.
   */
  dynamic val() {
    var obj = _ds.callMethod('val');
    var json = context['JSON'].callMethod('stringify', [obj]);
    return JSON.decode(json);
  }

  /**
   * Get a DataSnapshot for the location at the specified relative path. The
   * relative path can either bve a simple child name or a deeper slash
   * seperated path.
   */
  DataSnapshot child(String path) =>
      new DataSnapshot.fromJsObject(_ds.callMethod('child', [path]));

  /**
   * Enumerate through the DataSnapshot's children (in priority order). The
   * provided callback will be called synchronously with a DataSnapshot for
   * each child.
   */
  void forEach(cb(DataSnapshot snapshot)) {
    _ds.callMethod('forEach', [(obj) {
      cb(new DataSnapshot.fromJsObject(obj));
    }]);
  }

  /**
   * Returns true if the specified child exists.
   */
  bool hasChild(String path) => _ds.callMethod('hasChild', [path]);

  /**
   * `true` if the DataSnapshot has any children.
   *
   * If it does, you can enumerate them with forEach. If not, then the
   * snapshot either contains a primitive value or it is empty.
   */
  bool get hasChildren => _ds.callMethod('hasChildren');

  /**
   * The name of the location that generated this DataSnapshot.
   */
  String get name => _ds.callMethod('name');

  /**
   * The number of children for this DataSnapshot. If it has children,
   * you can enumerate them with forEach().
   */
  int get numChildren => _ds.callMethod('numChildren');

  /**
   * Get the Firebsae reference for the location that generated this
   * DataSnapshot.
   */
  Firebase ref() => new Firebase.fromJsObject(_ds.callMethod('ref'));

  /**
   * Get the priority of the data in this DataSnapshot.
   */
  dynamic getPriority() => _ds.callMethod('getPriority');

  /**
   * Exports the entire contents of the DataSnapshot as a Dart Map. This is
   * similar to val(), except priority information is included, making it
   * suitable for backing up your data.
   */
  dynamic exportVal() {
    var obj = _ds.callMethod('exportVal');
    var json = context['JSON'].callMethod('stringify', [obj]);
    return JSON.decode(json);
  }
}
