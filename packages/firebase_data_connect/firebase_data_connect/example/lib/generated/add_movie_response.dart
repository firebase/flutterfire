
import 'movie__key.dart';



class AddMovieResponse {
  
    
    Movie_Key movie_insert;
  
  
    AddMovieResponse.fromJson(Map<String, dynamic> json):
      
        movie_insert = 
          Movie_Key.fromJson(json['movie_insert'])
        ;


    Map<String, dynamic> toJson() {
      return {
        
          'movie_insert': 
            movie_insert.toJson(),
          
        
      };
    }
      
 
  AddMovieResponse(
    this.movie_insert,
  );
}