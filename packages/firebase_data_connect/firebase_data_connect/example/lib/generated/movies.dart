import 'package:firebase_data_connect/firebase_data_connect.dart';

import 'add_movie.dart';

import 'list_movies.dart';


class MoviesConnector {
  
  AddMovie get addMovie {
    return AddMovie(dataConnect: dataConnect);
  }
  
  ListMovies get listMovies {
    return ListMovies(dataConnect: dataConnect);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',
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