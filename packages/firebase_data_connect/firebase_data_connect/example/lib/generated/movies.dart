library movies;

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'add_person.dart';

part 'add_director_to_movie.dart';

part 'add_timestamp.dart';

part 'add_date_and_timestamp.dart';

part 'delete_all_timestamps.dart';

part 'seed_movies.dart';

part 'create_movie.dart';

part 'delete_movie.dart';

part 'thing.dart';

part 'seed_data.dart';

part 'list_movies.dart';

part 'list_movies_by_partial_title.dart';

part 'list_persons.dart';

part 'list_thing.dart';

part 'list_timestamps.dart';

part 'list_movies_by_genre.dart';

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

  DeleteAllTimestampsVariablesBuilder deleteAllTimestamps() {
    return DeleteAllTimestampsVariablesBuilder(
      dataConnect,
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

  ListMoviesByGenreVariablesBuilder listMoviesByGenre() {
    return ListMoviesByGenreVariablesBuilder(
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
