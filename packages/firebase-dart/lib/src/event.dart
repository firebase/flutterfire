library firebase.event;

import 'data_snapshot.dart';

/**
 * An Event is an object that is provided by every Stream on the query
 * object.
 *
 * It is simply a wrapper for a tuple of DataSnapshot and PrevChild.
 * Some events (like added, moved or changed) have a prevChild argument
 * that is the name of the object that is before the object referred by the
 * event in priority order.
 */
class Event {
  final DataSnapshot snapshot;
  final String prevChild;
  Event(this.snapshot, this.prevChild);
}
