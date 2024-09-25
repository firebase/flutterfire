part of movies;








class SeedMovies {
  String name = "seedMovies";
  SeedMovies({required this.dataConnect});

  Deserializer<SeedMoviesData> dataDeserializer = (String json)  => SeedMoviesData.fromJson(jsonDecode(json) as Map<String, dynamic>);
  
  MutationRef<SeedMoviesData, void> ref(
      ) {
    
    return dataConnect.mutation(this.name, dataDeserializer, emptySerializer, null);
  }
  FirebaseDataConnect dataConnect;
}


  


class SeedMoviesTheMatrix {
  
    
    
    
   String id;

   
  
  
    SeedMoviesTheMatrix.fromJson(Map<String, dynamic> json):
        id = 
 
    nativeFromJson<String>(json['id'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    nativeToJson<String>(id)
    
;
      
    
    return json;
  }

  SeedMoviesTheMatrix({
    
    required this.id,
  
  }) { // TODO: Only show this if there are optional fields.
    
      
    
  }
}



  


class SeedMoviesJurassicPark {
  
    
    
    
   String id;

   
  
  
    SeedMoviesJurassicPark.fromJson(Map<String, dynamic> json):
        id = 
 
    nativeFromJson<String>(json['id'])
  

        
       {
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    nativeToJson<String>(id)
    
;
      
    
    return json;
  }

  SeedMoviesJurassicPark({
    
    required this.id,
  
  }) { // TODO: Only show this if there are optional fields.
    
      
    
  }
}



  


class SeedMoviesData {
  
    
    
    
   SeedMoviesTheMatrix the_matrix;

   
  
    
    
    
   SeedMoviesJurassicPark jurassic_park;

   
  
  
    SeedMoviesData.fromJson(Map<String, dynamic> json):
        the_matrix = 
 
    SeedMoviesTheMatrix.fromJson(json['the_matrix'])
  

        ,
      
        jurassic_park = 
 
    SeedMoviesJurassicPark.fromJson(json['jurassic_park'])
  

        
       {
      
        
      
        
      
    }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['the_matrix'] = 
  
      the_matrix.toJson()
  
;
      
    
      
      json['jurassic_park'] = 
  
      jurassic_park.toJson()
  
;
      
    
    return json;
  }

  SeedMoviesData({
    
    required this.the_matrix,
  
    required this.jurassic_park,
  
  }) { // TODO: Only show this if there are optional fields.
    
      
    
      
    
  }
}







