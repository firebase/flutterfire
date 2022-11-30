Project: /docs/database/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Read and Write Data

## (Optional) Prototype and test with Firebase Emulator Suite

Before talking about how your app reads from and writes to Realtime Database,
let's introduce a set of tools you can use to prototype and test Realtime Database
functionality: Firebase Emulator Suite. If you're trying out different data
models, optimizing your security rules, or working to find the most
cost-effective way to interact with the back-end, being able to work locally
without deploying live services can be a great idea.

A Realtime Database emulator is part of the Emulator Suite, which
enables your app to interact with your emulated database content and config, as
well as optionally your emulated project resources (functions, other databases,
and security rules).emulator_suite_short

Using the Realtime Database emulator involves just a few steps:

1.  Adding a line of code to your app's test config to connect to the emulator.
1.  From the root of your local project directory, running `firebase emulators:start`.
1.  Making calls from your app's prototype code using a Realtime Database platform
    SDK as usual, or using the Realtime Database REST API.

A detailed [walkthrough involving Realtime Database and Cloud Functions](/docs/emulator-suite/connect_and_prototype?database=RTDB) is available. You should also have a look at the [Emulator Suite introduction](/docs/emulator-suite/).

## Get a DatabaseReference

To read or write data from the database, you need an instance of
`DatabaseReference`:

```dart
DatabaseReference ref = FirebaseDatabase.instance.ref();
```

## Write data

This document covers the basics of reading and writing Firebase data.

Firebase data is written to a `DatabaseReference` and retrieved by
awaiting or listening for events emitted by the reference. Events are emitted
once for the initial state of the data and again anytime the data changes.

<<_usecase_security_preamble.md>>

### Basic write operations {:#basic_write}

For basic write operations, you can use `set()` to save data to a specified
reference, replacing any existing data at that path. You can set a reference
to the following types: `String`, `boolean`, `int`, `double`, `Map`, `List`.

For instance, you can add a user with `set()` as follows:

```dart
DatabaseReference ref = FirebaseDatabase.instance.ref("users/123");

await ref.set({
  "name": "John",
  "age": 18,
  "address": {
    "line1": "100 Mountain View"
  }
});
```

Using `set()` in this way overwrites data at the specified location,
including any child nodes. However, you can still update a child without
rewriting the entire object. If you want to allow users to update their profiles
you could update the username as follows:

```dart
DatabaseReference ref = FirebaseDatabase.instance.ref("users/123");

// Only update the name, leave the age and address!
await ref.update({
  "age": 19,
});
```

The `update()` method accepts a sub-path to nodes, allowing you to update multiple
nodes on the database at once:

```dart
DatabaseReference ref = FirebaseDatabase.instance.ref("users");

await ref.update({
  "123/age": 19,
  "123/address/line1": "1 Mountain View",
});
```

## Read data

### Read data by listening for value events {:#read_value_events}

To read data at a path and listen for changes, use the
`onValue` property of `DatabaseReference` to listen for
`DatabaseEvent`s.

You can use the `DatabaseEvent` to read the data at a given path,
as it exists at the time of the event. This event is triggered once when the
listener is attached and again every time the data, including any children,
changes. The event has a `snapshot` property containing all data at that
location, including child data. If there is no data, the snapshot's
`exists` property will be `false` and its `value` property will be null.

Important: A `DatabaseEvent` is fired every time data is changed at
the specified database reference, including changes to children. To limit the
size of your snapshots, attach only at the highest level needed for watching
changes. For example, attaching a listener to the root of your database is
not recommended.

The following example demonstrates a social blogging application retrieving the
details of a post from the database:

```dart
DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('posts/$postId/starCount');
starCountRef.onValue.listen((DatabaseEvent event) {
    final data = event.snapshot.value;
    updateStarCount(data);
});
```

The listener receives a `DataSnapshot` that contains the data at the specified
location in the database at the time of the event in its `value` property.

### Read data once

#### Read once using get()

The SDK is designed to manage interactions with database servers whether your
app is online or offline.

Generally, you should use the value events techniques described above to read
data to get notified of updates to the data from the backend. Those technique
reduce your usage and billing, and are optimized to give your users the best
experience as they go online and offline.

If you need the data only once, you can use `get()` to get a snapshot of the
data from the database. If for any reason `get()` is unable to return the
server value, the client will probe the local storage cache and return an error
if the value is still not found.

The following example demonstrates retrieving a user's public-facing username
a single time from the database:

```dart
final ref = FirebaseDatabase.instance.ref();
final snapshot = await ref.child('users/$userId').get();
if (snapshot.exists) {
    print(snapshot.value);
} else {
    print('No data available.');
}
```

Unnecessary use of `get()` can increase use of bandwidth and lead to loss
of performance, which can be prevented by using a realtime listener as shown
above.

#### Read data once with once()

In some cases you may want the value from the local cache to be returned
immediately, instead of checking for an updated value on the server. In those
cases you can use `once()` to get the data from the local disk cache
immediately.

This is useful for data that only needs to be loaded once and isn't expected to
change frequently or require active listening. For instance, the blogging app
in the previous examples uses this method to load a user's profile when they
begin authoring a new post:

```dart
final event = await ref.once(DatabaseEventType.value);
final username = event.snapshot.value?.username ?? 'Anonymous';
```

## Updating or deleting data

### Update specific fields

To simultaneously write to specific children of a node without overwriting other
child nodes, use the `update()` method.

<a href="" id="fan-out"></a>
When calling `update()`, you can update lower-level child values by
specifying a path for the key. If data is stored in multiple locations to scale
better, you can update all instances of that data using
[data fan-out](structure-data#fanout). For example, a
social blogging app might want to create a post and simultaneously update it to
the recent activity feed and the posting user's activity feed. To do this, the
blogging application uses code like this:

```dart
void writeNewPost(String uid, String username, String picture, String title,
        String body) async {
    // A post entry.
    final postData = {
        'author': username,
        'uid': uid,
        'body': body,
        'title': title,
        'starCount': 0,
        'authorPic': picture,
    };

    // Get a key for a new Post.
    final newPostKey =
        FirebaseDatabase.instance.ref().child('posts').push().key;

    // Write the new post's data simultaneously in the posts list and the
    // user's post list.
    final Map<String, Map> updates = {};
    updates['/posts/$newPostKey'] = postData;
    updates['/user-posts/$uid/$newPostKey'] = postData;

    return FirebaseDatabase.instance.ref().update(updates);
}
```

This example uses `push()` to create a post in the node containing posts for
all users at `/posts/$postid` and simultaneously retrieve the key with
`key`. The key can then be used to create a second entry in the user's
posts at `/user-posts/$userid/$postid`.

Using these paths, you can perform simultaneous updates to multiple locations in
the JSON tree with a single call to `update()`, such as how this example
creates the new post in both locations. Simultaneous updates made this way
are atomic: either all updates succeed or all updates fail.

### Add a completion callback

If you want to know when your data has been committed, you can register
completion callbacks. Both `set()` and `update()` return `Future`s, to which
you can attach success and error callbacks that are called when the write has
been committed to the database and when the call was unsuccessful.

```dart
FirebaseDatabase.instance
    .ref('users/$userId/email')
    .set(emailAddress)
    .then((_) {
        // Data saved successfully!
    })
    .catchError((error) {
        // The write failed...
    });
```

### Delete data

The simplest way to delete data is to call `remove()` on a reference to the
location of that data.

You can also delete by specifying null as the value for another write operation
such as `set()` or `update()`. You can use this technique with `update()` to
delete multiple children in a single API call.

## Save data as transactions

When working with data that could be corrupted by concurrent modifications,
such as incremental counters, you can use a transaction by passing a 
transaction handler to `runTransaction()`. A transaction handler takes the
current state of the data as an argument and
returns the new desired state you would like to write. If another client
writes to the location before your new value is successfully written, your
update function is called again with the new current value, and the write is
retried.

For instance, in the example social blogging app, you could allow users to star
and unstar posts and keep track of how many stars a post has received as follows:

```dart
void toggleStar(String uid) async {
  DatabaseReference postRef =
      FirebaseDatabase.instance.ref("posts/foo-bar-123");

  TransactionResult result = await postRef.runTransaction((Object? post) {
    // Ensure a post at the ref exists.
    if (post == null) {
      return Transaction.abort();
    }

    Map<String, dynamic> _post = Map<String, dynamic>.from(post as Map);
    if (_post["stars"] is Map && _post["stars"][uid] != null) {
      _post["starCount"] = (_post["starCount"] ?? 1) - 1;
      _post["stars"][uid] = null;
    } else {
      _post["starCount"] = (_post["starCount"] ?? 0) + 1;
      if (!_post.containsKey("stars")) {
        _post["stars"] = {};
      }
      _post["stars"][uid] = true;
    }

    // Return the new data.
    return Transaction.success(_post);
  });
}
```

By default, events are raised each time the transaction update function runs,
so you run the function run multiple times, you may see intermediate states.
You can set `applyLocally` to `false` to suppress these intermediate states and
instead wait until the transaction has completed before events are raised:

```dart
await ref.runTransaction((Object? post) {
  // ...
}, applyLocally: false);
```

The result of a transaction is a `TransactionResult`, which contains information
such as whether the transaction was committed, and the new snapshot:

```dart
DatabaseReference ref = FirebaseDatabase.instance.ref("posts/123");

TransactionResult result = await ref.runTransaction((Object? post) {
  // ...
});

print('Committed? ${result.committed}'); // true / false
print('Snapshot? ${result.snapshot}'); // DataSnapshot
```

### Cancelling a transaction

If you want to safely cancel a transaction, call `Transaction.abort()` to 
throw an `AbortTransactionException`:

```dart
TransactionResult result = await ref.runTransaction((Object? user) {
  if (user !== null) {
    return Transaction.abort();
  }

  // ...
});

print(result.committed); // false
```

### Atomic server-side increments

In the above use case we're writing two values to the database: the ID of
the user who stars/unstars the post, and the incremented star count. If we
already know that user is starring the post, we can use an atomic increment
operation instead of a transaction.

```dart
void addStar(uid, key) async {
  Map<String, Object?> updates = {};
  updates["posts/$key/stars/$uid"] = true;
  updates["posts/$key/starCount"] = ServerValue.increment(1);
  updates["user-posts/$key/stars/$uid"] = true;
  updates["user-posts/$key/starCount"] = ServerValue.increment(1);
  return FirebaseDatabase.instance.ref().update(updates);
}
```

This code does not use a transaction operation, so it does not automatically get
re-run if there is a conflicting update. However, since the increment operation
happens directly on the database server, there is no chance of a conflict.

If you want to detect and reject application-specific conflicts, such as a user
starring a post that they already starred before, you should write custom
security rules for that use case.

## Work with data offline

If a client loses its network connection, your app will continue functioning
correctly.

Every client connected to a Firebase database maintains its own internal version
of any active data. When data is written, it's written to this local version
first. The Firebase client then synchronizes that data with the remote database
servers and with other clients on a "best-effort" basis.

As a result, all writes to the database trigger local events immediately, before
any data is written to the server. This means your app remains
responsive regardless of network latency or connectivity.

Once connectivity is reestablished, your app receives the appropriate set of
events so that the client syncs with the current server state, without having to
write any custom code.

Note: The Firebase Realtime Database web APIs do not persist data offline outside
of the session. In order for writes to be persisted to the server, the web
page must not be closed before the data is written to the server

We'll talk more about offline behavior in
[Learn more about online and offline capabilities](offline-capabilities).

## Next steps

* [Working with lists of data](lists-of-data)
* [Learn how to structure data](structure-data)
* [Learn more about online and offline capabilities](offline-capabilities)
