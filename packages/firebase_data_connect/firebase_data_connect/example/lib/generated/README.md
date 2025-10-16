# movies SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
MoviesConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### ListMovies
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.listMovies().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMoviesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MoviesConnector.instance.listMovies();
ListMoviesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.listMovies().ref();
ref.execute();

ref.subscribe(...);
```


### GetMovie
#### Required Arguments
```dart
GetMovieVariablesKey key = ...;
MoviesConnector.instance.getMovie(
  key: key,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetMovieData, GetMovieVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MoviesConnector.instance.getMovie(
  key: key,
);
GetMovieData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
GetMovieVariablesKey key = ...;

final ref = MoviesConnector.instance.getMovie(
  key: key,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListMoviesByPartialTitle
#### Required Arguments
```dart
String input = ...;
MoviesConnector.instance.listMoviesByPartialTitle(
  input: input,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMoviesByPartialTitleData, ListMoviesByPartialTitleVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MoviesConnector.instance.listMoviesByPartialTitle(
  input: input,
);
ListMoviesByPartialTitleData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String input = ...;

final ref = MoviesConnector.instance.listMoviesByPartialTitle(
  input: input,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListPersons
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.listPersons().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListPersonsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MoviesConnector.instance.listPersons();
ListPersonsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.listPersons().ref();
ref.execute();

ref.subscribe(...);
```


### ListThing
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.listThing().execute();
```

#### Optional Arguments
We return a builder for each query. For ListThing, we created `ListThingBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class ListThingVariablesBuilder {
  ...
 
  ListThingVariablesBuilder data(AnyValue? t) {
   _data.value = t;
   return this;
  }

  ...
}
MoviesConnector.instance.listThing()
.data(data)
.execute();
```

#### Return Type
`execute()` returns a `QueryResult<ListThingData, ListThingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MoviesConnector.instance.listThing();
ListThingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.listThing().ref();
ref.execute();

ref.subscribe(...);
```


### ListTimestamps
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.listTimestamps().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListTimestampsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MoviesConnector.instance.listTimestamps();
ListTimestampsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.listTimestamps().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### addPerson
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.addPerson().execute();
```

#### Optional Arguments
We return a builder for each query. For addPerson, we created `addPersonBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AddPersonVariablesBuilder {
  ...
 
  AddPersonVariablesBuilder name(String? t) {
   _name.value = t;
   return this;
  }

  ...
}
MoviesConnector.instance.addPerson()
.name(name)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<addPersonData, addPersonVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.addPerson();
addPersonData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.addPerson().ref();
ref.execute();
```


### addDirectorToMovie
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.addDirectorToMovie().execute();
```

#### Optional Arguments
We return a builder for each query. For addDirectorToMovie, we created `addDirectorToMovieBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class AddDirectorToMovieVariablesBuilder {
  ...
 
  AddDirectorToMovieVariablesBuilder personId(AddDirectorToMovieVariablesPersonId? t) {
   _personId.value = t;
   return this;
  }
  AddDirectorToMovieVariablesBuilder movieId(String? t) {
   _movieId.value = t;
   return this;
  }

  ...
}
MoviesConnector.instance.addDirectorToMovie()
.personId(personId)
.movieId(movieId)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<addDirectorToMovieData, addDirectorToMovieVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.addDirectorToMovie();
addDirectorToMovieData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.addDirectorToMovie().ref();
ref.execute();
```


### addTimestamp
#### Required Arguments
```dart
Timestamp timestamp = ...;
MoviesConnector.instance.addTimestamp(
  timestamp: timestamp,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<addTimestampData, addTimestampVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.addTimestamp(
  timestamp: timestamp,
);
addTimestampData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp timestamp = ...;

final ref = MoviesConnector.instance.addTimestamp(
  timestamp: timestamp,
).ref();
ref.execute();
```


### addDateAndTimestamp
#### Required Arguments
```dart
DateTime date = ...;
Timestamp timestamp = ...;
MoviesConnector.instance.addDateAndTimestamp(
  date: date,
  timestamp: timestamp,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<addDateAndTimestampData, addDateAndTimestampVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.addDateAndTimestamp(
  date: date,
  timestamp: timestamp,
);
addDateAndTimestampData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
DateTime date = ...;
Timestamp timestamp = ...;

final ref = MoviesConnector.instance.addDateAndTimestamp(
  date: date,
  timestamp: timestamp,
).ref();
ref.execute();
```


### seedMovies
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.seedMovies().execute();
```



#### Return Type
`execute()` returns a `OperationResult<seedMoviesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.seedMovies();
seedMoviesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.seedMovies().ref();
ref.execute();
```


### createMovie
#### Required Arguments
```dart
String title = ...;
int releaseYear = ...;
String genre = ...;
MoviesConnector.instance.createMovie(
  title: title,
  releaseYear: releaseYear,
  genre: genre,
).execute();
```

#### Optional Arguments
We return a builder for each query. For createMovie, we created `createMovieBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateMovieVariablesBuilder {
  ...
   CreateMovieVariablesBuilder rating(double? t) {
   _rating.value = t;
   return this;
  }
  CreateMovieVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  ...
}
MoviesConnector.instance.createMovie(
  title: title,
  releaseYear: releaseYear,
  genre: genre,
)
.rating(rating)
.description(description)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<createMovieData, createMovieVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.createMovie(
  title: title,
  releaseYear: releaseYear,
  genre: genre,
);
createMovieData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String title = ...;
int releaseYear = ...;
String genre = ...;

final ref = MoviesConnector.instance.createMovie(
  title: title,
  releaseYear: releaseYear,
  genre: genre,
).ref();
ref.execute();
```


### deleteMovie
#### Required Arguments
```dart
String id = ...;
MoviesConnector.instance.deleteMovie(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<deleteMovieData, deleteMovieVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.deleteMovie(
  id: id,
);
deleteMovieData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = MoviesConnector.instance.deleteMovie(
  id: id,
).ref();
ref.execute();
```


### thing
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.thing().execute();
```

#### Optional Arguments
We return a builder for each query. For thing, we created `thingBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class ThingVariablesBuilder {
  ...
 
  ThingVariablesBuilder title(AnyValue t) {
   _title.value = t;
   return this;
  }

  ...
}
MoviesConnector.instance.thing()
.title(title)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<thingData, thingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.thing();
thingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.thing().ref();
ref.execute();
```


### seedData
#### Required Arguments
```dart
// No required arguments
MoviesConnector.instance.seedData().execute();
```



#### Return Type
`execute()` returns a `OperationResult<seedDataData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MoviesConnector.instance.seedData();
seedDataData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MoviesConnector.instance.seedData().ref();
ref.execute();
```

