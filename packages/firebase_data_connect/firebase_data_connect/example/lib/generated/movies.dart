library movies;

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'list_movies.dart';

part 'list_movies_by_partial_title.dart';

part 'list_persons.dart';

part 'list_thing.dart';

part 'add_person.dart';

part 'add_director_to_movie.dart';

part 'seed_movies.dart';

part 'create_movie.dart';

part 'delete_movie.dart';

part 'thing.dart';

part 'seed_data.dart';

class MoviesConnector {
  ListMovies get listMovies {
    return ListMovies(dataConnect: dataConnect);
  }

  ListMoviesByPartialTitle get listMoviesByPartialTitle {
    return ListMoviesByPartialTitle(dataConnect: dataConnect);
  }

  ListPersons get listPersons {
    return ListPersons(dataConnect: dataConnect);
  }

  ListThing get listThing {
    return ListThing(dataConnect: dataConnect);
  }

  AddPerson get addPerson {
    return AddPerson(dataConnect: dataConnect);
  }

  AddDirectorToMovie get addDirectorToMovie {
    return AddDirectorToMovie(dataConnect: dataConnect);
  }

  SeedMovies get seedMovies {
    return SeedMovies(dataConnect: dataConnect);
  }

  CreateMovie get createMovie {
    return CreateMovie(dataConnect: dataConnect);
  }

  DeleteMovie get deleteMovie {
    return DeleteMovie(dataConnect: dataConnect);
  }

  Thing get thing {
    return Thing(dataConnect: dataConnect);
  }

  SeedData get seedData {
    return SeedData(dataConnect: dataConnect);
  }

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-west2',
    'movies',
    'dataconnect',
  );

  MoviesConnector({required this.dataConnect});
  static MoviesConnector get instance {
    return MoviesConnector(
        dataConnect:
            FirebaseDataConnect.instanceFor(connectorConfig: connectorConfig));
  }

  FirebaseDataConnect dataConnect;
}
