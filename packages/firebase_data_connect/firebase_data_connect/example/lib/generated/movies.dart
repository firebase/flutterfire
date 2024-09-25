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

part 'list_movies_by_partial_title.dart';

part 'list_persons.dart';

part 'list_thing.dart';

part 'list_timestamps.dart';



class MoviesConnector {
  
  AddPerson get addPerson {
    return AddPerson(dataConnect: dataConnect);
  }
  
  AddDirectorToMovie get addDirectorToMovie {
    return AddDirectorToMovie(dataConnect: dataConnect);
  }
  
  AddTimestamp get addTimestamp {
    return AddTimestamp(dataConnect: dataConnect);
  }
  
  AddDateAndTimestamp get addDateAndTimestamp {
    return AddDateAndTimestamp(dataConnect: dataConnect);
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
  
  ListTimestamps get listTimestamps {
    return ListTimestamps(dataConnect: dataConnect);
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

