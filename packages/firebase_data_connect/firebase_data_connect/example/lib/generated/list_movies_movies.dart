


class ListMoviesMovies {
  
    
    String id;
  
    
    String genre;
  
    
    String title;
  
    
    double rating;
  
  
    ListMoviesMovies.fromJson(Map<String, dynamic> json):
      
        id = 
          json['id']
        ,
        genre = 
          json['genre']
        ,
        title = 
          json['title']
        ,
        rating = 
          json['rating']
        ;


    Map<String, dynamic> toJson() {
      return {
        
          'id': 
            id
          ,
        
          'genre': 
            genre
          ,
        
          'title': 
            title
          ,
        
          'rating': 
            rating
          
        
      };
    }
      
 
  ListMoviesMovies(
    this.id,
  
    this.genre,
  
    this.title,
  
    this.rating,
  );
}