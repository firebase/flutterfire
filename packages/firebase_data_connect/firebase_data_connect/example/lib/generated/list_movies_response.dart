
import 'list_movies_movies.dart';



class ListMoviesResponse {
  
    
    List<ListMoviesMovies> movies;
  
  
    ListMoviesResponse.fromJson(Map<String, dynamic> json):
      
        movies = 
          (json['movies'] as List<dynamic>)
            .map((e) => ListMoviesMovies.fromJson(e))
            .toList()
        ;


    Map<String, dynamic> toJson() {
      return {
        
          'movies': 
            movies.map((e) => e.toJson()).toList(),
          
        
      };
    }
      
 
  ListMoviesResponse(
    this.movies,
  );
}