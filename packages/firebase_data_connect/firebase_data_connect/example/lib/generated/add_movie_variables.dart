


class AddMovieVariables {
  
    
    String genre;
  
    
    String title;
  
    
    double rating;
  
  
    AddMovieVariables.fromJson(Map<String, dynamic> json):
      
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
      
 
  AddMovieVariables(
    this.genre,
  
    this.title,
  
    this.rating,
  );
}