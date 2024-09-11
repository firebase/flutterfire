library movies;

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'list_movies.dart';

part 'list_movies_by_partial_title.dart';

part 'add_person.dart';

part 'add_director_to_movie.dart';

part 'create_movie.dart';

part 'delete_movie.dart';

class MoviesConnector {
  ListMovies get listMovies {
    return ListMovies(dataConnect: dataConnect);
  }

  ListMoviesByPartialTitle get listMoviesByPartialTitle {
    return ListMoviesByPartialTitle(dataConnect: dataConnect);
  }

  AddPerson get addPerson {
    return AddPerson(dataConnect: dataConnect);
  }

  AddDirectorToMovie get addDirectorToMovie {
    return AddDirectorToMovie(dataConnect: dataConnect);
  }

  CreateMovie get createMovie {
    return CreateMovie(dataConnect: dataConnect);
  }

  DeleteMovie get deleteMovie {
    return DeleteMovie(dataConnect: dataConnect);
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
