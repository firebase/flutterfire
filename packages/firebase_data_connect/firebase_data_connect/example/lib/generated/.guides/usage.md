# Basic Usage

```dart
MoviesConnector.instance.addPerson(addPersonVariables).execute();
MoviesConnector.instance.addDirectorToMovie(addDirectorToMovieVariables).execute();
MoviesConnector.instance.addTimestamp(addTimestampVariables).execute();
MoviesConnector.instance.addDateAndTimestamp(addDateAndTimestampVariables).execute();
MoviesConnector.instance.seedMovies().execute();
MoviesConnector.instance.createMovie(createMovieVariables).execute();
MoviesConnector.instance.deleteMovie(deleteMovieVariables).execute();
MoviesConnector.instance.thing(thingVariables).execute();
MoviesConnector.instance.seedData().execute();
MoviesConnector.instance.ListMovies().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await MoviesConnector.instance.ListThing({ ... })
.data(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

