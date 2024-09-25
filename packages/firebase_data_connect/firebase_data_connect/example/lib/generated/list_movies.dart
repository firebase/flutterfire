part of movies;








class ListMovies {
  String name = "ListMovies";
  ListMovies({required this.dataConnect});

  Deserializer<ListMoviesData> dataDeserializer = (String json)  => ListMoviesData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  
  QueryRef<ListMoviesData, void> ref(
      ) {
    
    return dataConnect.query(this.name, dataDeserializer, emptySerializer, null);
  }
  FirebaseDataConnect dataConnect;
}


  


class ListMoviesMovies {
  
    
    
    
   String id;

   
  
    
    
    
   String title;

   
  
    
    
    
   List<ListMoviesMoviesDirectedBy> directed_by;

   
  
    
    
    
   double? rating;

   
  
  
    ListMoviesMovies.fromJson(Map<String, dynamic> json):
        id = 
 
    nativeFromJson<String>(json['id'])
  

        ,
      
        title = 
 
    nativeFromJson<String>(json['title'])
  

        ,
      
        directed_by = 
 
    
      (json['directed_by'] as List<dynamic>)
        .map((e) => ListMoviesMoviesDirectedBy.fromJson(e))
        .toList()
    
  

        
       {
      
        
      
        
      
        
      
        
          rating = json['rating'] == null ? null : 
 
    nativeFromJson<double>(json['rating'])
  
;
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    nativeToJson<String>(id)
    
;
      
    
      
      json['title'] = 
  
    nativeToJson<String>(title)
    
;
      
    
      
      json['directed_by'] = 
  
    
      directed_by.map((e) => e.toJson()).toList()
    
  
;
      
    
      
        if (rating != null) {
          json['rating'] = 
  
    nativeToJson<double?>(rating)
    
;
        }
      
    
    return json;
  }

  ListMoviesMovies({
    
    required this.id,
  
    required this.title,
  
    required this.directed_by,
  
     this.rating,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
      
    
      
    
      
    
  }
}



  


class ListMoviesMoviesDirectedBy {
  
    
    
    
   String name;

   
  
  
    ListMoviesMoviesDirectedBy.fromJson(Map<String, dynamic> json):
        name = 
 
    nativeFromJson<String>(json['name'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['name'] = 
  
    nativeToJson<String>(name)
    
;
      
    
    return json;
  }

  ListMoviesMoviesDirectedBy({
    
    required this.name,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}



  


class ListMoviesData {
  
    
    
    
   List<ListMoviesMovies> movies;

   
  
  
    ListMoviesData.fromJson(Map<String, dynamic> json):
        movies = 
 
    
      (json['movies'] as List<dynamic>)
        .map((e) => ListMoviesMovies.fromJson(e))
        .toList()
    
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['movies'] = 
  
    
      movies.map((e) => e.toJson()).toList()
    
  
;
      
    
    return json;
  }

  ListMoviesData({
    
    required this.movies,
  
  }) { // TODO(mtewani): Only show this if there are optional fields.
    
      
    
  }
}







