library movies;

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'add_person.dart';

part 'add_director_to_movie.dart';

part 'add_timestamp.dart';

part 'add_date_and_timestamp.dart';

part 'seed_movies.dart';

part 'create_movie.dart';

part 'delete_movie.dart';

part 'thing.dart';

part 'seed_data.dart';

part 'list_movies.dart';

part 'get_movie.dart';

part 'list_movies_by_partial_title.dart';

part 'list_persons.dart';

part 'list_thing.dart';

part 'list_timestamps.dart';

class MoviesConnector {
  AddPersonVariablesBuilder addPerson() {
    return AddPersonVariablesBuilder(
      dataConnect,
    );
  }

  AddDirectorToMovieVariablesBuilder addDirectorToMovie() {
    return AddDirectorToMovieVariablesBuilder(
      dataConnect,
    );
  }

  AddTimestampVariablesBuilder addTimestamp({
    required Timestamp timestamp,
  }) {
    return AddTimestampVariablesBuilder(
      dataConnect,
      timestamp: timestamp,
    );
  }

  AddDateAndTimestampVariablesBuilder addDateAndTimestamp({
    required DateTime date,
    required Timestamp timestamp,
  }) {
    return AddDateAndTimestampVariablesBuilder(
      dataConnect,
      date: date,
      timestamp: timestamp,
    );
  }

  SeedMoviesVariablesBuilder seedMovies() {
    return SeedMoviesVariablesBuilder(
      dataConnect,
    );
  }

  CreateMovieVariablesBuilder createMovie({
    required String title,
    required int releaseYear,
    required String genre,
  }) {
    return CreateMovieVariablesBuilder(
      dataConnect,
      title: title,
      releaseYear: releaseYear,
      genre: genre,
    );
  }

  DeleteMovieVariablesBuilder deleteMovie({
    required String id,
  }) {
    return DeleteMovieVariablesBuilder(
      dataConnect,
      id: id,
    );
  }

  ThingVariablesBuilder thing() {
    return ThingVariablesBuilder(
      dataConnect,
    );
  }

  SeedDataVariablesBuilder seedData() {
    return SeedDataVariablesBuilder(
      dataConnect,
    );
  }

  ListMoviesVariablesBuilder listMovies() {
    return ListMoviesVariablesBuilder(
      dataConnect,
    );
  }

  GetMovieVariablesBuilder getMovie({
    required GetMovieVariablesKey key,
  }) {
    return GetMovieVariablesBuilder(
      dataConnect,
      key: key,
    );
  }

  ListMoviesByPartialTitleVariablesBuilder listMoviesByPartialTitle({
    required String input,
  }) {
    return ListMoviesByPartialTitleVariablesBuilder(
      dataConnect,
      input: input,
    );
  }

  ListPersonsVariablesBuilder listPersons() {
    return ListPersonsVariablesBuilder(
      dataConnect,
    );
  }

  ListThingVariablesBuilder listThing() {
    return ListThingVariablesBuilder(
      dataConnect,
    );
  }

  ListTimestampsVariablesBuilder listTimestamps() {
    return ListTimestampsVariablesBuilder(
      dataConnect,
    );
  }

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-west2',
    'movies',
    'dataconnect',
  );

  MoviesConnector({required this.dataConnect});
  static MoviesConnector get instance {
    return MoviesConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
