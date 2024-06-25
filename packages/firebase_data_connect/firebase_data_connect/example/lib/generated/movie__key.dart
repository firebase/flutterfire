


class Movie_Key {
  
    
    String id;
  
  
    Movie_Key.fromJson(Map<String, dynamic> json):
      
        id = 
          json['id']
        ;


    Map<String, dynamic> toJson() {
      return {
        
          'id': 
            id
          
        
      };
    }
      
 
  Movie_Key(
    this.id,
  );
}