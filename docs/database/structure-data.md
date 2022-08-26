Project: /docs/database/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Structure Your Database

This guide covers some of the key concepts in data architecture and best
practices for structuring the JSON data in your Firebase Realtime Database.

Building a properly structured database requires quite a bit of forethought.
Most importantly, you need to plan for how data is going to be saved and
later retrieved to make that process as easy as possible.

## How data is structured: it's a JSON tree

All Firebase Realtime Database data is stored as JSON objects. You can think of
the database as a cloud-hosted JSON tree. Unlike a SQL database, there are no
tables or records. When you add data to the JSON tree, it becomes a node in the
existing JSON structure with an associated key. You can provide your own keys,
such as user IDs or semantic names, or they can be provided for you using
`push()`.

If you create your own keys, they must be UTF-8 encoded, can be a maximum
of 768 bytes, and cannot contain `.`, `$`, `#`, `[`, `]`, `/`, or ASCII control
characters 0-31 or 127. You cannot use ASCII control characters in the values
themselves, either.
{: .note }

For example, consider a chat application that allows users to store a basic
profile and contact list. A typical user profile is located at a path, such as
`/users/$uid`. The user `alovelace` might have a database entry that
looks something like this:

```
{
  "users": {
    "alovelace": {
      "name": "Ada Lovelace",
      "contacts": { "ghopper": true },
    },
    "ghopper": { ... },
    "eclarke": { ... }
  }
}
```

Although the database uses a JSON tree, data stored in the database can be
represented as certain native types that correspond to available JSON types
to help you write more maintainable code.

## Best practices for data structure

### Avoid nesting data

Because the Firebase Realtime Database allows nesting data up to 32 levels deep,
you might be tempted to think that this should be the default structure.
However, when you fetch data at a location in your database, you also retrieve
all of its child nodes. In addition, when you grant someone read or write access
at a node in your database, you also grant them access to all data under that
node. Therefore, in practice, it's best to keep your data structure as flat
as possible.

For an example of why nested data is bad, consider the following
multiply-nested structure:

```
{
  // This is a poorly nested data architecture, because iterating the children
  // of the "chats" node to get a list of conversation titles requires
  // potentially downloading hundreds of megabytes of messages
  "chats": {
    "one": {
      "title": "Historical Tech Pioneers",
      "messages": {
        "m1": { "sender": "ghopper", "message": "Relay malfunction found. Cause: moth." },
        "m2": { ... },
        // a very long list of messages
      }
    },
    "two": { ... }
  }
}
```

With this nested design, iterating through the data becomes problematic. For
example, listing the titles of chat conversations requires the entire `chats`
tree, including all members and messages, to be downloaded to the client.


### Flatten data structures

If the data is instead split into separate paths, also called denormalization,
it can be efficiently downloaded in separate calls, as it is needed. Consider
this flattened structure:

```
{
  // Chats contains only meta info about each conversation
  // stored under the chats's unique ID
  "chats": {
    "one": {
      "title": "Historical Tech Pioneers",
      "lastMessage": "ghopper: Relay malfunction found. Cause: moth.",
      "timestamp": 1459361875666
    },
    "two": { ... },
    "three": { ... }
  },

  // Conversation members are easily accessible
  // and stored by chat conversation ID
  "members": {
    // we'll talk about indices like this below
    "one": {
      "ghopper": true,
      "alovelace": true,
      "eclarke": true
    },
    "two": { ... },
    "three": { ... }
  },

  // Messages are separate from data we may want to iterate quickly
  // but still easily paginated and queried, and organized by chat
  // conversation ID
  "messages": {
    "one": {
      "m1": {
        "name": "eclarke",
        "message": "The relay seems to be malfunctioning.",
        "timestamp": 1459361875337
      },
      "m2": { ... },
      "m3": { ... }
    },
    "two": { ... },
    "three": { ... }
  }
}
```

It's now possible to iterate through the list of rooms by downloading only a
few bytes per conversation, quickly fetching metadata for listing or displaying
rooms in a UI. Messages can be fetched separately and displayed as they arrive,
allowing the UI to stay responsive and fast.


### Create data that scales {:#fanout}


When building apps, it's often better to download a subset of a list.
This is particularly common if the list contains thousands of records.
When this relationship is static and one-directional, you can simply nest the
child objects under the parent.

Sometimes, this relationship is more dynamic, or it may be necessary to
denormalize this data. Many times you can denormalize the data by using a query
to retrieve a subset of the data, as discussed in
[Sorting and filtering data](lists-of-data#sorting_and_filtering_data).

But even this may be insufficient. Consider, for example, a two-way relationship
between users and groups. Users can belong to a group, and groups comprise a
list of users. When it comes time to decide which groups a user belongs to,
things get complicated.

What's needed is an elegant way to list the groups a user belongs to and
fetch only data for those groups. An *index* of groups can help a
great deal here:

```
// An index to track Ada's memberships
{
  "users": {
    "alovelace": {
      "name": "Ada Lovelace",
      // Index Ada's groups in her profile
      "groups": {
         // the value here doesn't matter, just that the key exists
         "techpioneers": true,
         "womentechmakers": true
      }
    },
    ...
  },
  "groups": {
    "techpioneers": {
      "name": "Historical Tech Pioneers",
      "members": {
        "alovelace": true,
        "ghopper": true,
        "eclarke": true
      }
    },
    ...
  }
}
```

You might notice that this duplicates some data by storing the relationship
under both Ada's record and under the group. Now `alovelace` is indexed under a
group, and `techpioneers` is listed in Ada's profile. So to delete Ada
from the group, it has to be updated in two places.

This is a necessary redundancy for two-way relationships. It allows you to
quickly and efficiently fetch Ada's memberships, even when the list of users or
groups scales into the millions or when Realtime Database security rules
prevent access to some of the records.

This approach, inverting the data by listing the IDs as keys and setting the
value to true, makes checking for a key as simple as reading
`/users/$uid/groups/$group_id` and checking if it is `null`. The index is faster
and a good deal more efficient than querying or scanning the data.

## Next Steps

* [Read and Write Data to Realtime Database](read-and-write)
