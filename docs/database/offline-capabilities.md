Project: /docs/database/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Enabling Offline Capabilities

Firebase applications work even if your app temporarily loses its network
connection. In addition, Firebase provides tools for persisting data locally,
managing presence, and handling latency.

## Disk Persistence {:#section-disk-persistence}

Firebase apps automatically handle temporary network interruptions.
Cached data is available while offline and Firebase resends any writes
when network connectivity is restored.

When you enable disk persistence, your app writes the data locally to the
device so your app can maintain state while offline, even if the user
or operating system restarts the app.

You can enable disk persistence with just one line of code.

```dart
FirebaseDatabase.instance.setPersistenceEnabled(true);
```

### Persistence Behavior {:#section-offline-behavior}

By enabling persistence, any data that the Firebase Realtime Database client
would sync while online persists to disk and is available offline,
even when the user or operating system restarts the app. This means your
app works as it would online by using the local data stored in the cache.
Listener callbacks will continue to fire for local updates.

The Firebase Realtime Database client automatically keeps a queue of all
write operations that are performed while your app is offline.
When persistence is enabled, this queue is also persisted to disk so all
of your writes are available when the user or operating system
restarts the app. When the app regains connectivity, all of
the operations are sent to the Firebase Realtime Database server.

If your app uses [Firebase Authentication](/docs/auth),
the Firebase Realtime Database client persists the user's authentication
token across app restarts.
If the auth token expires while your app is offline, the client pauses
write operations until your app re-authenticates the user, otherwise the
write operations might fail due to security rules.

### Keeping Data Fresh {:#section-prioritizing-the-local-cache}

The Firebase Realtime Database synchronizes and stores a local copy of the
data for active listeners. In addition, you can keep specific locations
in sync.

```dart
final scoresRef = FirebaseDatabase.instance.ref("scores");
scoresRef.keepSynced(true);
```

The Firebase Realtime Database client automatically downloads the data at
these locations and keeps it in sync even if the reference has no
active listeners. You can turn synchronization back off with the
following line of code.

```dart
scoresRef.keepSynced(false);
```

By default, 10MB of previously synced data is cached. This should be
enough for most applications. If the cache outgrows its configured size,
the Firebase Realtime Database purges data that has been used least recently.
Data that is kept in sync is not purged from the cache.

### Querying Data Offline {:#section-offline-queries}

The Firebase Realtime Database stores data returned from a query for use
when offline. For queries constructed while offline,
the Firebase Realtime Database continues to work for previously loaded data.
If the requested data hasn't loaded, the Firebase Realtime Database loads
data from the local cache. When network connectivity is available again,
the data loads and will reflect the query.

For example, this code queries for the last four items in a database of scores:

```dart
final scoresRef = FirebaseDatabase.instance.ref("scores");
scoresRef.orderByValue().limitToLast(4).onChildAdded.listen((event) {
  debugPrint("The ${event.snapshot.key} dinosaur's score is ${event.snapshot.value}.");
});
```

Assume that the user loses connection, goes offline, and restarts the app.
While still offline, the app queries for the last two items from the
same location. This query will successfully return the last two items
because the app had loaded all four items in the query above.

```dart
scoresRef.orderByValue().limitToLast(2).onChildAdded.listen((event) {
  debugPrint("The ${event.snapshot.key} dinosaur's score is ${event.snapshot.value}.");
});
```

In the preceding example, the Firebase Realtime Database client raises
'child added' events for the highest scoring two dinosaurs, by using the
persisted cache. But it will not raise a 'value' event, since the app has
never executed that query while online.

If the app were to request the last six items while offline, it would get
'child added' events for the four cached items straight away. When the
device comes back online, the Firebase Realtime Database client synchronizes
with the server and gets the final two 'child added' and the
'value' events for the app.

### Handling Transactions Offline {:#section-handling-transactions-offline}

Any transactions that are performed while the app is offline, are queued.
Once the app regains network connectivity, the transactions are sent to
the Realtime Database server.

Note: **Transactions are not persisted across app restarts.**
Even with persistence enabled, transactions are not persisted across
app restarts. So you cannot rely on transactions done offline
being committed to your Firebase Realtime Database. To provide the best
user experience, your app should show that a transaction has not
been saved into your Firebase Realtime Database yet, or make sure your
app remembers them manually and executes them again after an app
restart.



The Firebase Realtime Database has many features for dealing with offline
scenarios and network connectivity. The rest of this guide applies to
your app whether or not you have persistence enabled.

## Managing Presence {:#section-presence}

In realtime applications it is often useful to detect when clients
connect and disconnect. For example, you may
want to mark a user as 'offline' when their client disconnects.

Firebase Database clients provide simple primitives that you can use to
write to the database when a client disconnects from the Firebase Database
servers. These updates occur whether the client disconnects cleanly or not,
so you can rely on them to clean up data even if a connection is dropped
or a client crashes. All write operations, including setting,
updating, and removing, can be performed upon a disconnection.

Here is a simple example of writing data upon disconnection by using the
`onDisconnect` primitive:

```dart
final presenceRef = FirebaseDatabase.instance.ref("disconnectmessage");
// Write a string when this client loses connection
presenceRef.onDisconnect().set("I disconnected!");
```

### How onDisconnect Works

When you establish an `onDisconnect()` operation, the operation
lives on the Firebase Realtime Database server. The server checks security to
make sure the user can perform the write event requested, and informs
the your app if it is invalid. The server then
monitors the connection. If at any point the connection times out, or is
actively closed by the Realtime Database client, the server checks security a
second time (to make sure the operation is still valid) and then invokes
the event.

```dart
try {
    await presenceRef.onDisconnect().remove();
} catch (error) {
    debugPrint("Could not establish onDisconnect event: $error");
}
```

An onDisconnect event can also be canceled by calling `.cancel()`:

```dart
final onDisconnectRef = presenceRef.onDisconnect();
onDisconnectRef.set("I disconnected");
// ...
// some time later when we change our minds
// ...
onDisconnectRef.cancel();
```

## Detecting Connection State {:#section-connection-state}

For many presence-related features, it is useful for your app
to know when it is online or offline. Firebase Realtime Database
provides a special location at `/.info/connected` which
is updated every time the Firebase Realtime Database client's connection state
changes. Here is an example:

```dart
final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
connectedRef.onValue.listen((event) {
  final connected = event.snapshot.value as bool? ?? false;
  if (connected) {
    debugPrint("Connected.");
  } else {
    debugPrint("Not connected.");
  }
});
```

`/.info/connected` is a boolean value which is not
synchronized between Realtime Database clients because the value is
dependent on the state of the client. In other words, if one client
reads `/.info/connected` as false, this is no
guarantee that a separate client will also read false.

## Handling Latency {:#section-latency}

### Server Timestamps

The Firebase Realtime Database servers provide a mechanism to insert
timestamps generated on the server as data. This feature, combined with
`onDisconnect`, provides an easy way to reliably make note of
the time at which a Realtime Database client disconnected:

```dart
final userLastOnlineRef =
    FirebaseDatabase.instance.ref("users/joe/lastOnline");
userLastOnlineRef.onDisconnect().set(ServerValue.timestamp);
```

### Clock Skew

While `ServerValue.timestamp` is much more
accurate, and preferable for most read/write operations,
it can occasionally be useful to estimate the client's clock skew with
respect to the Firebase Realtime Database's servers. You
can attach a callback to the location `/.info/serverTimeOffset`
to obtain the value, in milliseconds, that Firebase Realtime Database clients
add to the local reported time (epoch time in milliseconds) to estimate
the server time. Note that this offset's accuracy can be affected by
networking latency, and so is useful primarily for discovering
large (> 1 second) discrepancies in clock time.

```dart
final offsetRef = FirebaseDatabase.instance.ref(".info/serverTimeOffset");
offsetRef.onValue.listen((event) {
  final offset = event.snapshot.value as num? ?? 0.0;
  final estimatedServerTimeMs =
      DateTime.now().millisecondsSinceEpoch + offset;
});
```

## Sample Presence App {:#section-sample}

By combining disconnect operations with connection state monitoring and
server timestamps, you can build a user presence system. In this system,
each user stores data at a database location to indicate whether or not a
Realtime Database client is online. Clients set this location to true when
they come online and a timestamp when they disconnect. This timestamp
indicates the last time the given user was online.

Note that your app should queue the disconnect operations before a user is
marked online, to avoid any race conditions in the event that the client's
network connection is lost before both commands can be sent to the server.

```dart
// Since I can connect from multiple devices, we store each connection
// instance separately any time that connectionsRef's value is null (i.e.
// has no children) I am offline.
final myConnectionsRef =
    FirebaseDatabase.instance.ref("users/joe/connections");

// Stores the timestamp of my last disconnect (the last time I was seen online)
final lastOnlineRef =
    FirebaseDatabase.instance.ref("/users/joe/lastOnline");

final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
connectedRef.onValue.listen((event) {
  final connected = event.snapshot.value as bool? ?? false;
  if (connected) {
    final con = myConnectionsRef.push();

    // When this device disconnects, remove it.
    con.onDisconnect().remove();

    // When I disconnect, update the last time I was seen online.
    lastOnlineRef.onDisconnect().set(ServerValue.timestamp);

    // Add this device to my connections list.
    // This value could contain info about the device or a timestamp too.
    con.set(true);
  }
});
```
