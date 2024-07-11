part of movies;





class AddDirectorToMovie {
  String name = "addDirectorToMovie";
  AddDirectorToMovie({required this.dataConnect});

  Deserializer<AddDirectorToMovieResponse> dataDeserializer = (String json)  => AddDirectorToMovieResponse.fromJson(jsonDecode(json) as Map<String, dynamic>);
  Serializer<AddDirectorToMovieVariables> varsSerializer = jsonEncode;
  MutationRef<AddDirectorToMovieResponse, AddDirectorToMovieVariables> ref(
      AddDirectorToMovieVariables vars) {
    return dataConnect.mutation(name, dataDeserializer, varsSerializer, vars);
  }
  FirebaseDataConnect dataConnect;
}


  


class AddDirectorToMovieDirectedByInsert {
  
    
    
    
    String directedbyId;
  
    
    
    
    String movieId;
  
  
    AddDirectorToMovieDirectedByInsert.fromJson(Map<String, dynamic> json):
      
        
          directedbyId = 
            json['directedbyId']
          ,
        
        
          movieId = 
            json['movieId']
          
         {
      
         
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['directedbyId'] = 
  
    directedbyId
  
;
      
    
      
      json['movieId'] = 
  
    movieId
  
;
      
    
    return json;
  }

  AddDirectorToMovieDirectedByInsert(
    this.directedbyId,
  
    this.movieId,
  );
  
    
  
    
  

}




  


class AddDirectorToMovieResponse {
  
    
    
    
    AddDirectorToMovieDirectedByInsert directedBy_insert;
  
  
    AddDirectorToMovieResponse.fromJson(Map<String, dynamic> json):
      
        
          directedBy_insert = 
            AddDirectorToMovieDirectedByInsert.fromJson(json['directedBy_insert'])
          
         {
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['directedBy_insert'] = 
  
    directedBy_insert.toJson()
  
;
      
    
    return json;
  }

  AddDirectorToMovieResponse(
    this.directedBy_insert,
  );
  
    
  

}




  


class AddDirectorToMovieVariablesPersonId {
  
    
    
    
    String id;
  
  
    AddDirectorToMovieVariablesPersonId.fromJson(Map<String, dynamic> json):
      
        
          id = 
            json['id']
          
         {
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
      json['id'] = 
  
    id
  
;
      
    
    return json;
  }

  AddDirectorToMovieVariablesPersonId(
    this.id,
  );
  
    
  

}




  


class AddDirectorToMovieVariables {
  
    
    
    
    AddDirectorToMovieVariablesPersonId? personId;
  
    
    
    
    String? movieId;
  
  
    AddDirectorToMovieVariables.fromJson(Map<String, dynamic> json):
      
        
          personId = 
            AddDirectorToMovieVariablesPersonId.fromJson(json['personId'])
          ,
        
        
          movieId = 
            json['movieId']
          
         {
      
         
      
         
      
    }


  // TODO(mtewani): Fix up to create a map on the fly
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
      
        if (personId != null) {
          json['personId'] = 
  
    personId!.toJson()
  
;
        }
      
    
      
        if (movieId != null) {
          json['movieId'] = 
  
    movieId
  
;
        }
      
    
    return json;
  }

  AddDirectorToMovieVariables(
    this.personId,
  
    this.movieId,
  );
  
    
  
    
  

}






